import XCTest
@testable import XMLDatabase

class XMLObjectTests: XCTestCase {
    
    
    // MARK: - Init tests
    
    func testValidProperties() {
        XCTAssertNoThrow(try XMLObject(id: 1))
        XCTAssertNoThrow(try XMLObject(id: 2))
        XCTAssertNoThrow(try XMLObject(id: 3))
        XCTAssertNoThrow(try XMLObject(id: 4))
        XCTAssertNoThrow(try XMLObject(id: 5))
        XCTAssertNoThrow(try XMLObject(id: 10))
        XCTAssertNoThrow(try XMLObject(id: 100000000))
        XCTAssertNoThrow(try XMLObject(id: 100000000000))
    }
    
    func testPropertiesAreSet() {
        var object: XMLObject?
        XCTAssertNoThrow(object = try XMLObject(id: 1))
        XCTAssertEqual(object!.id, 1)
    }
    
    func testIdIsNull() {
        // id is: 0
        XCTAssertThrowsError(try XMLObject(id: 0)) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 0)
        }
    }
    
    
    
    
    // MARK: - Method `isValid(id:)` tests
    
    func testIsValidWithNegativeId() {
        // id is: -1
        XCTAssertFalse(XMLObject.isValid(id: -1))
        
        // id is: -10
        XCTAssertThrowsError(try XMLObject(id: -10)) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, -10)
        }
        
        // id is: -112312314234
        XCTAssertThrowsError(try XMLObject(id: -112312314234)) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, -112312314234)
        }
    }
}

extension XMLObjectTests {
    static var allTests = [
        ("testValidProperties", testValidProperties),
        ("testPropertiesAreSet", testPropertiesAreSet),
        ("testIdIsNull", testIdIsNull),
        ("testIsValidWithNegativeId", testIsValidWithNegativeId)
    ]
}
