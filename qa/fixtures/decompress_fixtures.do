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

if not archive.exists():
    print(f"  [ERROR] Archive not found: {archive}")
    Macro.setLocal("_extracted", "0")
else:
    with tarfile.open(archive, "r:gz") as tar:
        members = tar.getmembers()
        existing = 0
        extracted = 0
        for m in members:
            dest = fixdir / m.name
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
end

display as text _n "Done: `_extracted' extracted, `_existing' already existed."
display as text "Fixtures are ready for offline QA testing."
