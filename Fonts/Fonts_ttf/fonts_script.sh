pointsize=72
for f in *.ttf; do
	directory_name="${f:0:-4}"
	mkdir $directory_name
	mv "$f" $directory_name/
	cd $directory_name
	printf "Converting font %s...\n" $directory_name
	for letter in {a..z} {A..Z} {0..0}; do
		convert -font "$f" -pointsize "$pointsize" label:"$letter" "$letter".bmp
	done
	printf "Done\n"
	cd ..
done
