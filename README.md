# Personal Site

> [!WARNING]
> Beware using emoji as it can mess up the python live server for some reason

## Installation & Running
- **live server**: Requires `python` & python packages:
    - watchfiles
    - aiohttp
- **markup**: Requires `git`, `bash`, `perl` & it's dependencies  to be installed, On windows this is all included with `git`

```
$ ./generate live
```
Begins live rebuild and preview of site

## Document Structure
- index.html    - Site Root (Generated)
- template.html - SSG Document Template
- src/
    - `index.html | index.md` - Site Root Source
    - `**/*.md | **/*.html` - Document Sources
- out
    - `**/*.html`           - Document Output

## Markup
Refer to [out/2021/lorem.html](https://nes.is-a.dev/out/2021/lorem.html) & [out/2022/nesdown.html](https://nes.is-a.dev/out/2022/nesdown.html)

## TODO
- Fix styling for `raylib-docs`