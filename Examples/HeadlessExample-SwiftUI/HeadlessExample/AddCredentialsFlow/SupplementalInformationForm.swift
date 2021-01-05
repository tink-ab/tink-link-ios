import SwiftUI
import TinkLink

struct SupplementalInformationForm: View {
    private var supplementInformationTask: SupplementInformationTask

    typealias CompletionHandler = (Result<Void, Error>) -> Void
    var onCompletion: CompletionHandler

    init(supplementInformationTask: SupplementInformationTask, onCompletion: @escaping CompletionHandler) {
        self.supplementInformationTask = supplementInformationTask
        self.onCompletion = onCompletion
    }

    var body: some View {
        EmptyView()
    }
}
