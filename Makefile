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
	swift doc generate Sources/TinkLink/ ../tink-core-ios/Sources/TinkCore/Shared/ ../tink-core-ios/Sources/TinkCore/TinkLink/ \
		--module-name TinkLink \
		--output docs \
		--format html \
		--base-url "https://tink-ab.github.io/tink-link-ios/"

lint:
	swiftlint 2> /dev/null

format:
	swiftformat . 2> /dev/null

test:
	cp ./TinkLinkTester/.TestPodfile ./TinkLinkTester/Podfile
	bundle exec pod install --project-directory="./TinkLinkTester/"
	xcodebuild test \
		-workspace ./TinkLinkTester/TinkLink.xcworkspace \
		-scheme TinkLinkTester \
		-destination 'platform=iOS Simulator,name=iPhone 11 Pro'

build-uikit-example:
	cp ./Examples/PermanentUserExample/.TestPodfile ./Examples/PermanentUserExample/Podfile
	bundle exec pod install --project-directory="./Examples/PermanentUserExample/"
	xcodebuild clean build \
		-workspace Examples/PermanentUserExample/PermanentUserExample.xcworkspace \
		-scheme PermanentUserExample \
		-destination 'generic/platform=iOS Simulator'

build-swiftui-example:
	cp ./Examples/PermanentUserExample-SwiftUI/.TestPodfile ./Examples/PermanentUserExample-SwiftUI/Podfile
	bundle exec pod install --project-directory="./Examples/PermanentUserExample-SwiftUI/"
	xcodebuild clean build \
		-workspace Examples/PermanentUserExample-SwiftUI/PermanentUserExample.xcworkspace \
		-scheme PermanentUserExample \
		-destination 'generic/platform=iOS Simulator'

build-tinklinkui-example:
	cp ./Examples/TinkLinkUIExample/.TestPodfile ./Examples/TinkLinkUIExample/Podfile
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
