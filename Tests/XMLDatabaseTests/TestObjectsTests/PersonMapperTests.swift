import FoundationXML
import SWXMLHash
import XCTest
@testable import XMLDatabase

class PersonMapperTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private let baseURL = Bundle.init(for: PersonMapperTests.self).resourceURL!
    private let xmlContent = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<Person id=\"1\"><Gender>male</Gender><FirstName>Manuel</FirstName></Person>\n"
    private let xmlContentWithLastname = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<Person id=\"1\"><Gender>male</Gender><FirstName>Manuel</FirstName><LastName>Pauls</LastName></Person>\n"
    
    
    // MARK: - Method `toXMLObject()` tests
    
    func testMapToXMLObject() {
        let personXMLIndexer: XMLIndexer = SWXMLHash.parse(xmlContent)["Person"].all[0]
        
        var person: Person?
        XCTAssertNoThrow(person = try PersonMapper.toXMLObject(from: personXMLIndexer, at: baseURL))

        guard person != nil else {
            XCTFail("Person is nil")
            return
        }
        
        XCTAssertEqual(person!.id, 1)
        XCTAssertEqual(person!.gender, Person.Gender.male)
        XCTAssertEqual(person!.firstName, "Manuel")
    }
    
    func testMaptToXMLObjectWithOptionalPropertyLastName() {
        let personXMLIndexer: XMLIndexer = SWXMLHash.parse(xmlContentWithLastname)["Person"].all[0]
        
        var person: Person?
        XCTAssertNoThrow(person = try PersonMapper.toXMLObject(from: personXMLIndexer, at: baseURL))

        guard person != nil else {
            XCTFail("Person is nil")
            return
        }
        
        XCTAssertEqual(person!.lastName, "Pauls")
    }
    
    
    // MARK: - Method `toXMLElement()` tests
    
    func testMapToXMLElement() {
        var person: Person?
        var xmlElement: FoundationXML.XMLElement?
        
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        guard person != nil else {
            XCTFail("Person is nil")
            return
        }
        xmlElement = PersonMapper.toXMLElement(from: person!)
        
        let xmlDocument = FoundationXML.XMLDocument(rootElement: xmlElement)
        XCTAssertEqual(xmlDocument.xmlString, xmlContent)
    }
    
    func testMapToXMLElementWithOptionalPropertyLastName() {
        var person: Person?
        var xmlElement: FoundationXML.XMLElement?
        
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        guard person != nil else {
            XCTFail("Person is nil")
            return
        }
        XCTAssertNoThrow(try person!.set(lastName: "Pauls"))
        xmlElement = PersonMapper.toXMLElement(from: person!)
        
        let xmlDocument = FoundationXML.XMLDocument(rootElement: xmlElement)
        XCTAssertEqual(xmlDocument.xmlString, xmlContentWithLastname)
    }
}

extension PersonMapperTests {
    static var allTests = [
        ("testMapToXMLObject", testMapToXMLObject),
        ("testMaptToXMLObjectWithOptionalPropertyLastName", testMaptToXMLObjectWithOptionalPropertyLastName),
        ("testMapToXMLElement", testMapToXMLElement),
        ("testMapToXMLElementWithOptionalPropertyLastName", testMapToXMLElementWithOptionalPropertyLastName)
    ]
}