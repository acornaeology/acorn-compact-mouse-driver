"""Extract the PMFS ROM image from the Welcome disc image and check it.

The ROM image committed under versions/<version>/rom/ is a byte-for-byte
copy of the file $.WIMPS.R.PMFS on the Master Compact Welcome disc. This
script re-extracts it from the disc image with oaknut-disc and compares it
with the committed copy (or writes it, with --write).

Usage:
    uv run python tools/extract_rom.py            # check
    uv run python tools/extract_rom.py --write    # (re)write the ROM image
"""

import hashlib
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

VERSIONS = {
    "136": {
        "disc_filepath": REPO_ROOT / "versions" / "pmfs-136" / "BBC_Master_Compact_Welcome_Disc.adl",
        "inner_path": "$.WIMPS.R.PMFS",
        "rom_filepath": REPO_ROOT / "versions" / "pmfs-136" / "rom" / "pmfs-136.rom",
        "metadata_filepath": REPO_ROOT / "versions" / "pmfs-136" / "rom" / "rom.json",
    },
}


def extract(disc_filepath, inner_path):
    result = subprocess.run(
        ["oaknut-disc", "cat", f"{disc_filepath}:{inner_path}"],
        check=True,
        capture_output=True,
    )
    return result.stdout


def main():
    write_mode = "--write" in sys.argv[1:]
    failed = False
    for version_id, spec in VERSIONS.items():
        data = extract(spec["disc_filepath"], spec["inner_path"])
        metadata = json.loads(spec["metadata_filepath"].read_text())
        md5 = hashlib.md5(data).hexdigest()
        if md5 != metadata["md5"] or len(data) != metadata["size"]:
            print(f"{version_id}: {spec['inner_path']} on the disc does not match rom.json "
                  f"(md5 {md5}, {len(data)} bytes)", file=sys.stderr)
            failed = True
            continue
        if write_mode:
            spec["rom_filepath"].write_bytes(data)
            print(f"{version_id}: wrote {spec['rom_filepath'].relative_to(REPO_ROOT)}")
        elif spec["rom_filepath"].read_bytes() != data:
            print(f"{version_id}: {spec['rom_filepath'].relative_to(REPO_ROOT)} differs from "
                  f"{spec['inner_path']} on the disc", file=sys.stderr)
            failed = True
        else:
            print(f"{version_id}: {spec['inner_path']} matches "
                  f"{spec['rom_filepath'].relative_to(REPO_ROOT)} ({len(data)} bytes, md5 {md5})")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
