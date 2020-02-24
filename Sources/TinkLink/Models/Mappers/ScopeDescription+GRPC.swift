extension ScopeDescription {
    init(grpcOAuth2ScopeDescription: GRPCOAuth2ScopeDescription) {
        self.title = grpcOAuth2ScopeDescription.title
        self.description = grpcOAuth2ScopeDescription.description_p
    }
}
