import Foundation
import XMLDatabase

enum PersonsError: Error {
    case onePersonDoesNotExist()
    case atLeastOnePersonShouldExist()
}


class Persons: XMLObjects<PersonMapper> {
    
    
    // MARK: - Properties
    
    // var for constraint: one person should exists
    private var onePersonExists: Bool
    
    
    // MARK: - Init
    
    override init(xmlFileURL: URL) throws {
        onePersonExists = false
        
        // init
        try super.init(xmlFileURL: xmlFileURL)
    }
    
    
    // MARK: - XMLObjects
    
    override func addObject(object: Person) throws {
        try super.addObject(object: object)
        // constraint: there should exists at least one person
        onePersonExists = true
    }
    
    override func save() throws {
        try checkConstraintOnePersonExists()
        try super.save()
    }
    
    override func deleteObject(id: Int) throws {
        guard self.count > 1 else {
            throw PersonsError.atLeastOnePersonShouldExist()
        }
        try super.deleteObject(id: id)
    }
    
    override open class func createEmptyXMLFile(url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else {
            throw XMLObjectsError.xmlFileExistsAlready(at: url)
        }
        
        let rootElementName = url.deletingPathExtension().lastPathComponent.capitalized
        let xmlDocument = XMLDocument(rootElement: Foundation.XMLElement(name: rootElementName))
        try xmlDocument.xmlData.write(to: url)
    }
    
    
    // MARK: - Constraints
    
    private func checkConstraintOnePersonExists() throws {
        guard onePersonExists == true else {
            throw PersonsError.onePersonDoesNotExist()
        }
    }
}
