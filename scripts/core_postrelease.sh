#!/bin/sh

echo Enter release number: 
read release

git checkout master
git pull 
git checkout -b public-sync-$release
git pull git@github.com:tink-ab/tink-core-ios master

gh pr create --repo tink-ab/tink-core-ios-private -t "Public Sync" -b "Tink Core post release public sync." -r tink-ab/ios-maintainer

git push git@github.com:tink-ab/tink-core-ios-private $release

pod trunk push TinkCore.podspec

echo Tink Core public sync created and pushed to cocoapods! 🎉
