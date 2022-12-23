//
//  XMLObjectsManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 28.12.17.
//


import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
import SWXMLHash

/// A manager to fetch, add, update and delete xml objects
open class XMLObjectsManager<MapperType: XMLObjectMapper> {
    
    
    // MARK: - Properties

    private let xmlDocumentManager: XMLDocumentManager
    
    
    // MARK: - Init
    
    public init(xmlDocumentManager: XMLDocumentManager) {
        self.xmlDocumentManager = xmlDocumentManager
    }


    // MARK: - Add

    public func addObject(object: inout MapperType.ObjectType) throws {
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let id = container.calculateNextId()
            try object.set(id: id)
            let xmlElement = MapperType.toXMLElement(from: object)
            try container.add(xmlElement: xmlElement, withId: id)
            try xmlDocumentManager.save()
        }
    }

    public func addObjects(objects: inout [MapperType.ObjectType]) throws {
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            var id: Int!
            var xmlElement: FXMLElement!
            for object in objects {
                id = container.calculateNextId()
                try object.set(id: id)
                xmlElement = MapperType.toXMLElement(from: object)
                try container.add(xmlElement: xmlElement, withId: id)
            }
            try xmlDocumentManager.save()
        }
    }


    // MARK: - Replace
    
    private func executeReplaceObject(container: XMLDocumentContainer, object: MapperType.ObjectType) throws {
        let xmlElement = MapperType.toXMLElement(from: object)
        try container.replace(xmlElement: xmlElement, withId: object.id)
    }

    public func replaceObject(object: MapperType.ObjectType) throws {
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            try executeReplaceObject(container: container, object: object)
            try xmlDocumentManager.save()
        }
    }

    public func replaceObjects(objects: [MapperType.ObjectType]) throws {
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            for object in objects {
                try executeReplaceObject(container: container, object: object)
            }
            try xmlDocumentManager.save()
        }
    }


    // MARK: - Remove

    public func removeObject(id: Int) throws {
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            try container.remove(id: id)
            try xmlDocumentManager.save()
        }
    }

    public func removeObject(object: MapperType.ObjectType) throws {
        try removeObject(id: object.id)
    }

    public func removeObjects(objects: [MapperType.ObjectType]) throws {
        let ids  = objects.map{$0.id}
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            for id in ids {
                try container.remove(id: id)
            }
            try xmlDocumentManager.save()
        }
    }


    // MARK: - Fetch

    public func fetchObject(id: Int) throws -> MapperType.ObjectType {
        var object: MapperType.ObjectType!
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElement = try container.fetch(id: id)
            //print(xmlElement)
            let url = URL(fileURLWithPath: xmlDocumentManager.url.path)
            object = try MapperType.toXMLObject(from: xmlElement, at: url)
        }

        return object
    }

    public func fetchObjects(ids: [Int]) throws -> [MapperType.ObjectType] {
        var objects: [MapperType.ObjectType] = []
        var xmlElement: XMLIndexer!
        let url = URL(fileURLWithPath: xmlDocumentManager.url.path)
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            for id in ids {
                xmlElement = try container.fetch(id: id)
                objects.append(try MapperType.toXMLObject(from: xmlElement, at: url))
            }
        }

        return objects
    }

    public func fetchObjects() throws -> [MapperType.ObjectType] {
        var objects: [MapperType.ObjectType] = []
        let url = URL(fileURLWithPath: "/")// change it?
        try xmlDocumentManager.workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElements = try container.fetchAll()

            for xmlElement in xmlElements {
                objects.append(try MapperType.toXMLObject(from: xmlElement, at: url))
            }
        }

        return objects
    }
}
