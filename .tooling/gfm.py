import sys
import cmarkgfm
from pathlib import Path

opts = cmarkgfm.Options.CMARK_OPT_UNSAFE | cmarkgfm.Options.CMARK_OPT_GITHUB_PRE_LANG | cmarkgfm.Options.CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE | cmarkgfm.Options.CMARK_OPT_SMART | cmarkgfm.Options.CMARK_OPT_LIBERAL_HTML_TAG
p = Path(sys.argv[1]).resolve()
with p.open('r', encoding="utf-8") as f:
    print(cmarkgfm.markdown_to_html(f.read(), options = opts))