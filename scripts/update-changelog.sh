#!/bin/sh

# Variables
ENVIRONMENT=master
SPACE_ID="tmqu5vj33f7w"
CONTENT_TYPE="changelog"

echo "Enter Contentful AccessToken:"
read access_token

gh release view --repo tink-ab/tink-link-ios >> release.txt
heading=$(awk -F'title:' '{print $2}'  release.txt | xargs echo -n)
url=$(awk -F'url:' '{print $2}'  release.txt | xargs echo -n) 
body=$(sed '1,/^--$/d' release.txt)  
rm release.txt

curl -X "POST" "https://api.contentful.com/spaces/$SPACE_ID/environments/$ENVIRONMENT/entries" --include \
--header "Authorization: Bearer $access_token" \
--header 'Content-Type: application/vnd.contentful.management.v1+json' \
--header "X-Contentful-Content-Type: $CONTENT_TYPE" \
--data-binary "{
  \"fields\": {
    \"heading\": {
      \"en-US\": \"Released $heading\"
    },
    \"body\": {
      \"en-US\": \"$body\nTo download source code, see the [release on GitHub]($url).\"
    },
    \"product\": {
      \"en-US\": [\"Platform\"]
    },
    \"tags\": {
      \"en-US\": [\"Tink Link\"]
    }
  }
}"
