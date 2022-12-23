import XCTest
@testable import XMLDatabase

class XMLObjectManagerTests: XCTestCase {
    
    
    // MARK: - Properties

    var url: URL!
    var lockedURL: URL!
    

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        
        let baseURL = FileManager.default.temporaryDirectory

        let filename = "Person.xml"
        url = baseURL.appendingPathComponent(filename)

        let lockedFilename = "_Person.xml"
        lockedURL = baseURL.appendingPathComponent(lockedFilename)
    }
    
    override func tearDown() {
        super.tearDown()

        removeFileIfExists(file: url)
        removeFileIfExists(file: lockedURL)
    }
    
    
    // MARK: - Init tests
    
    func testInit() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let object = try Person(id: 0, gender: .male, firstName: "Peter")
        let xmlElement = PersonMapper.toXMLElement(from: object)
        XCTAssertNoThrow(try container.add(xmlElement: xmlElement, withId: 0))
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        XCTAssertNoThrow(try XMLObjectManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager))
        XCTAssertTrue(xmlDocumentManager.isLocked)
    }
    
    func testInitAndReinit() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let object = try Person(id: 0, gender: .male, firstName: "Peter")
        let xmlElement = PersonMapper.toXMLElement(from: object)
        XCTAssertNoThrow(try container.add(xmlElement: xmlElement, withId: 0))
        var xmlDocumentManager: XMLDocumentManager! = try XMLDocumentManager(at: url, with: container)
        xmlDocumentManager = nil
        xmlDocumentManager = try XMLDocumentManager(at: url)
        let exportedContainer1 = String(decoding: container.export(), as: UTF8.self)
        let exportedContainer2 = String(decoding: xmlDocumentManager.container.export(), as: UTF8.self)

        XCTAssertEqual(exportedContainer1, exportedContainer2)
        
        XCTAssertNoThrow(try XMLObjectManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager))
        XCTAssertTrue(xmlDocumentManager.isLocked)
    }

    
    // MARK: - Method `setObject(object:)` and Method `fetchObject(object:)` tests

    func testAddAndFetch() throws {
        // init xmlDocumentManager
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let object = try Person(id: 0, gender: .male, firstName: "Peter")
        let xmlElement = PersonMapper.toXMLElement(from: object)
        print(xmlElement)
        XCTAssertNoThrow(try container.add(xmlElement: xmlElement, withId: 0))
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        // init manager
        var manager: XMLObjectManager<PersonMapper>!
        XCTAssertNoThrow(manager = try XMLObjectManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager))
        guard manager != nil else {
            XCTFail("Manager is nil.")
            return
        }

        // set lastname
        XCTAssertNoThrow(try object.set(lastName: "Brown"))
        XCTAssertNoThrow(try manager.setObject(object: object))

        // verify object
        var loadedObject: Person! 
        XCTAssertNoThrow(loadedObject = try manager.fetchObject())
        guard loadedObject != nil else {
            XCTFail("Loaded object is nil.")
            return
        }
        XCTAssertEqual(loadedObject.id, 0)
        XCTAssertEqual(loadedObject.gender, Person.Gender.male)
        XCTAssertEqual(loadedObject.firstName, "Peter")
        XCTAssertEqual(loadedObject.lastName, "Brown")
    }
    
    func testAddAndFetchWithPersistanceTest() throws {
        var manager: XMLObjectManager<PersonMapper>! = try initManager()
        
        let newObject = try Person(id: 0, gender: .female, firstName: "Berta")
        try manager.setObject(object: newObject)
        manager = nil
        
        manager = try initManager(withCreation: false)
        let fetchedObject = try manager.fetchObject()
        XCTAssertEqual(fetchedObject.gender, newObject.gender)
        XCTAssertEqual(fetchedObject.firstName, newObject.firstName)
    }
    
    
    // MARK: - Helpers
    
    func initManager(withCreation: Bool = true) throws -> XMLObjectManager<PersonMapper> {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let object = try Person(id: 0, gender: .male, firstName: "Peter")
        let xmlElement = PersonMapper.toXMLElement(from: object)
        try container.add(xmlElement: xmlElement, withId: 0)
        var xmlDocumentManager: XMLDocumentManager
        if withCreation {
            xmlDocumentManager = try XMLDocumentManager(at: url, with: container)
        } else {
            xmlDocumentManager = try XMLDocumentManager(at: url)
        }
        let manager = try XMLObjectManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)
        
        return manager
    }
}

extension XMLObjectManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testAddAndFetch", testAddAndFetch)
    ]
}
