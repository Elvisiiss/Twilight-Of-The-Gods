---
name: "ZSHH-rebuild"
description: "Rebuilds the Twilight of the Gods Godot game project. Invoke when user asks to rebuild, build, or export the game."
---

# ZSHH Rebuild

This skill rebuilds the Twilight of the Gods Godot game project, exporting it to a Windows executable.

## When to Use

Invoke this skill when:
- User asks to "rebuild", "build", or "export" the game
- User wants to generate a new executable after code changes
- User mentions "重新build" or "构建" or "编译"

## Steps

1. Run the build script located at `e:\Twilight-Of-The-Gods\game\build.ps1`:
   ```
   powershell -ExecutionPolicy Bypass -File build.ps1
   ```
   Working directory: `e:\Twilight-Of-The-Gods\game`

2. The build script will:
   - Locate the Godot Engine executable via `find_godot.ps1`
   - Export the project using the "Windows Desktop" preset
   - Output the executable to `e:\Twilight-Of-The-Gods\game\build\TwilightOfTheGods.exe`

3. Report the build result to the user:
   - If successful: Show the output path
   - If failed: Show the error message and exit code

## Notes

- The project uses Godot Engine (located via `find_godot.ps1`)
- Export preset: "Windows Desktop" with `embed_pck=true`
- Main scene: `res://Scenes/NewbieVillage.tscn`
- Output: `build/TwilightOfTheGods.exe`
