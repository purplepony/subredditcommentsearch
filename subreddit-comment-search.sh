#! /bin/bash

url="https://www.reddit.com/user/$1"
pagecount=0
color=1
subreddit="$2"
while true; do
	let pagecount=pagecount+1
	if [ $color -eq 1 ]; then echo -en "\e[34m"; fi # Escape sequence for colors"
	echo "**Searching page $pagecount: $url"
	if [ $color -eq 1 ]; then echo -en "\e[39m"; fi # End colored line"
	wget -q $url -O- | sed 's/>/>\n/g' > /tmp/page.html
	egrep -B 22 "$subreddit/comments/.+\" data-event-action=\"permalink\" class=\"bylink\"" /tmp/page.html | egrep "^--$|<time title=\"|$subreddit/comments/.+\" data-event-action=\"permalink\" class=\"bylink\"" | sed 's/<\/a>$//' | sed 's/^<a href="//g' | sed 's/&#32;<time title="//g' | cut -d '"' -f 1 | xargs 2>/dev/null | sed 's/--/\n/g' | sed 's/^ //g' | awk 'BEGIN {FS=" "} {print "-- " $3 " " $2 " at " $4 " " $6 ": " $7}' | egrep 'https'
	url=$(cat /tmp/page.html | sed 's/>/>\n/g' | grep 'nofollow next' | cut -d '"' -f 2 | sed 's/\&amp\;/\&/g')
	if [ -z $url ]; then break; fi
done
echo "End of comment history."
