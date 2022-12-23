//
//  XMLObjects.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 23.11.17.
//

/*
import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
import SWXMLHash

// Convention: All XML should be sorted, even if not they will be after saving first time

// MARK: XMLObjects

/// XMLObjects manage all objects with a specific type of a XML file
open class XMLObjects<MapperType: XMLObjectMapper> {
    
    
    // MARK: - Properties
    
    /// The URL, where the corresponding XML file is located
    /// -note: The file url changes, because after initializing file is locked by adding `_` at the beginning of the filename
    //private var xmlFileURL: URL
    
    /// The URL, where the unlocked XML file should be located
    //private let xmlUnlockedFileURL: URL
    
    /// The URL, where the locked XML file should be located
    //private let xmlLockedFileURL: URL
    private let manager: XMLDocumentManager
    private var container: XMLDocumentContainer
    
    /// The size of the XML file
    public let fileSize: UInt64
    
    /// The XML document, which represents the XML file as an object
    //private var xmlDocument: Foundation.XMLDocument {
    //    return container
    //}
    
    /// The name of the object which XMLObjects deal with
    private let objectName: String
    
    /// The name of the object in plural
    private let objectNamePlural: String
    
    /// The array with saved objects
    fileprivate var savedObjects: [MapperType.ObjectType]
    
    /// The array with unsaved objects
    /// -note: all added objectes will be put in there
    private var unsavedObjects: [MapperType.ObjectType]
    
    /// Return the amount of saved objects counted
    public var count: Int {
        return savedObjects.count
    }
    
    /// Return the amount of saved and unsaved objects counted
    public var countAll: Int {
        return (savedObjects+unsavedObjects).count
    }
    
    /// The ids of all saved objects
    private var savedObjectsIds: [Int]
    
    /// The ids of all unsaved objects
    private var unsavedObjectsIds: [Int]
    
    /// includes all free ids between 1 and maxId
    private var nextIds: [Int]
    
    /// heighest id of all (unsavedObjectsIds and savedObjectsIds)
    private var maxId: Int
    
    /// Return an id, which is not served by an saved or unsaved object
    /// -note: It generates an id, so that it fills hole after deleting one object
    public var nextId: Int {
        get {
            if nextIds.count > 0 {
                return nextIds.first!
            }
            return maxId + 1
        }
    }
    
    
    // MARK: - Init
    
    /// Set all properties and check wether the XML file is locked or does not exist
    public init(manager: XMLDocumentManager) throws {
        savedObjectsIds = []
        savedObjects = []
        unsavedObjects = []
        unsavedObjectsIds = []
        nextIds = []
        maxId = 0
        
        // get filesize
        var attr: [FileAttributeKey:Any] = [:]
        do {
            attr = try FileManager.default.attributesOfItem(atPath: manager.url.path)
        } catch {
            throw XMLObjectsError.xmlFileSizeReadingFailed(at: manager.url, error: error.localizedDescription)
        }
        fileSize = attr[FileAttributeKey.size] as! UInt64
        
        // lock file and init XMLDocument
        self.manager = manager
        container = try self.manager.loadAndLock()

        objectName = container.infoObject.objectName
        objectNamePlural = container.infoObject.objectNamePlural
        try importObjects()
        
        // check constraints
        try checkConstraintsForSave(objects: savedObjects + unsavedObjects)
    }

    public convenience init(xmlFileURL: URL) throws {
        let manager = try XMLDocumentManager(at: xmlFileURL)
        try self.init(manager: manager)
    }
    
    /// Unlock the XML file
    deinit {
        try? manager.unlock()
    }
    
    
    // MARK: - Open Methods
    
    /// create an empty XML file with a root element same as lowercased XML filename
    open class func createEmptyXMLFile(url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else {
            throw XMLObjectsError.xmlFileExistsAlready(at: url)
        }
        
        let rootElementName = url.deletingPathExtension().lastPathComponent.lowercased()
        _ = Foundation.XMLDocument(rootElement: Foundation.XMLElement(name: rootElementName))
        //try xmlDocument.xmlData.write(to: url)
    }
    
    open func checkConstraintsForAddObject(object: MapperType.ObjectType) throws {
    }
    
    open func checkConstraintsForDeleteObject(id: Int) throws {
    }
    
    open func checkConstraintsForSave(objects: [MapperType.ObjectType]) throws {
    }
    
    
    // MARK: - Public Methods
    
    /// Insert object with right index in array unsavedObjects and save its id in unsavedObjectsIds
    public func addObject(object: MapperType.ObjectType) throws {
        try checkConstraintsForAddObject(object: object)
        
        guard !unsavedObjectsIds.contains(object.id), !savedObjectsIds.contains(object.id) else {
            throw XMLObjectsError.idExistsAlready(id: object.id, at: URL(fileURLWithPath: "/"))//xmlUnlockedFileURL)
        }
        unsavedObjects.append(object)
        unsavedObjectsIds.append(object.id)
        addId(value: object.id)
    }
    
    /// Copy all unsaved objects to saved objects and insert the into XMLDocument ordered by id
    public func save() throws {
        try checkConstraintsForSave(objects: savedObjects + unsavedObjects)
        
        //let alreadySavedObjects = savedObjects.count
        
        if (unsavedObjects.count > 0) {
            savedObjects += unsavedObjects
            savedObjectsIds += unsavedObjectsIds
            savedObjects.sort(by: {$0.id < $1.id})
            savedObjectsIds.sort()
        }
        /*
        var xmlElement: Foundation.XMLElement
        for i in 0..<alreadySavedObjects {
            xmlElement = MapperType.toXMLElement(from: savedObjects[i])
            //try container.replace(at: i, xmlElement: xmlElement)
            //xmlDocument.rootElement()!.replaceChild(at: i, with: MapperType.toXMLElement(from: savedObjects[i]))
        }
        for i in alreadySavedObjects..<savedObjects.count {
            xmlElement = MapperType.toXMLElement(from: savedObjects[i])
            //try container.add(xmlElement: xmlElement, withId: savedObjects[i].id)
            //xmlDocument.rootElement()!.addChild(MapperType.toXMLElement(from: savedObjects[i]))
        }*/
        unsavedObjectsIds.removeAll()
        unsavedObjects.removeAll()
        
        try manager.saveAndUnlock(container: container)
    }
    
    /// Delete a saved/unsaved object by removing from arrays and additionally remove from XMLDocument for a saved object
    public func deleteObject(id: Int) throws {
        if (savedObjectsIds+unsavedObjectsIds).contains(id) {
            try checkConstraintsForDeleteObject(id: id)
            
            if let index = savedObjects.firstIndex(where: {$0.id == id}), let indexId = savedObjectsIds.firstIndex(where: {$0 == id}) {
                savedObjects.remove(at: index)
                savedObjectsIds.remove(at: indexId)
                //try container.remove(withId: id)
                //xmlDocument.rootElement()!.removeChild(at: index)
                deleteId(value: id)
            } else if let index = unsavedObjects.firstIndex(where: {$0.id == id}), let indexId = unsavedObjectsIds.firstIndex(where: {$0 == id}) {
                unsavedObjects.remove(at: index)
                unsavedObjectsIds.remove(at: indexId)
                deleteId(value: id)
            }
        }
    }
    
    /// Return a saved object selected by id
    public func getBy(id: Int) -> MapperType.ObjectType? {
        guard savedObjectsIds.contains(id) else {
            return nil
        }
        
        return savedObjects.filter{$0.id == id}[0]
    }
    
    
    // MARK: - Private Methods
    
    private func importObjects() throws {
        let xmlParsed = container.xmlIndexer//SWXMLHash.parse(xmlDocument.xmlString)
        let rootXMLElement = objectNamePlural.lowercased()
        guard xmlParsed[rootXMLElement].element != nil else {
            throw XMLObjectsError.rootXMLElementWasNotFound(rootElement: rootXMLElement, at: URL(fileURLWithPath: "/"))//xmlUnlockedFileURL)
        }
        let objects = xmlParsed[rootXMLElement][objectName.lowercased()].all
        
        for object in objects {
            try addObject(object: try MapperType.toXMLObject(from: object, at: URL(fileURLWithPath: "/")))//xmlUnlockedFileURL))
        }
        
        // imported objects should not be saved a second time
        self.savedObjects = unsavedObjects
        self.savedObjectsIds = unsavedObjectsIds
        unsavedObjects.removeAll()
        unsavedObjectsIds.removeAll()
    }
    
    /// Method to set the next ids by filling the array nextIds
    private func addId(value id: Int) {
        // id is in nextIds
        if (nextIds.contains(id)) {
            nextIds.remove(at: nextIds.firstIndex(of: id)!)
        }
        
        // there are empty ids between
        if id > maxId {
            for i in maxId+1..<id {
                nextIds.append(i)
            }
        }
        maxId = Swift.max(maxId, id)
    }
    
    /// Add the deleted id to the array nextId and adjust possibly maxId
    private func deleteId(value id: Int) {
        nextIds.append(id)
        nextIds.sort()
        
        if id == maxId {
            if nextIds.count > 0 {
                var previousId: Int = nextIds.last!
                var currentId: Int = 0
                var counter = 0
                for i in 1..<nextIds.count {
                    currentId = nextIds[nextIds.count-1-i]
                    if previousId - currentId > 1 {
                        break
                    }
                    previousId = currentId
                    counter += 1
                }
                maxId = previousId - 1
                
                // delete nextIds bigger than new maxId
                for _ in 0...counter {
                    nextIds.removeLast()
                }
            } else {
                maxId -= 1
            }
        }
    }
}


// MARK: - Sequence Protocol

extension XMLObjects: Sequence {
    public func makeIterator() -> Array<MapperType.ObjectType>.Iterator {
        return savedObjects.makeIterator()
    }
}
*/
