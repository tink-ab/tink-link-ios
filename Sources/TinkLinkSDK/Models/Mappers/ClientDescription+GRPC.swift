import Foundation

extension ClientDescription {
    init(grpcDescribeOAuth2ClientResponse: GRPCDescribeOAuth2ClientResponse) {
        self.iconURL = URL(string: grpcDescribeOAuth2ClientResponse.clientIconURL)
        self.name = grpcDescribeOAuth2ClientResponse.clientName
        self.url = URL(string: grpcDescribeOAuth2ClientResponse.clientURL)
        self.isEmbeddedAllowed = grpcDescribeOAuth2ClientResponse.embeddedAllowed
        self.scopes = grpcDescribeOAuth2ClientResponse.scopes.map(ScopeDescription.init(grpcOAuth2ScopeDescription:))
        self.isVerified = grpcDescribeOAuth2ClientResponse.verified
        self.isAggregator = grpcDescribeOAuth2ClientResponse.aggregator
    }
}
