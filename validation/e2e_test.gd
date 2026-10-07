extends SceneTree
## Test de bout en bout sur un vrai WebSocket : deux clients jouent une partie complète (IA) ;
## chaque client doit finir avec le même état que le serveur.
##   godot --headless --path . -s res://tools/server/e2e_test.gd
##       → serveur lancé dans ce processus (port 18910)
##   godot --headless --path . -s res://tools/server/e2e_test.gd -- --url ws://127.0.0.1:8910
##       → contre un serveur déjà lancé (local ou hébergé) : comparaison avec l'empreinte envoyée par le serveur
## Code de sortie 0 = réussi, 1 = échec.

const PORT: int = 18910
const TIMEOUT_MS: int = 120000
## Écart entre deux coups : le serveur limite le débit par connexion (NetProtocol.MSG_RATE).
const STEP_MS: int = 60

var _server: NetServer = null
var _clients: Array[NetClient] = []
var _conns: Array[NetConnection] = []
var _games: Array = [null, null]
var _stage: String = "connect"
var _start_ms: int = 0
var _sent: int = 0
var _last_step: int = 0


func _initialize() -> void:
	_start_ms = Time.get_ticks_msec()
	var url: String = "ws://127.0.0.1:%d" % PORT
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var k: int = args.find("--url")
	if k >= 0 and k + 1 < args.size():
		url = args[k + 1]
	else:
		_server = NetServer.new()
		_server.log_line.connect(func(t: String) -> void: print("  [serveur] ", t))
		root.add_child(_server)
		if _server.listen(PORT, "127.0.0.1") != OK:
			_finish(false, "port %d indisponible" % PORT)
			return
	_url = url
	print("Serveur : ", url)
	for i: int in 2:
		var c: NetClient = NetClient.new()
		_clients.append(c)
		var conn: NetConnection = NetConnection.new(c)
		_conns.append(conn)
		conn.open(url)


func _process(_delta: float) -> bool:
	if Time.get_ticks_msec() - _start_ms > TIMEOUT_MS:
		_finish(false, "délai dépassé à l'étape « %s »" % _stage)
		return true
	for i: int in 2:
		_conns[i].poll()
		for ev: Array in _clients[i].take_events():
			_on_event(i, ev)
	match _stage:
		"connect":
			if _clients[0].connected and _clients[1].connected:
				_clients[0].create_room("kael")
				_stage = "create"
		"create":
			if _clients[0].room_code != "":
				print("Salon créé : ", _clients[0].room_code)
				_clients[1].join_room(_clients[0].room_code, "naia")
				_stage = "join"
		"play":
			_play()
		"flood":
			_flood_conn.poll()
			_flood_client.take_events()
			if _flood_client.connected and not _flood_sent:
				_flood_sent = true
				for n: int in 200:
					_flood_client.ping()
				_flood_conn.poll()
			elif _flood_sent and not _flood_conn.active():
				_finish(true, "partie complète + connexion trop bavarde fermée par le serveur")
	return false


var _url: String = ""
var _flood_client: NetClient = NetClient.new()
var _flood_conn: NetConnection = NetConnection.new(_flood_client)
var _flood_sent: bool = false


## Limite de débit (G9) : une connexion qui envoie 200 messages d'un coup doit être fermée.
func _flood() -> void:
	_stage = "flood"
	_flood_conn.open(_url)


func _on_event(i: int, ev: Array) -> void:
	# Copie locale tenue à jour par les vues masquées du serveur (anti-triche).
	_games[i] = NetMirror.on_event(_games[i] as NetGame, _clients[i], ev)
	match str(ev[0]):
		"match_started":
			if _clients[i].seed_value != 0 or _clients[i].view.is_empty():
				_finish(false, "le client %d a reçu une graine ou pas de vue" % i)
			if _games[0] != null and _games[1] != null:
				_stage = "play"
		"action_rejected", "error", "connection_lost", "opponent_left", "_dropped", "_incompatible":
			_finish(false, "événement inattendu %s" % str(ev))


## Le joueur actif joue dès que tous les coups précédents sont revenus du serveur.
func _play() -> void:
	if _clients[0].last_n < _sent or _clients[1].last_n < _sent:
		return
	if (_games[0] as NetGame).inflight() > 0 or (_games[1] as NetGame).inflight() > 0:
		return
	if Time.get_ticks_msec() - _last_step < STEP_MS:
		return
	_last_step = Time.get_ticks_msec()
	var g0: NetGame = _games[0]
	if g0.is_over():
		var ok: bool = true
		for i: int in 2:
			# Chaque copie égale sa vue masquée (empreinte du serveur, et partie du serveur si elle est ici).
			ok = ok and (_games[i] as NetGame).checksum() == _clients[i].view_sum
			if _server != null:
				var room_game: Game = (_server.lobby.rooms.values()[0] as NetRoom).game
				ok = ok and _clients[i].view_sum == GameView.checksum(GameView.capture(room_game, _clients[i].my_index))
		if not ok:
			_finish(false, "empreintes différentes en fin de partie")
			return
		print("Partie : %d coups échangés, tour %d, empreintes identiques." % [_sent, g0.turn])
		_flood()
		return
	# Siège actif côté serveur = siège du client 0 s'il se voit actif (indice 0 local).
	var i: int = 0 if g0.active == 0 else 1
	var g: NetGame = _games[i]
	AiPlayer.step(g)
	for a: Dictionary in g.take_recorded():
		_clients[i].send_action(a)
		_sent += 1


func _finish(ok: bool, detail: String) -> void:
	print(("RÉUSSI : " if ok else "ÉCHEC : ") + detail)
	for c: NetConnection in _conns:
		c.close()
	if _server != null:
		_server.stop()
	quit(0 if ok else 1)
