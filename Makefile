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
ifeq ($(strip $(shell command -v xcodegen 2> /dev/null)),)
	brew install xcodegen
endif
ifeq ($(strip $(shell command -v carthage 2> /dev/null)),)
	brew install carthage
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
	xcodebuild clean test \
		-project Examples/TinkLinkExample/TinkLinkExample.xcodeproj \
		-scheme TinkLinkExample \
		-destination 'platform=iOS Simulator,name=iPhone 11 Pro'

build-carthage-frameworks:
	# Xcode 12 workaround: https://github.com/Carthage/Carthage/issues/3019#issuecomment-665136323
	export XCODE_XCCONFIG_FILE=$(PWD)/carthage.xcconfig
	echo $(XCODE_XCCONFIG_FILE)
	carthage bootstrap --platform iOS --no-use-binaries
	xcodegen generate
	carthage build --platform iOS --no-skip-current

ui-test:
	carthage bootstrap --platform iOS --no-use-binaries
	xcodegen generate
	xcodebuild test \
		-project TinkLink.xcodeproj \
		-scheme TinkLinkUIUITestsHost_iOS \
		-destination 'platform=iOS Simulator,name=iPhone 11 Pro'

build-uikit-example:
	xcodebuild clean

	xcodebuild -resolvePackageDependencies \
		-project Examples/HeadlessExample/HeadlessExample.xcodeproj \
		-clonedSourcePackagesDirPath $(TMPDIR)spm/

	xcodebuild build \
		-project Examples/HeadlessExample/HeadlessExample.xcodeproj \
		-scheme HeadlessExample \
		-destination 'generic/platform=iOS Simulator' \
		-clonedSourcePackagesDirPath $(TMPDIR)spm/

build-swiftui-example:
	xcodebuild clean

	xcodebuild -resolvePackageDependencies \
		-project Examples/HeadlessExample-SwiftUI/HeadlessExample.xcodeproj \
		-clonedSourcePackagesDirPath $(TMPDIR)spm/

	xcodebuild build \
		-project Examples/HeadlessExample-SwiftUI/HeadlessExample.xcodeproj \
		-scheme HeadlessExample \
		-destination 'generic/platform=iOS Simulator' \
		-clonedSourcePackagesDirPath $(TMPDIR)spm/

build-tinklinkui-example:
	xcodebuild clean

	xcodebuild -resolvePackageDependencies \
		-project Examples/TinkLinkExample/TinkLinkExample.xcodeproj \
		-clonedSourcePackagesDirPath $(TMPDIR)spm/

	xcodebuild build \
		-project Examples/TinkLinkExample/TinkLinkExample.xcodeproj \
		-scheme TinkLinkExample \
		-destination 'platform=iOS Simulator,name=iPhone 11 Pro' \
		-clonedSourcePackagesDirPath $(TMPDIR)spm/

translations:
	rm -rf Sources/TinkLinkUI/Translations.bundle/Base.lproj/
	mkdir Sources/TinkLinkUI/Translations.bundle/Base.lproj/
	find Sources/TinkLinkUI/ -name \*.swift | xargs genstrings -o Sources/TinkLinkUI/Translations.bundle/Base.lproj

carthage-project:
	xcodegen generate

clean: 
	rm -rf ./docs

release: format lint

.PHONY: all docs
