// File System, Argument Parser, Path Library
import {
  basename,
  extname,
  globToRegExp,
  join,
} from "https://deno.land/std@0.107.0/path/mod.ts";
import { existsSync } from "https://deno.land/std@0.107.0/fs/mod.ts";
import { parse } from "https://deno.land/std@0.107.0/flags/mod.ts";

// Helpers
import { getMimeType, getTree, humanFileSize } from "./helpers.ts";

// Initialize Server.
const args = parse(Deno.args, {
  default: {
    ignorePatterns: "",
    superhuman: false,
    port: 5000,
    live: true,
  },
  boolean: ["superhuman", "live"],
  string: ["ignorePatterns"],
  alias: { ignorePatterns: "ignore" },
});
args.ignorePatterns = args.ignore.split(",").map((item: string) =>
  globToRegExp(item, { extended: true, globstar: true })
);
console.dir("Parsed Arguments: " + JSON.stringify(args, null, 2));
const PORT = args.port;

// Embedded Script
const SCRIPT = `
<script>
// Create WebSocket connection.
const socket = new WebSocket('ws://localhost:${PORT}/ws-connect');

// Connection opened
socket.addEventListener('open', function (event) {
	console.log("🔥: Connected To Server.")
});

// Listen for messages
socket.addEventListener('message', function (event) {
    console.log('🔥: ', event.data);
	if (event.data == "UPDATE") { location.reload() }
});

socket.addEventListener('close', () => { console.log('🔥: Connection Closed') })
</script>
`;

// {{{
let sockets: WebSocket[] = [];
const loadedFiles: Set<string> = new Set();

// TODO: Only send events about updated files?
async function serveConnection(conn: Deno.Conn) {
  const connection = Deno.serveHttp(conn);

  for await (const request of connection) {
    // TODO: maybe the join isnt required?
    let path = join(
      ".",
      request.request.url
        .replace(/https?:\/\/[^\/]+/, ""), // Strip everything but route
    );

    const headers = new Headers();

    if (path == "ws-connect") {
      const { socket, response } = Deno.upgradeWebSocket(request.request);
      const idx = sockets.push(socket);
      socket.onclose = () => {
        sockets = sockets.splice(idx, 1);
      };
      request.respondWith(response);
      console.log(
        "\u001b[32mWS-CONNECT\u001b[0m Total connected sockets: " +
          sockets.length,
      );
      return;
    }

    if (!existsSync(path)) {
      request.respondWith(
        new Response("File Not Found.", {
          status: 404,
          headers,
        }),
      );
      return;
    }

    const info = await Deno.stat(path);

    if (
      info.isDirectory && existsSync(join(path, "index.html"))
    ) {
      path = join(path, "index.html");
    }
    console.log("\u001b[34mREQ\u001b[0m " + path);

    // Embed Script {{{
    if (path.includes(".html")) {
      // Embed Script & Return
      headers.set("content-type", "text/html");

      const data = new TextDecoder("utf-8").decode(await Deno.readFile(path)) +
        SCRIPT;

      request.respondWith(
        new Response(data, {
          status: 200,
          headers,
        }),
      );

      loadedFiles.add(path);
    } // }}}

    // Guess Mime Type & Return File {{{
    else if (info.isFile) {
      let mimeType;
      switch (extname(path)) {
        case ".css":
          mimeType = "text/css";
          break;
        case ".js":
          mimeType = "text/javascript";
          break;
        case ".html":
          mimeType = "text/html";
          break;
        default:
          mimeType = await getMimeType(path);
      }
      headers.set("content-type", mimeType);
      request.respondWith(
        new Response(await Deno.readFile(path), {
          status: 200,
          headers,
        }),
      );
      loadedFiles.add(path);
    } 

    // File Tree {{{
    else if (info.isDirectory) {
      headers.set("content-type", "text/html");
      request.respondWith(
        new Response(await getTree(path), {
          status: 200,
          headers,
        }),
      );
    }
    // }}}
  }
}
// }}}

async function server() {
  const server = Deno.listen({ port: PORT });
  console.log(`✨ Server Running At localhost:${PORT}`);

  for await (const conn of server) {
    serveConnection(conn);
  }
}

// TODO: Figure out some way to ignore multiple events at the same time
let lastEvent = 0;
async function fileWatcher() {
  const watcher = Deno.watchFs(".");
  console.log(`🍿 Watching File System`);
  for await (const event of watcher) {
    // Events That Change Files:
    if (event.kind == "create" || event.kind == "modify") {
      const now = performance.now();
      if (0.8 > (now - lastEvent)) {
        continue;
      }

      event.paths = event.paths.filter((path) =>
        !args.ignorePatterns.some((pat: RegExp) => path.match(pat))
      );
      
	  if (
        event.paths.length > 0 &&
        event.paths.some((f) => loadedFiles.has(basename(f)))
      ) {
        console.log("\u001b[31mFS\u001b[0m Loaded file was updated");
        sockets.forEach((sock) => sock.send("UPDATE")); // TODO: complex shit here
      }
      lastEvent = now;
    }
  }
}

const listenToSignals = async () => {
  for await (const _ of Deno.signal("SIGUSR1")) {
	  console.log('\u001b[34mSIG\u001b[0m Update Signal Recieved')
    sockets.forEach((sock) => sock.send("UPDATE"));
  }
};

Deno.chdir(String(args["_"][0] ?? "."));
try {
  server();
} catch (err) {
  console.log("Encountered Error: " + err);
  Deno.exit(0);
}

if (args.live) {
  fileWatcher();
}

// Print Memory Usage, Every 2 Minutes
setInterval(() => {
  console.log(
    `\u001b[35mPERF\u001b[0m Memory usage: ${
      humanFileSize(Deno.memoryUsage().heapTotal)
    }`,
  );
}, 60000 * 2);

// Listen To UNIX Signals For Updates
listenToSignals();
