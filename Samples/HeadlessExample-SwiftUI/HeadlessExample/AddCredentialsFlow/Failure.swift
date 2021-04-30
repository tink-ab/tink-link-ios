import Foundation

struct Failure: Identifiable {
    let id = UUID()
    let error: Error
}
