//
//  XMLInfoObjectMapper.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 01.01.21.
//


import Foundation
import FoundationXML
import SWXMLHash

class XMLInfoObjectMapper: XMLObjectMapper {
    typealias ObjectType = XMLInfoObject
    
    static func toXMLObject(from xmlIndexer: XMLIndexer, at url: URL) throws -> XMLInfoObject {
        // XML elements should exists
        let _xmlIndexer = xmlIndexer["Info"]
        let maxIdString = try XMLInfoObjectMapper.getXMLElement(of: _xmlIndexer, name: "MaxId", at: url).text
        let gapIdsString = try XMLInfoObjectMapper.getXMLElement(of: _xmlIndexer, name: "GapIds", at: url).text
        let countString = try XMLInfoObjectMapper.getXMLElement(of: _xmlIndexer, name: "Count", at: url).text
        let objectName = try XMLInfoObjectMapper.getXMLElement(of: _xmlIndexer, name: "ObjectName", at: url).text
        let objectNamePlural = try XMLInfoObjectMapper.getXMLElement(of: _xmlIndexer, name: "ObjectNamePlural", at: url).text
        
        // init info object
        let newXMLInfoObject = try XMLInfoObject(
            maxIdString: maxIdString, 
            gapIdsString: gapIdsString,
            countString: countString,
            objectName: objectName,
            objectNamePlural: objectNamePlural)
        
        return newXMLInfoObject
    }
    
    static func toXMLElement(from infoObject: XMLInfoObject) -> FoundationXML.XMLElement {
        let infoXMLElement = FoundationXML.XMLElement(name: "Info")

        let maxIdXMLElement = FoundationXML.XMLElement(name: "MaxId", 
            stringValue: "\(infoObject.maxId)")

        let gapIdsXMLElement = FoundationXML.XMLElement(name: "GapIds", 
            stringValue: infoObject.gapIds.map{String($0)}.joined(separator:","))

        let countXMLElement = FoundationXML.XMLElement(name: "Count", 
            stringValue: "\(infoObject.count)")

        let objectNameXMLElement = FoundationXML.XMLElement(name: "ObjectName", 
            stringValue: "\(infoObject.objectName)")

        let objectNamePluralXMLElement = FoundationXML.XMLElement(name: "ObjectNamePlural", 
            stringValue: "\(infoObject.objectNamePlural)")
        
        // add XML elements to info XML element
        infoXMLElement.addChild(maxIdXMLElement)
        infoXMLElement.addChild(gapIdsXMLElement)
        infoXMLElement.addChild(countXMLElement)
        infoXMLElement.addChild(objectNameXMLElement)
        infoXMLElement.addChild(objectNamePluralXMLElement)
        
        return infoXMLElement
    }
}
