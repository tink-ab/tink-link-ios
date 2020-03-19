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
ifeq ($(strip $(shell command -v protoc 2> /dev/null)),)
	$(error "`protoc` is not available, please install Google's protoc compiler")
endif
ifeq ($(strip $(shell command -v bundle 2> /dev/null)),)
	gem install bundler
endif
	bundle install > /dev/null

CFLAGS = -Xcc -ISources/BoringSSL/include

plugins:
	mkdir -p ./GRPC/plugins
	swift build $(CFLAGS) --product protoc-gen-swift --static-swift-stdlib -c release
	swift build $(CFLAGS) --product protoc-gen-grpc-swift --static-swift-stdlib -c release
	cp .build/release/protoc-gen-swift ./GRPC/plugins/
	cp .build/release/protoc-gen-grpc-swift ./GRPC/plugins/

generate:
	mkdir -p ./Sources/TinkLink/GRPC/
	protoc \
		--proto_path=./GRPC/proto \
		--proto_path=./GRPC/third-party \
		./GRPC/proto/*.proto \
		--swift_out=./Sources/TinkLink/GRPC/ \
		--grpc-swift_out=./Sources/TinkLink/GRPC/ \
		--swift_opt=Visibility=Internal \
		--grpc-swift_opt=Visibility=Internal,Client=true,Server=false \
		--plugin=protoc-gen-swift=./GRPC/plugins/protoc-gen-swift \
		--plugin=protoc-gen-grpc-swift=./GRPC/plugins/protoc-gen-grpc-swift

docs:
	bundle exec jazzy \
		--clean \
		--author Tink \
		--author_url https://tink.com \
		--github_url https://github.com/tink-ab/tink-link-ios \
		--github-file-prefix https://github.com/tink-ab/tink-link-ios/tree/v$(VERSION) \
		--module-version $(VERSION) \
		--module TinkLink \
		--swift-build-tool spm \
		--build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5 \
		--output docs

lint:
	swiftlint 2> /dev/null

format:
	swiftformat . 2> /dev/null

test:
	swift test 

clean: 
	rm -rf ./GRPC/plugins/
	rm -rf ./Sources/TinkLinkSDK/GRPC/
	rm -rf ./docs

release: format lint

.PHONY: all docs
