import Foundation
import XCTest
import SWXMLHash
@testable import XMLDatabase

class XMLAddressMapperTests: XCTestCase {
    private let randomURL = Bundle.init(for: XMLAddressMapperTests.self).resourceURL!
    
    // MARK: Import tests
    
    func testImportAddressWithValidProperties() {
        let xmlContent = "<address id=\"1\"><city>Berlin</city><street>Spandauer Straße</street></address>"
        let xmlElementParsed: XMLIndexer = SWXMLHash.parse(xmlContent)["address"].all[0]
        
        do {
            let address = try XMLAddressMapper.toObject(element: xmlElementParsed, at: randomURL)
            
            XCTAssertEqual(address.id, 1)
            XCTAssertEqual(address.city, "Berlin")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testImportAddressWithInvalidId() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // id exists but is invalid
        xmlContent = "<address id=\"0\"><city>Berlin</city><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 0)
        }
        
        // id does not exist
        xmlContent = "<address><city>Berlin</city><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectsError.requiredAttributeIsMissing(let element, let attribute, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "address")
            XCTAssertEqual(attribute, "id")
            XCTAssertEqual(url.path, randomURL.path)
        }
    }
    
    func testImportAddressWithInvalidCity() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // city exists but is invalid
        xmlContent = "<address id=\"1\"><city>A</city><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed, at: randomURL)) { error in
            guard case AddressError.invalidCity(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, "A")
        }
        
        // city does not exist
        xmlContent = "<address id=\"1\"><street>Spandauer Straße</street></address>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["address"].all[0]
        
        XCTAssertThrowsError(try XMLAddressMapper.toObject(element: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectsError.requiredElementIsMissing(let element, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "city")
            XCTAssertEqual(url.path, randomURL.path)
        }
    }
    
    
    // MARK: Export tests
    
    func testExportAddress() {
        var address: Address?
        var xmlElement: Foundation.XMLElement?
        let xmlDocument = XMLDocument(rootElement: Foundation.XMLElement(name: "addresses"))
        
        // add first address
        XCTAssertNoThrow(address = try Address(id: 1, city: "Berlin", street: "Spandauer Straße"))
        xmlElement = XMLAddressMapper.toXML(object: address!)
        xmlDocument.rootElement()!.addChild(xmlElement!)
        
        // add second address
        XCTAssertNoThrow(address = try Address(id: 2, city: "Cologne", street: "Ehrenstraße"))
        xmlElement = XMLAddressMapper.toXML(object: address!)
        xmlDocument.rootElement()!.addChild(xmlElement!)
        
        XCTAssertEqual(xmlDocument.xmlString(options: XMLNode.Options.documentTidyXML), "<addresses><address id=\"1\"><city>Berlin</city><street>Spandauer Straße</street></address><address id=\"2\"><city>Cologne</city><street>Ehrenstraße</street></address></addresses>")
    }
}

extension XMLAddressMapperTests {
    static var allTests = [
        ("testImportAddressWithValidProperties", testImportAddressWithValidProperties),
        ("testImportAddressWithInvalidId", testImportAddressWithInvalidId),
        ("testImportAddressWithInvalidCity", testImportAddressWithInvalidCity),
        ("testExportAddress", testExportAddress),
    ]
}

