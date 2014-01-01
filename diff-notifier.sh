DIFF_FOLDER=./old_diffs

updated=""

echo
while read line
do
    author=`echo $line | awk -F';' '{print $1}' | tr -d [[:space:]]`
    url=`echo $line | awk -F';' '{print $2}' | tr -d [[:space:]]`

    echo -e "Checking" $author...
    echo $url

    old="$DIFF_FOLDER/$author.html"
    new="$DIFF_FOLDER/$author.tmp"

    # Initialize new webpage trackers
    if [ ! -f $old ]
    then
        curl -s "$url" > "$old"
        echo Initialized webpage.
    else
        s=`echo $url | tr -d " "`
        #curl $s
        curl -s "$url" > "$new"
        difflines=`diff "$old" "$new" | wc -l`

        if [ ! $difflines = 0 ]
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
