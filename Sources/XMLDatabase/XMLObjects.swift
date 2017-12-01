//
//  XMLObjects.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 23.11.17.
//

import Foundation
import SWXMLHash

// Convention: All XML should be sorted, even if not they will be after saving first time

// MARK: XMLObjects

/// XMLObjects manage all objects with a specific type of a XML file
class XMLObjects<MapperType: XMLObjectMapper> {
    
    
    // MARK: Properties
    
    /// The URL, where the corresponding XML file is located
    /// -note: The file url changes, because after initializing file is locked by adding `_` at the beginning of the filename
    private var xmlFileURL: URL
    
    /// The URL, where the unlocked XML file should be located
    private let xmlUnlockedFileURL: URL
    
    /// The URL, where the locked XML file should be located
    private let xmlLockedFileURL: URL
    
    /// The XML document, which represents the XML file as an object
    private var xmlDocument: XMLDocument
    
    /// The name of the object which XMLObjects deal with
    private let objectName: String
    
    /// The name of the object in plural
    private let objectNamePlural: String
    
    /// The array with saved objects
    private var savedObjects: [MapperType.ObjectType]
    
    /// The array with unsaved objects
    /// -note: all added objectes will be put in there
    private var unsavedObjects: [MapperType.ObjectType]
    
    /// Return the amount of saved objects counted
    public var count: Int {
        return savedObjects.count
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
                let first = nextIds.first!
                return first
            }
            return maxId + 1
        }
    }
    
    
    // MARK: Init
    
    /// Set all properties and check wether the XML file is locked or does not exist
    init(xmlFileURL: URL) throws {
        savedObjectsIds = []
        savedObjects = []
        unsavedObjects = []
        unsavedObjectsIds = []
        nextIds = []
        maxId = 0
        objectName = String(describing: MapperType.ObjectType.self)
        objectNamePlural = xmlFileURL.deletingPathExtension().lastPathComponent.capitalized
        xmlUnlockedFileURL = xmlFileURL.deletingLastPathComponent().appendingPathComponent("\(objectNamePlural).xml")
        xmlLockedFileURL = xmlFileURL.deletingLastPathComponent().appendingPathComponent("_\(objectNamePlural).xml")
        self.xmlFileURL = xmlFileURL
        
        // check
        let fileManager = FileManager.default
        let firstCharacter = objectNamePlural[objectNamePlural.startIndex]
        
        guard firstCharacter != "_" else {
            throw XMLObjectsError.invalidXMLFilename(at: xmlFileURL)
        }
        guard !fileManager.fileExists(atPath: xmlLockedFileURL.path) else {
            throw XMLObjectsError.xmlFileIsLocked(at: xmlLockedFileURL)
        }
        guard fileManager.fileExists(atPath: xmlUnlockedFileURL.path) else {
            throw XMLObjectsError.xmlFileDoesNotExist(at: xmlUnlockedFileURL)
        }
        
        // lock file
        let lockedFileName = "_\(objectNamePlural).xml"
        try self.xmlFileURL.rename(newName: lockedFileName)
        
        
        // init XMLDocument
        if fileManager.fileExists(atPath: xmlUnlockedFileURL.path) {
            let rootElement = Foundation.XMLElement(name: objectNamePlural.lowercased())
            xmlDocument = Foundation.XMLDocument(rootElement: rootElement)
        } else {
            xmlDocument = try Foundation.XMLDocument(contentsOf: self.xmlFileURL, options: XMLNode.Options.documentTidyXML)
            try importObjects()
        }
    }
    
    /// Unlock the XML file
    deinit {
        do {
            try self.xmlFileURL.rename(newName: xmlUnlockedFileURL.lastPathComponent)
        } catch {
            print("\(error)")
        }
    }
    
    
    // MARK: Public Methods
    
    /// Insert object with right index in array unsavedObjects and save its id in unsavedObjectsIds
    /**
     Executes the closure on a background queue after a set amount of seconds.
     
     - parameter delay:   Delay in seconds
     - parameter closure: Code to execute after delay
     */
    func addObject(object: MapperType.ObjectType) throws {
        guard !unsavedObjectsIds.contains(object.id), !savedObjectsIds.contains(object.id) else {
            throw XMLObjectsError.idExistsAlready(id: object.id, at: xmlUnlockedFileURL)
        }
        unsavedObjects.append(object)
        unsavedObjectsIds.append(object.id)
        addId(value: object.id)
    }
    
    
    // MARK: Actions on XML file
    
    /// Copy all unsaved objects to saved objects and insert the into XMLDocument ordered by id
    public func save() throws {
        if (unsavedObjects.count > 0) {
            let alreadySavedObjects = savedObjects.count
            savedObjects += unsavedObjects
            savedObjectsIds += unsavedObjectsIds
            savedObjects.sort(by: {$0.id < $1.id})
            savedObjectsIds.sort()
            
            for i in 0..<alreadySavedObjects {
                xmlDocument.rootElement()!.replaceChild(at: i, with: MapperType.toXML(object: savedObjects[i]))
            }
            for i in alreadySavedObjects..<savedObjects.count {
                xmlDocument.rootElement()!.addChild(MapperType.toXML(object: savedObjects[i]))
            }
            unsavedObjectsIds.removeAll()
            unsavedObjects.removeAll()
            
            try xmlDocument.xmlData(options: XMLNode.Options.nodePrettyPrint).write(to: xmlFileURL)
        }
    }
    
    
    /// Delete a saved/unsaved object by removing from arrays and additionally remove from XMLDocument for a saved object
    func deleteObject(id: Int) {
        if (savedObjectsIds+unsavedObjectsIds).contains(id) {
            if let index = getIndexOfSavedObjectsBy(id: id), let indexId = getIndexOfSavedObjectsIdsBy(id: id) {
                savedObjects.remove(at: index)
                savedObjectsIds.remove(at: indexId)
                xmlDocument.rootElement()!.removeChild(at: index)
                deleteId(value: id)
            } else if let index = getIndexOfUnsavedObjectsBy(id: id), let indexId = getIndexOfUnsavedObjectsIdsBy(id: id) {
                unsavedObjects.remove(at: index)
                unsavedObjectsIds.remove(at: indexId)
                deleteId(value: id)
            }
        }
    }
    
    /// Return a saved object selected by index
    func get(at index: Int) -> MapperType.ObjectType {
        return savedObjects[index]
    }
    
    /// Return a saved object selected by id
    func getBy(id: Int) -> MapperType.ObjectType? {
        guard savedObjectsIds.contains(id) else {
            return nil
        }
        
        return savedObjects.filter{$0.id == id}[0]
    }
    
    
    // MARK: Private Methods
    
    private func importObjects() throws {
        let xmlParsed = SWXMLHash.parse(xmlDocument.xmlString)
        let rootXMLElement = objectNamePlural.lowercased()
        guard xmlParsed[rootXMLElement].element != nil else {
            throw XMLObjectsError.rootXMLElementWasNotFound(rootElement: rootXMLElement, at: xmlUnlockedFileURL)
        }
        let objects = xmlParsed[rootXMLElement][objectName.lowercased()].all
        
        for object in objects {
            try addObject(object: try MapperType.toObject(element: object, at: xmlUnlockedFileURL))
        }
        
        // imported objects should not be saved a second time
        self.savedObjects = unsavedObjects
        self.savedObjectsIds = unsavedObjectsIds
        unsavedObjects.removeAll()
        unsavedObjectsIds.removeAll()
    }
    
    /// Methode to set the next ids by filling the array nextIds
    private func addId(value id: Int) {
        // id is in nextIds
        if (nextIds.contains(id)) {
            nextIds.remove(at: nextIds.index(of: id)!)
        }
        
        // there are empty ids between
        if id > maxId {
            for i in maxId+1..<id {
                nextIds.append(i)
            }
        }
        maxId = max(maxId, id)
    }
    
    /// add the deleted id to the array nextId and adjust possibly maxId
    private func deleteId(value id: Int) {
        nextIds.append(id)
        nextIds.sort()
        
        if id == maxId {
            if nextIds.count > 0 {
                var previousId: Int = nextIds.last!
                var currentId: Int = 0
                for i in 0..<nextIds.count {
                    currentId = nextIds[nextIds.count-1-i]
                    if previousId - currentId > 1 {
                        break
                    }
                    previousId = currentId
                }
                maxId = currentId - 1
            } else {
                maxId -= 1
            }
        }
    }
    
    private func getIndexOfSavedObjectsBy(id: Int) -> Int? {
        for (index, object) in savedObjects.enumerated() {
            if object.id == id {
                return index
            }
        }
        return nil
    }
    
    private func getIndexOfUnsavedObjectsBy(id: Int) -> Int? {
        for (index, object) in unsavedObjects.enumerated() {
            if object.id == id {
                return index
            }
        }
        return nil
    }
    
    private func getIndexOfSavedObjectsIdsBy(id: Int) -> Int? {
        for (index, objectId) in savedObjectsIds.enumerated() {
            if objectId == id {
                return index
            }
        }
        return nil
    }
    
    private func getIndexOfUnsavedObjectsIdsBy(id: Int) -> Int? {
        for (index, objectId) in unsavedObjectsIds.enumerated() {
            if objectId == id {
                return index
            }
        }
        return nil
    }
}
