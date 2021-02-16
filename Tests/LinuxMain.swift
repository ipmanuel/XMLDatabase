import XCTest
@testable import XMLDatabaseTests

XCTMain([
    testCase(XMLObjectTests.allTests),
    testCase(FileDataManagerTests.allTests),
    testCase(XMLInfoObjectTests.allTests),
    testCase(XMLDocumentContainerTests.allTests),
    testCase(XMLDocumentManagerTests.allTests),
    testCase(XMLObjectsManagerTests.allTests),
    testCase(XMlObjectMapperTests.allTests),
    testCase(PersonMapperTests.allTests),
    testCase(PersonTests.allTests)
])
