import XCTest
@testable import XMLDatabase
import Crypto


class FileCryptoDataManagerTests: XCTestCase {
    

    // MARK: - Properties

    var url: URL!
    var lockedURL: URL!
    var cryptoManager: CryptoManager!
    

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        
        let baseURL = FileManager.default.temporaryDirectory

        let filename = "TestFile.crypto"
        url = baseURL.appendingPathComponent(filename)

        let lockedFilename = "_TestFile.crypto"
        lockedURL = baseURL.appendingPathComponent(lockedFilename)
        
        removeFileIfExists(file: url)
        removeFileIfExists(file: lockedURL)
        
        cryptoManager = CryptoManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    // MARK: - Init tests
    
    func testInit() throws {
        try createTestFile()
                
        XCTAssertNoThrow(try FileCryptoDataManager(at: url, cryptoManager: cryptoManager))
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
    
    func testSaveAndLoadWithInvalidCryptoManager() throws {
        try createTestFile()
        let fileDataManager = try FileCryptoDataManager(at: url, cryptoManager: CryptoManager())
        XCTAssertThrowsError(try fileDataManager.loadAndLock()) { error in
            guard case CryptoManagerError.decryptionFailed = error else {
                return XCTFail("\(error)")
            }
        }
    }
    
    
    // MARK: - Method `createFile(data:)` tests
    
    func testCreateFile() throws {
        XCTAssertNoThrow(try createTestFile())
        XCTAssertTrue(FileDataManager.checkFileExists(at: url))
        let manager = try FileCryptoDataManager(at: url, cryptoManager: cryptoManager)
        let loadedFileData = try manager.loadAndLock()
        let loadedContent = String(decoding: loadedFileData, as: UTF8.self)
        XCTAssertEqual(loadedContent, "ABC")
    }
    
    func testCreateFileWithCryptoVerification() throws {
        try createTestFile()
        let fileDataManager = try FileDataManager(at: url)
        let loadedFileData = try fileDataManager.load()
        let loadedContent = String(decoding: loadedFileData, as: UTF8.self)
        XCTAssertNotEqual(loadedContent, "ABC")
    }
    
    
    // MARK: - Helpers
    
    func createTestFile() throws {
        let fileContent = "ABC"
        let fileData = fileContent.data(using: .utf8)!
        try FileCryptoDataManager.createFile(at: url, withData: fileData, cryptoManager: cryptoManager)
    }
    
    func loadFileContent(fileDataManager: FileCryptoDataManager) throws -> String {
        let loadedFileData = try fileDataManager.load()
        let loadedFileContent = String(decoding: loadedFileData, as: UTF8.self)
        
        return loadedFileContent
    }
}


extension FileCryptoDataManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testSaveAndLoad", testSaveAndLoad),
        ("testSaveAndLoadWithInvalidCryptoManager", testSaveAndLoadWithInvalidCryptoManager),
        ("testCreateFile", testCreateFile),
        ("testCreateFileWithCryptoVerification", testCreateFileWithCryptoVerification),
    ]
}
