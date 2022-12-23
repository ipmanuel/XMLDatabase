import XCTest
@testable import XMLDatabase

class XMLObjectsManagerTests: XCTestCase {
    
    
    // MARK: - Properties

    var url: URL!
    var lockedURL: URL!
    

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        
        let baseURL = FileManager.default.temporaryDirectory

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

    func testAddObject() throws {
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

    
    // MARK: - Method `addObjects(objects:)` tests
    
    func testAddObjects() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        var xmlDocumentManager: XMLDocumentManager? = try XMLDocumentManager(at: url, with: container)

        var manager: XMLObjectsManager? = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager!)

        let newPerson = try Person(id: 0, gender: .male, firstName: "Manuel")
        let newPerson2 = try Person(id: 0, gender: .male, firstName: "Manuel")
        var persons = [newPerson, newPerson2]
        XCTAssertNoThrow(try manager!.addObjects(objects: &persons))
        
        // deinit and init
        manager = nil
        xmlDocumentManager = nil
        xmlDocumentManager = try XMLDocumentManager(at: url)
        manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager!)
        
        let fetchedPersons = try manager!.fetchObjects()
        XCTAssertEqual(persons[0].id, fetchedPersons[0].id)
        XCTAssertEqual(persons[1].id, fetchedPersons[1].id)
    }
    
    
    // MARK: - Method `replaceObject(object:)` tests
    
    func testReplaceObject() throws {
        // prepare
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)
        let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)
        var newPerson = try Person(id: 0, gender: .male, firstName: "Manuel")
        try manager.addObject(object: &newPerson)
        
        let updatedPerson = try Person(id: 0, gender: .male, firstName: "Peter")
        XCTAssertNoThrow(try manager.replaceObject(object: updatedPerson))
        let fetchedPerson = try manager.fetchObject(id: 0)
        XCTAssertEqual(newPerson.id, fetchedPerson.id)
        XCTAssertEqual(newPerson.gender, fetchedPerson.gender)
        XCTAssertEqual(fetchedPerson.firstName, "Peter")
    }
    
    
    // MARK: - Method `replaceObjects(objects:)` tests
    
    func testReplaceObjects() throws {
        // prepare
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)
        let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)
        var newPerson1 = try Person(id: 0, gender: .male, firstName: "Manuel")
        var newPerson2 = try Person(id: 0, gender: .male, firstName: "Manuel")
        try manager.addObject(object: &newPerson1)
        try manager.addObject(object: &newPerson2)
        
        let updatedPerson1 = try Person(id: 0, gender: .male, firstName: "Peter")
        let updatedPerson2 = try Person(id: 1, gender: .male, firstName: "Max")
        XCTAssertNoThrow(try manager.replaceObjects(objects: [updatedPerson1, updatedPerson2]))
        let fetchedPerson1 = try manager.fetchObject(id: 0)
        let fetchedPerson2 = try manager.fetchObject(id: 1)
        XCTAssertEqual(newPerson1.id, fetchedPerson1.id)
        XCTAssertEqual(newPerson1.gender, fetchedPerson1.gender)
        XCTAssertEqual(fetchedPerson1.firstName, "Peter")
        XCTAssertEqual(newPerson2.id, fetchedPerson2.id)
        XCTAssertEqual(newPerson2.gender, fetchedPerson2.gender)
        XCTAssertEqual(fetchedPerson2.firstName, "Max")
    }
    
    
    // MARK: - Method `removeObject(id:)` tests

    func testRemoveObject() throws {
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
    
    
    // MARK: - Method `removeObjects(ids:)` tests
    
    // TODO
    

    // MARK: - Method `fetchObject(id:)` tests

    func testFetchObject() throws {
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


    // MARK: - Performance tests of a container with 1.000 objects 

    func testReadPerformanceWithThousandObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 1000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 500)
        }
    }


    // MARK: - Performance tests of a container with 10.000 objects 

    func testReadPerformanceWithTenThousandObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 10000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 5000)
        }
    }


    // MARK: - Performance tests of a container with 1.000000 objects
    
    /*
    func testReadPerformanceWithOneMillionObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 1000000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 500000)
        }
    }*/
}

extension XMLObjectsManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testAddObject", testAddObject),
        ("testAddObjects", testAddObjects),
        ("testReplaceObject", testReplaceObject),
        ("testReplaceObjects", testReplaceObjects),
        ("testRemoveObject", testRemoveObject),
        ("testFetchObject", testFetchObject),
        ("testReadPerformanceWithThousandObjects", testReadPerformanceWithThousandObjects),
        ("testReadPerformanceWithTenThousandObjects", testReadPerformanceWithTenThousandObjects),
        //("testReadPerformanceWithOneMillionObjects", testReadPerformanceWithOneMillionObjects)
    ]
}
