import XCTest
@testable import XMLDatabase

class PersonsXMLDatabaseTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private var basePath: URL?
    private var personsXMLContent: String?
    private var personsLockedXMLFilePath: URL?
    private var personsUnlockedXMLFilePath: URL?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        basePath = Bundle.init(for: PersonsXMLDatabaseTests.self).resourceURL!
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName><lastName>Pauls</lastName></person></persons>"
        personsLockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        personsUnlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: personsLockedXMLFilePath!)
        removeFileIfExists(file: personsUnlockedXMLFilePath!)
        
        super.tearDown()
    }
    
    
    // MARK: unlock xml files
    
    func testXMLDatabaseWithLockedFiles() {
        do {
            try personsXMLContent!.write(to: personsLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: personsLockedXMLFilePath!.path))
            
            _ = try PersonsXMLDatabase(url: basePath!)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testXMLDatabaseWithAddressesLockedFile() {
        do {
            try personsXMLContent!.write(to: personsUnlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: personsUnlockedXMLFilePath!.path))
            
            _ = try PersonsXMLDatabase(url: basePath!)
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testXMLDatabaseWithPersonsLockedFile() {
        do {
            try personsXMLContent!.write(to: personsLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: personsLockedXMLFilePath!.path))
            
            _ = try PersonsXMLDatabase(url: basePath!)
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    /*
    func testAddManyPersons() {
        // create xml file
        XCTAssertNoThrow(try personsXMLContent!.write(to: personsLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssert(FileManager.default.fileExists(atPath: personsLockedXMLFilePath!.path))
        
        // init XML database
        var db: PersonsXMLDatabase?
        XCTAssertNoThrow(db = try PersonsXMLDatabase(url: basePath!))
        
        // add and save 5000 persons
        var person: Person?
        for _ in 0...5000 {
            XCTAssertNoThrow(try person = Person(id: db!.persons.nextId, gender: .male, firstName: "Peter"))
            XCTAssertNoThrow(try db!.persons.addObject(object: person!))
        }
        XCTAssertNoThrow(try db!.persons.save())
    }*/
}

extension PersonsXMLDatabaseTests {
    static var allTests = [
        ("testXMLDatabaseWithLockedFiles", testXMLDatabaseWithLockedFiles),
        ("testXMLDatabaseWithAddressesLockedFile", testXMLDatabaseWithAddressesLockedFile),
        ("testXMLDatabaseWithPersonsLockedFile", testXMLDatabaseWithPersonsLockedFile),
        //("testAddManyPersons", testAddManyPersons)
        ]
}
