//
//  XMLObjectsTests.swift
//  XMLDatabaseTests
//
//  Created by Manuel Pauls on 30.11.17.
//

import XCTest
@testable import XMLDatabase

class XMLObjectsTests: XCTestCase {

    
    // MARK: - Properties
    
    private var baseURL: URL?
    private var xmlContent: String?
    private var lockedXMLFileURL: URL?
    private var unlockedXMLFileURL: URL?
    private var xmlObjects: XMLObjects<PersonMapper>?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        baseURL = Bundle.init(for: XMLObjectsTests.self).resourceURL!
        xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person><person id=\"32\"><gender>female</gender><firstName>Sophie</firstName></person></persons>"
        lockedXMLFileURL = baseURL!.appendingPathComponent("_Persons.xml")
        unlockedXMLFileURL = baseURL!.appendingPathComponent("Persons.xml")
        do {
            try xmlContent!.write(to: unlockedXMLFileURL!, atomically: true, encoding: String.Encoding.utf8)
            xmlObjects = try XMLObjects<PersonMapper>(xmlFileURL: unlockedXMLFileURL!)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {
        removeFileIfExists(file: lockedXMLFileURL!)
        removeFileIfExists(file: unlockedXMLFileURL!)
        
        super.tearDown()
    }
    
    
    // MARK: - Init tests
    
    func testLock() {
        // locked XML file should exists, because instance is running
        XCTAssertTrue(FileManager.default.fileExists(atPath: lockedXMLFileURL!.path))
        
        // test to init a second instance
        XCTAssertThrowsError(try Persons(xmlFileURL: unlockedXMLFileURL!)) { error in
            guard case XMLObjectsError.xmlFileIsLocked( _) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertThrowsError(try Persons(xmlFileURL: lockedXMLFileURL!)) { error in
            guard case XMLObjectsError.invalidXMLFilename(let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(url.deletingPathExtension().lastPathComponent, "_Persons")
        }
    }
    
    func testXMLFileWithoutRootElement() {
        xmlObjects = nil
        let XMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        XCTAssertNoThrow(try XMLContent.write(to: unlockedXMLFileURL!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssertThrowsError(try XMLObjects<PersonMapper>(xmlFileURL: unlockedXMLFileURL!)) { error in
            guard case XMLObjectsError.rootXMLElementWasNotFound(let rootElement, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(rootElement, "persons")
            XCTAssertEqual(url.path, unlockedXMLFileURL!.path)
        }
    }
    
    func testXMLFileDoesNotExist() {
        let xmlFileURL = baseURL!.appendingPathComponent("Test.xml")
        XCTAssertThrowsError(try XMLObjects<PersonMapper>(xmlFileURL: xmlFileURL)) { error in
            guard case XMLObjectsError.xmlFileDoesNotExist(let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(url.path, xmlFileURL.path)
        }
    }
    
    func testDeinit() {
        xmlObjects = nil
        XCTAssertTrue(FileManager.default.fileExists(atPath: unlockedXMLFileURL!.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: lockedXMLFileURL!.path))
    }
    
    
    // MARK: - Method `importObjects()` tests
    
    func testImportObjects() {
        XCTAssertEqual(xmlObjects!.count, 2)
        
        // get object with id 1
        if let object = xmlObjects!.getBy(id: 1) {
            XCTAssertEqual(object.id, 1)
            XCTAssertEqual(object.gender, Person.Gender.male)
            XCTAssertEqual(object.firstName, "Manuel")
        } else {
            XCTFail("Object with id \"1\" was not found.")
        }
        
        // get object with id 32
        if let object = xmlObjects!.getBy(id: 32) {
            XCTAssertEqual(object.id, 32)
            XCTAssertEqual(object.gender, Person.Gender.female)
            XCTAssertEqual(object.firstName, "Sophie")
        } else {
            XCTFail("Object with id \"32\" was not found.")
        }
    }
    
    // MARK: - Methods `addObject()`, `save()` tests
    
    func testAddAndSaveObjects() {
        var xmlObject: Person?
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: 5))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        XCTAssertEqual(xmlObjects!.count, 2)
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 3)
        
        // init again
        xmlObjects = nil
        XCTAssertNoThrow(xmlObjects = try XMLObjects<PersonMapper>(xmlFileURL: unlockedXMLFileURL!))
        XCTAssertEqual(xmlObjects?.count, 3)
        xmlObjects = nil
        
        // test file content
        var xmlDocument: XMLDocument?
        XCTAssertNoThrow(xmlDocument = try XMLDocument(contentsOf: unlockedXMLFileURL!, options: XMLNode.Options.documentTidyXML))
        XCTAssertEqual(xmlDocument!.xmlString, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person><person id=\"5\"><gender>male</gender><firstName>Manuel</firstName></person><person id=\"32\"><gender>female</gender><firstName>Sophie</firstName></person></persons>")
    }
    
    func testConstraintIdShouldBeUnique() {
        var xmlObject: Person?
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: 1))
        XCTAssertThrowsError(try xmlObjects!.addObject(object: xmlObject!)) { error in
            guard case XMLObjectsError.idExistsAlready(let value, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 1)
            XCTAssertEqual(url.path, unlockedXMLFileURL!.path)
        }
    }
    
    func testChangeXMLObjectAndSave() {
        // deinit
        xmlObjects = nil
        
        // init persons
        var persons: Persons?
        var person: Person?
        XCTAssertNoThrow(persons = try Persons(xmlFileURL: unlockedXMLFileURL!))
        XCTAssertNoThrow(person = persons?.getBy(id: 1))
        XCTAssertNoThrow(try person?.change(firstName: "Sarah"))
        persons?.getBy(id: 1)?.change(gender: Person.Gender.female)
        XCTAssertNoThrow(try persons?.save())
        
        // close instance and reinit
        persons = nil
        person = nil
        XCTAssertNoThrow(persons = try Persons(xmlFileURL: unlockedXMLFileURL!))
        XCTAssertNoThrow(person = persons?.getBy(id: 1))
        XCTAssertEqual(person?.firstName, "Sarah")
        XCTAssertEqual(person?.gender, Person.Gender.female)
    }
    
    // MARK: - Property `nextId` tests
    
    func testPropertyNextId() {
        var xmlObject: Person?
        
        // 1.   addObject(id: 1)    xmlObjects.nextIds = []
        // 2.   addObject(id: 32)   xmlObjects.nextIds = [2,...,31,33,34]
        // 3.   addObject(id: 2)    xmlObjects.nextIds = [3,...,31,33,34]
        // 4.   addObject(id: 3)    xmlObjects.nextIds = [4,...,31,33,34]
        // ...
        // 32.  addObject(id: 31)   xmlObjects.nextIds = [33,34]
        for i in 2...31 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: i))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        }
        XCTAssertEqual(xmlObjects!.nextId, 33)
        
