//
//  XMLObjectsManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 28.12.17.
//


import Foundation
import FoundationXML
import SWXMLHash

/// XMLObjects manage all objects with a specific type of a XML file
open class XMLObjectsManager<MapperType: XMLObjectMapper> {
    
    
    // MARK: - Properties

    private let xmlDocumentManager: XMLDocumentManager
    
    
    // MARK: - Init
    
    public init(xmlDocumentManager: XMLDocumentManager) {
        self.xmlDocumentManager = xmlDocumentManager
    }


    // MARK: - Add

    public func addObject(object: inout MapperType.ObjectType) throws {
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let id = container.calculateNextId()
            try object.set(id: id)
            let xmlElement = MapperType.toXMLElement(from: object)
            try container.add(xmlElement: xmlElement, withId: id)
        }
    }

    public func addObjects(objects: inout [MapperType.ObjectType]) throws {
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            var id: Int!
            var xmlElement: FoundationXML.XMLElement!
            for object in objects {
                id = container.calculateNextId()
                try object.set(id: id)
                xmlElement = MapperType.toXMLElement(from: object)
                try container.add(xmlElement: xmlElement, withId: id)
            }
        }
    }


    // MARK: - Replace

    public func replaceObject(object: MapperType.ObjectType) throws {
        let id = object.id
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElement = MapperType.toXMLElement(from: object)
            try container.replace(xmlElement: xmlElement, withId: id)
        }
    }

    public func replaceObjects(objects: [MapperType.ObjectType]) throws {
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            var id: Int!
            var xmlElement: FoundationXML.XMLElement!
            for object in objects {
                id = container.calculateNextId()
                try object.set(id: id)
                xmlElement = MapperType.toXMLElement(from: object)
                try container.replace(xmlElement: xmlElement, withId: id)
            }
        }
    }


    // MARK: - Remove

    public func removeObject(id: Int) throws {
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            try container.remove(id: id)
        }
    }

    public func removeObject(object: MapperType.ObjectType) throws {
        try removeObject(id: object.id)
    }

    public func removeObjects(objects: [MapperType.ObjectType]) throws {
        let ids  = objects.map{$0.id}
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            for id in ids {
                try container.remove(id: id)
            }
        }
    }


    // MARK: - Fetch

    public func fetchObject(id: Int) throws -> MapperType.ObjectType {
        var object: MapperType.ObjectType!
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElement = try container.fetch(id: id)
            print(xmlElement)
            let url = URL(fileURLWithPath: "/")

            object = try MapperType.toXMLObject(from: xmlElement, at: url)
        }

        return object
    }

    public func fetchObjects(ids: [Int]) throws -> [MapperType.ObjectType] {
        var objects: [MapperType.ObjectType] = []
        var xmlElement: XMLIndexer!
        let url = URL(fileURLWithPath: "/")
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
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
        try workWithContainer() { (container: XMLDocumentContainer) throws -> () in
            let xmlElements = try container.fetchAll()

            for xmlElement in xmlElements {
                objects.append(try MapperType.toXMLObject(from: xmlElement, at: url))
            }
        }

        return objects
    }


    // MARK: - Private methods

    func workWithContainer(body: (XMLDocumentContainer) throws -> ()) throws {
        do {
            let container = try xmlDocumentManager.loadAndLock()
            try body(container)
            try xmlDocumentManager.saveAndUnlock(container: container)
        } catch {
            try? xmlDocumentManager.unlock()

            throw error
        }
    }
}