"""Detect if Windows darkmode is enabled."""

import winreg
import os


def darkmode_enabled():
    """Whether Windows darkmode is enabled."""
    registry = winreg.ConnectRegistry(None, winreg.HKEY_CURRENT_USER)
    reg_keypath = (
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    )
    try:
        reg_key = winreg.OpenKey(registry, reg_keypath)
    except FileNotFoundError:
        return False

    for i in range(1024):
        try:
            value_name, value, _ = winreg.EnumValue(reg_key, i)
            if value_name == "AppsUseLightTheme":
                return value == 0
        except OSError:
            break
    return False


if __name__ == "__main__":
    if os.name == "nt":
        print(darkmode_enabled())
    else:
        raise ValueError("Not running on Windows")
