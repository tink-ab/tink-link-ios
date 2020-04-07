extension ScopeDescription {
    init(restOAuth2ScopeDescription: RESTDescribeOAuth2ClientResponse.RESTScopeDescription) {
        self.title = restOAuth2ScopeDescription.title
        self.description = restOAuth2ScopeDescription.description
    }
}
