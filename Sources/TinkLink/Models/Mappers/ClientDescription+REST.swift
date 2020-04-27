import Foundation

extension ClientDescription {
    init(restOAuth2Description description: RESTDescribeOAuth2ClientResponse) {
        self.iconURL = URL(string: description.clientIconUrl)
        self.name = description.clientName
        self.url = URL(string: description.clientUrl)
        self.isEmbeddedAllowed = description.embeddedAllowed
        self.scopes = description.scopesDescriptionsList.map(ScopeDescription.init)
        self.isVerified = description.verified
        self.isAggregator = description.aggregator
    }
}
