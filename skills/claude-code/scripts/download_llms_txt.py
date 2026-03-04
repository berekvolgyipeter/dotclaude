"""Download Claude Code llms.txt into the skill's references folder."""

from pathlib import Path

import requests

URL = "https://code.claude.com/docs/llms.txt"
DEST = Path(__file__).parent.parent / "references" / "llms.txt"


def main() -> None:
    print(f"Downloading {URL} ...")
    response = requests.get(URL)
    response.raise_for_status()
    DEST.parent.mkdir(parents=True, exist_ok=True)
    DEST.write_text(response.text, encoding="utf-8")
    print(f"Saved to {DEST}")


if __name__ == "__main__":
    main()
