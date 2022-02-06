import {
  extname,
  join,
} from "https://deno.land/std/path/mod.ts";


function existsSync(filePath: string): boolean {
  try {
    Deno.lstatSync(filePath);
    return true;
  } catch (err) {
    if (err instanceof Deno.errors.NotFound) {
      return false;
    }
    throw err;
  }
}

// Use `file` to get mime type
export async function getMimeType(path: string) {
  const process = Deno.run({
    cmd: ["file", "--mime-type", path],
    stdout: "piped",
  });
  const out = await process.output();
  process.close();
  return new TextDecoder("utf-8").decode(out).replace(/^\S+: /, "").replace(
    "\n",
    "",
  );
}

// Byte size for humans
export function humanFileSize(size: number) {
    const i = Math.floor( Math.log(size) / Math.log(1024) );
    return Number(( size / Math.pow(1024, i) ).toFixed(2)) * 1 + ' ' + ['B', 'kB', 'MB', 'GB', 'TB'][i];
}

// Generate File Tree
export async function getTree(path: string) {
  let output = `<html><pre style="tab-size: 4;">` + path + "/\n";
  for await (const entry of Deno.readDir(path)) {
    output += `\t<a href="/${path}/${entry.name}">${entry.name}</a>\n`;
  }
  return output + "</html>";
}

const canUseFile = await Deno.permissions.query({ name: "run", command: "file" })
export async function serveFile(path: string, request: Deno.RequestEvent, SCRIPT: string, log: boolean) {
	const headers = new Headers();
    if (!existsSync(path)) {
      request.respondWith(
        new Response("File Not Found.", {
          status: 404,
          headers,
        }),
      ).catch(console.error);
      return;
    }

    const info = await Deno.stat(path);

    if (
      info.isDirectory && existsSync(join(path, "index.html"))
    ) {
      path = join(path, "index.html");
    }
    log && console.log("\u001b[34mREQ\u001b[0m " + path);

    if (path.includes(".html")) {
      // Embed Script & Return
      headers.set("content-type", "text/html");

      const data = new TextDecoder("utf-8").decode(await Deno.readFile(path)).replace('</body>', SCRIPT+'</body>') // add to end of body tag

      request.respondWith(
        new Response(data, {
          status: 200,
          headers,
        }),
      ).catch(console.error);

	  return path
    } // }}}

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
          mimeType = canUseFile ? await getMimeType(path) : ""
      }
      headers.set("content-type", mimeType);
      request.respondWith(
        new Response(await Deno.readFile(path), {
          status: 200,
          headers,
        }),
      ).catch(console.error);
	  return path;
    }
	// }}}

    else if (info.isDirectory) {
      headers.set("content-type", "text/html");
      await request.respondWith(
        new Response(await getTree(path), {
          status: 200,
          headers,
        }),
      );
    }

}
