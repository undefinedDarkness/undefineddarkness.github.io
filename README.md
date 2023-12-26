# Personal Site

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
Refer to [out/2021/lorem.html](https://nes.is-a.dev/out/2021/lorem.html)