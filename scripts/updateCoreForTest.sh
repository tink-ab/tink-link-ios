#!/bin/sh

rm -rf ./tink-core-ios-private

git clone -v git@github.com:tink-ab/tink-core-ios-private.git
cd ./tink-core-ios-private
git checkout tags/1.0.0
make internal-distribution-framework
rm -rf TinkCore.xcframework
cp -r ./build/TinkCore-internal.xcframework TinkCore.xcframework
sed -i '' "s/url: \".*\.xcframework\.zip\", checksum: \".*\"/path: \"TinkCore\.xcframework\"/" Package.swift
cd ..

old_path=".package(name: \"TinkCore\", url: \"https://github.com/tink-ab/tink-core-ios\", upToNextMajor(from:\"1.0.0\")),"
new_path=".package(name: \"TinkCore\", path: \"./tink-core-ios-private\"),"
sed -i '' "s|$old_path|$new_path|" Package.swift


sed -i '' '108d' project.yml
old_core_path="url: https://github.com/tink-ab/tink-core-ios"
new_core_path="path: ./tink-core-ios-private"
sed -i '' "s|$old_core_path|$new_core_path|" project.yml
