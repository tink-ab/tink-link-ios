#!/bin/sh

echo "Enter release number:"
read release

if [[ $version =~ ^([0-9]{1,2}\.){2}[0-9]{1,10}$ ]]; then
git checkout master
git pull
git checkout -b public-sync-$release
else
  echo "$release is not in the right format."
  exit
fi

git pull git@github.com:tink-ab/tink-link-ios master

gh pr create --repo tink-ab/tink-link-ios-private -t "Public Sync" -b "Tink Link post release public sync." -r tink-ab/ios-maintainer

git push git@github.com:tink-ab/tink-link-ios-private $release

pod trunk push TinkLink.podspec --skip-tests --skip-import-validation --allow-warnings
pod trunk push TinkLinkUI.podspec --skip-tests --skip-import-validation --allow-warnings

echo "Tink Link public sync created and pushed to cocoapods! 🎉"
