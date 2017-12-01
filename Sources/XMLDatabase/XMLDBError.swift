//
//  XMLDatabaseError.swift
//  XMLDatabasePackageDescription
//
//  Created by Manuel Pauls on 01.12.17.
//

import Foundation

// MARK: - Error Enumerations


/// An enumeration for the various errors of `XMLObjects`.
enum XMLObjectsError: Error {
    case invalidXMLFilename(at: URL)
    case xmlFileDoesNotExist(at: URL)
    case xmlFileIsLocked(at: URL)
    case requiredAttributeIsMissing(element: String, attribute: String, at: URL)
    case requiredElementIsMissing(element: String, at: URL)
    case requiredElementTextIsInvalid(element: String, text: String, at: URL)
    case rootXMLElementWasNotFound(rootElement: String, at: URL)
    case idExistsAlready(id: Int, at: URL)
}
    
/// An enumeration for the various errors of `XMLObject`.
enum XMLObjectError: Error {
    case invalidId(value: Int)
    case invalidIdString(value: String)
}


// MARK: - LocalizedError Descriptions for XMLObejctsError

extension XMLObjectsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidXMLFilename(let url):
            return String(format: NSLocalizedString("The filename of the given XML file \"%s\" located in \"%s\" is invalid.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .xmlFileDoesNotExist(let url):
            return String(format: NSLocalizedString("The given XML file \"%s\" located in \"%s\" does not exist.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .xmlFileIsLocked(let url):
            return String(format: NSLocalizedString("The given XML file \"%s\" located in \"%s\" is locked.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .requiredAttributeIsMissing(let element, let attribute, let url):
            return String(format: NSLocalizedString("The required XML attribute \"%s\" is missing in the XML element \"%s\" in XML file \"%s\".", comment: ""), arguments: [attribute, element, url.path])
        case .requiredElementIsMissing(let element, let url):
            return String(format: NSLocalizedString("The required XML element \"%s\" is missing in XML file \"%s\".", comment: ""), arguments: [element, url.path])
        case .requiredElementTextIsInvalid(let element, let text, let url):
            return String(format: NSLocalizedString("The text \"%s\" of the XML element \"%s\" is invalid in XML file \"%s\".", comment: ""), arguments: [text, element, url.path])
        case .rootXMLElementWasNotFound(let rootElement, let url):
            return String(format: NSLocalizedString("The XML root element \"%s\" is missing in in the XML file \"%s\".", comment: ""), arguments: [rootElement, url.path])
        case .idExistsAlready(let id, let url):
            return String(format: NSLocalizedString("The id \"%d\" of the object exists already in XML file \"%s\".", comment: ""), arguments: [id, url.path])
        }
    }
}


// MARK: - LocalizedError Descriptions for XMLObjectError

extension XMLObjectError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidId(let value):
            return String(format: NSLocalizedString("The given number \"%d\" is not a valid id.", comment: ""), arguments: [value])
        case .invalidIdString(let value):
            return String(format: NSLocalizedString("The given text \"%s\" contains not a valid id.", comment: ""), arguments: [value])
        }
    }
}

