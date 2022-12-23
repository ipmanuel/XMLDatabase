//
//  XMLDocumentContainer.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 01.01.21.
//


import Foundation
#if canImport(FoundationXML)
    import FoundationXML
    public typealias FXMLElement = FoundationXML.XMLElement
    public typealias FXMLDocument = FoundationXML.XMLDocument
    public typealias FXMLNode = FoundationXML.XMLNode
#else
    public typealias FXMLElement = Foundation.XMLElement
    public typealias FXMLDocument = Foundation.XMLDocument
    public typealias FXMLNode = Foundation.XMLNode
#endif
import SWXMLHash

/// XML Object with an id (not thread safe)
public class XMLDocumentContainer {
    
    
    // MARK: - Properties

    public lazy var xmlDocument: FXMLDocument = {
        return try! initXMLDocument()// Attention of try!
    }()
    public var xmlIndexer: XMLIndexer {
        return getXMLIndexer()
    }
    public lazy var infoObject: XMLInfoObject = {
        return try! initInfoObject()// Attention of try!
    }()
    private var xmlIndexerMutable: XMLIndexer!
    private var containerUpdated = false
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
        let rootElement = FXMLElement(name: "\(objectNamePlural)")
        let xmlDocument = FXMLDocument(rootElement: rootElement)
        
        let xmlInfoObject = try XMLInfoObject(objectName: objectName, objectNamePlural: objectNamePlural)
        let infoXMLElement = XMLInfoObjectMapper.toXMLElement(from: xmlInfoObject)

        let objectsElement = FXMLElement(name: "Entries")

        rootElement.addChild(infoXMLElement)
        rootElement.addChild(objectsElement)

        try self.init(xmlString: xmlDocument.xmlString)
    }

    public func verify() -> [Error]? {
        var errors: [Error] = []
        var xmlDocument: FXMLDocument?
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

    
    public func replace(xmlElement: FXMLElement, withId id: Int) throws {
        guard checkIdExists(id: id) else {
            throw XMLDocumentContainerError.idDoesNotExist
        }
        let index = calculateIndex(of: id)
        xmlDocument.rootElement()!.elements(forName: "Entries")[0].replaceChild(at: index, with: xmlElement)

        containerUpdated = true
    }

    public func add(xmlElement: FXMLElement, withId id: Int) throws {
        try infoObject.add(id: id)
        
        if id == infoObject.maxId {
            xmlDocument.rootElement()!.elements(forName: "Entries")[0].addChild(xmlElement)
        } else {
            let index = calculateIndex(of: id)
            xmlDocument.rootElement()!.elements(forName: "Entries")[0].insertChild(xmlElement, at: index)
        }
        
        containerUpdated = true
    }

    public func remove(id: Int) throws {
        guard checkIdExists(id: id) else {
            throw XMLDocumentContainerError.idDoesNotExist
        }
        let index = calculateIndex(of: id)
        try infoObject.remove(id: id)
        xmlDocument.rootElement()!.elements(forName: "Entries")[0].removeChild(at: index)

        containerUpdated = true
    }

    public func fetch(id: Int) throws -> XMLIndexer {
        guard checkIdExists(id: id) else {
            throw XMLDocumentContainerError.idDoesNotExist
        }
        let index = calculateIndex(of: id)
        let rootXMLElement = infoObject.objectNamePlural
        let objectName = infoObject.objectName
        let xmlElement = xmlIndexer[rootXMLElement]["Entries"][objectName][index]
        //print("XMLIndexer (name: \(objectName): \(xmlIndexer[rootXMLElement]["Entries"][objectName].all)")

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

    public func checkIdExists(id: Int) -> Bool {
        guard id >= 0 else {
            return false
        }
        guard id <= infoObject.maxId else {
            return false
        }
        guard !infoObject.gapIds.contains(id) else {
            return false
        }

        return true
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

    func calculateId(of index: Int) -> Int {
        var id = index
        for gapId in infoObject.gapIds {
            if id == gapId {
                id += 1
            } else if id > gapId {
                id += 1   
            }
        }

        guard checkIdExists(id: id) else {
            return -1
        }

        return id
    }

    /// note: this works because gapIds are sorted
    func calculateIndex(of id: Int) -> Int {
        guard checkIdExists(id: id) else {
            return -1
        }
        var index: Int!
        var amountOfGapIds = 0
        for gapId in infoObject.gapIds {
            if id > gapId {
                amountOfGapIds += 1
            }
        }
        index = id - amountOfGapIds

        return index
    }

    private func initXMLDocument() throws -> FXMLDocument {
        // attention this function can crash if someone manipulate the xml file manually
        xmlDocumentIsInitialized = true
        let options = FXMLNode.Options.documentTidyXML
        
        return try FXMLDocument(xmlString: xmlString, options: options)
    }

    private func getXMLIndexer() -> XMLIndexer {
        if xmlIndexerMutable == nil || containerUpdated == true {
            containerUpdated = false
            xmlIndexerMutable = SWXMLHash.parse(xmlDocument.xmlString)
        }

        return xmlIndexerMutable
    }

    func initInfoObject() throws -> XMLInfoObject {
        let infoObjectXMLString = xmlDocument.rootElement()!.elements(forName: "Info")[0].xmlString
        let xml = SWXMLHash.parse(infoObjectXMLString)

        return try XMLInfoObjectMapper.toXMLObject(from: xml, at: URL(fileURLWithPath: "/"))
    }
}
