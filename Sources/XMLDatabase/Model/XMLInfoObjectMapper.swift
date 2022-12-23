//
//  XMLInfoObjectMapper.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 01.01.21.
//


import Foundation
#if canImport(FoundationXML)
    import FoundationXML
#endif
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
    
    static func toXMLElement(from infoObject: XMLInfoObject) -> FXMLElement {
        let infoXMLElement = FXMLElement(name: "Info")

        let maxIdXMLElement = FXMLElement(name: "MaxId",
            stringValue: "\(infoObject.maxId)")

        let gapIdsXMLElement = FXMLElement(name: "GapIds",
            stringValue: infoObject.gapIds.map{String($0)}.joined(separator:","))

        let countXMLElement = FXMLElement(name: "Count",
            stringValue: "\(infoObject.count)")

        let objectNameXMLElement = FXMLElement(name: "ObjectName",
            stringValue: "\(infoObject.objectName)")

        let objectNamePluralXMLElement = FXMLElement(name: "ObjectNamePlural",
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
