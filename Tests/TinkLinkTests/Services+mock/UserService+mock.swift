import Foundation
@testable import TinkLink

class MockedUserService: UserService {
    func userProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}
