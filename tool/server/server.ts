// File System, Argument Parser, Path Library
import {
  basename,
  globToRegExp,
  join,
} from "https://deno.land/std@0.107.0/path/mod.ts";
import { parse } from "https://deno.land/std@0.107.0/flags/mod.ts";

// Helpers
// TODO: Implement Some Class
import { humanFileSize, serveFile } from "./helpers.ts";

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

let sockets: WebSocket[] = [];
const loadedFiles: Set<string> = new Set();

// TODO: Only send events about updated files?
async function serveConnection(conn: Deno.Conn) {
  const connection = Deno.serveHttp(conn);

  for await (const request of connection) {
    // TODO: maybe the join isnt required?
    const path = join(
      ".",
      request.request.url
        .replace(/https?:\/\/[^\/]+/, ""), // Strip everything but route
    );

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
    } else {
      const x = await serveFile(path, request, SCRIPT);
      !!x && loadedFiles.add(x);
    }
  }
}

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
        event.paths.length > 0 && // Make sure list isnt empty
        event.paths.some((f) => loadedFiles.has(basename(f))) // See if any file has been loaded
      ) {
        console.log("\u001b[31mFS\u001b[0m Loaded file was updated");
        sockets.forEach((sock) => sock.send("UPDATE"));
      }
      lastEvent = now;
    }
  }
}

const listenToSignals = async () => {
  for await (const _ of Deno.signal("SIGUSR1")) {
    console.log("\u001b[34mSIG\u001b[0m Update Signal Recieved");
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
