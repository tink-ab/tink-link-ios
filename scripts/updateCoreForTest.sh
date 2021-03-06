#!/bin/sh

rm -rf ./tink-core-ios-private

git clone -v git@github.com:tink-ab/tink-core-ios-private.git
cd ./tink-core-ios-private
git checkout 0.7.0
make internal-distribution-framework
rm -rf TinkCore.xcframework
cp -r ./build/TinkCore-internal.xcframework TinkCore.xcframework
sed -i '' "s/url: \".*\.xcframework\.zip\", checksum: \".*\"/path: \"TinkCore\.xcframework\"/" Package.swift
cd ..

old_path=".package(name: \"TinkCore\", url: \"https://github.com/tink-ab/tink-core-ios\", .upToNextMinor(from: \"0.7.0\")),"
new_path=".package(name: \"TinkCore\", path: \"./tink-core-ios-private\"),"
sed -i '' "s|$old_path|$new_path|" Package.swift
