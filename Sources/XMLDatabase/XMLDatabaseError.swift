//
//  XMLDatabaseError.swift
//  XMLDatabasePackageDescription
//
//  Created by Manuel Pauls on 01.12.17.
//

import Foundation


// MARK: - Error Enumerations

/// An enumeration for method `rename()` in URL extension
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


// MARK: - Equatable

extension URLError: Equatable {
    public static func ==(lhs: URLError, rhs: URLError) -> Bool {
        switch lhs {
        case .fileDoesNotExist(let at):
            if case .fileDoesNotExist(let at2) = rhs, at == at2 {
                return true
            }
        case .fileWithNewFilenameExistsAlready(let oldName, let at):
            if case .fileWithNewFilenameExistsAlready(let oldName2, let at2) = rhs, oldName == oldName2, at == at2 {
                return true
            }
        }
        return false
    }
    
}

extension XMLObjectsError: Equatable {
    public static func ==(lhs: XMLObjectsError, rhs: XMLObjectsError) -> Bool {
        switch lhs {
        case .invalidXMLFilename(let at):
            if case .invalidXMLFilename(let at2) = rhs, at == at2 {
                return true
            }
        case .xmlFileDoesNotExist(let at):
            if case .xmlFileDoesNotExist(let at2) = rhs, at == at2 {
                return true
            }
        case .xmlFileExistsAlready(let at):
            if case .xmlFileExistsAlready(let at2) = rhs, at == at2 {
                return true
            }
        case .xmlFileIsLocked(let at):
            if case .xmlFileIsLocked(let at2) = rhs, at == at2 {
                return true
            }
        case .xmlFileSizeReadingFailed(let at, let error):
            if case .xmlFileSizeReadingFailed(let at2, let error2) = rhs, at == at2, error == error2 {
                return true
            }
        case .requiredAttributeIsMissing(let element, let attribute, let at):
            if case .requiredAttributeIsMissing(let element2, let attribute2, let at2) = rhs, element == element2, attribute == attribute2, at == at2  {
                return true
            }
        case .requiredElementIsMissing(let element, let at):
            if case .requiredElementIsMissing(let element2, let at2) = rhs, element == element2, at == at2  {
                return true
            }
        case .requiredElementTextIsInvalid(let element, let text, let at):
            if case .requiredElementTextIsInvalid(let element2, let text2, let at2) = rhs, element == element2, text == text2, at == at2  {
                return true
            }
        case .rootXMLElementWasNotFound(let rootElement, let at):
            if case .rootXMLElementWasNotFound(let rootElement2, let at2) = rhs, rootElement == rootElement2, at == at2  {
                return true
            }
        case .idExistsAlready(let id, let at):
            if case .idExistsAlready(let id2, let at2) = rhs, id == id2, at == at2  {
                return true
            }
        }
        return false
    }
}

extension XMLObjectError: Equatable {
    public static func ==(lhs: XMLObjectError, rhs: XMLObjectError) -> Bool {
        switch lhs {
        case .invalidId(let value):
            if case .invalidId(let value2) = rhs, value == value2 {
                return true
            }
        case .invalidIdString(let value):
            if case .invalidIdString(let value2) = rhs, value == value2 {
                return true
            }
        }
        return false
    }
}


// MARK: - LocalizedError
#if os(Linux)
extension URLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileDoesNotExist(let at):
            return String(format: NSLocalizedString("The given file \"%@\" located in \"%@\" does not exist.", comment: ""), arguments: [at.lastPathComponent, at.deletingLastPathComponent().path])
        case .fileWithNewFilenameExistsAlready(let oldName, let at):
            return String(format: NSLocalizedString("The file \"%@\" located in \"%@\" exists already.", comment: ""), arguments: [at.lastPathComponent, at.deletingLastPathComponent().path])
        }
    }
}

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
#endif
