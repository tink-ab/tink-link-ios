@testable import TinkLink
import XCTest

class SupplementalInfoFieldTests: XCTestCase {
    func testSupplementalInfoFieldValidation() {
        let firstFieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Security Code",
            hint: "",
            maxLength: nil,
            minLength: nil,
            isMasked: false,
            isNumeric: true,
            isImmutable: true,
            isOptional: false,
            name: "loginDescriptionField",
            initialValue: "7483",
            pattern: "",
            patternError: "",
            helpText: "Login using your Card Reader. Enter the security code and press Ok. Provide the given return code in the input field to continue \n"
        )
        let secondFieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Input Code",
            hint: "",
            maxLength: nil,
            minLength: nil,
            isMasked: false,
            isNumeric: true,
            isImmutable: false,
            isOptional: false,
            name: "loginInputField",
            initialValue: "7483",
            pattern: "",
            patternError: "",
            helpText: ""
        )
        let supplementalInfoCredential = Credentials(id: .init(stringLiteral: "test-credential"), providerID: "test-multi-supplemental", kind: .password, status: .created, statusPayload: "", statusUpdated: nil, updated: nil, fields: ["username" : "tink-test"], supplementalInformationFields: [firstFieldSpecification, secondFieldSpecification], thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)

        var form = Form(fieldSpecifications: supplementalInfoCredential.supplementalInformationFields)
        
        let editableForms = form.fields.filter { $0.attributes.isEditable }
        XCTAssertEqual(editableForms.count, 1)

        let edtiableForm = editableForms.first!
        do {
            try form.validateFields()
        } catch let error as Form.ValidationError {
            XCTAssertEqual(error.errors.count, 1)
            let fieldError = error.errors.first
            if case .requiredFieldEmptyValue(let fieldName) = fieldError {
                XCTAssertEqual(fieldName, edtiableForm.name)
            } else {
                XCTFail("The Field error should be requiredFieldEmptyValue")
            }
        } catch {
            XCTFail("Should only have Form ValidationError")
        }

        form.fields[1].text = "1234"
        do {
            try form.validateFields()
        } catch {
            XCTFail("Should not have ValidationError")
        }
    }
}
