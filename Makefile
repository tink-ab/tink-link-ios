VERSION = $(shell git tag | sort -V | tail -1)

all:

bootstrap:
ifeq ($(strip $(shell command -v brew 2> /dev/null)),)
	$(error "`brew` is not available, please install homebrew")
endif
ifeq ($(strip $(shell command -v gem 2> /dev/null)),)
	$(error "`gem` is not available, please install ruby")
endif
ifeq ($(strip $(shell command -v swiftlint 2> /dev/null)),)
	brew install swiftlint
endif
ifeq ($(strip $(shell command -v swiftformat 2> /dev/null)),)
	brew install swiftformat
endif
ifeq ($(strip $(shell command -v swift doc 2> /dev/null)),)
	brew install swiftdocorg/formulae/swift-doc
endif
ifeq ($(strip $(shell command -v bundle 2> /dev/null)),)
	gem install bundler
endif
	bundle install

docs:
	swift doc generate Sources/TinkLink/ ../tink-core-ios/Sources/TinkCore/Shared/ ../tink-core-ios/Sources/TinkCore/AIS/ ../tink-core-ios/Sources/TinkCore/PIS/ \
		--module-name TinkLink \
		--output docs \
		--format html \
		--base-url "https://tink-ab.github.io/tink-link-ios/"
	swift doc generate Sources/TinkLinkUI/ \
		--module-name TinkLinkUI \
		--output docs/tinklinkui \
		--format html \
		--base-url "https://tink-ab.github.io/tink-link-ios/tinklinkui/"

lint:
	swiftlint 2> /dev/null

format:
	swiftformat . 2> /dev/null

test:
	bundle exec pod install --project-directory="./TinkLinkTester/"
	xcodebuild test \
		-workspace ./TinkLinkTester/TinkLink.xcworkspace \
		-scheme TinkLinkTester \
		-destination 'platform=iOS Simulator,name=iPhone 11 Pro'

build-uikit-example:
	xcodebuild clean build \
		-workspace Examples/PermanentUserExample/PermanentUserExample.xcworkspace \
		-scheme PermanentUserExample \
		-destination 'generic/platform=iOS Simulator'

build-swiftui-example:
	xcodebuild clean build \
		-workspace Examples/PermanentUserExample-SwiftUI/PermanentUserExample.xcworkspace \
		-scheme PermanentUserExample \
		-destination 'generic/platform=iOS Simulator'

build-tinklinkui-example:
	bundle exec pod install --project-directory="./Examples/TinkLinkUIExample/"
	xcodebuild clean build \
		-workspace Examples/TinkLinkUIExample/TinkLinkUIExample.xcworkspace \
		-scheme TinkLinkUIExample \
		-destination 'generic/platform=iOS Simulator'

generate-translations:
	find Sources/TinkLinkUI/ -name \*.swift | xargs genstrings -o Sources/TinkLinkUI/Translations/Base.lproj

clean: 
	rm -rf ./docs

release: format lint

.PHONY: all docs
