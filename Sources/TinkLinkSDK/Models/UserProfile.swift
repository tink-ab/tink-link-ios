import Foundation

struct UserProfile {
    public var username: String
    public var nationalID: String
}

extension UserProfile {
    init(grpcUserProfile: GRPCUserProfile) {
        username = grpcUserProfile.username
        nationalID = grpcUserProfile.nationalID
    }
}
