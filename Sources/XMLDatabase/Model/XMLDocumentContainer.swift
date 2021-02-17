//
//  XMLDocumentContainer.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 01.01.21.
//


import Foundation
import FoundationXML
import SWXMLHash

/// XML Object with an id (not thread safe)
public class XMLDocumentContainer {
    
    
    // MARK: - Properties

    public lazy var xmlDocument: FoundationXML.XMLDocument = {
        return try! initXMLDocument()// Attention of try!
    }()
    public lazy var xmlIndexer: XMLIndexer = {
        return initXMLIndexer()
    }()
    public lazy var infoObject: XMLInfoObject = {
        return try! initInfoObject()// Attention of try!
    }()
    private var xmlString: String
    private var xmlDocumentIsInitialized = false
    private var xmlIndexerIsInitialized = false

    
    // MARK: - Init
    
    /// init container from xml string    
    public init(xmlString: String) throws {
        self.xmlString = xmlString
    }


    /// init empty container
    public convenience init(objectName: String, objectNamePlural: String) throws {
        let rootElement = FoundationXML.XMLElement(name: "\(objectNamePlural)")
        var xmlDocument = FoundationXML.XMLDocument(rootElement: rootElement)
        
        let xmlInfoObject = try XMLInfoObject(objectName: objectName, objectNamePlural: objectNamePlural)
        let infoXMLElement = XMLInfoObjectMapper.toXMLElement(from: xmlInfoObject)

        var objectsElement = FoundationXML.XMLElement(name: "Entries")

        rootElement.addChild(infoXMLElement)
        rootElement.addChild(objectsElement)

        try self.init(xmlString: xmlDocument.xmlString)
    }

    public func verify() -> [Error]? {
        var errors: [Error] = []
        var xmlDocument: FoundationXML.XMLDocument?
        do {
            xmlDocument = try initXMLDocument()
            
        } catch {
            errors.append(error)
        }

        if let xmlDocumentUnpacked = xmlDocument, xmlDocumentUnpacked.rootElement() != nil {
            let entriesTagExists = xmlDocumentUnpacked.rootElement()!.elements(forName: "Entries").count == 1
            if !entriesTagExists {
                errors.append(XMLDocumentContainerError.entriesTagDoesNotExist)
            }
        } else {
            errors.append(XMLDocumentContainerError.rootElementDoesNotExist)
        }

        if errors.count == 0 {
            do {
                let _ = try initInfoObject()
            } catch {
                errors.append(error)
            }
        }

        return errors.count > 0 ? errors : nil
    }

    
    public func replace(xmlElement: FoundationXML.XMLElement, withId id: Int) throws {
        let index = calculateIndex(of: id)
        xmlDocument.rootElement()!.elements(forName: "Entries")[0].replaceChild(at: index, with: xmlElement)
    }

    public func add(xmlElement: FoundationXML.XMLElement, withId id: Int) throws {
        try infoObject.add(id: id)
        
        if id == infoObject.maxId {
            xmlDocument.rootElement()!.elements(forName: "Entries")[0].addChild(xmlElement)
        } else {
            let index = calculateIndex(of: id)
            xmlDocument.rootElement()!.elements(forName: "Entries")[0].insertChild(xmlElement, at: index)
        }
        
    }

    public func remove(id: Int) throws {
        let index = calculateIndex(of: id)
        try infoObject.remove(id: id)
        xmlDocument.rootElement()!.elements(forName: "Entries")[0].removeChild(at: index)
    }

    public func fetch(id: Int) throws -> XMLIndexer {
        let index = calculateIndex(of: id)
        let objectName = infoObject.objectName
        let xmlElement = xmlIndexer[infoObject.objectNamePlural]["Entries"][objectName][index]

        return xmlElement
    }

    public func fetchAll() throws -> [XMLIndexer] {
        let rootXMLElement = infoObject.objectNamePlural
        let objectName = infoObject.objectName

        return xmlIndexer[rootXMLElement]["Entries"][objectName].all
    }

    public func export() -> Data {
        let infoObjectXMLElement = XMLInfoObjectMapper.toXMLElement(from: infoObject)
        xmlDocument.rootElement()!.replaceChild(at: 0, with: infoObjectXMLElement)

        let options = XMLNode.Options.documentTidyXML
        return xmlDocument.xmlData(options: options)
    }

    public func calculateNextId() -> Int {
        var nextId: Int!
        let amountOfGapIds = infoObject.gapIds.count
        if amountOfGapIds > 0 {
            nextId = infoObject.gapIds[Int.random(in: 0..<amountOfGapIds)]
        } else {
            nextId = infoObject.maxId + 1
        }

        return nextId
    }

    private func calculateId(of index: Int) -> Int {
        var id: Int!
        var amountOfGapIds = 0
        for gapId in infoObject.gapIds {
            if index > gapId {
                break
            }
            amountOfGapIds += 1
        }
        id = index + amountOfGapIds

        return id
    }

    private func calculateIndex(of id: Int) -> Int {
        var index: Int!
        var amountOfGapIds = 0
        for gapId in infoObject.gapIds {
            if id > gapId {
                break
            }
            amountOfGapIds += 1
        }
        index = id - amountOfGapIds
        

        return index
    }

    private func initXMLDocument() throws -> FoundationXML.XMLDocument {
        // attention this function can crash if someone manipulate the xml file manually
        xmlDocumentIsInitialized = true
        let options = FoundationXML.XMLNode.Options.documentTidyXML
        
        return try FoundationXML.XMLDocument(xmlString: xmlString, options: options)
    }

    private func initXMLIndexer() -> XMLIndexer {
        var xmlIndexerIsInitialized = true

        return SWXMLHash.parse(xmlString)
    }

    func initInfoObject() throws -> XMLInfoObject {
        let infoObjectXMLString = xmlDocument.rootElement()!.elements(forName: "Info")[0].xmlString
        let xml = SWXMLHash.parse(infoObjectXMLString)

        return try XMLInfoObjectMapper.toXMLObject(from: xml, at: URL(fileURLWithPath: "/"))
    }
}
