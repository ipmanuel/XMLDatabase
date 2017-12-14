import Foundation
import XCTest
import SWXMLHash
@testable import XMLDatabase

class XMlObjectMapperTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private var basePath: URL?
    private var xmlContent: String?
    private var lockedXMLFilePath: URL?
    private var unlockedXMLFilePath: URL?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        basePath = Bundle.init(for: XMLDatabaseTests.self).resourceURL!
        xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        lockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        unlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: lockedXMLFilePath!)
        removeFileIfExists(file: unlockedXMLFilePath!)
        
        super.tearDown()
    }
    
    
    // MARK: - Method `getId()` tests
    
    func testValidId() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        var value: Int?
        for object in objects {
            XCTAssertNoThrow(value = try PersonMapper.getAttributeId(of: object.element!, at: basePath!))
            XCTAssertEqual(value, 1)
        }
    }
    
    func testInvalidId() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"-1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getAttributeId(of: object.element!, at: basePath!))
        }
    }
    
    func testIdIsMissing() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getAttributeId(of: object.element!, at: basePath!)) { error in
                guard case XMLObjectsError.requiredAttributeIsMissing(_, _, _) = error else {
                    return XCTFail("\(error)")
                }
            }
        }
    }
    
    // MARK: - Method `getXMLElement()` tests
    
    func testElementIsValid() {
        let xmlParsed = SWXMLHash.parse(xmlContent!)
        let objects = xmlParsed["persons"]["person"].all
        
        var xmlElement: SWXMLHash.XMLElement?
        for object in objects {
            XCTAssertNoThrow(xmlElement = try PersonMapper.getXMLElement(of: object, name: "gender", at: unlockedXMLFilePath!))
            XCTAssertEqual(xmlElement!.text, "male")
        }
    }
    
    func testElementIsMissing() {
        let xmlParsed = SWXMLHash.parse(xmlContent!)
        let objects = xmlParsed["persons"]["person"].all
        
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getXMLElement(of: object, name: "lastName", at: unlockedXMLFilePath!)) { error in
                guard case XMLObjectsError.requiredElementIsMissing(let element, let url) = error else {
                    return XCTFail("\(error)")
                }
                XCTAssertEqual(element, "lastName")
                XCTAssertEqual(url.path, unlockedXMLFilePath!.path)
            }
        }
    }
    
    
    // MARK: - Method `getXMLElementAttributeValue()` tests
    
    func testElementAttributeIsValid() {
        let xmlParsed = SWXMLHash.parse(xmlContent!)
        let objects = xmlParsed["persons"]["person"].all
    
        var xmlElement: SWXMLHash.XMLElement
        var attributeValue: String?
        for object in objects {
            xmlElement = object.element!
            XCTAssertNoThrow(attributeValue = try PersonMapper.getAttributeValue(of: xmlElement, name: "id", at: unlockedXMLFilePath!))
            XCTAssertEqual(attributeValue!, "1")
        }
    }
    
    func testElementAttributeIsMissing() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getAttributeValue(of: object.element!, name: "id", at: unlockedXMLFilePath!)) { error in
                guard case XMLObjectsError.requiredAttributeIsMissing(let element, let attribute, let url) = error else {
                    return XCTFail("\(error)")
                }
                XCTAssertEqual(element, "person")
                XCTAssertEqual(attribute, "id")
                XCTAssertEqual(url.path, unlockedXMLFilePath!.path)
            }
        }
    }
}

extension XMlObjectMapperTests {
    static var allTests = [
        ("testValidId", testValidId),
        ("testInvalidId", testInvalidId),
        ("testIdIsMissing", testIdIsMissing),
        ("testElementIsValid", testElementIsValid),
        ("testElementIsMissing", testElementIsMissing),
        ("testElementAttributeIsValid", testElementAttributeIsValid),
        ("testElementAttributeIsMissing", testElementAttributeIsMissing),
    ]
}

