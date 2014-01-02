DIFF_FOLDER=./old_diffs
LOG=$DIFF_FOLDER/logs.txt

updated=""

is_same() {
    # Returns 1 if they are the same image, 0 otherwise
    old_size=`identify $1 | awk '{print $3}'`
    new_size=`identify $2 | awk '{print $3}'`

    if [ ! $old_size = $new_size ]
    then
	echo 0
	return 1
    fi

    diff_pixels=$((compare -metric ae $1 $2 $1.compare) 2>&1)
    rm $1.compare

    if [ ! $diff_pixels = 0 ]
    then
	echo 0
	return 1
    fi
    echo 1
    return 1
}

echo
while read line
do
    author=`echo $line | awk -F';' '{print $1}' | tr -d [[:space:]]`
    url=`echo $line | awk -F';' '{print $2}' | tr -d [[:space:]]`

    echo -e "Checking" $author...
    echo $url

    old="$DIFF_FOLDER/$author-full.png"
    new="$DIFF_FOLDER/$author-tmp-full.png"

    # Initialize new webpage trackers
    if [ ! -f $old ]
    then
        webkit2png -F -o $author -D $DIFF_FOLDER $url > $LOG 2>&1
        echo Initialized webpage.
    else
	webkit2png -F -o $author-tmp -D $DIFF_FOLDER $url > $LOG 2>&1

	same=$(is_same $old $new)

#        diffpixels=$((compare -metric ae $old $new $old.compare) 2>&1)
#	echo "$diffpixels pixels changed"
#	rm $old.compare

        if [ "$same" = 0 ]
        then
            echo Updates detected!
            mv "$new" "$old"
            updated="$updated$author: $url\n"
        else
            rm $new
            echo No updates.
        fi
    fi
    echo
done < <(cat diff_urls.txt)

if [ -n "$updated" ]
then
    echo -e "The following pages had updates:\n"
    echo -e $updated
    #echo -e "Sending email to $(whoami):" $updated "\n"
    #echo -e "--------------------\n"$updated"\n----------------------" | mail -s "Updated websites $(date "+%b %d %Y")" `whoami`@`hostname`
else
    echo "No updated pages were found."
fi
