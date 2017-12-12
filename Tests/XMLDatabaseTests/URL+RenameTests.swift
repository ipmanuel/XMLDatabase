import XCTest
@testable import XMLDatabase

class URLExtensionTests: XCTestCase {

    
    // MARK: - Method `rename()` tests
    
    func testRename() {
        let fileContent = "ABC"
        let url = Bundle.init(for: URLExtensionTests.self).resourceURL!
        let originalFilename = "TestFile.txt"
        let newFilename = "NewFile.txt"
        
        let originalFileURL = url.appendingPathComponent(originalFilename)
        let newFileURL = url.appendingPathComponent(newFilename)
        var fileURL = url.appendingPathComponent(originalFilename)
        
        XCTAssertNoThrow(try fileContent.write(to: originalFileURL, atomically: true, encoding: String.Encoding.utf8))
        XCTAssertNoThrow(try fileURL.rename(newName: newFilename))
        
        if fileURL != newFileURL {
            XCTFail("Should:\n\"\(fileURL.path)\"\nis:\n\"\(newFileURL.path)\"")
        }
        
        if !FileManager.default.fileExists(atPath: newFileURL.path) || FileManager.default.fileExists(atPath: originalFileURL.path) {
            XCTFail()
        }
        
        XCTAssertNoThrow(try FileManager.default.removeItem(at: newFileURL))
    }
}


extension URLExtensionTests {
    static var allTests = [
        ("testRename", testRename)
    ]
}
