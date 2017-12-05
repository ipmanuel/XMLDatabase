//
//  XMLObjectsTests.swift
//  XMLDatabaseTests
//
//  Created by Manuel Pauls on 30.11.17.
//

import XCTest
@testable import XMLDatabase

class XMLObjectsTests: XCTestCase {

    // addresses XML file
    private var baseURL: URL?
    private var xmlContent: String?
    private var lockedXMLFileURL: URL?
    private var unlockedXMLFileURL: URL?
    private var xmlObjects: XMLObjects<XMLAddressMapper>?
    
    
    // MARK: Init
    
    override func setUp() {
        super.setUp()
        
        baseURL = Bundle.init(for: XMLObjectsTests.self).resourceURL!
        xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><addresses><address id=\"1\"><city>Berlin</city><street>Spandauer Straße</street></address><address id=\"32\"><city>Amsterdam</city><street>Rozengracht</street></address></addresses>"
        lockedXMLFileURL = baseURL!.appendingPathComponent("_Addresses.xml")
        unlockedXMLFileURL = baseURL!.appendingPathComponent("Addresses.xml")
        do {
            try xmlContent!.write(to: unlockedXMLFileURL!, atomically: true, encoding: String.Encoding.utf8)
            xmlObjects = try XMLObjects<XMLAddressMapper>(xmlFileURL: unlockedXMLFileURL!)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {
        removeFileIfExists(file: lockedXMLFileURL!)
        removeFileIfExists(file: unlockedXMLFileURL!)
        
        super.tearDown()
    }
    
    
    // MARK: XMLObjectsTests
    
    func testLock() {
        // locked XML file should exists, because instance is running
        XCTAssertTrue(FileManager.default.fileExists(atPath: lockedXMLFileURL!.path))
        
        // test to init a second instance
        XCTAssertThrowsError(try Addresses(xmlFileURL: unlockedXMLFileURL!)) { error in
            guard case XMLObjectsError.xmlFileIsLocked( _) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertThrowsError(try Addresses(xmlFileURL: lockedXMLFileURL!)) { error in
            guard case XMLObjectsError.invalidXMLFilename(let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(url.deletingPathExtension().lastPathComponent, "_Addresses")
        }
    }
    
    func testDeinit() {
        xmlObjects = nil
        XCTAssertTrue(FileManager.default.fileExists(atPath: unlockedXMLFileURL!.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: lockedXMLFileURL!.path))
    }
    
    func testImportObjects() {
        XCTAssertEqual(xmlObjects!.count, 2)
        
        // get object with id 1
        if let object = xmlObjects!.getBy(id: 1) {
            XCTAssertEqual(object.id, 1)
            XCTAssertEqual(object.city, "Berlin")
            XCTAssertEqual(object.street, "Spandauer Straße")
        } else {
            XCTFail("Object with id \"1\" was not found.")
        }
        
        // get object with id 32
        if let object = xmlObjects!.getBy(id: 32) {
            XCTAssertEqual(object.id, 32)
            XCTAssertEqual(object.city, "Amsterdam")
            XCTAssertEqual(object.street, "Rozengracht")
        } else {
            XCTFail("Object with id \"32\" was not found.")
        }
    }
    
    func testAddAndSaveObjects() {
        var address: Address?
        XCTAssertNoThrow(address = try Address(id: 5, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        XCTAssertEqual(xmlObjects!.count, 2)
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 3)
        
        // init again
        xmlObjects = nil
        XCTAssertNoThrow(xmlObjects = try XMLObjects<XMLAddressMapper>(xmlFileURL: unlockedXMLFileURL!))
        XCTAssertEqual(xmlObjects!.count, 3)
        xmlObjects = nil
        
        // test file content
        var xmlDocument: XMLDocument?
        XCTAssertNoThrow(xmlDocument = try XMLDocument(contentsOf: unlockedXMLFileURL!, options: XMLNode.Options.documentTidyXML))
        XCTAssertEqual(xmlDocument!.xmlString, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><addresses><address id=\"1\"><city>Berlin</city><street>Spandauer Straße</street></address><address id=\"5\"><city>Cologne</city><street>Ehrenstraße</street></address><address id=\"32\"><city>Amsterdam</city><street>Rozengracht</street></address></addresses>")
    }
    
    func testNextId() {
        var address: Address?
        
        // 1.   addObject(id: 1)    xmlObjects.nextIds = []
        // 2.   addObject(id: 32)   xmlObjects.nextIds = [2,...,31,33,34]
        // 3.   addObject(id: 2)    xmlObjects.nextIds = [3,...,31,33,34]
        // 4.   addObject(id: 3)    xmlObjects.nextIds = [4,...,31,33,34]
        // ...
        // 32.  addObject(id: 31)   xmlObjects.nextIds = [33,34]
        for i in 2...31 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(address = try Address(id: i, city: "Cologne", street: "Ehrenstraße"))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        }
        XCTAssertEqual(xmlObjects!.nextId, 33)
        
        // 33. deleteObject(id: 4)  xmlObjects.nextIds = [4,33,34]
        xmlObjects!.deleteObject(id: 4)
        
        // 34. deleteObject(id: 5)  xmlObjects.nextIds = [4,5,33,34]
        xmlObjects!.deleteObject(id: 5)
        
        // 35. addObject(id: 4)     xmlObjects.nextIds = [5,33,34]
        XCTAssertEqual(xmlObjects!.nextId, 4)
        XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        
        // 36. addObject(id: 5)    xmlObjects.nextIds = [33,34]
        XCTAssertEqual(xmlObjects!.nextId, 5)
        XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        
        // 37. addObject(id: 33)   xmlObjects.nextIds = [34]
        XCTAssertEqual(xmlObjects!.nextId, 33)
        XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        
        // 38. addObject(id: 34)   xmlObjects.nextIds = []
        XCTAssertEqual(xmlObjects!.nextId, 34)
        XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        
        // 39. deleteObject(id: 6)  xmlObjects.nextIds = [6, 35]
        xmlObjects!.deleteObject(id: 6)
        
        // 40. addObject(id: 6)     xmlObjects.nextIds = [35]
        XCTAssertEqual(xmlObjects!.nextId, 6)
        XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        
        // 40. addObject(id: 36)   xmlObjects.nextIds = [35,37,38]
        XCTAssertEqual(xmlObjects!.nextId, 35)
        XCTAssertNoThrow(address = try Address(id: 37, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
        
        // 41. addObject(id: 35)   xmlObjects.nextIds = [37,38]
        XCTAssertEqual(xmlObjects!.nextId, 35)
        XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
    }
    
    func testSimmulateRandomNextId() {
        var object: Address?
        XCTAssertNoThrow(object = try Address(id: 40, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
        
        XCTAssertNoThrow(object = try Address(id: 60, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
        
        // fill from id = 2 to id = 31 by nextId
        for i in 2...31 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(object = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
        }
        
        // fill from id = 33 to id = 39 by nextId
        for i in 33...39 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(object = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
        }
        
        // delete last object
        xmlObjects!.deleteObject(id: 60)
        
        // fill from id = 41 to id = 59 by nextId
        for i in 41...59 {
            XCTAssertEqual(xmlObjects!.nextId, i)
            XCTAssertNoThrow(object = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
        }
        
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 59)
        
        // delete all objects
        for i in 0...59 {
            xmlObjects!.deleteObject(id: i)
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 0)
        
        XCTAssertEqual(xmlObjects!.nextId, 1)
        XCTAssertNoThrow(object = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
    }
    
    func testSimmulateTotallyRandomNextId() {
        var address: Address?
        var randomId: Int
        var insertedIds = [1, 32]
        
        // insert 200 objects with random ids
        for _ in 1...200 {
            randomId = Int(arc4random_uniform(UInt32(400))) + 1
            while(insertedIds.contains(randomId)) {
                randomId = Int(arc4random_uniform(UInt32(400))) + 1
            }
            XCTAssertNoThrow(address = try Address(id: randomId, city: "Cologne", street: "Ehrenstraße"))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: address!))
            insertedIds.append(randomId)
        }
        
        
        // delete randomly 100 objects
        var index: Int
        for _ in 0...200 {
            index = Int(arc4random_uniform(UInt32(insertedIds.count)))
            xmlObjects!.deleteObject(id: insertedIds[index])
            insertedIds.remove(at: index)
        }
        
        // insert objects with nextId
        for _ in 1...400 {
            insertedIds.append(xmlObjects!.nextId)
            XCTAssertNoThrow(address = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
            do {
                try xmlObjects!.addObject(object: address!)
            } catch {
                XCTFail("\(error)")
                break
            }
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        
        var previousId: Int = -1
        for id in insertedIds.sorted() {
            if previousId != -1 {
                XCTAssertTrue(id - previousId == 1)
            }
            previousId = id
        }
    }
    
    func testDelete() {
        // delete saved object
        xmlObjects!.deleteObject(id: 1)
        XCTAssertEqual(xmlObjects!.count, 1)
        
        // delete unsaved object
        var object: Address?
        for _ in 1...60 {
            XCTAssertNoThrow(object = try Address(id: xmlObjects!.nextId, city: "Cologne", street: "Ehrenstraße"))
            XCTAssertNoThrow(try xmlObjects!.addObject(object: object!))
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 61)
        
        // delete an object
        xmlObjects!.deleteObject(id: 1)
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 60)
        
        // delete all objects
        for i in 1...61 {
            xmlObjects!.deleteObject(id: i)
        }
        XCTAssertNoThrow(try xmlObjects!.save())
        XCTAssertEqual(xmlObjects!.count, 0)
        
    }
    
    func testConstraintIdShouldBeUnique() {
        var object: Address?
        XCTAssertNoThrow(object = try Address(id: 1, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertThrowsError(try xmlObjects!.addObject(object: object!)) { error in
            guard case XMLObjectsError.idExistsAlready(let value, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, 1)
            XCTAssertEqual(url.path, unlockedXMLFileURL!.path)
        }
    }
    
    func testXMLFileWithoutRootElement() {
        xmlObjects = nil
        let XMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        XCTAssertNoThrow(try XMLContent.write(to: unlockedXMLFileURL!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssertThrowsError(try XMLObjects<XMLAddressMapper>(xmlFileURL: unlockedXMLFileURL!)) { error in
            guard case XMLObjectsError.rootXMLElementWasNotFound(let rootElement, let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(rootElement, "addresses")
            XCTAssertEqual(url.path, unlockedXMLFileURL!.path)
        }
    }
    
    func testXMLFileDoesNotExist() {
        let xmlFileURL = baseURL!.appendingPathComponent("Test.xml")
        XCTAssertThrowsError(try XMLObjects<XMLAddressMapper>(xmlFileURL: xmlFileURL)) { error in
            guard case XMLObjectsError.xmlFileDoesNotExist(let url) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(url.path, xmlFileURL.path)
        }
    }
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
