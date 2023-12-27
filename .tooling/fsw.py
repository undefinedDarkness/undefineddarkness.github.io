from watchfiles import watch, Change as FSE
from pathlib import Path
import asyncio
import sys

def main():
    root = Path('.').resolve()
    for changes in watch("./src"):
        for change in changes:
            fp = Path(change[1])
            if fp.suffix == '.md' and (change[0] == FSE.added or change[0] == FSE.modified):
                print(fp.relative_to(root).as_posix())
                sys.stdout.flush()
try:
    main()
except KeyboardInterrupt:
    sys.exit(0)
