@testable import TinkLink
import XCTest

class FormTests: XCTestCase {
    func testFieldValidation() throws {
        let fieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Social security number",
            hint: "YYYYMMDDNNNN",
            maxLength: 12,
            minLength: 12,
            isMasked: false,
            isNumeric: true,
            isImmutable: false,
            isOptional: false,
            name: "username",
            initialValue: "",
            pattern: "(19|20)[0-9]{10}",
            patternError: "Please enter a valid social security number.",
            helpText: ""
        )

        var field = Form.Field(fieldSpecification: fieldSpecification)

        do {
            try field.validate()
        } catch Form.Field.ValidationError.requiredFieldEmptyValue(let fieldName) {
            XCTAssertEqual(fieldName, "username")
        } catch {
            XCTFail()
        }

        field.text = "1212121212"

        do {
            try field.validate()
        } catch Form.Field.ValidationError.minLengthLimit(let fieldName, let minLength) {
            XCTAssertEqual(fieldName, "username")
            XCTAssertEqual(minLength, 12)
        } catch {
            XCTFail()
        }

        field.text = "121212121212"

        do {
            try field.validate()
        } catch Form.Field.ValidationError.invalid(let fieldName, let reason) {
            XCTAssertEqual(fieldName, "username")
            XCTAssertEqual(reason, "Please enter a valid social security number.")
        } catch {
            XCTFail()
        }

        field.text = "201212121212"

        try field.validate()
    }

    func testUsernameAndPasswordFieldValidation() throws {
        let usernameFieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Username",
            hint: "",
            maxLength: nil,
            minLength: nil,
            isMasked: false,
            isNumeric: false,
            isImmutable: false,
            isOptional: false,
            name: "username",
            initialValue: "",
            pattern: "",
            patternError: "",
            helpText: ""
        )
        let passwordFieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Password",
            hint: "",
            maxLength: nil,
            minLength: nil,
            isMasked: true,
            isNumeric: false,
            isImmutable: false,
            isOptional: false,
            name: "password",
            initialValue: "",
            pattern: "",
            patternError: "",
            helpText: ""
        )

        var form = Form(fieldSpecifications: [usernameFieldSpecification, passwordFieldSpecification])

        do {
            try form.validateFields()
        } catch let formValidationError as Form.ValidationError {
            XCTAssertEqual(formValidationError.errors.count, 2)
            if case .requiredFieldEmptyValue(let fieldName) = formValidationError[fieldName: "username"] {
                XCTAssertEqual(fieldName, "username")
            } else {
                XCTFail()
            }
            if case .requiredFieldEmptyValue(let fieldName) = formValidationError[fieldName: "password"] {
                XCTAssertEqual(fieldName, "password")
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }

        form.fields[name: "username"]!.text = "12345678"

        do {
            try form.validateFields()
        } catch let error as Form.ValidationError {
            XCTAssertEqual(error.errors.count, 1)
            if case .requiredFieldEmptyValue(let fieldName) = error[fieldName: "password"] {
                XCTAssertEqual(fieldName, "password")
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }

        form.fields[name: "password"]!.text = "abcd"

        try form.validateFields()
    }

    func testServiceCodeFieldValidation() throws {
        let fieldSpecification = Provider.FieldSpecification(
            fieldDescription: "Service code",
            hint: "NNNN",
            maxLength: 4,
            minLength: 4,
            isMasked: true,
            isNumeric: true,
            isImmutable: false,
            isOptional: false,
            name: "password",
            initialValue: "",
            pattern: "([0-9]{4})",
            patternError: "Please enter four digits.",
            helpText: ""
        )

        var field = Form.Field(fieldSpecification: fieldSpecification)

        do {
            try field.validate()
        } catch Form.Field.ValidationError.requiredFieldEmptyValue(let fieldName) {
            XCTAssertEqual(fieldName, "password")
        } catch {
            XCTFail()
        }

        field.text = "12345"

        do {
            try field.validate()
        } catch Form.Field.ValidationError.maxLengthLimit(let fieldName, let maxLength) {
            XCTAssertEqual(fieldName, "password")
            XCTAssertEqual(maxLength, 4)
        } catch {
            XCTFail()
        }

        field.text = "ABCD"

        do {
            try field.validate()
        } catch Form.Field.ValidationError.invalid(let fieldName, let reason) {
            XCTAssertEqual(fieldName, "password")
            XCTAssertEqual(reason, "Please enter four digits.")
        } catch {
            XCTFail()
        }

        field.text = "1234"

        try field.validate()
    }
}
