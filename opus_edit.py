#!/usr/bin/env python3

import os
import shutil
import sys
import glob
import subprocess

import taglib

def progress_bar(current_pos, end_val, line=""):
    bar_length = 20
    full_size = bar_length + 7

    percent = current_pos / end_val
    hashes = "#" * round(percent * bar_length)
    spaces = " " * (bar_length - len(hashes))

    width = shutil.get_terminal_size()[0]
    line += " " * (width - full_size - len(line))
    status = "\r[{0}{1}]{2}% {3}".format(hashes, spaces,
                                  round(percent*100), line)

    if len(status) < width:
        print(status,end="")
    else:
        print(status[:width],end="")

    if current_pos == end_val:
        print()
        
def edit_tags(files, path):
    number_of_files = len(files)
    extension_length = len(".opus")
    current = 0

    for f in files:
        file_name = f[len(path):-extension_length]
        song = taglib.File(f)
        song.tags = {}

        artist, sep, title  = file_name.partition(" - ")
        song.tags["ARTIST"] = [artist]
        song.tags["TITLE"] = [title]
        song.save()

        current += 1
        progress_bar(current, number_of_files, file_name)

def refresh_mpd(pid):
    if os.path.exists(pid):
        print("Refreshing MPD")
        subprocess.call(["mpc","-q","clear"])
        subprocess.call(["mpc","-q","update"])
        subprocess.call(["mpc","-q","add","/"])
        subprocess.call(["mpc","-q","random","on"])
        subprocess.call(["mpc","-q","repeat","on"])
    else:
        print("MPD not currently running")

def move_files(files):
    try:
        dst = os.environ["HOME"] + "/Music/"
        [shutil.move(f,dst) for f in files]
        print("Moving files to ~/Music")
    except shutil.Error:
        print("Files already in Music directory")

if __name__ == "__main__":
    try:
        music_path = sys.argv[1]
        if not music_path.endswith("/"):
            music_path += "/"
    except IndexError:
        print("No path specified")
        exit()

    music_files = glob.glob(music_path + "*.opus")
    if music_files:
        edit_tags(music_files, music_path)
        print("Edited {0} songs".format(len(music_files)))

        move_files(music_files)
        mpd_pid = os.environ["HOME"] + "/.config/mpd/pid"
        refresh_mpd(mpd_pid)

        print("Done!")
    else:
        print("No files selected")
