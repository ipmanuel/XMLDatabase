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
    
    /// Returns generate an object with a type which is specified in ObjectType from an XML element
    static func toObject(element: XMLIndexer) throws -> ObjectType
    static func toXML(object: ObjectType) -> Foundation.XMLElement
}

extension XMLObjectMapper {
    static func getId(from xmlElement: XMLIndexer) throws -> Int {
        guard let element = xmlElement.element else {
            throw XMLObjectsError.requiredElementIsMissing(element: "? extends XMLObject", in: String(describing: Self.self))
        }
        guard let idString = element.attribute(by: "id")?.text else {
            throw XMLObjectsError.requiredAttributeIsMissing(element: element.name, attribute: "id", in: String(describing: Self.self))
        }
        
        return try XMLObject.getId(from: idString)
    }
}
