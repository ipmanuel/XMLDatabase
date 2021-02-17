import XCTest
@testable import XMLDatabase

class XMLObjectsManagerTests: XCTestCase {
    
    
    // MARK: - Properties

    var url: URL!
    var lockedURL: URL!
    

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        
        let baseURL = Bundle.init(for: XMLObjectsManagerTests.self).resourceURL!

        let filename = "Persons.xml"
        url = baseURL.appendingPathComponent(filename)

        let lockedFilename = "_Persons.xml"
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
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        let _ = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)
    }


    // MARK: - Method `addObject(object:)` tests

    func testAdd() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)

        var newPerson = try Person(id: 0, gender: .male, firstName: "Manuel")
        XCTAssertNoThrow(try manager.addObject(object: &newPerson))
        XCTAssertEqual(newPerson.id, 0)

        var newPerson2 = try Person(id: 0, gender: .male, firstName: "Manuel")
        XCTAssertNoThrow(try manager.addObject(object: &newPerson2))
        XCTAssertEqual(newPerson2.id, 1)

        let objects = try manager.fetchObjects()
        XCTAssertEqual(objects.count, 2)
        guard objects.count >= 2 else {
            XCTFail("There are less than two objects.")
            return
        }
        XCTAssertEqual(objects[0].id, 0)
        XCTAssertEqual(objects[1].id, 1)
    }

    // MARK: - Method `removeObject(id:)` tests

    func testRemove() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)

        var newPerson = try Person(id: 0, gender: .male, firstName: "Manuel")
        XCTAssertNoThrow(try manager.addObject(object: &newPerson))
        XCTAssertEqual(newPerson.id, 0)

        var newPerson2 = try Person(id: 0, gender: .male, firstName: "Manuel")
        XCTAssertNoThrow(try manager.addObject(object: &newPerson2))
        XCTAssertEqual(newPerson2.id, 1)

        var objects = try manager.fetchObjects()
        XCTAssertEqual(objects.count, 2)
        guard objects.count >= 2 else {
            XCTFail("There are less than two objects.")
            return
        }
        XCTAssertEqual(objects[0].id, 0)
        XCTAssertEqual(objects[1].id, 1)

        XCTAssertNoThrow(try manager.removeObject(id: 0))
        objects = try manager.fetchObjects()
        XCTAssertEqual(objects.count, 1)
        XCTAssertNoThrow(try manager.addObject(object: &newPerson))
        objects = try manager.fetchObjects()
        XCTAssertEqual(objects.count, 2)
    }


    // MARK: - Method `fetchObject(id:)` tests

    func testFetch() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)

        var newPerson = try Person(id: 0, gender: .male, firstName: "Manuel")
        XCTAssertNoThrow(try manager.addObject(object: &newPerson))
        XCTAssertEqual(newPerson.id, 0)

        var newPerson2 = try Person(id: 0, gender: .male, firstName: "Manuel")
        XCTAssertNoThrow(try manager.addObject(object: &newPerson2))
        XCTAssertEqual(newPerson2.id, 1)

        var fetchedObject: Person!
        XCTAssertNoThrow(fetchedObject = try manager.fetchObject(id: 0))
        guard fetchedObject != nil else {
            XCTFail("FetchedObject is nil.")
            return
        }
        
        XCTAssertEqual(fetchedObject.id, 0)
        XCTAssertEqual(fetchedObject.gender, Person.Gender.male)
        XCTAssertEqual(fetchedObject.firstName, "Manuel")
    }


    // MARK: - Method `workWithContainer(body:)` tests

    func testWorkWithContainer() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)

        let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)

        let body = {(container: XMLDocumentContainer) throws -> () in}
        XCTAssertNoThrow(try manager.workWithContainer(body: body))
    }
}

extension XMLObjectsManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testAdd", testAdd),
        ("testRemove", testRemove),
        ("testFetch", testFetch),
        ("testWorkWithContainer", testWorkWithContainer)
    ]
}
