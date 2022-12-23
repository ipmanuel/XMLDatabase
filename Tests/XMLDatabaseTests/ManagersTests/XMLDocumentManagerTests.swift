import XCTest
@testable import XMLDatabase

class XMLDocumentManagerTests: XCTestCase {
    
    
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
        var manager: XMLDocumentManager!
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url, with: container))

        guard manager != nil else {
            XCTFail("Manager is nil")
            return
        }
        
        XCTAssertEqual(container.xmlDocument.xmlString, manager.container.xmlDocument.xmlString)
    }
    
    func testInitAndReinit() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        var manager: XMLDocumentManager!
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url, with: container))

        guard manager != nil else {
            XCTFail("Manager is nil")
            return
        }
        XCTAssertNoThrow(try manager!.unlock())
        
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url))
    }
    
    func testInitAndReinitWithError() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        var manager: XMLDocumentManager!
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url, with: container))
        XCTAssertThrowsError(manager = try XMLDocumentManager(at: url)) { error in
            guard case FileDataManagerError.fileIsAlreadyLocked(at: let exceptionURL) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertNotEqual(exceptionURL, url)
        }
        if manager != nil {
            try? manager.unlock()
        }
    }
    
    
    // MARK: - Deinit tests
    
    func testDeinit() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        var xmlDocumentManager: XMLDocumentManager?
        XCTAssertNoThrow(xmlDocumentManager = try XMLDocumentManager(at: url, with: container))
        xmlDocumentManager = nil
        XCTAssertNoThrow(xmlDocumentManager = try XMLDocumentManager(at: url))
        try? xmlDocumentManager?.unlock()
    }
    
    
    // MARK: - Method `save()` tests
    
    func testSave() throws {
        // prepare
        var manager: XMLDocumentManager!
        let container = try initContainerWithObjects(amount: 1)
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url, with: container))
        XCTAssertEqual(manager.container.infoObject.count, 1)
        XCTAssertNoThrow(try manager.save())
        XCTAssertNoThrow(try manager.unlock())

        
        // reinit
        manager = try XMLDocumentManager(at: url)
        XCTAssertEqual(manager.container.infoObject.count, 1)
    }
    
    
    // MARK: - Method `unlock()` tests
    
    func testUnlock() throws {
        // prepare
        let container = try initContainerWithObjects(amount: 1)
        let manager = try XMLDocumentManager(at: url, with: container)
        
        // test
        XCTAssertNoThrow(try manager.unlock())
        XCTAssertFalse(manager.isLocked)
    }
    
    
    // MARK: - Method `workWithContainer(body:)` tests

    func testWorkWithContainer() throws {
        let outerContainer = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        let xmlDocumentManager = try XMLDocumentManager(at: url, with: outerContainer)

        let body = {(container: XMLDocumentContainer) throws -> () in
            XCTAssertEqual(container.xmlDocument.xmlString, outerContainer.xmlDocument.xmlString)
        }
        XCTAssertNoThrow(try xmlDocumentManager.workWithContainer(body: body))
    }
}

extension XMLDocumentManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testInitAndReinit", testInit),
        ("testInitAndReinitWithError", testInitAndReinitWithError),
        ("testDeinit", testDeinit),
        ("testSave", testSave),
        ("testUnlock", testUnlock),
        ("testWorkWithContainer", testWorkWithContainer)
    ]
}
