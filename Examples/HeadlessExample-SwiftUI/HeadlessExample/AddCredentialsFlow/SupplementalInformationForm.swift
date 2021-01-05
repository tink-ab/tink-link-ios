import SwiftUI
import TinkLink

struct SupplementalInformationForm: View {
    private var supplementInformationTask: SupplementInformationTask

    @State private var form: TinkLink.Form
    @State private var isCancelling = false
    @State private var isLoading = false

    init(supplementInformationTask: SupplementInformationTask) {
        self.supplementInformationTask = supplementInformationTask
        self._form = State(initialValue: TinkLink.Form(supplementInformationTask: supplementInformationTask))
    }

    var body: some View {
        SwiftUI.Form {
            ForEach(Array(zip(form.fields.indices, form.fields)), id: \.1.name) { (fieldIndex, field) in
                FormField(field: $form.fields[fieldIndex])
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isCancelling = true
                    supplementInformationTask.cancel()
                }
                .disabled(isCancelling)
            }
            ToolbarItem {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Submit") {
                        isLoading = true
                        supplementInformationTask.submit(form)
                    }
                    .disabled(!form.areFieldsValid)
                }
            }
        })
    }
}
