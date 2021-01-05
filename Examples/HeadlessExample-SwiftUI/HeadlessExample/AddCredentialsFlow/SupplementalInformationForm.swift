import SwiftUI
import TinkLink

struct SupplementalInformationForm: View {
    private var supplementInformationTask: SupplementInformationTask

    @State private var form: TinkLink.Form

    typealias CompletionHandler = (Result<Void, Error>) -> Void
    var onCompletion: CompletionHandler

    init(supplementInformationTask: SupplementInformationTask, onCompletion: @escaping CompletionHandler) {
        self.supplementInformationTask = supplementInformationTask
        self.onCompletion = onCompletion
        self._form = State(initialValue: TinkLink.Form(supplementInformationTask: supplementInformationTask))
    }

    var body: some View {
        SwiftUI.Form {
            ForEach(Array(zip(form.fields.indices, form.fields)), id: \.1.name) { (fieldIndex, field) in
                FormField(field: $form.fields[fieldIndex])
            }
        }
    }
}
