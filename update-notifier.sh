touch tmp.txt

updated=""

echo
while read line
do
    url=`echo $line | awk -F';' '{print $1}'`
    prev=`echo $line | awk -F';' '{print $2}'`
    
    # Get Last-modified field from headers
    lm=`curl -Is $url | grep Last-Modified | awk '{gsub(/Last-Modified:[ \t]+/,"");print}'`

    echo "Checking" $url...

    if [ "$prev" = 'not_parseable' ]
    then
	echo "Not parseable."
	result="not_parseable"
    elif [ -z "$lm" ]
    then
	echo "Not parseable."
	result="not_parseable"
    elif [ "$prev" = "$lm" ]
    then
	echo "No changes found."
	result=$lm
    else
	echo "Updates detected!"
	result=$lm
	updated=$updated"\n"$url
    fi

    echo $url';'$result >> tmp.txt
    
#    echo URL: $url
#    echo PREV: $prev
#    echo LASTMODIFIED: $lm
    echo
done < <(cat urls.txt)

if [ -n "$updated" ]
then
    echo -e "Changes were discovered!\n"
    echo -e "Sending email to $(whoami) with the following updated pages:" $updated "\n"
    echo -e $updated | mail -s "Updated websites $(date "+%b %d %Y")" `whoami`@`hostname`
fi

mv tmp.txt urls.txt
