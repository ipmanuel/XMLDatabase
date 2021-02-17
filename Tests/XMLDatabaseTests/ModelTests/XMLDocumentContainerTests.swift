import XCTest
import FoundationXML
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


    // MARK: - Performance tests of a container with 1.000000 objects

    func testPerformanceWithOneMillionObjects() throws {
        var containerOptional: XMLDocumentContainer?
        XCTAssertNoThrow(containerOptional = try initContainerWithObjects(amount: 1000000))
        let container = try XCTUnwrap(containerOptional)
        measure {
            let _ = try! container.fetch(id: 500000)
        }
    }


    // MARK: - Helpers

    private func initContainerWithObjects(amount: Int) throws -> XMLDocumentContainer {
        container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        var xmlElement: FoundationXML.XMLElement
        var newPerson: Person
        for id in 0..<amount {
            newPerson = try Person(id: id, gender: .male, firstName: "Manuel")
            xmlElement = PersonMapper.toXMLElement(from: newPerson)
            try container.add(xmlElement: xmlElement, withId: id)
        }

        return container
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
        ("testRemove", testRemove),
        ("testPerformanceWithFiveObjects", testPerformanceWithFiveObjects),
        ("testPerformanceWithThousandObjects", testPerformanceWithThousandObjects),
        ("testPerformanceWithTenThousandObjects", testPerformanceWithTenThousandObjects)//,
        //("testPerformanceWithOneMillionObjects", testPerformanceWithOneMillionObjects)
    ]
}
