import XCTest
@testable import XMLDatabase

class PersonsTests: XCTestCase {
    // basePath
    private var basePath: URL?
    
    // persons locked XMLFile
    private var personsXMLContent: String?
    private var personsLockedXMLFilePath: URL?
    private var personsUnlockedXMLFilePath: URL?
    
    override func setUp() {
        super.setUp()
        
        // basePath
        basePath = Bundle.init(for: PersonsTests.self).resourceURL!
        
        // persons locked and unlocked xml files
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><relation>me</relation><firstName>Manuel</firstName><lastName>Pauls</lastName></person></persons>"
        personsLockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        personsUnlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        URL.removeFileIfExists(file: personsLockedXMLFilePath!)
        URL.removeFileIfExists(file: personsUnlockedXMLFilePath!)
        
        super.tearDown()
    }
    
    
    // MARK: XMLObjects
    
    func testImportObjects() {
        do {
            createUnlockedXMLFile()
            
            let persons = try Persons(xmlFileURL: personsUnlockedXMLFilePath!)
            let person = try Person(id: persons.nextId, gender: Person.Gender.male, firstName: "Peter")
            try persons.addObject(object: person)
            try persons.save()
            
            let foundPersonImported = persons.getBy(id: 1)!
            XCTAssertEqual(foundPersonImported.id, 1)
            XCTAssertEqual(foundPersonImported.gender, Person.Gender.male)
            XCTAssertEqual(foundPersonImported.firstName, "Manuel")
            
            
            let foundPersonAdded = persons.getBy(id: 2)!
            XCTAssertEqual(foundPersonAdded.id, 2)
            XCTAssertEqual(foundPersonAdded.gender, Person.Gender.male)
            XCTAssertEqual(foundPersonAdded.firstName, "Peter")
            
            XCTAssertTrue(persons.getBy(id: 3) == nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    /*
    func testUnsavedObjects() {
        do {
            createUnlockedXMLFile()
        } catch {
            XCTFail("\(error)")
        }
    }*/
    
    func testInitMultipleInstances() {
        var personsFirst: Persons?
        var personsAfter: Persons?
        
        createUnlockedXMLFile()
        
        XCTAssertNoThrow(personsFirst = try Persons(xmlFileURL: personsUnlockedXMLFilePath!))
        XCTAssertThrowsError(personsAfter = try Persons(xmlFileURL: personsUnlockedXMLFilePath!)) { error in
            guard case XMLObjectsError.xmlFileIsLocked( _) = error else {
                return XCTFail("\(error)")
            }
        }
        
        XCTAssert(personsFirst != nil)
        XCTAssert(personsAfter == nil)
    }
    
    func testXMLFileWithoutRootElement() {
        let personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><addresses></addresses>"
        XCTAssertNoThrow(try personsXMLContent.write(to: personsUnlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssert(FileManager.default.fileExists(atPath: personsUnlockedXMLFilePath!.path))
        XCTAssertThrowsError(try Persons(xmlFileURL: personsUnlockedXMLFilePath!)) { error in
            guard case XMLObjectsError.rootXMLElementWasNotFound( _) = error else {
                return XCTFail("\(error)")
            }
        }
    }
    
    func testConstraintIdShouldBeUnique() {
        createUnlockedXMLFile()
        
        var person: Person?
        var persons: Persons?
        XCTAssertNoThrow(persons = try Persons(xmlFileURL: personsUnlockedXMLFilePath!))
        XCTAssertNoThrow(person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertThrowsError(try persons?.addObject(object: person!)) { error in
            guard case XMLObjectsError.idExistsAlready(let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 1)
        }
    }
    
    
    // MARK: Persons
    /*
    func testConstraintRelationMeShouldExistsOnce() {
        createUnlockedXMLFile()
        
        var person: Person?
        var persons: Persons?
        XCTAssertNoThrow(persons = try Persons(xmlFileURL: personsUnlockedXMLFilePath!))
        XCTAssertNoThrow(person = try Person(id: 2, gender: Person.Gender.male, relation: Person.Relation.me, firstName: "Manuel"))
        XCTAssertThrowsError(try persons?.addObject(object: person!)) { error in
            guard case PersonsError.relationMeExistsMoreThanOnce() = error else {
                return XCTFail("\(error)")
            }
        }
    }*/
    
    private func createUnlockedXMLFile() {
        XCTAssertNoThrow(try personsXMLContent!.write(to: personsUnlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssert(FileManager.default.fileExists(atPath: personsUnlockedXMLFilePath!.path))
    }
}
