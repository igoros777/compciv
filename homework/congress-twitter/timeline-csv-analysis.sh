username="${1}"
postcount="${2}"
commonwords="https://gist.githubusercontent.com/deekayen/4148741/raw/01c6252ccc5b5fb307c1bb899c95989a8a284616/1-1000.txt"
excludelist="$(curl -s -q ${commonwords} | xargs 2>/dev/null | sed -r 's/ /|/g')|http|https"
workdir="/root/data-hold"
mkdir -p "${workdir}"
echo "Fetching tweets for ${username} into ${workdir}/${username}"
file="${workdir}/${username}"
t timeline -n ${postcount} --csv ${username} > ${file}
count=$(csvfix order -f 1 ${file} | wc -l)
lastdate=$(csvfix order -fn 'Posted at' ${file} | tail -n 1)
echo "Analyzing $count tweets by ${1} since ${lastdate}"

echo "Top 10 hashtags by ${username}"
cat ${file} | csvfix order -fn 'Text' | grep -oP '#[A-z0-9_]+' | tr "[:upper:]" "[:lower:]" | grep -vE "$(echo ${excludelist} | sed -r 's/[,; ]/\|/g')" | sort | uniq -c | sort -rn | head -n 10

echo "Top 10 retweeted users by ${username}"
cat ${file} | csvfix order -fn 'Text' |  grep -oP 'RT @[A-z0-9_]+' | grep -oP '@[A-z0-9_]+' | sort | uniq -c | sort -rn | head -n 10

echo "Top 10 mentioned users (not including retweets) by ${username}"
cat ${file} | csvfix order -fn 'Text' | grep -v "RT" | grep -oP '@[A-z0-9_]+' | tr "[:upper:]" "[:lower:]" | sort | uniq -c | sort -rn | head -n 10

echo "Top tweeted 10 words with 5+ letters by ${username}"
cat ${file} | csvfix order -fn 'Text' | grep -oP '[[:alpha:]]{5,}' | sort | uniq -c | sort -rn | head -n 10
