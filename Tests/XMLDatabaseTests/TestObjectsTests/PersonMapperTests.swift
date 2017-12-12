import SWXMLHash
import XCTest
@testable import XMLDatabase

class PersonMapperTests: XCTestCase {
    private let randomURL = Bundle.init(for: PersonMapperTests.self).resourceURL!
    
    
    // MARK: valid properties
    
    func testImportPersonWithValidProperties() {
        let xmlContent = "<person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person>"
        let xmlElementParsed: XMLIndexer = SWXMLHash.parse(xmlContent)["person"].all[0]
        do {
            let person = try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)
            
            XCTAssertEqual(person.id, 1)
            XCTAssertEqual(person.gender, Person.Gender.male)
            XCTAssertEqual(person.firstName, "Manuel")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    // MARK: property id tests
    
    func testImportPersonWithInvalidId() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // id exists but is invalid
        xmlContent = "<person id=\"0\"><gender>male</gender><firstName>Manuel</firstName></person>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        XCTAssertThrowsError(try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 0)
        }
        
        // id does not exist
        xmlContent = "<person><gender>male</gender><relation>me</relation><firstName>Manuel</firstName></person>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["person"].all[0]
        XCTAssertThrowsError(try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectsError.requiredAttributeIsMissing(let element, let attribute, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "person")
            XCTAssertEqual(attribute, "id")
            XCTAssertEqual(url.path, randomURL.path)
        }
    }
    
    
    // MARK: property gender tests
    
    func testImportPersonWithInvalidGender() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // gender exists but is invalid
        xmlContent = "<person id=\"1\"><gender>males</gender><relation>me</relation><firstName>Manuel</firstName></person>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        XCTAssertThrowsError(try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)) { error in
            guard case PersonError.invalidGender(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, "males")
        }
        
        // gender does not exist
        xmlContent = "<person id=\"1\"><relation>me</relation><firstName>Manuel</firstName></person>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        XCTAssertThrowsError(try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectsError.requiredElementIsMissing(let element, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "gender")
            XCTAssertEqual(url.path, randomURL.path)
        }
    }
    
    
    // MARK: property firstName tests
    
    func testImportPersonWithInvalidFirstName() {
        var xmlContent: String
        var xmlElementParsed: XMLIndexer
        
        // relation exists but is invalid
        xmlContent = "<person id=\"1\"><gender>male</gender><relation>me</relation><firstName>A</firstName></person>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        XCTAssertThrowsError(try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)) { error in
            guard case PersonError.invalidFirstName(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, "A")
        }
        
        // relation does not exist
        xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><person id=\"1\"><gender>male</gender><relation>me</relation></person>"
        xmlElementParsed = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        XCTAssertThrowsError(try PersonMapper.toObject(xmlIndexer: xmlElementParsed, at: randomURL)) { error in
            guard case XMLObjectsError.requiredElementIsMissing(let element, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(element, "firstName")
            XCTAssertEqual(url.path, randomURL.path)
        }
    }
}

extension PersonMapperTests {
    static var allTests = [
        ("testImportPersonWithValidProperties", testImportPersonWithValidProperties),
        ("testImportPersonWithInvalidId", testImportPersonWithInvalidId),
        ("testImportPersonWithInvalidGender", testImportPersonWithInvalidGender),
        ("testImportPersonWithInvalidFirstName", testImportPersonWithInvalidFirstName)
    ]
}