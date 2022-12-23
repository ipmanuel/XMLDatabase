import XCTest
@testable import XMLDatabase


class FileDataManagerTests: XCTestCase {
    

    // MARK: - Properties

    var url: URL!
    var lockedURL: URL!
    

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        
        let baseURL = FileManager.default.temporaryDirectory

        let filename = "TestFile.txt"
        url = baseURL.appendingPathComponent(filename)

        let lockedFilename = "_TestFile.txt"
        lockedURL = baseURL.appendingPathComponent(lockedFilename)
        
        removeFileIfExists(file: url)
        removeFileIfExists(file: lockedURL)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    // MARK: - Init tests
    
    func testInit() throws {
        try createTestFile()
        
        var manager: FileDataManager! 
        XCTAssertNoThrow(manager = try FileDataManager(at: url))

        guard manager != nil else {
            XCTFail("Manager is nil")
            return
        }
        
        // check properties
        XCTAssertEqual(manager.filename, "TestFile.txt")
        XCTAssertEqual(manager.url.path, url.path)
    }
    
    func testInitWithNonExistingFile() throws {
        XCTAssertThrowsError(try FileDataManager(at: url)) { error in
            guard case FileDataManagerError.fileDoesNotExist = error else {
                return XCTFail("\(error)")
            }
        }
    }
    
    func testInitWithLock() throws {
        try createTestFile()
        var manager: FileDataManager! = try FileDataManager(at: url)
        let _ = try manager.loadAndLock()
        
        XCTAssertThrowsError(try FileDataManager(at: url)) { error in
            guard case FileDataManagerError.fileIsAlreadyLocked = error else {
                return XCTFail("\(error)")
            }
        }
        
        // test deinit
        manager = nil
        XCTAssertNoThrow(manager = try FileDataManager(at: url))
    }
    
    
    // MARK: - Method `save(data:)` and `load(data:)` tests
    
    func testSaveAndLoad() throws {
        try createTestFile()
        let manager = try FileDataManager(at: url)
        let _ = try manager.loadAndLock()
        
        let fileContent = "CBA"
        let fileData = fileContent.data(using: .utf8)!
        XCTAssertNoThrow(try manager.save(data: fileData))
        var loadedFileData: Data!
        XCTAssertNoThrow(loadedFileData = try manager.load())
        let loadedFileContent = String(decoding: loadedFileData, as: UTF8.self)
        XCTAssertEqual(loadedFileContent, fileContent)
    }
    
    
    // MARK: - Method `loadAndLock()` and `unlock()` tests
    
    func testLoadAndLockAndUnlock() throws {
        try testInit()

        let manager = try FileDataManager(at: url)
        XCTAssertNoThrow(try manager.loadAndLock())

        // check if there is a lock
        XCTAssertThrowsError(try manager.loadAndLock()) { error in
            guard case FileDataManagerError.fileIsAlreadyLocked = error else {
                return XCTFail("\(error)")
            }
        }

        XCTAssertNoThrow(try manager.unlock())
        XCTAssertNoThrow(try manager.loadAndLock())
        XCTAssertNoThrow(try manager.unlock())
    }
    
    
    // MARK: - Method `createFile(data:)` and `checkFileExists(at:)` tests
    
    func testCreateFile() throws {
        XCTAssertNoThrow(try createTestFile())
        XCTAssertTrue(FileDataManager.checkFileExists(at: url))
    }
    
    func testCreateFileWithExistingOne() throws {
        XCTAssertNoThrow(try createTestFile())
        
        let fileData = "123".data(using: .utf8)!
        XCTAssertThrowsError(try FileDataManager.createFile(at: url, withData: fileData)) { error in
            guard case FileDataManagerError.fileExistsAlready = error else {
                return XCTFail("\(error)")
            }
        }
    }
    
    func testFileExist() throws {
        XCTAssertFalse(FileDataManager.checkFileExists(at: url))
    }
    
    // MARK: - Helpers
    
    func createTestFile() throws {
        let fileContent = "ABC"
        let fileData = fileContent.data(using: .utf8)!
        try FileDataManager.createFile(at: url, withData: fileData)

    }
}


extension FileDataManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testInitWithNonExistingFile", testInitWithNonExistingFile),
        ("testInitWithLock", testInitWithLock),
        ("testSaveAndLoad", testSaveAndLoad),
        ("testLoadAndLockAndUnlock", testLoadAndLockAndUnlock),
        ("testCreateFile", testCreateFile),
        ("testCreateFileWithExistingOne", testCreateFileWithExistingOne),
        ("testFileExist", testFileExist)
    ]
}
