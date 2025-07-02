# 🛠 watcher-release-tools

Automated versioning, packaging, and GitHub release flow for [watcher-monitoring](https://github.com/egk10/watcher-monitoring)

## Scripts

| Script             | Purpose                           |
|--------------------|------------------------------------|
| `make_deb_autotag.sh` | Builds `.deb`, tags repo, pushes release |
| `readme_cleaner.sh`   | Syncs badge and install command in README |
| `version_debug.sh`    | Prints latest and next semantic version |

## Usage

Run from inside this repo:

```bash
./make_deb_autotag.sh

Or clean the badge/install block:
./readme_cleaner.sh

