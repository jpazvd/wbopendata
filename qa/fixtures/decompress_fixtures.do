*===============================================================================
* decompress_fixtures.do — Extract QA fixture files from fixtures.tar.gz
*
* Run once after cloning the repo. The compressed archive is tracked in git;
* this script unpacks it so that the Stata QA harness can read files directly.
*
* Requires: Stata 16+ (uses python integration)
*
* Usage:
*   do qa/fixtures/decompress_fixtures.do
*===============================================================================

local fixdir  "`c(pwd)'/qa/fixtures"

display as text _n "=== Extracting QA fixtures ==="
display as text "  fixtures dir: `fixdir'" _n

python:
import tarfile, os
from pathlib import Path
from sfi import Macro

fixdir = Path(Macro.getLocal("fixdir"))
archive = fixdir / "fixtures.tar.gz"
fixdir_resolved = fixdir.resolve()

if not archive.exists():
    print(f"  [ERROR] Archive not found: {archive}")
    Macro.setLocal("_extracted", "0")
else:
    with tarfile.open(archive, "r:gz") as tar:
        members = tar.getmembers()
        existing = 0
        extracted = 0
        skipped = 0
        for m in members:
            # Compute the intended destination for this member
            dest = fixdir / m.name

            # Resolve the destination and ensure it stays within fixdir to
            # prevent path traversal via entries like ../../outside.
            try:
                dest_resolved = dest.resolve()
                fixdir_resolved = fixdir.resolve()
                # Check if dest_resolved is within fixdir_resolved
                try:
                    dest_resolved.relative_to(fixdir_resolved)
                except ValueError:
                    print(f"  [SKIP] Unsafe path outside fixtures dir: {m.name}")
                    skipped += 1
                    continue
            except (OSError, ValueError):
                print(f"  [SKIP] Unsafe path (unable to normalize): {m.name}")
                skipped += 1
                continue

            dest = dest_resolved

            if dest.exists() and not m.isdir():
                existing += 1
                continue
            tar.extract(m, path=fixdir)
            if not m.isdir():
                sz = dest.stat().st_size
                print(f"  [OK] {m.name}  ({sz:,} bytes)")
                extracted += 1

    Macro.setLocal("_extracted", str(extracted))
    Macro.setLocal("_existing", str(existing))
    Macro.setLocal("_skipped", str(skipped))
end

display as text _n "Done: `_extracted' extracted, `_existing' already existed."
display as text "Fixtures are ready for offline QA testing."
