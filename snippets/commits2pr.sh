#!/usr/bin/env bash
 
# only works if $USER is the same as your github username... change it if its different
body=$(git log --author $USER --format="#### %s%n%b" --first-parent --no-merges)
echo $body | pbcopy
echo $body
