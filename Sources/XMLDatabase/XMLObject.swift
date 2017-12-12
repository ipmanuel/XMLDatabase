//
//  XMLObject.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 23.11.17.
//

import Foundation

/// XML Object with an id
open class XMLObject {
    
    
    // MARK: - Properties
    
    private var idMutable: Int
    public var id: Int {
        return idMutable
    }
    
    
    // MARK: - Init
    
    public init(id: Int) throws {
        guard XMLObject.isValid(id: id) else {
            throw XMLObjectError.invalidId(value: id)
        }
        idMutable = id
    }
    
    
    // MARK: - Validate
    
    public class func isValid(id: Int) -> Bool {
        return id > 0
    }
    
    
    // MARK: - Convert
    
    public class func getId(from idString: String) throws -> Int {
        guard let id = Int(idString) else {
            throw XMLObjectError.invalidIdString(value: idString)
        }
        guard XMLObject.isValid(id: id) else {
            throw XMLObjectError.invalidId(value: id)
        }
        
        return id
    }
}
