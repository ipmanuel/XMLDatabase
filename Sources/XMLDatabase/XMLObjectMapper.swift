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
    
    /// Return an object with a type which is specified in ObjectType from an XML element
    static func toObject(xmlIndexer: XMLIndexer, at: URL) throws -> ObjectType
    
    /// Return an XMLElement with the data of the object
    static func toXML(object: ObjectType) -> Foundation.XMLElement
}

extension XMLObjectMapper {
    
    /// Return an id as Int from an attribute of a XML element
    public static func getId(from xmlElement: SWXMLHash.XMLElement, at url: URL) throws -> Int {
        let idString = try getElementAttributeValue(xmlElement: xmlElement, name: "id", at: url)
        
        return try XMLObject.getId(from: idString)
    }
    
    /// Return an XML element
    public static func getElement(xmlIndexer: XMLIndexer, name: String, url: URL) throws -> SWXMLHash.XMLElement {
        guard let xmlElement = xmlIndexer[name].element else {
            throw XMLObjectsError.requiredElementIsMissing(element: name, at: url)
        }
        
        return xmlElement
    }
    
    /// Return an attribute value of an XML element
    public static func getElementAttributeValue(xmlElement: SWXMLHash.XMLElement, name: String, at url: URL) throws -> String {
        guard let attribute = xmlElement.attribute(by: name) else {
            throw XMLObjectsError.requiredAttributeIsMissing(element: xmlElement.name, attribute: name, at: url)
        }
        
        return attribute.text
    }
}

