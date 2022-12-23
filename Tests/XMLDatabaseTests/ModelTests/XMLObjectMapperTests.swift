import Foundation
import XCTest
import SWXMLHash
@testable import XMLDatabase

class XMlObjectMapperTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private var baseURL: URL?
    private var xmlContent: String?
    private var lockedXMLFileURL: URL?
    private var unlockedXMLFileURL: URL?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        baseURL = FileManager.default.temporaryDirectory
        xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        lockedXMLFileURL = baseURL!.appendingPathComponent("_Persons.xml")
        unlockedXMLFileURL = baseURL!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: lockedXMLFileURL!)
        removeFileIfExists(file: unlockedXMLFileURL!)
        
        super.tearDown()
    }
    
    
    // MARK: - Method `getAttributeId()` tests
    
    func testValidId() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        var value: Int?
        for object in objects {
            XCTAssertNoThrow(value = try PersonMapper.getAttributeId(of: object.element!, at: baseURL!))
            XCTAssertEqual(value, 1)
        }
    }
    
    func testInvalidId() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"-1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getAttributeId(of: object.element!, at: baseURL!))
        }
    }
    
    func testIdIsMissing() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getAttributeId(of: object.element!, at: baseURL!)) { error in
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
            XCTAssertNoThrow(xmlElement = try PersonMapper.getXMLElement(of: object, name: "gender", at: unlockedXMLFileURL!))
            XCTAssertEqual(xmlElement!.text, "male")
        }
    }
    
    func testElementIsMissing() {
        let xmlParsed = SWXMLHash.parse(xmlContent!)
        let objects = xmlParsed["persons"]["person"].all
        for object in objects {
            XCTAssertThrowsError(try PersonMapper.getXMLElement(of: object, name: "lastName", at: unlockedXMLFileURL!)) { error in
                XCTAssertEqual(error as! XMLObjectsError, XMLObjectsError.requiredElementIsMissing(element: "lastName", at: unlockedXMLFileURL!))
            }
        }
    }
    
    
    // MARK: - Method `getXMLElementAttributeValue()` tests
    
    func testElementAttributeIsValid() {
        let xmlParsed = SWXMLHash.parse(xmlContent!)
        let objects = xmlParsed["persons"]["person"].all
        let xmlElement: SWXMLHash.XMLElement = objects.first!.element!
        var attributeValue: String?
        
        XCTAssertNoThrow(attributeValue = try PersonMapper.getAttributeValue(of: xmlElement, name: "id", at: unlockedXMLFileURL!))
        XCTAssertEqual(attributeValue!, "1")
    }
    
    func testElementAttributeIsMissing() {
        let xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        let xmlParsed = SWXMLHash.parse(xmlContent)
        let objects = xmlParsed["persons"]["person"].all
        let xmlElement: SWXMLHash.XMLElement = objects.first!.element!
        
        XCTAssertThrowsError(try PersonMapper.getAttributeValue(of: xmlElement, name: "id", at: unlockedXMLFileURL!)) { error in
            XCTAssertEqual(error as! XMLObjectsError, XMLObjectsError.requiredAttributeIsMissing(element: "person", attribute: "id", at: unlockedXMLFileURL!))
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