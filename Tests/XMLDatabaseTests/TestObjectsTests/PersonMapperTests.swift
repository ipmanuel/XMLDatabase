import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
import SWXMLHash
import XCTest
@testable import XMLDatabase

class PersonMapperTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private let baseURL = FileManager.default.temporaryDirectory
    private let xmlContent = "<Person id=\"1\"><Gender>male</Gender><FirstName>Manuel</FirstName></Person>"
    private let xmlContentWithLastname = "<Person id=\"1\"><Gender>male</Gender><FirstName>Manuel</FirstName><LastName>Pauls</LastName></Person>"
    
    
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
        var xmlElement: FXMLElement?
        
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        guard person != nil else {
            XCTFail("Person is nil")
            return
        }
        xmlElement = PersonMapper.toXMLElement(from: person!)
        
        let xmlDocument = FXMLDocument(rootElement: xmlElement)
        let expected = minifyXMLString(xmlContent)
        let actual = minifyXMLString(xmlDocument.xmlString)
        XCTAssertEqual(expected, actual)
    }
    
    func testMapToXMLElementWithOptionalPropertyLastName() {
        var person: Person?
        var xmlElement: FXMLElement?
        
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        guard person != nil else {
            XCTFail("Person is nil")
            return
        }
        XCTAssertNoThrow(try person!.set(lastName: "Pauls"))
        xmlElement = PersonMapper.toXMLElement(from: person!)
        
        let xmlDocument = FXMLDocument(rootElement: xmlElement)

        let expected = minifyXMLString(xmlContentWithLastname)
        let actual = minifyXMLString(xmlDocument.xmlString)
        XCTAssertEqual(expected, actual)
    }
}

func minifyXMLString(_ xmlString: String) -> String {
    let regex = try! NSRegularExpression(pattern:"<\\?xml version.*?>", options:.caseInsensitive)
    let updatedXMLString = regex.stringByReplacingMatches(in: xmlString, options: [], range: NSMakeRange(0, xmlString.count), withTemplate:"")
    
    return updatedXMLString.components(separatedBy: .newlines).map{ $0.trimmingCharacters(in: .whitespaces)}.joined()
}

extension PersonMapperTests {
    static var allTests = [
        ("testMapToXMLObject", testMapToXMLObject),
        ("testMaptToXMLObjectWithOptionalPropertyLastName", testMaptToXMLObjectWithOptionalPropertyLastName),
        ("testMapToXMLElement", testMapToXMLElement),
        ("testMapToXMLElementWithOptionalPropertyLastName", testMapToXMLElementWithOptionalPropertyLastName)
    ]
}
