# A Bash script is not in the pinned spec language; the pinned lexer rejects '#'.
while read -r line; do
  echo "$line" | wc -l
done < bigfile
