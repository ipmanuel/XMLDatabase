//
//  XMLObjectManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 06.03.21.
//


import Foundation
import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
import SWXMLHash

/// A manager to fetch and set a xml object
open class XMLObjectManager<MapperType: XMLObjectMapper> {
    
    
    // MARK: - Properties

    private let xmlDocumentManager: XMLDocumentManager
    
    
    // MARK: - Init
    
    public init(xmlDocumentManager: XMLDocumentManager) throws {
        let container = xmlDocumentManager.container
        // TODO Check container.infoObject.count == 1
        guard container.checkIdExists(id: 0) else {
            throw XMLObjectManagerError.containerIsEmpty
        }
        self.xmlDocumentManager = xmlDocumentManager
    }


    // MARK: - Replace

    public func setObject(object: MapperType.ObjectType) throws {
        let id = object.id
        guard id == 0 else {
            throw XMLObjectManagerError.idIsNotNull
        }
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElement = MapperType.toXMLElement(from: object)
            try container.replace(xmlElement: xmlElement, withId: id)
            try xmlDocumentManager.save()
        }
    }


    // MARK: - Fetch

    public func fetchObject() throws -> MapperType.ObjectType {
        var object: MapperType.ObjectType!
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElement = try container.fetch(id: 0)
            let url = URL(fileURLWithPath: "/")

            object = try MapperType.toXMLObject(from: xmlElement, at: url)
        }

        return object
    }
}
