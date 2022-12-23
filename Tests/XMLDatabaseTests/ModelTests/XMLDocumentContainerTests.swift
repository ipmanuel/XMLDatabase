import XCTest
import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
import SWXMLHash
@testable import XMLDatabase

class XMLDocumentContainerTests: XCTestCase {
    

    // MARK: - Properties

    var container: XMLDocumentContainer!


    // MARK: - Set up / tear down
    
    override func tearDown() {
        container = nil
        
        super.tearDown()
    }

    
    // MARK: - Init tests
    
    func testInit() throws {
        XCTAssertNoThrow(container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons"))

        guard container != nil else {
            XCTFail("Object is nil")
            return
        }
    }


    // MARK: - Method `verify()` tests

    func testVerify() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 0))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        let errors = container.verify()
        XCTAssertNil(errors)
    }

    func testVerifyWithErrors() throws {
        XCTAssertNoThrow(container = try XMLDocumentContainer(xmlString: "asdasd asd"))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        let errors = container.verify()
        guard errors != nil else {
            XCTFail("Errors is nil")
            return
        }
    }


    // MARK: - Method `initInfoObject()` tests

    func testInitInfoObject() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 0))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        XCTAssertNoThrow(try container.initInfoObject())
    }


    // MARK: - Method `add(id:)` tests

    func testAdd() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 50))
    }


    // MARK: - Method `remove(id:)` tests

    func testRemove() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 123))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }
        XCTAssertEqual(container.infoObject.count, 123)

        // remove one object
        XCTAssertNoThrow(try container.remove(id: 4))
        XCTAssertEqual(container.infoObject.count, 122)
        XCTAssertTrue(container.infoObject.gapIds.contains(4))
        XCTAssertEqual(container.infoObject.gapIds.count, 1)

        // remove another object
        XCTAssertNoThrow(try container.remove(id: 99))
        XCTAssertEqual(container.infoObject.count, 121)
        XCTAssertTrue(container.infoObject.gapIds.contains(99))
        XCTAssertEqual(container.infoObject.gapIds.count, 2)
    }

    func testRemoveWithError() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 1))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        // try to remove an object with does not exists
        XCTAssertThrowsError(try container.remove(id: 1)) { error in
            guard case XMLDocumentContainerError.idDoesNotExist = error else {
                return XCTFail("\(error)")
            }
        }
    }


    // MARK: - Method `fetch(id:)` tests

    func testFetch() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 5))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        //var xmlStringData: Data?
        //xmlStringData = container.export()
        //let xmlString = String(decoding: try XCTUnwrap(xmlStringData), as: UTF8.self)
        //print(xmlString)

        // fetch one entry
        //print(try container.fetchAll())
        var personXMLElement: XMLIndexer!
        XCTAssertNoThrow(personXMLElement = try container.fetch(id: 0))
        guard personXMLElement != nil else {
            XCTFail("fetchedXMLObject is nil")
            return
        }
        //print("XMLElement: \(personXMLElement)")
        let url = URL(fileURLWithPath: "/")
        var person: Person!
        XCTAssertNoThrow(person = try PersonMapper.toXMLObject(from: personXMLElement, at: url))

        guard person != nil else {
            XCTFail("person is nil")
            return
        }

        // check fetched diary entry
        XCTAssertEqual(person.gender, Person.Gender.male)
        XCTAssertEqual(person.firstName, "Manuel")
    }

    func testFetchWithError() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 1))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        // try to remove an object with does not exists
        XCTAssertThrowsError(try container.fetch(id: 1)) { error in
            guard case XMLDocumentContainerError.idDoesNotExist = error else {
                return XCTFail("\(error)")
            }
        }
    }


    // MARK: - Method `export()` tests

    func testExport() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 100))
        guard container != nil else {
            XCTFail("Object is nil")
            return
        }

        // remove a few objects
        for id in 0...7 {
            XCTAssertNoThrow(try container.remove(id: id * 5))
        }

        // export and init new container
        var xmlStringData: Data? 
        xmlStringData = container.export()
        let xmlString = String(decoding: try XCTUnwrap(xmlStringData), as: UTF8.self)
        var newContainerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(newContainerOptional = try XMLDocumentContainer(xmlString: xmlString))
        let newContainer = try XCTUnwrap(newContainerOptional)

        // check if there were some objects lost
        XCTAssertEqual(container.infoObject.count, newContainer.infoObject.count)
        XCTAssertEqual(container.infoObject.maxId, newContainer.infoObject.maxId)
        XCTAssertEqual(container.infoObject.gapIds, newContainer.infoObject.gapIds)    
    }


    // MARK: - Method `calculateIndex(of: )` tests

    func testCalculateIndex() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 100))
        guard container != nil else {
            XCTFail("container is nil")
            return
        }

        // verify indices
        XCTAssertEqual(container.calculateIndex(of: 89), 89)
        XCTAssertEqual(container.calculateIndex(of: 0), 0)
        XCTAssertEqual(container.calculateIndex(of: 2), 2)
        XCTAssertEqual(container.calculateIndex(of: 6), 6)
        XCTAssertEqual(container.calculateIndex(of: 91), 91)

        // remove objects
        XCTAssertNoThrow(try container.remove(id: 90))
        XCTAssertNoThrow(try container.remove(id: 5))
        XCTAssertNoThrow(try container.remove(id: 1))

        // verify indices
        XCTAssertEqual(container.calculateIndex(of: 1), -1)
        XCTAssertEqual(container.calculateIndex(of: 5), -1)
        XCTAssertEqual(container.calculateIndex(of: 89), 87)
        XCTAssertEqual(container.calculateIndex(of: 0), 0)
        XCTAssertEqual(container.calculateIndex(of: 6), 4)
        XCTAssertEqual(container.calculateIndex(of: 91), 88)
    }


    // MARK: - Method `calculateId(of: )` tests

    func testCalculateId() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 100))
        guard container != nil else {
            XCTFail("container is nil")
            return
        }

        // verify indices
        XCTAssertEqual(container.calculateId(of: 89), 89)
        XCTAssertEqual(container.calculateId(of: 0), 0)
        XCTAssertEqual(container.calculateId(of: 2), 2)
        XCTAssertEqual(container.calculateId(of: 6), 6)
        XCTAssertEqual(container.calculateId(of: 91), 91)

        // remove objects
        XCTAssertNoThrow(try container.remove(id: 90))
        XCTAssertNoThrow(try container.remove(id: 5))
        XCTAssertNoThrow(try container.remove(id: 1))

        // verify indices
        var calculatedId: Int
        for index in 0..<container.infoObject.count {
            calculatedId = container.calculateId(of: index)
            XCTAssertNotEqual(calculatedId, -1)
            if calculatedId == -1 {
                print("Failed Index: \(index)")
            }
        }
        XCTAssertEqual(container.calculateId(of: 4), 6)
        XCTAssertEqual(container.calculateId(of: 90), 93)
        XCTAssertEqual(container.calculateId(of: 0), 0)
        XCTAssertEqual(container.calculateId(of: 1), 2)
        XCTAssertEqual(container.calculateId(of: 91), 94)

        // test with empty container
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 0))
        guard container != nil else {
            XCTFail("container is nil")
            return
        }

        XCTAssertEqual(container.calculateId(of: -1), -1)
        XCTAssertEqual(container.calculateId(of: 0), -1)
        XCTAssertEqual(container.calculateId(of: 1), -1)
        XCTAssertEqual(container.calculateId(of: 2), -1)
        XCTAssertEqual(container.calculateId(of: 3), -1)
    }


    // MARK: - Method `checkIdExists()` tests

    func testCheckIdExists() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 0))
        XCTAssertFalse(container.checkIdExists(id: -1))
        XCTAssertFalse(container.checkIdExists(id: 0))
        XCTAssertFalse(container.checkIdExists(id: 1))

        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 1))
        XCTAssertFalse(container.checkIdExists(id: -1))
        XCTAssertTrue(container.checkIdExists(id: 0))
        XCTAssertFalse(container.checkIdExists(id: 1))

        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 5))
        XCTAssertNoThrow(try container.remove(id: 3))
        XCTAssertFalse(container.checkIdExists(id: -1))
        XCTAssertTrue(container.checkIdExists(id: 0))
        XCTAssertTrue(container.checkIdExists(id: 1))
        XCTAssertTrue(container.checkIdExists(id: 2))
        XCTAssertFalse(container.checkIdExists(id: 3))
        XCTAssertTrue(container.checkIdExists(id: 4))
        XCTAssertFalse(container.checkIdExists(id: 5))
    }


    // MARK: - Method `calculateNextId()` tests

    func testCalculateNextId() throws {
        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 0))
        XCTAssertEqual(container.calculateNextId(), 0)
        XCTAssertEqual(container.calculateNextId(), 0)
        XCTAssertEqual(container.calculateNextId(), 0)

        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 2))
        XCTAssertEqual(container.calculateNextId(), 2)

        XCTAssertNoThrow(container = try initContainerWithObjects(amount: 10000))
        XCTAssertEqual(container.calculateNextId(), 10000)
    }


    // MARK: - Performance tests of a container with 5 objects

    func testPerformanceWithFiveObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 5))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 2)
        }
    }


    // MARK: - Performance tests of a container with 1.000 objects 

    func testPerformanceWithThousandObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 1000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 500)
        }
    }


    // MARK: - Performance tests of a container with 10.000 objects 

    func testPerformanceWithTenThousandObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 10000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 5000)
        }
    }
    
    
    // MARK: - Performance tests of a container with 100.000 objects

    func testPerformanceWithHundredThousandObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 100000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 50000)
        }
    }


    // MARK: - Performance tests of a container with 1.000000 objects
    /*
    func testPerformanceWithOneMillionObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 1000000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 500000)
        }
    }*/
}

extension XMLDocumentContainerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testVerify", testVerify),
        ("testVerifyWithErrors", testVerifyWithErrors),
        ("testInitInfoObject", testInitInfoObject),
        ("testExport", testExport),
        ("testCheckIdExists", testCheckIdExists),
        ("testAdd", testAdd),
        ("testRemove", testRemove),
        ("testRemoveWithError", testRemoveWithError),
        ("testFetch", testFetch),
        ("testFetchWithError", testFetchWithError),
        ("testCalculateIndex", testCalculateIndex),
        ("testCalculateId", testCalculateId),
        ("testCalculateNextId", testCalculateNextId),
        ("testPerformanceWithFiveObjects", testPerformanceWithFiveObjects),
        ("testPerformanceWithThousandObjects", testPerformanceWithThousandObjects),
        ("testPerformanceWithTenThousandObjects", testPerformanceWithTenThousandObjects),
        //("testPerformanceWithOneMillionObjects", testPerformanceWithOneMillionObjects)
    ]
}
