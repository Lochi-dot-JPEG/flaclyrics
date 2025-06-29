#!/bin/sh

LRCFILES=()


while getopts ":h" option; do
	case $option in
		h) # display Help
		echo usage: download.sh [folder to download lyrics for]
		exit;;
	esac
done

if [ ! -d "$1" ]; then
	echo Directory doesn\'t exist;
	echo usage: download.sh [folder to download lyrics for]
	exit
fi

cd "$1"

for song in *.flac; do

	# Check if lyrics file already exists
	OUTPUTNAME=$(basename "$song" .flac).lrc
	if [ -e "$OUTPUTNAME" ]; then
		echo "Lyrics already exist for: $(basename "$song" .flac), skipping"
		continue
	fi

	ARTIST=$(metaflac --show-tag="AlbumArtist" "$song")
	if [ -z "$ARTIST" ]; then
		ARTIST=$(metaflac --show-tag="Artist" "$song")
		if [ -z "$ARTIST" ]; then
			echo "$song doesn't have a AlbumArtist or Artist tag."
			continue
		fi
	fi
	ARTIST=${ARTIST#*=} # Remove everything before and including =

	ALBUM=$(metaflac --show-tag="Album" "$song")
	ALBUM=${ALBUM#*=} # Remove everything before and including =
	if [ -z "$ALBUM" ]; then
		echo "$song doesn't have a Album tag."
		continue
	fi

	TITLE=$(metaflac --show-tag="Title" "$song")
	TITLE=${TITLE#*=} # Remove everything before and including =
	if [ -z "$TITLE" ]; then
		echo "$song doesn't have a Title tag."
		continue
	fi

	LENGTH=$(soxi -D "$song")
	if [ -z "$LENGTH" ]; then
		echo "Can't get length. Is sox installed?"
		continue
	fi
	LENGTH=$(printf "%.0f\n" $LENGTH) # Round length


	REQUEST="/api/get?artist_name=$ARTIST&track_name=$TITLE&album_name=$ALBUM&duration=$LENGTH"
	echo "Downloading lyrics for $ARTIST - $TITLE to $OUTPUTNAME"
	curl -s -o - --get \
		--data-urlencode "artist_name=$ARTIST" \
		--data-urlencode "track_name=$TITLE" \
		--data-urlencode "album_name=$ALBUM" \
		--data-urlencode "duration=$LENGTH" \
		https://lrclib.net/api/get | jq ".syncedLyrics // .plainLyrics" --raw-output > "$OUTPUTNAME" &
	LRCFILES+=("$OUTPUTNAME")
done

wait

# Check if any of the lyric files were invalid
for file in "${LRCFILES[@]}"; do
	content=$(<"$file")
	if [ "$content" = "null" ]; then
		rm "$file"
		echo "Couldn't fetch lyrics for $file"
	else
		echo "Fetched lyrics for $file"
	fi
done
