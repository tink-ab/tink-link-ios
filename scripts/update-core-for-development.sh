#!/bin/sh

# Use local core dependency
old_path=".package(name: \"TinkCore\", url: \"https://github.com/tink-ab/tink-core-ios\", .upToNextMinor(from: \"0.7.0\")),"
new_path=".package(name: \"TinkCore\", path: \"../tink-core-ios\"),"
sed -i '' "s|$old_path|$new_path|" Package.swift

# Use source files for core package
cd ../tink-core-ios

sed -i '' '20,21d' Package.swift
sed -i '' 's/.binaryTarget(/.target(name: \"TinkCore\", exclude: \[\"Info.plist\"\]/' Package.swift

cd ../tink-link-ios
