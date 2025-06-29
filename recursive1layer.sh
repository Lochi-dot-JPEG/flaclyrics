#!/bin/sh


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -d "$1" ]; then
	echo Directory doesn\'t exist;
	echo usage: download.sh [folder to download lyrics for]
	exit
fi
cd "$1"

for folder in */; do
	sh "$SCRIPT_DIR/download.sh" "$folder" &
done

wait
