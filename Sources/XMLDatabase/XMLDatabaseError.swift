//
//  XMLDatabaseError.swift
//  XMLDatabasePackageDescription
//
//  Created by Manuel Pauls on 01.12.17.
//

import Foundation

// MARK: - Error Enumerations

public enum URLError: Error {
    case fileDoesNotExist(at: URL)
    case fileWithNewFilenameExistsAlready(oldName: String, at: URL)
}

/// An enumeration for the various errors of `XMLObjects`.
public enum XMLObjectsError: Error {
    case invalidXMLFilename(at: URL)
    case xmlFileDoesNotExist(at: URL)
    case xmlFileExistsAlready(at: URL)
    case xmlFileIsLocked(at: URL)
    case xmlFileSizeReadingFailed(at: URL, error: String)
    case requiredAttributeIsMissing(element: String, attribute: String, at: URL)
    case requiredElementIsMissing(element: String, at: URL)
    case requiredElementTextIsInvalid(element: String, text: String, at: URL)
    case rootXMLElementWasNotFound(rootElement: String, at: URL)
    case idExistsAlready(id: Int, at: URL)
}
    
/// An enumeration for the various errors of `XMLObject`.
public enum XMLObjectError: Error {
    case invalidId(value: Int)
    case invalidIdString(value: String)
}


// MARK: - LocalizedError Descriptions for XMLObejctsError

extension XMLObjectsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidXMLFilename(let url):
            return String(format: NSLocalizedString("The filename of the given XML file \"%@\" located in \"%@\" is invalid.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .xmlFileDoesNotExist(let url):
            return String(format: NSLocalizedString("The given XML file \"%@\" located in \"%@\" does not exist.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .xmlFileExistsAlready(let url):
            return String(format: NSLocalizedString("The given XML file \"%@\" located in \"%@\" exists already.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .xmlFileIsLocked(let url):
            return String(format: NSLocalizedString("The given XML file \"%@\" located in \"%@\" is locked.", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path])
        case .xmlFileSizeReadingFailed(let url, let error):
            return String(format: NSLocalizedString("Could not read the file size of the XML file \"%@\" located in \"%@\" (error: \"%@\").", comment: ""), arguments: [url.lastPathComponent, url.deletingLastPathComponent().path, error])
        case .requiredAttributeIsMissing(let element, let attribute, let url):
            return String(format: NSLocalizedString("The required XML attribute \"%@\" is missing in the XML element \"%@\" in XML file \"%@\".", comment: ""), arguments: [attribute, element, url.path])
        case .requiredElementIsMissing(let element, let url):
            return String(format: NSLocalizedString("The required XML element \"%@\" is missing in XML file \"%@\".", comment: ""), arguments: [element, url.path])
        case .requiredElementTextIsInvalid(let element, let text, let url):
            return String(format: NSLocalizedString("The text \"%@\" of the XML element \"%@\" is invalid in XML file \"%@\".", comment: ""), arguments: [text, element, url.path])
        case .rootXMLElementWasNotFound(let rootElement, let url):
            return String(format: NSLocalizedString("The XML root element \"%@\" is missing in in the XML file \"%@\".", comment: ""), arguments: [rootElement, url.path])
        case .idExistsAlready(let id, let url):
            return String(format: NSLocalizedString("The id \"%d\" of the object exists already in XML file \"%@\".", comment: ""), arguments: [id, url.path])
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
            return String(format: NSLocalizedString("The given text \"%@\" contains not a valid id.", comment: ""), arguments: [value])
        }
    }
}

