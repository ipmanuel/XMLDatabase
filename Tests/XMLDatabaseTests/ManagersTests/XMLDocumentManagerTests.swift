import XCTest
@testable import XMLDatabase

class XMLDocumentManagerTests: XCTestCase {
    
    
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
        var manager: XMLDocumentManager!
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url, with: container))

        guard manager != nil else {
            XCTFail("Manager is nil")
            return
        }   
    }


    // MARK: - Method `loadAndLock()` and `saveAndUnlock(container:)` tests

    func testLoadAndLock() throws {
        let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
        var manager: XMLDocumentManager!
        XCTAssertNoThrow(manager = try XMLDocumentManager(at: url, with: container))

        guard manager != nil else {
            XCTFail("Manager is nil")
            return
        }

        var loadedContainer: XMLDocumentContainer!
        XCTAssertNoThrow(loadedContainer = try manager.loadAndLock())
        XCTAssertTrue(manager.isLocked)
        XCTAssertNoThrow(try manager.saveAndUnlock(container: loadedContainer))
    }
}

extension XMLDocumentManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testLoadAndLock", testLoadAndLock)
        
    ]
}
