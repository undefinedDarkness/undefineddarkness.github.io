from watchfiles import watch, Change as FSE
from pathlib import Path
import asyncio
import sys

def main():
    root = Path('.').resolve()
    for changes in watch("./src"):
        for change in changes:
            fp = Path(change[1])
            if (fp.suffix == '.md' or fp.suffix == '.html') and (change[0] == FSE.added or change[0] == FSE.modified):
                print(fp.as_posix())
                sys.stdout.flush()
try:
    main()
except KeyboardInterrupt:
    sys.exit(0)
