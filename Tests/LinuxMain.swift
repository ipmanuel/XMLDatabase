import XCTest
@testable import XMLDatabaseTests

XCTMain([
    testCase(CryptoManagerTests.allTests),
    testCase(FileDataManagerTests.allTests),
    testCase(FileCryptoDataManagerTests.allTests),
    testCase(XMLDocumentManagerTests.allTests),
    testCase(XMLCryptoDocumentManagerTests.allTests),
    testCase(XMLObjectManagerTests.allTests),
    testCase(XMLObjectsManagerTests.allTests),
    
    testCase(XMLDocumentContainerTests.allTests),
    testCase(XMLInfoObjectTests.allTests),
    testCase(XMlObjectMapperTests.allTests),
    testCase(XMLObjectTests.allTests),
    
    testCase(PersonMapperTests.allTests),
    testCase(PersonTests.allTests)
])
