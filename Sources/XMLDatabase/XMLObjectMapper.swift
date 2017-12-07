//
//  XMLObjectMapper.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 23.11.17.
//

import Foundation
import SWXMLHash

protocol XMLObjectMapper: class {
    associatedtype ObjectType: XMLObject
    
    /// Returns an object with a type which is specified in ObjectType from an XML element
    static func toObject(element: XMLIndexer, at: URL) throws -> ObjectType
    
    /// Returns an XMLElement with the data of the object
    static func toXML(object: ObjectType) -> Foundation.XMLElement
}

extension XMLObjectMapper {
    static func getId(from xmlElement: XMLIndexer, at url: URL) throws -> Int {
        guard let element = xmlElement.element else {
            throw XMLObjectsError.requiredElementIsMissing(element: String(describing: Self.ObjectType.self).lowercased(), at: url)
        }
        guard let idString = element.attribute(by: "id")?.text else {
            throw XMLObjectsError.requiredAttributeIsMissing(element: element.name, attribute: "id", at: url)
        }
        
        return try XMLObject.getId(from: idString)
    }
}
