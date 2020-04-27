import Foundation

struct RESTCallbackRelayedRequest: Codable {
    /// The state from the received callback from the ASPSP. Used by Tink to connect the incoming callback to the correct session.
    var state: String
    /// The post parameters from the received callback from the ASPSP. Contains the parameters necessary for the integration to continue the communication with the ASPSP.
    var parameters: [String:String]
}
