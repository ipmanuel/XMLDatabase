import XCTest
@testable import XMLDatabase

class FileDataManagerTests: XCTestCase {
    

    // MARK: - Properties

    var url: URL!
    var lockedURL: URL!
    

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        
        let baseURL = Bundle.init(for: FileDataManagerTests.self).resourceURL!

        let filename = "TestFile.txt"
        url = baseURL.appendingPathComponent(filename)

        let lockedFilename = "_TestFile.txt"
        lockedURL = baseURL.appendingPathComponent(lockedFilename)
    }
    
    override func tearDown() {
        super.tearDown()

        removeFileIfExists(file: url)
        removeFileIfExists(file: lockedURL)
    }
    
    
    // MARK: - Init tests
    
    func testInit() throws {
        let fileContent = "ABC"
        let fileData = fileContent.data(using: .utf8)!

        var manager: FileDataManager! 
        XCTAssertNoThrow(manager = try FileDataManager(at: url, withData: fileData))

        guard manager != nil else {
            XCTFail("Manager is nil")
            return
        }

        // check Properties
        // todo



        let data = try manager.load()
        let readFileConted = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(fileContent, readFileConted)

        XCTAssertNoThrow(manager = try FileDataManager(at: url))
    }

    func testInitWithExistingFile() throws {
        try testInit()

        let manager = try FileDataManager(at: url)
        let fileContent1 = String(decoding: try manager.load(), as: UTF8.self)

        let newFileData = "CBA".data(using: .utf8)!

        XCTAssertThrowsError(try FileDataManager(at: url, withData: newFileData)) { error in
            guard case FileDataManagerError.fileExistsAlready = error else {
                return XCTFail("\(error)")
            }
        }

        let fileContent2 = String(decoding: try manager.load(), as: UTF8.self)
        XCTAssertEqual(fileContent1, fileContent2)
    }

    func testLock() throws {
        try testInit()

        let manager = try FileDataManager(at: url)

        // set read and lock
        let _ = String(decoding: try manager.loadAndLock(), as: UTF8.self)

        // check if there is a lock
        XCTAssertThrowsError(try manager.loadAndLock()) { error in
            guard case FileDataManagerError.fileIsAlreadyLocked = error else {
                return XCTFail("\(error)")
            }
        }

        XCTAssertNoThrow(try manager.unlock())
    }
}

extension FileDataManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testInitWithExistingFile", testInitWithExistingFile),
        ("testLock", testLock)
    ]
}
