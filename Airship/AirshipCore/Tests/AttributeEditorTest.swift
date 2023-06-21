/* Copyright Airship and Contributors */

import XCTest

@testable import AirshipCore

class AttributeEditorTest: XCTestCase {

    var date: UATestDate!

    override func setUp() {
        self.date = UATestDate()
    }

    func testEditor() throws {
        var out: [AttributeUpdate]?

        let editor = AttributesEditor(date: self.date) { updates in
            out = updates
        }

        editor.remove("bar")
        editor.set(string: "neat", attribute: "bar")

        editor.set(int: 10, attribute: "foo")
        editor.remove("foo")

        let applyDate = Date(timeIntervalSince1970: 1)
        self.date.dateOverride = applyDate
        editor.apply()

        XCTAssertEqual(2, out?.count)

        let foo = out?.first { $0.attribute == "foo" }
        let bar = out?.first { $0.attribute == "bar" }

        XCTAssertEqual(AttributeUpdateType.remove, foo?.type)
        XCTAssertEqual(applyDate, foo?.date)
        XCTAssertNil(foo?.jsonValue?.unWrap())

        XCTAssertEqual(AttributeUpdateType.set, bar?.type)
        XCTAssertEqual("neat", bar?.jsonValue?.unWrap() as? String)
        XCTAssertEqual(applyDate, foo?.date)
    }

    func testDateAttribute() throws {
        var out: [AttributeUpdate]?

        let editor = AttributesEditor(date: self.date) { updates in
            out = updates
        }

        editor.set(date: Date(timeIntervalSince1970: 10000), attribute: "date")
        let applyDate = Date(timeIntervalSince1970: 1)
        self.date.dateOverride = applyDate
        editor.apply()

        let attribute = out?.first

        XCTAssertEqual(AttributeUpdateType.set, attribute?.type)
        XCTAssertEqual(applyDate, attribute?.date)
        XCTAssertEqual(
            "1970-01-01T02:46:40",
            attribute?.jsonValue?.unWrap() as! String
        )
    }

    func testEditorNoAttributes() throws {
        var out: [AttributeUpdate]?

        let editor = AttributesEditor(date: self.date) { updates in
            out = updates
        }

        editor.apply()

        XCTAssertEqual(0, out?.count)
    }

    func testEditorEmptyString() throws {
        var out: [AttributeUpdate]?
        let editor = AttributesEditor(date: self.date) { updates in
            out = updates
        }
        editor.set(string: "", attribute: "cool")
        editor.set(string: "cool", attribute: "")
        editor.apply()

        XCTAssertEqual(0, out?.count)
    }

    func testEditorInvalidAttirbutes() throws {
        let validString = String(repeating: "a", count: 1024)
        let invalidString = String(repeating: "a", count: 1025)

        var out: [AttributeUpdate]?
        let editor = AttributesEditor(date: self.date) { updates in
            out = updates
        }
        editor.set(string: validString, attribute: validString)
        editor.set(string: invalidString, attribute: validString)
        editor.set(string: validString, attribute: invalidString)
        editor.apply()

        XCTAssertEqual(1, out?.count)
        XCTAssertEqual(AttributeUpdateType.set, out?.first?.type)
        XCTAssertEqual(validString, out?.first?.jsonValue?.unWrap() as? String)
        XCTAssertEqual(validString, out?.first?.attribute)
    }

}
