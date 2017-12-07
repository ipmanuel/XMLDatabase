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
        var addressesLockedXMLFileURL = url.appendingPathComponent("_\(addressesXMLFilename)")
        var personsLockedXMLFileURL = url.appendingPathComponent("_\(personsXMLFilename)")
        try PersonsXMLDatabase.unlockIfXMLFileExists(url: &addressesLockedXMLFileURL)
        try PersonsXMLDatabase.unlockIfXMLFileExists(url: &personsLockedXMLFileURL)
        
        // init addresses
        let addressesUnlockedXMLFilePath = url.appendingPathComponent(addressesXMLFilename)
        try addressesInstance = Addresses(xmlFileURL: addressesUnlockedXMLFilePath)
        
        // init persons
        let personsUnlockedXMLFilePath = url.appendingPathComponent(personsXMLFilename)
        try personsInstance = Persons(xmlFileURL: personsUnlockedXMLFilePath)
        
        print("AddressesCheck: \(eachAddressShouldExists())")
    }
    
    
    // MARK: Persons Constraints
    
    func eachAddressShouldExists() -> Bool {
        for i in 0..<persons.count {
            for addressId in persons.get(at: i).addressesIds {
                if addresses.getBy(id: addressId) == nil {
                    return false
                }
            }
        }
        return true
    }
    
    
}
