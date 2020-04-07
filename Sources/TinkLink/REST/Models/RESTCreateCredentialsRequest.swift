import Foundation

struct RESTCreateCredentialsRequest: Codable {

    /// The provider (financial institution) that the credentials is connected to.
    var providerName: String
    /// This is a key-value map of &#x60;Field&#x60; name and value found on the &#x60;Provider&#x60; to which the credentials belongs to. This parameter is required when creating credentials.
    var fields: [String:String]
    /// This URI will be used by the ASPSP to pass the authorization code. It corresponds to the redirect/callback URI in OAuth2/OpenId. This parameter is only applicable if you are a TPP.
    var callbackUri: String?
    /// The end user will be redirected to this URI after the authorization code has been delivered.
    var appUri: String?
    /// Defines if the Credentials creation should cause a refresh on aggregated data. Defaults to &#x60;true&#x60;
    var triggerRefresh: Bool?
}
