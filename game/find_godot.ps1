$godotPaths = @(
    "E:\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe",
    "$env:LOCALAPPDATA\Programs\Godot\Godot.exe",
    "$env:LOCALAPPDATA\Godot\Godot.exe",
    "C:\Program Files\Godot Engine\Godot.exe",
    "C:\Program Files (x86)\Godot Engine\Godot.exe"
)

foreach ($path in $godotPaths) {
    if (Test-Path $path) {
        Write-Output $path
        exit 0
    }
}

Write-Output "NOT_FOUND"
exit 1