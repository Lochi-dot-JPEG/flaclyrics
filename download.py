#!/bin/python3

import os
import sys
import subprocess


def show_help():
    print("""Downloads lyric files for every file in the given directory
Usage: download.py [DIR]""")


def get_stdout(_arguments: list):
    return subprocess.run(_arguments, capture_output=True).stdout.decode().strip()


args = len(sys.argv)

if args < 2:
    print("Not enough arguments")
    show_help()
    exit()

directory = sys.argv[1]

if not os.path.exists(directory):
    print("Path " + str(directory) + " doesn't exist")
    exit()

print(os.getcwd())
os.chdir(directory)

files = os.listdir(".")
for file in files:
    if not file.endswith(".flac"):
        # print(file + ' not a flac skipping')
        continue
    base_name = get_stdout(["basename", file, ".flac"])
    output_name = base_name + ".lrc"
    if os.path.exists(output_name):
        print('Lyrics already exist for ' + output_name)
        continue

#    os.path.exists()
#    if [-e "$OUTPUTNAME"]
#    then
#    echo "Lyrics already exist for: $(basename "$song" .flac), skipping"
#    continue
#    fi
