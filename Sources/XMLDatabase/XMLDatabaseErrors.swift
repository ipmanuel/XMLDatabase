//
//  XMLDatabaseErrors.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 01.12.17.
//


import Foundation


// MARK: - Error Enumerations

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

/// An enumeration for the various errors of `XMLInfoObject`.
public enum XMLInfoObjectError: Error {
    case invaliMaxtId(value: Int)
    case invalidGapIds(value: [Int])
    case invaliCount(value: Int)
    case invalidMaxIdString(value: String)
    case invalidGapIdsString(value: String)
    case invalidCountString(value: String)
    case invalidGapIdsString(vale: String)
    case invaliObjectName(singular: String, plural: String)
    case gapIdsExists
    case noEmptyGapIdsExists
}

/// An enumeration for the various errors of `FileDataManager`.
public enum FileDataManagerError: Error {
    case fileDoesNotExist(at: URL)
    case unlockedAndLockedFileExists(unlockedAt: URL, lockedAt: URL)
    case fileIsAlreadyLocked(at: URL)
    case fileIsNotLocked(at: URL)
    case fileExistsAlready(at: URL)
    case writeFileDataFailed(at: URL, error: Error)
}

/// An enumeration for the various errors of `XMLDocumenContainer`.
public enum XMLDocumentContainerError: Error {
    case rootElementDoesNotExist
    case entriesTagDoesNotExist
    case invalidId
}


// MARK: - Equatable

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