import os
import sys
import json
import subprocess
from datetime import datetime

# Load JSON config
CONFIG_FILE = "autopush.json"
with open(CONFIG_FILE, "r") as f:
    config = json.load(f)

# Shortcuts
project = config["project"]
colors = config["colors"]
messages = config["messages"]
commit_cfg = config["commit"]
git_cfg = config["git"]
lock_cfg = config["lock_system"]
logging_cfg = config["logging"]
version_cfg = config["versioning"]

# Resolve paths
PROJECT_DIR = os.path.expanduser(project["dir"])
LOGFILE = os.path.join(PROJECT_DIR, project["logfile"])
LOCKFILE = os.path.join(PROJECT_DIR, project["lockfile"])
VERSION_FILE = os.path.join(PROJECT_DIR, project["version_file"])
COMMITS_FILE = os.path.join(PROJECT_DIR, project["commits_file"])
CHANGELOG_FILE = os.path.join(PROJECT_DIR, project["changelog_file"])

# Helper for colored output
def cprint(text, color):
    print(f"{color}{text}{colors['reset']}")

# Ensure project directory exists
if not os.path.isdir(PROJECT_DIR):
    cprint(f"Project directory {PROJECT_DIR} does not exist!", colors['red'])
    sys.exit(1)

os.chdir(PROJECT_DIR)

# Lock system
if lock_cfg["enabled"] and os.path.exists(LOCKFILE):
    cprint(messages["autopush_running"], colors['red'])
    sys.exit(1)

if lock_cfg["enabled"]:
    with open(LOCKFILE, "w") as f:
        f.write("locked")

# Dashboard header
print("\n-------------------------------------")
cprint("AUTOPUSH PRODUCTION ENGINE", colors['blue'])
print(datetime.now())
print("-------------------------------------")
print("Running diagnostics...")

# Verify Git repository
if subprocess.run(["git", "rev-parse", "--is-inside-work-tree"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode != 0:
    cprint(messages["not_git_repo"], colors['red'])
    if os.path.exists(LOCKFILE):
        os.remove(LOCKFILE)
    sys.exit(1)

# Fetch remote
if git_cfg["fetch_remote"]:
    print("Syncing with remote...")
    subprocess.run(["git", "fetch", project["remote"]])

# Detect changes
CHANGES = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True).stdout.strip()
if not CHANGES:
    cprint(messages["no_changes"], colors['yellow'])
else:
    cprint(messages["changes_detected"], colors['green'])
    subprocess.run(["git", "add", "."])
    auto_message = f"{commit_cfg['auto_prefix']} {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    subprocess.run(["git", "commit", "-m", auto_message])

# Version bump
if version_cfg["enabled"] and os.path.exists(VERSION_FILE):
    with open(VERSION_FILE, "r") as f:
        current = f.read().strip()
    major, minor, patch = map(int, current.split("."))
    patch += 1
    new_version = f"{major}.{minor}.{patch}"
    with open(VERSION_FILE, "w") as f:
        f.write(new_version)
    subprocess.run(["git", "add", VERSION_FILE])
    subprocess.run(["git", "commit", "-m", f"{commit_cfg['version_prefix']}{new_version}"])
    cprint(f"{messages['version_updated']}{new_version}", colors['green'])

# Update commits log
log_count = str(git_cfg["commit_log_count"])
subprocess.run(f"git log --oneline -{log_count} > {COMMITS_FILE}", shell=True)
subprocess.run(["git", "add", COMMITS_FILE])
subprocess.run(["git", "commit", "-m", commit_cfg["commits_log_prefix"]], stderr=subprocess.DEVNULL)

# Update changelog
with open(CHANGELOG_FILE, "a") as f:
    f.write(f"Update {datetime.now()}\n")
subprocess.run(["git", "add", CHANGELOG_FILE])
subprocess.run(["git", "commit", "-m", commit_cfg["changelog_prefix"]], stderr=subprocess.DEVNULL)

# Pull safe
print("Pulling latest remote updates...")
pull_cmd = ["git", "pull"]
if git_cfg["pull_rebase"]:
    pull_cmd.append("--rebase")
pull_cmd.append(project["remote"])
pull_cmd.append(project["branch"])
subprocess.run(pull_cmd)

# Push system
print("Pushing to remote...")
push_result = subprocess.run(["git", "push", project["remote"], project["branch"]])
if push_result.returncode == 0:
    cprint(messages["push_success"], colors['green'])
else:
    cprint(messages["push_failed"], colors['red'])

# Logging
if logging_cfg["enabled"]:
    with open(LOGFILE, "a") as f:
        f.write(f"AUTOPUSH RUN {datetime.now()}\n")
        if logging_cfg["log_status"]:
            status = subprocess.run(["git", "status"], capture_output=True, text=True)
            f.write(status.stdout + "\n")

# Cleanup
if lock_cfg["enabled"]:
    os.remove(LOCKFILE)

print()
cprint(messages["automation_complete"], colors['green'])
print("-------------------------------------")