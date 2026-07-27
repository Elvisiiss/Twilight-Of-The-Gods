---
name: "delete-logs"
description: "Deletes all log files in the game directory. Invoke when user asks to clean/remove/delete log files or wants to clear game logs."
---

# Delete Logs

This skill deletes all log files from the `game/` directory.

## How to Execute

Run the PowerShell script:
```bash
powershell -ExecutionPolicy Bypass -File delete_logs.ps1
```

## Options

- **Dry Run** (preview only, no deletion):
  ```bash
  powershell -ExecutionPolicy Bypass -File delete_logs.ps1 -dryrun
  ```

- **Force Delete** (skip confirmation):
  Pass any argument to skip the confirmation prompt:
  ```bash
  powershell -ExecutionPolicy Bypass -File delete_logs.ps1 -force
  ```

## Target Files

The script deletes:
- `.log` files in `game/` directory
- `*_log.txt` files in `game/` directory

## Safety

- Does NOT delete chapter files in `chapters/` directory
- Does NOT delete other project files
- Shows confirmation prompt before deletion (unless forced)
- Supports dry-run mode for previewing what will be deleted

## Example Usage

When user says "删除日志文件", "清理日志", or "删除游戏日志", run:
```bash
powershell -ExecutionPolicy Bypass -File delete_logs.ps1
```

The script will:
1. List all found log files
2. Ask for confirmation
3. Delete files after confirmation
