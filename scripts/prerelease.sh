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

sed -i "" 's/  spec.version      = "[0-9]*\.[0-9]*\.[0-9]*"/  spec.version      = "'$newVersion'"/' TinkLink.podspec
sed -i "" 's/  spec.version      = "[0-9]*\.[0-9]*\.[0-9]*"/  spec.version      = "'$newVersion'"/' TinkLinkUI.podspec
sed -i "" 's/  spec.dependency "TinkLink", "[0-9]*\.[0-9]*\.[0-9]*"/  spec.dependency "TinkLink", "'$newVersion'"/' TinkLinkUI.podspec
sed -i "" 's/      MARKETING_VERSION: [0-9]*\.[0-9]*\.[0-9]*/      MARKETING_VERSION: '$newVersion'/' project.yml

git commit -am"Update version"

make docs
make ui-docs
git add .
git commit -m"Update docs"

make format
git commit -am"Format project"

make carthage-project
git commit -am"Update Xcode project"

make module-interfaces
git commit -am"Update module interfaces"

gh pr create --repo tink-ab/tink-link-ios-private -t "rc:$newVersion" -b "Release candidate for Tink Link pre release." -r tink-ab/ios-maintainer

echo Release candidate PR has been created! 🎉
