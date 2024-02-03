Param (
    [string]$Target,
    [string]$Destination
)

function Add-AdminShortcutFlag {
    # Source: https://stackoverflow.com/q/28997799

    Param (
        [string]$Path
    )

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $bytes[0x15] = $bytes[0x15] -bor 0x20 # Set byte 21 (0x15) bit 6 (0x20) ON
    [System.IO.File]::WriteAllBytes($Path, $bytes)
}

$Target = [System.IO.Path]::GetFullPath($Target)
    $Destination = [System.IO.Path]::GetFullPath($Destination)

If (-Not (Test-Path $Target)) {
    Throw "The source file $Target does not exist"
}
If (-Not (Test-Path $Destination)) {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Destination)
    $Shortcut.Targetpath = $Target
    $Shortcut.Save()
    Add-AdminShortcutFlag -Path $Destination
}
Else {
    Write-Error "Destination $Destination already exists"
}
