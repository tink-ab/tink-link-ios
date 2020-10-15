#!/bin/sh
echo Enter new pod spec version:
read newVersion

if [[ $newVersion =~ ^([0-9]{1,2}\.){2}[0-9]{1,10}$ ]]; then
git checkout master
git pull
git checkout -b rc-$newVersion
else
  echo "$newVersion is not in the right format."
  exit
fi

sed -i "" 's/  spec.version      = "[0-9]\.[0-9]\.[0-9]"/  spec.version      = "'$newVersion'"/' TinkLink.podspec
sed -i "" 's/  spec.version      = "[0-9]\.[0-9]\.[0-9]"/  spec.version      = "'$newVersion'"/' TinkLinkUI.podspec
sed -i "" 's/      MARKETING_VERSION: [0-9]\.[0-9]\.[0-9]/      MARKETING_VERSION: '$newVersion'/' project.yml

git commit -am"Update version"

make docs
git commit -am"Update docs"

make format
git commit -am"Format project"

make carthage-project
git commit -am"Update Xcode project"

xcodebuild -project TinkCore.xcodeproj -target "TinkCore_iOS" build | xcpretty
swift test

gh pr create --repo tink-ab/tink-link-ios-private -t "rc:$newVersion" -b "Release candidate for Tink Link pre release." -r tink-ab/ios-maintainer

echo Release candidate PR has been created! 🎉
