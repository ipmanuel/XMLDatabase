//
//  XMLObject.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 23.11.17.
//

import Foundation

/// XML Object with an id
class XMLObject {
    
    
    // MARK: Properties
    
    private var idMutable: Int
    var id: Int {
        return idMutable
    }
    
    
    // MARK: Init
    
    init(id: Int) throws {
        guard XMLObject.isValid(id: id) else {
            throw XMLObjectError.invalidId(value: id)
        }
        idMutable = id
    }
    
    
    // MARK: Validate
    
    class func isValid(id: Int) -> Bool {
        return id > 0
    }
    
    
    // MARK: Convert
    
    class func getId(from idString: String) throws -> Int {
        guard let id = Int(idString) else {
            throw XMLObjectError.invalidIdString(value: idString)
        }
        guard XMLObject.isValid(id: id) else {
            throw XMLObjectError.invalidId(value: id)
        }
        
        return id
    }
}

/// An enumeration for the various errors of XMLObject.
enum XMLObjectError: Error {
    case invalidId(value: Int)
    case invalidIdString(value: String)
}
