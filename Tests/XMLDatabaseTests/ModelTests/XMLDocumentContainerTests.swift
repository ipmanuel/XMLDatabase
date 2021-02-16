import XCTest
import FoundationXML
@testable import XMLDatabase

class XMLDocumentContainerTests: XCTestCase {
    

    // MARK: - Properties
    
    // MARK: - setUp / tearDown
    /*
    override func setUp() {
        super.setUp()
        
        // basePath
        basePath = Bundle.init(for: PersonsTests.self).resourceURL!
        
        // persons locked and unlocked xml files
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><relation>me</relation><firstName>Manuel</firstName><lastName>Pauls</lastName></person></persons>"
        personsLockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        personsUnlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: personsLockedXMLFilePath!)
        removeFileIfExists(file: personsUnlockedXMLFilePath!)
        
        super.tearDown()
    }*/
    
    
    // MARK: - Init tests
    
    func testInit() throws {
        var container: XMLDocumentContainer!
        XCTAssertNoThrow(container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons"))

        guard container != nil else {
            XCTFail("Object is nil")
            return
        }
    }


    // MARK: - Method `verify()` tests

    func testVerify() throws {
        var container: XMLDocumentContainer!
        XCTAssertNoThrow(container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons"))

        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        var errors = container.verify()

        XCTAssertNil(errors)
    }

    func testVerifyWithErrors() throws {
        var container: XMLDocumentContainer!
        XCTAssertNoThrow(container = try XMLDocumentContainer(xmlString: "asdasd asd"))

        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        var errors = container.verify()
        guard errors != nil else {
            XCTFail("Errors is nil")
            return
        }
        //XCTAssertTrue(errors![0] == XMLDocumentContainerError.rootElementDoesNotExist)
        
        print(errors)
    }


    // MARK: - Method `initInfoObject()` tests

    func testInitInfoObject() throws {
        var container: XMLDocumentContainer!
        XCTAssertNoThrow(container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons"))

        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        var variable: XMLInfoObject?
        XCTAssertNoThrow(variable = try container.initInfoObject())
    }


    // MARK: - Method `export()` tests

    func testExport() throws {
        var container: XMLDocumentContainer!
        XCTAssertNoThrow(container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons"))


        guard container != nil else {
            XCTFail("Object is nil")
            return
        }


        var data: Data!

        XCTAssertNoThrow(data = try container.export())

        guard data != nil else {
            XCTFail("data is nil")
            return
        }

        //let xmlString = String(decoding: data, as: UTF8.self)

        //XCTAssertEqual(xmlString, "asd")
    }


    // MARK: - Method `add(id:)` tests

    func testAdd() throws {
        var container: XMLDocumentContainer!
        XCTAssertNoThrow(container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons"))

        var xmlElement: FoundationXML.XMLElement
        var newPerson: Person
        for id in 0...4 {
            newPerson = try Person(id: id, gender: .male, firstName: "Manuel")
            xmlElement = PersonMapper.toXMLElement(from: newPerson)
            XCTAssertNoThrow(try container.add(xmlElement: xmlElement, withId: id))
        }
    }
}

extension XMLDocumentContainerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testVerify", testVerify),
        ("testVerifyWithErrors", testVerifyWithErrors),
        ("testInitInfoObject", testInitInfoObject),
        ("testExport", testExport),
        ("testAdd", testAdd),
    ]
}
