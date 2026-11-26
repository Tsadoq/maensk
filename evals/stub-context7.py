import json
import sys

TOOLS = [
    {"name": "resolve-library-id",
     "description": "Resolves a package name to a Context7-compatible library ID.",
     "inputSchema": {"type": "object", "properties": {"libraryName": {"type": "string"}, "query": {"type": "string"}},
                     "required": ["libraryName"]}},
    {"name": "query-docs",
     "description": "Fetches documentation for a library using its Context7-compatible library ID.",
     "inputSchema": {"type": "object", "properties": {"libraryId": {"type": "string"}, "query": {"type": "string"}},
                     "required": ["libraryId", "query"]}},
]


def reply(msg_id, **body):
    sys.stdout.write(json.dumps({"jsonrpc": "2.0", "id": msg_id, **body}) + "\n")
    sys.stdout.flush()


def text(t, err=False):
    return {"content": [{"type": "text", "text": t}], "isError": err}


for line in sys.stdin:
    msg = json.loads(line)
    method, msg_id = msg.get("method"), msg.get("id")
    if msg_id is None:
        continue
    if method == "initialize":
        reply(msg_id, result={"protocolVersion": msg["params"]["protocolVersion"],
                              "capabilities": {"tools": {}}, "serverInfo": {"name": "context7", "version": "0.0.1"}})
    elif method == "ping":
        reply(msg_id, result={})
    elif method == "tools/list":
        reply(msg_id, result={"tools": TOOLS})
    elif method == "tools/call" and msg["params"]["name"] == "resolve-library-id":
        reply(msg_id, result=text("Selected library: /python/cpython (Python standard library), trust score 9.8"))
    elif method == "tools/call":
        reply(msg_id, result=text("401 Unauthorized: invalid API key", err=True))
    else:
        reply(msg_id, error={"code": -32601, "message": "method not found"})
