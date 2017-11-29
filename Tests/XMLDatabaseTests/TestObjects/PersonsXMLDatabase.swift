import Foundation
@testable import XMLDatabase

class PersonsXMLDatabase: XMLDatabase {
    private let addressesXMLFilename = "Addresses.xml"
    private let addressesInstance: Addresses
    var addresses: Addresses {
        return addressesInstance
    }
    
    private let personsXMLFilename = "Persons.xml"
    private let personsInstance: Persons
    var persons: Persons {
        return personsInstance
    }
    
    required init (url: URL) throws {
        // unlock all xml files
        var addressesLockedXMLFilePath = url.appendingPathComponent("_\(addressesXMLFilename)")
        var personsLockedXMLFilePath = url.appendingPathComponent("_\(personsXMLFilename)")
        
        if FileManager.default.fileExists(atPath: addressesLockedXMLFilePath.path) {
            try addressesLockedXMLFilePath.rename(newName: "Addresses.xml")
        }
        if FileManager.default.fileExists(atPath: personsLockedXMLFilePath.path) {
            try personsLockedXMLFilePath.rename(newName: "Persons.xml")
        }
        
        // init addresses
        let addressesUnlockedXMLFilePath = url.appendingPathComponent(addressesXMLFilename)
        try addressesInstance = Addresses(xmlFileURL: addressesUnlockedXMLFilePath)
        
        // init persons
        let personsUnlockedXMLFilePath = url.appendingPathComponent(personsXMLFilename)
        try personsInstance = Persons(xmlFileURL: personsUnlockedXMLFilePath)
    }
}
