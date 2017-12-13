import Foundation
import XMLDatabase

class PersonsXMLDatabase: XMLDatabase {
    private let personsXMLFilename = "Persons.xml"
    private let personsInstance: Persons
    var persons: Persons {
        return personsInstance
    }
    
    required init (url: URL) throws {
        // unlock xml file
        var personsLockedXMLFileURL = url.appendingPathComponent("_\(personsXMLFilename)")
        try PersonsXMLDatabase.unlockIfXMLFileExists(url: &personsLockedXMLFileURL)
        
        // init persons
        let personsUnlockedXMLFilePath = url.appendingPathComponent(personsXMLFilename)
        try personsInstance = Persons(xmlFileURL: personsUnlockedXMLFilePath)
    }
}
