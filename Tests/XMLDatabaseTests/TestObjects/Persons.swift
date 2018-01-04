//
//  Person.swift
//  PersonsXMLDatabase
//
//  Created by Manuel Pauls on 14.12.17.
//

import Foundation
import XMLDatabase

enum PersonsError: Error, Equatable {
    case onePersonDoesNotExist()
    case atLeastOnePersonShouldExist()
    
    static func ==(lhs: PersonsError, rhs: PersonsError) -> Bool {
        switch lhs {
        case .onePersonDoesNotExist:
            if case .onePersonDoesNotExist() = rhs {
                return true
            }
        case .atLeastOnePersonShouldExist:
            if case .atLeastOnePersonShouldExist() = rhs {
                return true
            }
        }
        return false
    }
}


class Persons: XMLObjects<PersonMapper> {
    
    
    // MARK: - Properties
    
    // var for constraint: one person should exists
    private var onePersonExists: Bool
    
    
    // MARK: - Init
    
    override init(xmlFileURL: URL) throws {
        onePersonExists = false
        
        // init
        try super.init(xmlFileURL: xmlFileURL)
    }
    
    
    // MARK: - XMLObjects
    
    override func checkConstraintsForAddObject(object: Person) throws {
        try super.checkConstraintsForAddObject(object: object)
        
        // constraint: there should exists at least one person
        onePersonExists = true
    }
    
    
    override func checkConstraintsForDeleteObject(id: Int) throws {
        try super.checkConstraintsForDeleteObject(id: id)
        
        guard self.countAll > 1 else {
            throw PersonsError.atLeastOnePersonShouldExist()
        }
    }
    
    override func checkConstraintsForSave(objects: [Person]) throws {
        try super.checkConstraintsForSave(objects: objects)
        
        guard onePersonExists == true else {
            throw PersonsError.onePersonDoesNotExist()
        }
    }
    
    override open class func createEmptyXMLFile(url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else {
            throw XMLObjectsError.xmlFileExistsAlready(at: url)
        }
        
        let rootElementName = url.deletingPathExtension().lastPathComponent.capitalized
        let xmlDocument = XMLDocument(rootElement: Foundation.XMLElement(name: rootElementName))
        try xmlDocument.xmlData.write(to: url)
    }
    
    
    /*
     override func addObject(object: Person) throws {
     try super.addObject(object: object)
     // constraint: there should exists at least one person
     onePersonExists = true
     }
     
     override func save() throws {
     try checkConstraintOnePersonExists()
     try super.save()
     }
     
     override func deleteObject(id: Int) throws {
     guard self.count > 1 else {
     throw PersonsError.atLeastOnePersonShouldExist()
     }
     try super.deleteObject(id: id)
     }*/
}
