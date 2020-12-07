@testable import TinkCore
@testable import TinkLink
import XCTest

class FormTests: XCTestCase {
    func testFieldValidation() throws {
        let fieldSpecification = Provider.Field(
            description: "Social security number",
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

        var field = Form.Field(field: fieldSpecification)

        do {
            try field.validate()
        } catch let error as Form.Field.ValidationError where error.code == .requiredFieldEmptyValue {
            XCTAssertEqual(error.fieldName, "username")
        } catch {
            XCTFail()
        }

        field.text = "1212121212"

        do {
            try field.validate()
        } catch let error as Form.Field.ValidationError where error.code == .minLengthLimit {
            XCTAssertEqual(error.fieldName, "username")
            XCTAssertEqual(error.minLength, 12)
        } catch {
            XCTFail()
        }

        field.text = "121212121212"

        do {
            try field.validate()
        } catch let error as Form.Field.ValidationError where error.code == .invalid {
            XCTAssertEqual(error.fieldName, "username")
            XCTAssertEqual(error.reason, "Please enter a valid social security number.")
        } catch {
            XCTFail()
        }

        field.text = "201212121212"

        try field.validate()
    }

    func testUsernameAndPasswordFieldValidation() throws {
        let usernameFieldSpecification = Provider.Field(
            description: "Username",
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
        let passwordFieldSpecification = Provider.Field(
            description: "Password",
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

        var form = Form(fields: [usernameFieldSpecification, passwordFieldSpecification])

        do {
            try form.validateFields()
        } catch let formValidationError as Form.ValidationError {
            XCTAssertEqual(formValidationError.errors.count, 2)
            if let fieldError = formValidationError[fieldName: "username"], case .requiredFieldEmptyValue = fieldError {
                XCTAssertEqual(fieldError.fieldName, "username")
            } else {
                XCTFail()
            }
            if let fieldError = formValidationError[fieldName: "password"], case .requiredFieldEmptyValue = fieldError {
                XCTAssertEqual(fieldError.fieldName, "password")
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
            if let fieldError = error[fieldName: "password"], case .requiredFieldEmptyValue = fieldError {
                XCTAssertEqual(fieldError.fieldName, "password")
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
        let fieldSpecification = Provider.Field(
            description: "Service code",
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

        var field = Form.Field(field: fieldSpecification)

        do {
            try field.validate()
        } catch let error as Form.Field.ValidationError where error.code == .requiredFieldEmptyValue {
            XCTAssertEqual(error.fieldName, "password")
        } catch {
            XCTFail()
        }

        field.text = "12345"

        do {
            try field.validate()
        } catch let error as Form.Field.ValidationError where error.code == .maxLengthLimit {
            XCTAssertEqual(error.fieldName, "password")
            XCTAssertEqual(error.maxLength, 4)
        } catch {
            XCTFail()
        }

        field.text = "ABCD"

        do {
            try field.validate()
        } catch let error as Form.Field.ValidationError where error.code == .invalid {
            XCTAssertEqual(error.fieldName, "password")
            XCTAssertEqual(error.reason, "Please enter four digits.")
        } catch {
            XCTFail()
        }

        field.text = "1234"

        try field.validate()
    }
}
