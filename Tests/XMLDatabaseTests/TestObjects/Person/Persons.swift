import Foundation
@testable import XMLDatabase

enum PersonsError: Error {
    case onePersonDoesNotExist()
}


class Persons: XMLObjects<XMLPersonMapper> {
    
    
    // MARK: vars
    
    // var for constraint: relation me should exists
    private var onePersonExists: Bool
    
    
    // MARK: init
    
    override init(xmlFileURL: URL) throws {
        onePersonExists = false
        
        // init
        try super.init(xmlFileURL: xmlFileURL)
    }
    
    
    // MARK: add object
    
    override func addObject(object: Person) throws {
        try super.addObject(object: object)
        // constraint: there should exists at least one person
        onePersonExists = true
    }
    
    override func save() throws {
        try checkConstraintOnePersonExists()
        try super.save()
    }
    
    
    // MARK: constraints
    
    private func checkConstraintOnePersonExists() throws {
        guard onePersonExists == true else {
            throw PersonsError.onePersonDoesNotExist()
        }
    }
}
