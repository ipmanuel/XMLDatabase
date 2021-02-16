import XCTest
@testable import XMLDatabase

class XMLInfoObjectTests: XCTestCase {
    

    // MARK: - Properties

    var object: XMLInfoObject! 
    
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
    
    func testInit1() throws {
        XCTAssertNoThrow(object = try XMLInfoObject(objectName: "Person", objectNamePlural: "Persons"))

        guard object != nil else {
            XCTFail("Object is nil")
            return
        }

        XCTAssertEqual(object.maxId, -1)
        XCTAssertEqual(object.gapIds, [])
        XCTAssertEqual(object.gapIds.count, 0)
        XCTAssertEqual(object.objectName, "Person")
        XCTAssertEqual(object.objectNamePlural, "Persons")
    }

    func testInit2() throws {
        XCTAssertNoThrow(object = try XMLInfoObject(maxIdString: "-1", 
            gapIdsString: "", countString: "0", objectName: "DiaryEntry", objectNamePlural: "DiaryEntries"))

        guard object != nil else {
            XCTFail("Object is nil")
            return
        }

        XCTAssertEqual(object.maxId, -1)
        XCTAssertEqual(object.gapIds, [])
        XCTAssertEqual(object.gapIds.count, 0)
        XCTAssertEqual(object.objectName, "DiaryEntry")
        XCTAssertEqual(object.objectNamePlural, "DiaryEntries")
    }
    
    
    // MARK: - Method `addGapId(id:)` tests
    
    func testAddGapIds() {
        XCTAssertNoThrow(object = try XMLInfoObject(objectName: "Person", objectNamePlural: "Persons"))

        guard object != nil else {
            XCTFail("Object is nil")
            return
        }

        // simulate to add entries
        XCTAssertNoThrow(try object.incrementMaxId())
        XCTAssertNoThrow(try object.incrementMaxId())
        XCTAssertNoThrow(try object.incrementMaxId())
        XCTAssertEqual(object.maxId, 2)

        // simulate to remove the first entry
        XCTAssertNoThrow(try object.addGapId(id: 0))
        XCTAssertEqual(object.gapIds, [0])

        // simulate to remove the second entry
        XCTAssertNoThrow(try object.addGapId(id: 1))
        XCTAssertEqual(object.gapIds, [0, 1])
    }

    func testAddGapIdsWithErrors() {
        XCTAssertNoThrow(object = try XMLInfoObject(objectName: "Person", objectNamePlural: "Persons"))

        guard object != nil else {
            XCTFail("Object is nil")
            return
        }

        // simulate to add entries
        XCTAssertNoThrow(try object.incrementMaxId())
        XCTAssertEqual(object.maxId, 0)

        // simulate to remove the first entry
        XCTAssertThrowsError(try object.addGapId(id: 0)) { error in
            guard case XMLInfoObjectError.noEmptyGapIdsExists = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(object.gapIds, [])
        }
    }
    

    // MARK: - Methods `add(id:)` and `remove(id:)` tests

    func testAddRemoveWithValidParams() {
        XCTAssertNoThrow(object = try XMLInfoObject(objectName: "Person", objectNamePlural: "Persons"))

        guard object != nil else {
            XCTFail("Object is nil")
            return
        }

        // simulate to add entries
        XCTAssertNoThrow(try object.add(id: 0))
        XCTAssertNoThrow(try object.add(id: 1))
        XCTAssertNoThrow(try object.add(id: 2))
        XCTAssertNoThrow(try object.add(id: 3))
        XCTAssertNoThrow(try object.remove(id: 2))
        XCTAssertNoThrow(try object.add(id: 4))
        XCTAssertNoThrow(try object.add(id: 2))
        XCTAssertNoThrow(try object.remove(id: 1))
        XCTAssertNoThrow(try object.add(id: 5))
        XCTAssertNoThrow(try object.add(id: 1))
    }


    // MARK: - Property `count` tests

    func testCount() {
        XCTAssertNoThrow(object = try XMLInfoObject(objectName: "Person", objectNamePlural: "Persons"))

        guard object != nil else {
            XCTFail("Object is nil")
            return
        }

        // simulate to add entries
        XCTAssertNoThrow(try object.add(id: 0))
        XCTAssertEqual(object.count, 1)
        XCTAssertNoThrow(try object.add(id: 1))
        XCTAssertEqual(object.count, 2)
        XCTAssertNoThrow(try object.add(id: 2))
        XCTAssertEqual(object.count, 3)
        XCTAssertNoThrow(try object.add(id: 3))
        XCTAssertEqual(object.count, 4)
        XCTAssertNoThrow(try object.remove(id: 2))
        XCTAssertEqual(object.count, 3)
        XCTAssertNoThrow(try object.add(id: 4))
        XCTAssertEqual(object.count, 4)
        XCTAssertNoThrow(try object.add(id: 2))
        XCTAssertEqual(object.count, 5)
        XCTAssertNoThrow(try object.remove(id: 1))
        XCTAssertEqual(object.count, 4)
        XCTAssertNoThrow(try object.add(id: 5))
        XCTAssertEqual(object.count, 5)
        XCTAssertNoThrow(try object.add(id: 1))
        XCTAssertEqual(object.count, 6)
    }
    
    // MARK: - Private Methods
    
}

extension XMLInfoObjectTests {
    static var allTests = [
        ("testInit1", testInit1),
        ("testInit2", testInit2),
        ("testAddGapIds", testAddGapIds),
        ("testAddGapIdsWithErrors", testAddGapIdsWithErrors),
        ("testAddRemoveWithValidParams", testAddRemoveWithValidParams),
        ("testCount", testCount)
    ]
}
