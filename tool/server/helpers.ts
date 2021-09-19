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
