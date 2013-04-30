#! /bin/bash

echo $IFS

for f in output/*.txt; do

	cat $f | while read line; do

		file=`echo $line | cut -f 1 -d ','`
		id=`echo $line | cut -f 2 -d ','`
		ss=`echo $line | cut -f 3 -d ','`
		scene=`echo $line | cut -f 4 -d ',' | sed 's/[^-a-z0-9]/-/g' | sed 's/-[-]*/-/g'`

		dst="posters/$file-$scene.png"
		src="/Users/fjenett/Repos/piecemaker/public/video/full/$file.mp4"

		echo "ffmpeg -ss $ss -i $src -f image2 -vframes 1 $dst"

	done
done