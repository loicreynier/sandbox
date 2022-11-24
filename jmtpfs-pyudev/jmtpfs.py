"""Script monitoring MTP devices actions for mount/demount.

The monitoring is performed through a pyudev `Monitor` and devices
are mounted using the `jmtpfs` command via `os.system`.

The monitoring is dirty, there is no exception capturing if devices
fail to mount/unmount.
"""

import os
import time

import pyudev
from pyudev import Device

mounted: dict[str, tuple[bool, str | None]] = {}
USER = os.getlogin()
MOUNTDIR = f"/media/{USER}"
SLEEP_TIME = 5


def callback(device: Device) -> None:
    """Mount and demount MTP devices."""
    if device.action == "add" and device.get("ID_MTP_DEVICE"):
        name = str(device)
        path = device.get("ID_SERIAL")
        bus = device.get("BUSNUM")
        dev = device.get("DEVNUM")
        os.system(f"mkdir -p {MOUNTDIR}/{path}")
        os.system(f"jmtpfs -device={bus},{dev} {MOUNTDIR}/{path}")
        mounted[name] = True, path
        print(f"{name} mounted in {MOUNTDIR}/{path}")
    elif device.action == "remove":
        name = str(device)
        path = device.get("ID_SERIAL")
        try:
            if mounted[name][0]:
                path = mounted[name][1]
                os.system(f"fusermount -u {MOUNTDIR}/{path}")
                os.system(f"rmdir {MOUNTDIR}/{path}")
                mounted[name] = False, None
                print(f"{name} unmounted from {MOUNTDIR}/{path}")
        except KeyError:
            pass


if __name__ == "__main__":
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by("usb")
    observer = pyudev.MonitorObserver(monitor, callback=callback)
    observer.start()
    try:
        while True:
            time.sleep(SLEEP_TIME)
    except KeyboardInterrupt:
        observer.stop()
        observer.join()
