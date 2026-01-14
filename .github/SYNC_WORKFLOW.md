# sync-to-public.yml: Automated Release Synchronization

**Purpose**: Automatically synchronize clean, production-ready code from the private development repository (`wbopendata-dev`) to the public production repository (`wbopendata`) when a release is tagged.

**Status**: Production-ready  
**Last Updated**: January 14, 2026  
**Maintainer**: João Pedro Azevedo

---

## Table of Contents

1. [How It Works](#how-it-works)
2. [Rationale](#rationale)
3. [Advantages](#advantages)
4. [Risks and Mitigation](#risks-and-mitigation)
5. [Promotion Gates](#promotion-gates)
6. [Quick Reference](#quick-reference)

---

## How It Works

### Trigger

The workflow activates when a **version tag** is pushed to `wbopendata-dev`:

```bash
git tag -a v1.2.3 -m "Release v1.2.3: New features and bugfixes"
git push origin v1.2.3    # ← Triggers sync workflow
```

**Pattern**: Version tags matching `v*` (e.g., `v1.0.0`, `v2.3.1-beta`, `v14.2.0`)

### Execution Steps

#### Step 1: Checkout Full History
```yaml
uses: actions/checkout@v4
with:
  fetch-depth: 0  # Full history for completeness
```
Clones entire repository with complete git history (allows verification of commits).

#### Step 2: Remove Private Content
```bash
rm -rf paper/                          # Pre-publication manuscripts
rm -rf drafts/ internal/ benchmarks/   # Development materials
rm -rf personal/ eb1a/                 # Personal files
rm -rf _drafts/ _archive/ _deprecated/ # Metadata
rm -rf tests/logs/ qa/logs/ qa/results/ validation/results/  # Execution artifacts
find . -name '*.log' -type f -delete   # Build/test logs
rm -f .github/copilot-instructions.md  # AI assistant config
rm -rf .github/copilot/ .github/prompts/ # Additional AI config
rm -f .github/workflows/sync-to-public.yml  # Hide automation logic
```

**Categories removed** (50+ items across 9 folders):
| Category | Items | Reason |
|----------|-------|--------|
| **Academic** | paper/, drafts/ | Pre-publication work (not ready for public) |
| **Strategic** | internal/ | Roadmaps, project status, meeting notes |
| **Testing** | tests/logs/, qa/logs/, qa/results/, *.log | Execution artifacts, not source code |
| **Research** | benchmarks/, validation/results/ | Unpublished performance data |
| **Personal** | eb1a/, personal/, _drafts/ | Personal documents |
| **Metadata** | _archive/, _deprecated/ | Development tracking |
| **Infrastructure** | .github/copilot*, .github/workflows/sync-to-public.yml | Internal automation |

#### Step 3: Verify Removal (Safety Gate)
```bash
# Scan for all private patterns
if [[ -d "paper/" ]] || [[ -d "internal/" ]] || ... ; then
  echo "ERROR: Private content detected after removal!"
  exit 1  # Abort workflow
fi

# Scan for all .log files
if find . -name '*.log' -type f | grep -q . ; then
  echo "ERROR: Log files detected after removal!"
  exit 1  # Abort workflow
fi
```

**Function**: Defense-in-depth verification. If removal step fails, workflow aborts **before** syncing to public repo.

**Prevents**: Accidental leakage of sensitive content due to shell command errors or unexpected files.

#### Step 4: Push to Staging Branch
```yaml
uses: cpina/github-action-push-to-another-repository@main
with:
  destination-github-username: 'jpazvd'
  destination-repository-name: 'wbopendata'
  target-branch: main  # Pushes to wbopendata/staging
```

**Flow**: 
```
wbopendata-dev (clean code) → GitHub Actions → wbopendata/staging branch
```

Creates a commit with filtered code in the public repo's `staging` branch.

#### Step 5: Propagate Version Tags
```bash
git push origin v1.2.3:v1.2.3  # Pushes tag to wbopendata
```

**Function**: Makes the exact release version visible in the public repo so users can reference releases:
```bash
cd wbopendata
git tag                 # Shows v1.0.0, v1.1.0, v1.2.3, etc.
git checkout v1.2.3    # Users can checkout specific versions
```

---

## Rationale

### Why Tag-Triggered (Not Continuous)?

**Problem**: Continuous syncs (every push to main) would:
- Expose incomplete work (commits in progress)
- Create confusing commit history in public repo
- Prevent pre-release review/testing
- Lack clear release markers

**Solution**: Version tags as explicit release checkpoints
- Only intentional releases sync
- Clear versioning (Semantic Versioning)
- Time for testing before release
- Git history shows exactly when releases occurred

### Why Staging → Develop → Main (Three Gates)?

**Defense-in-depth approach**:

| Gate | Actor | Purpose |
|------|-------|---------|
| **Staging** | Workflow (automatic) | Clean code synced, ready for review |
| **Develop** | You (manual PR) | Test the release, verify nothing broke |
| **Main** | You (manual PR) | Production release, publicly available |

**Benefit**: Each gate is a checkpoint to catch problems:
1. Staging: Verify content removal worked (no .log files, no paper/ folder, etc.)
2. Develop: Test the release code in staging environment
3. Main: Final approval before users see it

**Alternative** (rejected): Direct main sync
- Risk: Any mistake goes straight to production
- No rollback opportunity
- Users affected immediately

### Why Verify After Removal?

**Problem**: Shell command errors are silent
```bash
rm -rf internal/  # Typo: "internal_" doesn't exist
# Shell succeeds but file isn't removed!
# Workflow continues and syncs the file to public repo
```

**Solution**: Scan for all private patterns after removal
- Confirms removal actually happened
- Catches typos and logic errors
- Aborts workflow **before** pushing to public

**Fail-safe**: Better to block a valid sync than leak private content

---

## Advantages

### 1. **Automated Consistency**
- Every release follows identical process (no manual steps forgotten)
- No human error in content removal (script is deterministic)
- Reproducible results across releases

### 2. **Safety Through Multiple Layers** (Defense-in-Depth)
| Layer | Mechanism | Catches |
|-------|-----------|---------|
| Layer 1 | Workflow removal | Intentional private content |
| Layer 2 | Verification step | Shell/logic errors in removal |
| Layer 3 | .gitignore patterns | Accidental commits of private files |

### 3. **Audit Trail**
```bash
# See exactly what went into each release
git log wbopendata/staging --oneline

# Compare releases
git diff v1.0.0..v1.1.0

# Trace back sync to original dev commit
git show <staging-commit>
```

### 4. **Clear Release Boundaries**
- Tag in dev repo = intent to release
- Staging branch in public repo = content ready for review
- Develop merge = tested and approved
- Main merge = live to users

### 5. **Version Control Integration**
- Users can `git checkout v1.2.3` to get exact release
- GitHub releases created automatically from tags
- SSC package manager can reference versions
- Changelog can be auto-generated from tags

### 6. **Rollback Capability**
If release has problems:
```bash
# Users can stay on previous version
git checkout v1.1.5

# Or fix in develop, create new tag
git tag -a v1.2.4 -m "Hotfix: ..."
```

### 7. **Separation of Concerns**
- Dev repo: complete history, all experiments, work-in-progress
- Public repo: clean, release-only, user-focused

---

## Risks and Mitigation

### Risk 1: Private Content Accidentally Leaks 🔴 **CRITICAL**

**Scenario**: 
```
Developer creates PHASE_2_COMPLETE.md in root
Commits it to wbopendata-dev/main
Pushes v1.2.0 tag
Workflow runs but misses this file
Public repo now has internal status report visible to everyone
```

**Mitigation**:
- ✅ **Layer 1**: Workflow explicitly removes 50+ private patterns
- ✅ **Layer 2**: Verification step scans for remaining private items (aborts if found)
- ✅ **Layer 3**: .gitignore blocks future commits of private patterns
- ✅ **Layer 4**: Pre-commit hook prevents pushing files matching private patterns

**Additional Protection**:
```yaml
# If verification fails:
- name: Verify no private content
  run: |
    if [ $(git ls-files | grep -E "^(paper|internal|drafts)/" | wc -l) -gt 0 ]; then
      echo "ERROR: Private folders detected!"
      exit 1
    fi
```

**Detection**: If leaked, visible immediately in GitHub public repo. Action: Delete from public repo, rotate credentials, investigate commit.

---

### Risk 2: SSH Deploy Key Compromised 🔴 **CRITICAL**

**Scenario**:
```
Deploy key stored in GitHub secret is exposed
Attacker uses key to push malicious code to wbopendata/staging
Users pull compromised release
```

**Mitigation**:
- ✅ Deploy key has **write-only scope** (can't read private repos)
- ✅ Separate from main GitHub account (if personal key compromised, others still safe)
- ✅ Key stored in GitHub Secrets (encrypted, not in repo)
- ✅ Limited to `wbopendata` repo (can't affect `wbopendata-dev`)

**Response Plan**:
1. Delete compromised key from wbopendata settings
2. Generate new deploy key pair locally
3. Add new public key to wbopendata/Deploy keys
4. Update `PUBLIC_REPO_DEPLOY_KEY` secret with new private key
5. Audit recent commits in wbopendata (look for unauthorized pushes)
6. If malicious commits found: revert, create new release

**Detection**: GitHub activity log shows all SSH pushes with key fingerprint

---

### Risk 3: Workflow Gets Into Infinite Loop 🟡 **MODERATE**

**Scenario**:
```
Workflow pushes to wbopendata/staging
GitHub auto-creates release tag v1.2.0
Webhook triggers sync workflow again (if configured)
Infinite loop
```

**Mitigation**:
- ✅ Workflow only triggers on tags pushed to **wbopendata-dev** (not wbopendata)
- ✅ Tags created by workflow in wbopendata don't trigger anything there
- ✅ No webhooks configured between wbopendata and wbopendata-dev

**Verification**:
```bash
# Confirm workflow only runs on wbopendata-dev
cat .github/workflows/sync-to-public.yml | grep "on:"
# Should show: repository trigger from wbopendata-dev only
```

---

### Risk 4: Staging Branch Out of Sync with Release 🟡 **MODERATE**

**Scenario**:
```
Staging branch force-pushed locally
Public staging branch now diverged from expected state
You merge staging→develop, get old code
Users complain about regression
```

**Mitigation**:
- ✅ Branch protection on wbopendata/staging (only github-actions[bot] can push)
- ✅ No force-push allowed to staging
- ✅ Audit trail in git log shows all staging commits

**Prevention**:
```bash
# NEVER do this:
git push --force origin staging

# Workflow handles it instead:
git push origin staging  # Normal push, no force
```

---

### Risk 5: Verification Script Misses Private Content 🟡 **MODERATE**

**Scenario**:
```
New private pattern emerges (e.g., "confidential/")
Verification script doesn't check for it
File leaks to public repo
```

**Mitigation**:
- ✅ Verification script is explicit (lists all patterns, not wildcard)
- ✅ Script reviewed in code (changes require git commit + review)
- ✅ Pre-commit hook catches commits of private patterns
- ✅ Manual audit possible: `git ls-files | head -20`

**Maintenance**:
When adding new private folders:
1. Update workflow removal step
2. Update verification step  
3. Update .gitignore
4. Update pre-commit hook
5. Test with `git check-ignore -v filename`

---

### Risk 6: Workflow Fails Mid-Execution 🟠 **LOW**

**Scenario**:
```
GitHub Actions environment runs out of disk space
Removal step fails partway through
Verification runs but is corrupted
Partial content pushed to staging
```

**Mitigation**:
- ✅ `set -e` in bash (stop on first error)
- ✅ Each step is atomic (either completes or fails)
- ✅ Verification step happens **after** removal (catches failures)
- ✅ GitHub Actions automatically retries on infrastructure failures

**Response**:
If workflow fails mid-execution:
1. Check GitHub Actions logs for error message
2. Verify what was pushed to wbopendata/staging
3. Delete staging branch if compromised: `git push origin --delete staging`
4. Fix root cause (usually typo in workflow YAML)
5. Retry: `git push origin v1.2.3`

---

### Risk 7: Tag Typo Triggers Wrong Release 🟠 **LOW**

**Scenario**:
```
Developer types: git tag -a v11.0.0 (meant v1.1.0)
Pushes tag: git push origin v11.0.0
Workflow syncs wrong version number
Public repo shows v11.0.0 instead of v1.1.0
```

**Mitigation**:
- ✅ Pre-release checklist (verify version before tagging)
- ✅ Git log visible before tagging: `git log --oneline -5`
- ✅ Tag message required: `git tag -a` (prevents lightweight tags)
- ✅ Tag visible before push: `git tag` and `git show v1.1.0`

**Prevention**:
```bash
# Good practice:
git log --oneline -3                    # Verify commits
git tag -a v1.1.0 -m "Release v1.1.0"  # Explicit version
git show v1.1.0                         # Verify tag content
git push origin v1.1.0                  # Push only when ready
```

---

## Promotion Gates

### Gate 1: Tag Creation (Automatic Entry to Staging)

**Actor**: You  
**Action**: Create version tag in `wbopendata-dev`  
**Trigger**: Workflow auto-runs, syncs to staging

```bash
git tag -a v1.2.0 -m "Release v1.2.0: new features"
git push origin v1.2.0
# → Workflow automatically syncs to wbopendata/staging
```

**Review Point**: Examine `wbopendata/staging` branch to confirm no private content

---

### Gate 2: Staging → Develop (Manual PR - Testing)

**Actor**: You  
**Action**: Create PR from `staging` to `develop` in `wbopendata`  
**Purpose**: Test release in staging environment

```bash
# In GitHub UI:
# Create PR: wbopendata-dev/staging → wbopendata/develop
# Title: "Release v1.2.0"
# Description: List of changes being tested
```

**Review Checklist**:
- ✅ No private files/folders (paper/, internal/, *.log, etc.)
- ✅ All important code present (compare with dev repo)
- ✅ No unexpected changes
- ✅ Version number correct in headers/docs
- ✅ CHANGELOG updated

**Outcome**: Merge if tests pass, reject if issues found

---

### Gate 3: Develop → Main (Manual PR - Release)

**Actor**: You  
**Action**: Create PR from `develop` to `main` in `wbopendata`  
**Purpose**: Final approval before users see release

```bash
# In GitHub UI:
# Create PR: wbopendata/develop → wbopendata/main
# Title: "Release v1.2.0 to Production"
# Require approval before merging
```

**Review Checklist**:
- ✅ Develop branch tested and working
- ✅ All PRs in this release closed/merged
- ✅ Release notes written
- ✅ No critical bugs found during testing
- ✅ Users notified of release (if needed)

**Outcome**: Merge to make release live. Users pulling from `main` get v1.2.0

---

## Quick Reference

### Creating a Release

```bash
cd wbopendata-dev

# 1. Ensure all changes committed
git status

# 2. Verify recent commits
git log --oneline -5

# 3. Create version tag
git tag -a v1.2.0 -m "Release v1.2.0: description of changes"

# 4. Verify tag
git show v1.2.0

# 5. Push tag (triggers workflow)
git push origin v1.2.0

# 6. Monitor workflow
# Go to GitHub → Actions → sync-to-public.yml → watch run

# 7. After workflow succeeds, go to wbopendata repo

# 8. Review staging branch
git log staging --oneline -3

# 9. Create PR: staging → develop (for testing)
# Review changes, test thoroughly

# 10. Create PR: develop → main (for release)
# Final approval, then merge

# 11. Release is now live!
```

### Checking What Will Sync

```bash
# See private content that WILL be removed
git ls-files | grep -E "^(paper|internal|drafts|personal|benchmarks|_drafts|_archive|_deprecated|eb1a)/"

# See .log files that WILL be removed
git ls-files | grep "\.log$"

# See what's left (this is what syncs)
git ls-files | wc -l
```

### Emergency: Undo a Release

```bash
# If staging sync is wrong, delete it
cd wbopendata
git push origin --delete staging

# In wbopendata-dev, delete the tag
cd wbopendata-dev
git tag -d v1.2.0
git push origin --delete v1.2.0

# Fix the issue and retry
git tag -a v1.2.1 -m "Fixed release"
git push origin v1.2.1
```

### Adding New Private Patterns

When adding a new private folder (e.g., `confidential/`):

**1. Update workflow removal step** (`.github/workflows/sync-to-public.yml`):
```yaml
rm -rf confidential/
```

**2. Update verification step**:
```bash
if [[ -d "confidential/" ]]; then
  echo "ERROR: confidential/ detected!"
  exit 1
fi
```

**3. Update .gitignore** (both repos):
```gitignore
confidential/
```

**4. Test locally**:
```bash
echo "secret content" > confidential/notes.txt
git check-ignore -v confidential/notes.txt
# Should show: .gitignore:NN:confidential/	confidential/notes.txt
```

---

## Diagram: Release Flow

```
wbopendata-dev/main (with private content)
         ↓
    [Create Tag v1.2.0]
         ↓
   GitHub Actions Triggers
         ↓
   ┌─────────────────────┐
   │ Remove private      │
   │ Remove *.log        │
   │ Remove .github/*    │
   └─────────────────────┘
         ↓
   ┌─────────────────────┐
   │ VERIFY Removal      │
   │ Abort if found?     │  ← Defense Layer 2
   └─────────────────────┘
         ↓
   wbopendata/staging (clean code)
         ↓
    [Create PR to develop]
         ↓
   wbopendata/develop (staging → tested)
         ↓
    [Create PR to main]
         ↓
   wbopendata/main (develop → released)
         ↓
    Users: git pull (get clean v1.2.0)
```

---

## Contact & Maintenance

**Questions about this workflow?** See:
- [github-repo-sop.md](.github/github-repo-sop.md) - Full SOP for public/private repo management
- [copilot-instructions.md](.github/copilot-instructions.md) - Stata ADO development standards

**Issues or concerns?** Check GitHub Actions logs:
1. Go to wbopendata-dev repository
2. Click "Actions" tab
3. Click "Sync to Public Repo (Staging)"
4. Find failed run
5. Expand job details to see error message

---

*Last Updated: January 14, 2026*  
*Workflow File: `.github/workflows/sync-to-public.yml`*  
*Applies To: wbopendata-dev → wbopendata release synchronization*
