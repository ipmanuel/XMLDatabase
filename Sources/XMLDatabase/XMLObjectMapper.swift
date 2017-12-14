//
//  XMLObjectMapper.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 23.11.17.
//

import Foundation
import SWXMLHash

public protocol XMLObjectMapper: class {
    associatedtype ObjectType: XMLObject
    
    /// Returns an XMLObject which is specified in ObjectType from a XMLIndexer object
    static func toXMLObject(from: XMLIndexer, at: URL) throws -> ObjectType
    
    /// Returns an XMLElement based the data of an ObjectType
    static func toXMLElement(from: ObjectType) -> Foundation.XMLElement
}

extension XMLObjectMapper {
    
    /// Returns an id as an Int from an attribute of a XML element
    public static func getAttributeId(of xmlElement: SWXMLHash.XMLElement, at url: URL) throws -> Int {
        let idString = try getAttributeValue(of: xmlElement, name: "id", at: url)
        
        return try XMLObject.getId(from: idString)
    }
    
    /// Returns a specific XML element found in a XMLIndexer object
    public static func getXMLElement(of xmlIndexer: XMLIndexer, name: String, at url: URL) throws -> SWXMLHash.XMLElement {
        guard let xmlElement = xmlIndexer[name].element else {
            throw XMLObjectsError.requiredElementIsMissing(element: name, at: url)
        }
        
        return xmlElement
    }
    
    /// Returns an attribute value of a XML element
    public static func getAttributeValue(of xmlElement: SWXMLHash.XMLElement, name: String, at url: URL) throws -> String {
        guard let attribute = xmlElement.attribute(by: name) else {
            throw XMLObjectsError.requiredAttributeIsMissing(element: xmlElement.name, attribute: name, at: url)
        }
        
        return attribute.text
    }
    
    /// Returns the root XML element of a XMLIndexer object
    public static func getRootXMLElement(of xmlIndexer: XMLIndexer, at url: URL) throws -> SWXMLHash.XMLElement {
        guard let xmlElement = xmlIndexer.element else {
            throw XMLObjectsError.requiredElementIsMissing(element: String(describing: ObjectType.self).lowercased(), at: url)
        }
        
        return xmlElement
    }
}

