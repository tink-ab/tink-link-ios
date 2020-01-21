# gRPC

## Requirements
1. Download and install the latest Protobuf compiler here: [Protobuf Releases](https://github.com/protocolbuffers/protobuf/releases)
2. Run `make plugins`

## Update TinkGRPC
1. Replace `.proto` files in `./GRPC/proto` directory with latest files from [Tink gRPC](https://github.com/tink-ab/tink-grpc).
2. Run `make generate` to generate new Swift code.
