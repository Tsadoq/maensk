#!/usr/bin/env python3
import json
import subprocess
import sys
import threading
from pathlib import Path

STUB = Path(__file__).resolve().parent.parent / "evals" / "stub-context7.py"


def test_stub():
    with subprocess.Popen([sys.executable, str(STUB)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True) as proc:
        timer = threading.Timer(10, proc.kill)
        timer.start()

        def send(msg):
            proc.stdin.write(json.dumps({"jsonrpc": "2.0", **msg}) + "\n")
            proc.stdin.flush()

        def ask(msg_id, method, params=None):
            send({"id": msg_id, "method": method, "params": params or {}})
            reply = json.loads(proc.stdout.readline())
            assert reply["jsonrpc"] == "2.0" and reply["id"] == msg_id, reply
            return reply

        try:
            init = ask(1, "initialize", {"protocolVersion": "2025-03-26", "capabilities": {},
                                         "clientInfo": {"name": "test", "version": "0"}})["result"]
            assert init["protocolVersion"] == "2025-03-26" and "tools" in init["capabilities"], init
            assert all(isinstance(init["serverInfo"][k], str) for k in ("name", "version")), init
            send({"method": "notifications/initialized"})
            assert ask(2, "ping")["result"] == {}
            tools = ask(3, "tools/list")["result"]["tools"]
            assert sorted(t["name"] for t in tools) == ["query-docs", "resolve-library-id"], tools
            assert all(t["inputSchema"]["type"] == "object" for t in tools), tools
            resolved = ask(4, "tools/call", {"name": "resolve-library-id", "arguments": {"libraryName": "python"}})["result"]
            assert resolved["isError"] is False and resolved["content"][0]["type"] == "text", resolved
            assert "/python/cpython" in resolved["content"][0]["text"], resolved
            docs = ask(5, "tools/call", {"name": "query-docs",
                                         "arguments": {"libraryId": "/python/cpython", "query": "csv quoting"}})["result"]
            assert docs["isError"] is True and docs["content"][0]["type"] == "text", docs
            assert docs["content"][0]["text"] == "401 Unauthorized: invalid API key", docs
            error = ask(6, "resources/list")["error"]
            assert error["code"] == -32601 and isinstance(error["message"], str), error
        finally:
            timer.cancel()
            proc.kill()


if __name__ == "__main__":
    test_stub()
    print("ok")