        // 33. deleteObject(id: 4)  xmlObjects.nextIds = [4,33,34]
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 4))
        
        // 34. deleteObject(id: 5)  xmlObjects.nextIds = [4,5,33,34]
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 5))
        
        // 35. addObject(id: 4)     xmlObjects.nextIds = [5,33,34]
        XCTAssertEqual(xmlObjects!.nextId, 4)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // 36. addObject(id: 5)    xmlObjects.nextIds = [33,34]
        XCTAssertEqual(xmlObjects!.nextId, 5)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // 37. addObject(id: 33)   xmlObjects.nextIds = [34]
        XCTAssertEqual(xmlObjects!.nextId, 33)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // 38. addObject(id: 34)   xmlObjects.nextIds = []
        XCTAssertEqual(xmlObjects!.nextId, 34)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // 39. deleteObject(id: 6)  xmlObjects.nextIds = [6, 35]
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 6))
        
        // 40. addObject(id: 6)     xmlObjects.nextIds = [35]
        XCTAssertEqual(xmlObjects!.nextId, 6)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // 41. addObject(id: 37)   xmlObjects.nextIds = [35,37,38]
        XCTAssertEqual(xmlObjects!.nextId, 35)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: 37))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // 42. addObject(id: 35)   xmlObjects.nextIds = [35,38]
        XCTAssertEqual(xmlObjects!.nextId, 35)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
    }
    
    func testSimmulateRandomNextId() {
        var xmlObject: Person?
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: 40))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: 60))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // fill from id = 2 to id = 31 by nextId
        for i in 2...31 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        }
        
        // fill from id = 33 to id = 39 by nextId
        for i in 33...39 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        }
        
        // delete last object
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 60))
        
        // fill from id = 41 to id = 59 by nextId
        for i in 41...59 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        }
        
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 59)
        
        // delete all objects
        for i in 0...59 {
            XCTAssertNoThrow(try xmlObjects!.deleteObject(id: i))
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 0)
        
        // add object with id = 1
        XCTAssertEqual(xmlObjects!.nextId, 1)
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        
        // add object with id = 70
        XCTAssertNoThrow(xmlObject = try getXMLObject(id: 70))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        XCTAssertEqual(xmlObjects!.nextId, 2)
        
        // delete object with id = 1
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 1))
        
        // delete object with id = 70
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 70))
        XCTAssertEqual(xmlObjects!.nextId, 1)
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 0)
    }
    
    func testSimmulateTotallyRandomNextId() {
        var xmlObject: Person?
        var randomId: Int
        var insertedIds = [1, 32]
        
        // insert 400 objects with random ids
        for _ in 1...400 {
            randomId = Int(arc4random_uniform(UInt32(500))) + 1
            while(insertedIds.contains(randomId)) {
                randomId = Int(arc4random_uniform(UInt32(500))) + 1
            }
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: randomId))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
            insertedIds.append(randomId)
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(insertedIds.count, xmlObjects!.count)
        
        
        // delete randomly 300 objects
        var index: Int
        for _ in 0...300 {
            index = Int(arc4random_uniform(UInt32(insertedIds.count)))
            XCTAssertNoThrow(try xmlObjects!.deleteObject(id: insertedIds[index]))
            insertedIds.remove(at: index)
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(insertedIds.count, xmlObjects!.count)
        
        
        // insert objects with nextId
        for _ in 1...400 {
            let id = xmlObjects!.nextId
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
            insertedIds.append(id)
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(insertedIds.count, xmlObjects!.count)
        
        var previousId: Int = -1
        for id in (insertedIds).sorted() {
            if previousId != -1 {
                XCTAssertTrue(id - previousId == 1, "id: \(id); previousId: \(previousId)")
            }
            previousId = id
        }
    }
    
    
    // MARK: - Method `deleteObject()` tests
    
    func testDelete() {
        // delete saved object
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 1))
        XCTAssertEqual(xmlObjects!.count, 1)
        
        // delete unsaved object
        var xmlObject: Person?
        for _ in 1...60 {
            XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 61)
        
        // delete an object
        XCTAssertNoThrow(try xmlObjects!.deleteObject(id: 1))
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 60)
        
        // delete all objects
        for i in 1...61 {
            XCTAssertNoThrow(try xmlObjects!.deleteObject(id: i))
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 0)
    }
    
    
    // MARK: - Method `importObjects()` tests
    
    func testCreateEmptyXMLFile() {
        XCTAssertNoThrow(try XMLObjects<PersonMapper>.createEmptyXMLFile(url: unlockedXMLFileURL!))
        XCTAssertTrue(FileManager.default.fileExists(atPath: unlockedXMLFileURL!.path))
        
        var xmlDocument: XMLDocument?
        XCTAssertNoThrow(xmlDocument = try XMLDocument(contentsOf: unlockedXMLFileURL!, options: XMLNode.Options.documentTidyXML))
        let rootElement = xmlDocument!.rootElement()!
        XCTAssertEqual(rootElement.name, "persons")
        XCTAssertTrue(rootElement.children == nil)
    }
    
    
    // MARK: - Method `makeIterator()` tests
    
    func testIterateThroughObjects() {
        let ids = [1, 32]
        for (index,xmlObject) in xmlObjects!.enumerated() {
            XCTAssertEqual(xmlObject.id, ids[index])
        }
    }
    
    
    // MARK: - Performance tests
    /*
    func testAddManyXMLObjects() {
        // create xml file
        XCTAssertNoThrow(try xmlContent!.write(to: lockedXMLFileURL!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssert(FileManager.default.fileExists(atPath: lockedXMLFileURL!.path))
        
        // add and save 5000 persons
        self.measure {
            do {
                var xmlObject: Person?
                for _ in 0...5000 {
                    XCTAssertNoThrow(xmlObject = try getXMLObject(id: xmlObjects!.nextId))
                    XCTAssertNoThrow(try xmlObjects!.addObject(object: xmlObject!))
                }
                XCTAssertNoThrow(try xmlObjects!.save())
            } catch {
                
            }
        }
    }*/
    
    
    // MARK: - Private Methods
    
    private func getXMLObject(id: Int) throws -> Person {
        return try Person(id: id, gender: .male, firstName: "Manuel")
    }
}

extension XMLObjectsTests {
    static var allTests = [
        ("testLock", testLock),
        ("testDeinit", testDeinit),
        ("testImportObjects", testImportObjects),
        ("testAddAndSaveObjects", testAddAndSaveObjects),
        ("testPropertyNextId", testPropertyNextId),
        ("testSimmulateRandomNextId", testSimmulateRandomNextId),
        ("testSimmulateTotallyRandomNextId", testSimmulateTotallyRandomNextId),
        ("testDelete", testDelete),
        ("testConstraintIdShouldBeUnique", testConstraintIdShouldBeUnique),
        ("testXMLFileWithoutRootElement", testXMLFileWithoutRootElement),
        ("testXMLFileDoesNotExist", testXMLFileDoesNotExist),
        ("testCreateEmptyXMLFile", testCreateEmptyXMLFile)
    ]
}

internal func removeFileIfExists(file url: URL) {
    do {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    } catch {
        print("File could not removed \(url.path): \(error)")
    }
}
