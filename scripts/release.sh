#!/bin/sh
echo "Enter the release version:"
read version

if [[ $version =~ ^([0-9]{1,2}\.){2}[0-9]{1,10}$ ]]; then
	git checkout master
	git pull
else
  	echo "Version $version is not in the right format."
  	exit
fi

git checkout -b release-changes-$version

# Squash commits
git reset --soft $(git describe --abbrev=0 --tags)
git commit -am "Release version $version"

git fetch --all
# Incase there is no `public-master` branch, note that this assumes the public repo is named as `public` locally
git checkout --track -b public-master public/master
git checkout public-master

git checkout -b rc-$version
git cherry-pick -b release-changes-$version

gh pr create --repo tink-ab/tink-link-ios -t "Tink Link $version release" -b "Release candidate for Tink Link public release." -r tink-ab/ios-maintainer

echo "PR created, wait for approval and draft a new release changelog! 🎉"
