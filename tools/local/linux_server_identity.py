"""Check only the public identity of the local validation container (stdlib)."""
import argparse
import base64
import hashlib
import json
import os
import socket
import struct
import time
import urllib.error
import urllib.request
from pathlib import Path

EXPECTED = {
    "version": "0.3.0",
    "source_revision": "f204c529d3a6e51b3997ff52f2d0a813f515c58cfe1d87c19afa68e0664bfe66",
    "protocol": 4,
    "rules_revision": 5,
    "rules": "da42603253ac",
}
HOST, PORT = "127.0.0.1", 10000
MAX_MESSAGE = 65536


def require_identity(info):
    for key, expected in EXPECTED.items():
        if info.get(key) != expected:
            raise RuntimeError(f"Public identity mismatch: {key}")


def exact(stream, count):
    result = bytearray()
    while len(result) < count:
        piece = stream.read(count - len(result))
        if not piece:
            raise RuntimeError("WebSocket closed before public welcome")
        result.extend(piece)
    return bytes(result)


def masked_frame(opcode, payload=b""):
    if len(payload) > 125:
        raise RuntimeError("Unexpected control payload")
    mask = os.urandom(4)
    return bytes([0x80 | opcode, 0x80 | len(payload)]) + mask + bytes(
        value ^ mask[i % 4] for i, value in enumerate(payload)
    )


def welcome():
    key = base64.b64encode(os.urandom(16)).decode("ascii")
    with socket.create_connection((HOST, PORT), timeout=10) as connection:
        connection.sendall((
            f"GET / HTTP/1.1\r\nHost: {HOST}:{PORT}\r\n"
            "Upgrade: websocket\r\nConnection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n"
        ).encode("ascii"))
        stream = connection.makefile("rb", buffering=0)
        header = bytearray()
        while not header.endswith(b"\r\n\r\n"):
            header.extend(exact(stream, 1))
            if len(header) > 16384:
                raise RuntimeError("Oversized HTTP upgrade")
        lines = header.decode("iso-8859-1").split("\r\n")
        if lines[0].split()[1] != "101":
            raise RuntimeError("WebSocket upgrade did not return 101")
        headers = dict(line.split(":", 1) for line in lines[1:] if ":" in line)
        headers = {name.lower(): value.strip() for name, value in headers.items()}
        accept = base64.b64encode(hashlib.sha1(
            (key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode("ascii")
        ).digest()).decode("ascii")
        if headers.get("sec-websocket-accept") != accept:
            raise RuntimeError("Invalid WebSocket upgrade digest")
        message = bytearray()
        started = False
        while True:
            first, second = exact(stream, 2)
            opcode, final = first & 15, bool(first & 128)
            if first & 112 or second & 128:
                raise RuntimeError("Unexpected WebSocket extension or masked server frame")
            length = second & 127
            if length == 126:
                length = struct.unpack("!H", exact(stream, 2))[0]
            elif length == 127:
                length = struct.unpack("!Q", exact(stream, 8))[0]
            if length > MAX_MESSAGE:
                raise RuntimeError("Oversized welcome frame")
            payload = exact(stream, length)
            if opcode == 9:
                connection.sendall(masked_frame(10, payload))
                continue
            if opcode == 10:
                continue
            if opcode == 1 and not started:
                started = True
            elif opcode != 0 or not started:
                raise RuntimeError("Expected text welcome, got different WebSocket opcode")
            message.extend(payload)
            if len(message) > MAX_MESSAGE:
                raise RuntimeError("Oversized welcome message")
            if final:
                break
        info = json.loads(message.decode("utf-8"))
        if info.get("t") != "welcome" or info.get("v") != 4:
            raise RuntimeError("Expected protocol 4 welcome")
        require_identity(info)
        # Record public fields only; never persist an unrecognized message or a token.
        public = {key: info[key] for key in EXPECTED}
        public.update(t="welcome", v=4)
        connection.sendall(masked_frame(8, struct.pack("!H", 1000)))
        stream.close()
        return public


def validate(output, wait_seconds):
    deadline = time.monotonic() + wait_seconds
    health = None
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    while time.monotonic() < deadline:
        try:
            with opener.open(f"http://{HOST}:{PORT}/healthz", timeout=3) as response:
                if response.status != 200:
                    raise RuntimeError("Health HTTP status must be 200")
                raw = response.read(MAX_MESSAGE + 1)
                if len(raw) > MAX_MESSAGE:
                    raise RuntimeError("Oversized health body")
                info = json.loads(raw)
            if info.get("ready") is True:
                require_identity(info)
                health = {key: info[key] for key in EXPECTED}
                health["ready"] = True
                break
        except (urllib.error.URLError, TimeoutError, OSError):
            pass
        time.sleep(1)
    if health is None:
        raise RuntimeError("Container health not ready before timeout")
    result = {"health": health, "welcome": welcome(), "identity_matches": True}
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    parser.add_argument("--wait-seconds", type=int, default=60)
    args = parser.parse_args()
    if not 1 <= args.wait_seconds <= 120:
        parser.error("wait-seconds must be between 1 and 120")
    validate(args.output, args.wait_seconds)
