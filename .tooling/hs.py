from aiohttp import web, WSMsgType
from mimetypes import guess_type as guess_mime_type
from pathlib import Path
from watchfiles import awatch
import asyncio
import magic
import io

# A terribly simple little hot server

fileNotFoundDoc = """
<html>
    <head>
    </head>
    <body>
        File was not found on this server.
    </body>
</html>
"""

injectionScript = """
<script defer>
    <!-- INJECTED BY WEB SERVER -->
    const socket = new WebSocket('ws://localhost:5000/ws-connect')
    socket.addEventListener('message', e => {
        if (e.data == "UPDATE")
            document.location.reload();
    })
    socket.addEventListener('open', e => {
        let fileName = document.location.pathname.split('/').pop();
        if (fileName.length == 0)
            fileName = "index.html"
        socket.send(`REGISTER ${fileName}`);
    })
</script>
</body>
"""

def injectHTML(path):

    fp = open(path, "r", encoding="utf8")
    content = fp.read()
    fp.close()

    content = content.replace("</body>", injectionScript)

    return web.Response(content_type="text/html", text=content)

async def generichandle(req):
    path = Path(req.match_info.get('name', 'index.html'))
    # print(path)

    if not path.is_file():
        return web.Response(status=404, text=fileNotFoundDoc, content_type="text/html")

    if path.suffix == '.html':
        return injectHTML(path)

    fp = open(path, "rb")
    content = fp.read()
    fp.close()

    mimetype = guess_mime_type(str(path))[0] or "text/plain"

    return web.Response(body=content, content_type=mimetype)

sockets = []
async def wshandle(req):
    global sockets
    ws = web.WebSocketResponse()
    await ws.prepare(req)

    async for msg in ws:
        if msg.type == WSMsgType.TEXT:
            words = msg.data.split(" ")
            if words[0] == "REGISTER":
                sockets.append((words[1], ws))
                print("HS: Registered %s" % words[1])
        else:
            print("Unexpected WS message of type:", msg.type)

    sockets = [conn for conn in sockets if conn[1] != ws]

    return ws

app = web.Application()
app.add_routes([
    web.get('/', generichandle),
    web.get('/ws-connect', wshandle),
    web.get(r'/{name:.*}', generichandle)
])

async def watch():
    # paths = list(Path('./out').glob('**/*.html'))
    async for changes in awatch("out"):
        for change in changes:
            fp = Path(change[1])
            fn = fp.name
            # print("Updating all listening for %s" % fn)
            applicable = [conn for conn in sockets if conn[0] == fn] 
            for socket in applicable:
                await socket[1].send_str("UPDATE")

async def main():

    # Initiate Web Server
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, "localhost", 5000)
    await site.start()
    print("HS: Server Started @ \u001b[31mlocalhost:5000\u001b[0m")

    # Initialize File Watcher
    await watch()

    await asyncio.Event().wait()

asyncio.run(main())
