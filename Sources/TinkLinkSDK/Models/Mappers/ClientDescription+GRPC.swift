import Foundation

extension ClientDescription {
    init(grpcDescribeOAuth2ClientResponse: GRPCDescribeOAuth2ClientResponse) {
        self.iconURL = URL(string: grpcDescribeOAuth2ClientResponse.clientIconURL)
        self.name = grpcDescribeOAuth2ClientResponse.clientName
        self.url = URL(string: grpcDescribeOAuth2ClientResponse.clientURL)
        self.embeddedAllowed = grpcDescribeOAuth2ClientResponse.embeddedAllowed
        self.scopes = grpcDescribeOAuth2ClientResponse.scopes.map(ScopeDescription.init(grpcOAuth2ScopeDescription:))
        self.verified = grpcDescribeOAuth2ClientResponse.verified
        self.aggregator = grpcDescribeOAuth2ClientResponse.aggregator
    }
}
