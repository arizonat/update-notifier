DIFF_FOLDER=./old_diffs
LOG=$DIFF_FOLDER/logs.txt

updated=""

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
        webkit2png -F -o $author -D $DIFF_FOLDER $url > $LOG
        echo Initialized webpage.
    else
	webkit2png -F -o $author-tmp -D $DIFF_FOLDER $url > $LOG
        diffpixels=`compare -metric ae $old $new $old.compare`
	rm $old.compare

        if [ ! $diffpixels = 0 ]
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
    echo -e "Changes were discovered!\n"
    echo -e "Sending email to $(whoami):" $updated "\n"
    echo -e "--------------------\n"$updated"\n----------------------" | mail -s "Updated websites $(date "+%b %d %Y")" `whoami`@`hostname`
fi
