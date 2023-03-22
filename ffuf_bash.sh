#!/bin/bash

# Check for required arguments
if [[ -z $1 ]] || [[ ! -f $1 ]]; then
  echo "Usage: ./ffuf-multi-site.sh [site-list.txt] [dictionary-file]"
  exit 1
fi

if [[ -z $2 ]] || [[ ! -f $2 ]]; then
  echo "Usage: ./ffuf-multi-site.sh [site-list.txt] [dictionary-file]"
  exit 1
fi

# Create a random directory to store the results
directory=$(mktemp -d "$(pwd)/XXXXXX")

# Read site list file into an array
sites=()
while read site; do
  sites+=("$site")
done < $1


# Loop through each site and run ffuf
for site in "${sites[@]}"; do
  echo "Scanning $site..."
  domain=$(echo $site | cut -d / -f 3)
  filename=$(echo $domain | sed 's/\./_/g')
  ./ffuf -w "$2" -u "$site/FUZZ" -mc 200,403 -ac -t 50 -o "$directory/results_$filename.json" -of json
done


# Filter out successful results using jq
successful_results=$(cat $directory/*.json | jq -r '.results[] | select(.status == 200 or .status == 403) | .url')

# Save successful results to a file
echo "$successful_results" > "$directory/successful_all.txt"

