#!/bin/sh
echo Enter release version:
read version

if [[ $version =~ ^([0-9]{1,2}\.){2}[0-9]{1,10}$ ]]; then
git checkout master
git pull
else
  echo "$version is not in the right format."
  exit
fi

git checkout -b rc-$version
gh pr create --repo tink-ab/tink-core-ios -t "Tink Core $version" -b "Release candidate for Tink Core public release." -r tink-ab/ios-maintainer

echo PR created, wait for approval and draft a new release changelog! 🎉
