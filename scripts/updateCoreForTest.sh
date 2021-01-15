#!/bin/sh

rm -rf ./tink-core-ios-private

git clone -v git@github.com:tink-ab/tink-core-ios-private.git
cd ./tink-core-ios-private
git checkout 1.0
make internal-distribution-framework
rm -rf TinkCore.xcframework
cp -r ./build/TinkCore-internal.xcframework TinkCore.xcframework
cd ..

old_path=".package(name: \"TinkCore\", url: \"https://github.com/tink-ab/tink-core-ios\", .exact(\"1.0.0-rc.2\")),"
new_path=".package(name: \"TinkCore\", path: \"./tink-core-ios-private\"),"
sed -i '' "s|$old_path|$new_path|" Package.swift
