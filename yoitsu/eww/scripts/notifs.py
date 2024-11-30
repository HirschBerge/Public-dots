#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python311.withPackages (ps: with ps; [ psutil dbus-python pygobject3 gobject-introspection jedi-language-server ])" gobject-introspection

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import threading
import time
import os
import psutil
from pathlib import Path
import subprocess

def get_app_icon(app_name):
    """Get the app icon path if it exists, otherwise return None."""
    icon_path = Path.home() / ".config" / "notification_icons" / f"{app_name}.svg"
    if icon_path.exists():
        return str(icon_path)
    print(f"No icon for {app_name}")
    return Path.home() / ".config" / "notification_icons" / "normal.svg"

class Notification:
    def __init__(self, summary, body, icon, actions):
        self.summary = summary
        self.body = body
        self.icon = icon
        self.actions = actions

no_sound = [ 'vesktop' ]

def play_notification_sound(app_name):
    """Play notification sound if the app name is not in the no_sound list."""
    if app_name not in no_sound:
        try:
            # Command to play the sound at 20% volume
            subprocess.run(["pw-play", str(Path.home() / ".config/notification_icons/notification.wav"), "--volume", "0.2"], check=True)
        except Exception as e:
            print(f"Failed to play sound: {e}")

notifications = []


def remove_object(notif):
    time.sleep(6)
    notifications.remove(notif)
    print_state()


def add_object(notif):
    notifications.insert(0, notif)
    print_state()
    timer_thread = threading.Thread(target=remove_object, args=(notif,))
    timer_thread.start()


def print_state():
    string = ""
    for item in notifications:
        summary = item.summary.replace("'", "\\'").replace('"', '\\"').replace("\n", " ")
        body = item.body.replace("'", "\\'").replace('"', '\\"').replace("\n", " ")
        string += f"""
                  (button :class 'notif'
                   (box :orientation 'horizontal' :space-evenly false
                      (image :image-width 100 :image-height 100 :path '{item.icon or ''}')
                      (box :orientation 'vertical'
                        (label :width 300 :wrap true :text '{summary or ''}')
                        (label :width 300 :wrap true :text '{body or ''}')
                  )))
                  """
    string = string.replace("\n", " ")
    print(rf"""(box :orientation 'vertical' {string or ''})""", flush=True)


class NotificationServer(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName(
            "org.freedesktop.Notifications", bus=dbus.SessionBus()
        )
        dbus.service.Object.__init__(self, bus_name, "/org/freedesktop/Notifications")

    @dbus.service.method(
        "org.freedesktop.Notifications", in_signature="susssasa{sv}i", out_signature="u"
    )
    def Notify(
        self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout
    ):
        try:
            if len(body) >= 45:
                body = body[:42] + "..."
            # Check for the icon in the specified directory
            if not app_icon:
                icon_path = get_app_icon(app_name)
                print(icon_path)
            else:
                icon_path = app_icon
            # Use the provided app_icon as a fallback if no custom icon exists
            if not icon_path:
                icon_path = app_icon
            # Add the notification with the resolved icon path
            play_notification_sound(app_name)
            add_object(Notification(summary, body, icon_path, actions))
        except Exception as e:
            print(f"Error handling notification: {e}")
        return 0

    @dbus.service.method(
        "org.freedesktop.Notifications", in_signature="", out_signature="ssss"
    )
    def GetServerInformation(self):
        return ("Custom Notification Server", "ExampleNS", "1.0", "1.2")

    @dbus.service.method(
        "org.freedesktop.Notifications", in_signature="", out_signature="as"
    )
    def GetCapabilities(self):
        return ["actions", "persistence"]

    @dbus.service.method(
        "org.freedesktop.Notifications", in_signature="", out_signature="v"
    )
    def ClearNotifications(self):
        try:
            notifications.clear()  # Clear all notifications
        except:
            print("Cleared notifications!")
        print_state()  # Print the updated state
        self.exit_server()  # Call the method to exit the server

    def exit_server(self):
        print("Exiting notification server...")
        GLib.MainLoop().quit()  # Exit the GLib main loop


def kill_existing_instances():
    current_pid = os.getpid()
    for proc in psutil.process_iter(["pid", "name"]):
        if proc.info["name"] == "python" and proc.pid != current_pid:
            try:
                # Optionally, you can add conditions here to match the exact script if necessary
                proc.terminate()  # Gracefully terminate the process
                proc.wait()  # Wait for the process to finish
                print(f"Killed existing instance with PID: {proc.pid}")
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass


DBusGMainLoop(set_as_default=True)

if __name__ == "__main__":
    server = NotificationServer()
    mainloop = GLib.MainLoop()
    mainloop.run()
