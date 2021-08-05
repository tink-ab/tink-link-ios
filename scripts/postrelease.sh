#!/bin/sh

git checkout master
git pull
bundle exec pod trunk push TinkLink.podspec --skip-tests --skip-import-validation --allow-warnings
# Maybe need to wait a bit for the TinkLinkUI cocoapods push, since it take sometime to process the TinkLink pod.
bundle exec pod trunk push TinkLinkUI.podspec --skip-tests --skip-import-validation --allow-warnings

echo "Tink Link public sync created and pushed to cocoapods! 🎉"
