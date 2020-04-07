import Foundation

extension UserProfile {
    init(restUser: RESTUser) {
        username = restUser.username ?? ""
        nationalID = restUser.nationalId ?? ""
    }
}
