extends SceneTree
## Test de bout en bout du jeu en ligne sur un VRAI WebSocket, avec un serveur dans un processus séparé :
## partie rapide (file d'attente) → coups joués par l'IA → coupure brutale d'un joueur → reprise
## automatique (jeton, vue masquée actuelle, même état public que le serveur) → tour passé par le minuteur
## → fin de partie normale reçue par les deux joueurs.
##   godot --headless --path . -s res://tools/server/online_e2e.gd
##       → lance son propre serveur (port 18911, donné par la variable PORT, minuteur de 4 s)
##   godot --headless --path . -s res://tools/server/online_e2e.gd -- --url wss://xxx.trycloudflare.com
##       → contre un serveur déjà lancé (local, tunnel ou hébergé) ; l'étape « minuteur » est sautée
##         si le serveur a un minuteur long.
## Code de sortie 0 = réussi, 1 = échec.

const PORT: int = 18911
const TURN_SECONDS: int = 4
const TIMEOUT_MS: int = 120000

var _url: String = ""
var _pid: int = -1
var _sessions: Array[NetSession] = []
var _games: Array = [null, null]
var _stage: String = "boot"
var _start_ms: int = 0
var _stage_ms: int = 0
var _steps: int = 0
var _seen: Dictionary = {}
var _timer_mode: bool = false


func _initialize() -> void:
	_start_ms = Time.get_ticks_msec()
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var k: int = args.find("--url")
	if k >= 0 and k + 1 < args.size():
		_url = args[k + 1]
	else:
		# Serveur séparé : même moteur, même projet, port transmis par la variable PORT (comme un hébergeur).
		OS.set_environment("PORT", str(PORT))
		_pid = OS.create_process(OS.get_executable_path(), [
			"--headless", "--path", ProjectSettings.globalize_path("res://"),
			"-s", "res://tools/server/server.gd", "--", "--turn-seconds", str(TURN_SECONDS),
		])
		if _pid <= 0:
			_finish(false, "impossible de lancer le serveur")
			return
		_url = "ws://127.0.0.1:%d" % PORT
	print("Serveur : ", _url)
	for i: int in 2:
		var c: NetClient = NetClient.new()
		_sessions.append(NetSession.new(c, NetConnection.new(c)))
	_go("connect")
	for s: NetSession in _sessions:
		s.connect_to(_url, Time.get_ticks_msec())


func _go(stage: String) -> void:
	_stage = stage
	_stage_ms = Time.get_ticks_msec()
	print("  étape : ", stage)


func _process(_delta: float) -> bool:
	var now: int = Time.get_ticks_msec()
	if now - _start_ms > TIMEOUT_MS:
		_finish(false, "délai dépassé à l'étape « %s » (événements vus : %s)" % [_stage, str(_seen.keys())])
		return true
	for i: int in 2:
		_sessions[i].tick(now)
		for ev: Array in _sessions[i].take_events():
			_on_event(i, ev)
	match _stage:
		"connect":
			if _sessions[0].state == NetSession.State.ONLINE and _sessions[1].state == NetSession.State.ONLINE:
				_sessions[0].client.find_match("kael")
				_go("queue")
		"queue":
			if _seen.has("queue_status"):
				_sessions[1].client.find_match("naia")
				_go("match")
		"match":
			if _games[0] != null and _games[1] != null:
				_go("play_before_cut")
		"play_before_cut":
			if _steps < 25 or not _settled():
				_play()
			else:
				# Coupure brutale du joueur 2 : son WebSocket se ferme sans prévenir.
				(_sessions[1].transport as NetConnection).close()
				_sessions[1].client.closed()
				_go("reconnect")
		"reconnect":
			if _seen.has("reconnected") and _seen.has("opponent_back"):
				if not _check_sync("après reprise"):
					return true
				_timer_mode = _url.begins_with("ws://127.0.0.1:%d" % PORT)
				_go("timer" if _timer_mode else "play_to_end")
		"timer":
			# Personne ne joue : le serveur passe le tour au bout de TURN_SECONDS.
			if _seen.has("turn_auto_passed") and _settled():
				if not _check_sync("après tour passé"):
					return true
				_go("play_to_end")
		"play_to_end":
			_play()
			if _seen.has("match_ended") and int(_seen["match_ended"]) >= 2:
				var ok: bool = _check_sync("fin de partie")
				_finish(ok, "%d coups, tour %d, partie rapide + reprise%s vérifiées" % [
						_steps, (_games[0] as NetGame).turn, " + minuteur" if _timer_mode else ""])
	return false


func _on_event(i: int, ev: Array) -> void:
	var name_: String = str(ev[0])
	_seen[name_] = int(_seen.get(name_, 0)) + 1
	var c: NetClient = _sessions[i].client
	# Copie locale tenue à jour par les vues masquées du serveur (anti-triche).
	_games[i] = NetMirror.on_event(_games[i] as NetGame, c, ev)
	match name_:
		"reconnected":
			print("  reprise : vue masquée reçue par le client %d (coup n° %d)" % [i, c.last_n])
		"action_rejected", "error", "connection_lost", "opponent_left":
			_finish(false, "événement inattendu %s (client %d)" % [str(ev), i])
		"match_ended":
			if str(ev[2]) != "normal":
				_finish(false, "fin inattendue %s" % str(ev))


## Tous les coups envoyés sont revenus du serveur aux deux clients (mêmes états partout).
func _settled() -> bool:
	if _games[0] == null or _games[1] == null:
		return false
	if _sessions[0].client.last_n != _sessions[1].client.last_n:
		return false
	for i: int in 2:
		var g: NetGame = _games[i]
		if g.inflight() > 0 or g.checksum() != _sessions[i].client.view_sum:
			return false
	return true


func _play() -> void:
	if not _settled() or _sessions[1].reconnecting():
		return
	var g0: NetGame = _games[0]
	if g0.is_over():
		return
	var i: int = 0 if g0.active == 0 else 1
	var g: NetGame = _games[i]
	AiPlayer.step(g)
	for a: Dictionary in g.take_recorded():
		_sessions[i].client.send_action(a)
		_steps += 1


func _check_sync(when: String) -> bool:
	for i: int in 2:
		if (_games[i] as NetGame).checksum() != _sessions[i].client.view_sum:
			_finish(false, "client %d désynchronisé %s" % [i, when])
			return false
	print("  synchronisés ", when, " (coup n° ", _sessions[0].client.last_n, ")")
	return true


func _finish(ok: bool, detail: String) -> void:
	print(("RÉUSSI : " if ok else "ÉCHEC : ") + detail)
	for s: NetSession in _sessions:
		s.disconnect_now()
	if _pid > 0:
		OS.kill(_pid)
		_pid = -1
	quit(0 if ok else 1)
