import FoundationXML
import SWXMLHash
import XCTest
@testable import XMLDatabase

class PersonMapperTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private let baseURL = Bundle.init(for: PersonMapperTests.self).resourceURL!
    
    
    // MARK: - Method `toXMLObject()` tests
    
    func testMapToXMLObject() {
        let xmlContent = "<person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person>"
        let personXMLIndexer: XMLIndexer = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        var person: Person?
        XCTAssertNoThrow(person = try PersonMapper.toXMLObject(from: personXMLIndexer, at: baseURL))
        
        XCTAssertEqual(person!.id, 1)
        XCTAssertEqual(person!.gender, Person.Gender.male)
        XCTAssertEqual(person!.firstName, "Manuel")
    }
    
    func testMaptToXMLObjectWithOptionalPropertyLastName() {
        let xmlContent = "<person id=\"1\"><gender>male</gender><firstName>Manuel</firstName><lastName>Pauls</lastNam>/person>"
        let personXMLIndexer: XMLIndexer = SWXMLHash.parse(xmlContent)["person"].all[0]
        
        var person: Person?
        XCTAssertNoThrow(person = try PersonMapper.toXMLObject(from: personXMLIndexer, at: baseURL))
        
        XCTAssertEqual(person!.lastName, "Pauls")
    }
    
    
    // MARK: - Method `toXMLElement()` tests
    
    func testMapToXMLElement() {
        var person: Person?
        var xmlElement: FoundationXML.XMLElement?
        let xmlContent = "<person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person>"
        
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        xmlElement = PersonMapper.toXMLElement(from: person!)
        
        let xmlDocument = FoundationXML.XMLDocument(rootElement: xmlElement)
        XCTAssertEqual(xmlDocument.xmlString, xmlContent)
    }
    
    func testMapToXMLElementWithOptionalPropertyLastName() {
        var person: Person?
        var xmlElement: FoundationXML.XMLElement?
        let xmlContent = "<person id=\"1\"><gender>male</gender><firstName>Manuel</firstName><lastName>Pauls</lastName></person>"
        
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertNoThrow(try person!.set(lastName: "Pauls"))
        xmlElement = PersonMapper.toXMLElement(from: person!)
        
        let xmlDocument = FoundationXML.XMLDocument(rootElement: xmlElement)
        XCTAssertEqual(xmlDocument.xmlString, xmlContent)
    }
}

extension PersonMapperTests {
    static var allTests = [
        ("testMapToXMLObject", testMapToXMLObject),
        ("testMapToXMLElement", testMaptToXMLObjectWithOptionalPropertyLastName),
        ("testImportPersonWithInvalidGender", testMapToXMLElement),
        ("testMapToXMLElementWithOptionalPropertyLastName", testMapToXMLElementWithOptionalPropertyLastName)
    ]
}
