import SWXMLHash
import XCTest
@testable import XMLDatabase

class XMLAddressMapperTests: XCTestCase {
    
    
    // MARK: valid properties
    
    func testImportAddressWithValidProperties() {
        let xmlContent = "<address id=\"1\"><city>Berlin</city><street>Spandauer Straße</street></address>"
        let xmlElementParsed: XMLIndexer = SWXMLHash.parse(xmlContent)["address"].all[0]
        do {
            let address = try XMLAddressMapper.toObject(element: xmlElementParsed)
            
            XCTAssertEqual(address.id, 1)
            XCTAssertEqual(address.city, "Berlin")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    // MARK: property id tests
    
    func testImportAddressWithInvalidId() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // id exists but is invalid
        xmlContent = "<address id=\"0\"><city>Berlin</city><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed)) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 0)
        }
        
        // id does not exist
        xmlContent = "<address><city>Berlin</city><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        print(xmlElementParsed.element!.name)
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed)) { error in
            guard case XMLObjectsError.requiredAttributeIsMissing(let element, let attribute, let className) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "address")
            XCTAssertEqual(attribute, "id")
            XCTAssertEqual(className, "XMLAddressMapper")
        }
    }
    
    
    // MARK: property gender tests
    
    func testImportAddressWithInvalidCity() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // city exists but is invalid
        xmlContent = "<address id=\"1\"><city>A</city><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed)) { error in
            guard case AddressError.invalidCity(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, "A")
        }
        
        // city does not exist
        xmlContent = "<address id=\"1\"><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed)) { error in
            guard case XMLObjectsError.requiredElementIsMissing(let element, let className) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "city")
            XCTAssertEqual(className, "XMLAddressMapper")
        }
    }
}

extension XMLAddressMapperTests {
    static var allTests = [
        ("testImportAddressWithValidProperties", testImportAddressWithValidProperties),
        ("testImportAddressWithInvalidId", testImportAddressWithInvalidId),
        ("testImportAddressWithInvalidCity", testImportAddressWithInvalidCity)
    ]
}

