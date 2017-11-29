import Foundation
@testable import XMLDatabase

enum AddressError: Error {
    case invalidId(value: String)
    case invalidCity(value: String)
    case invalidStreet(value: String)
}

class Address: XMLObject, CustomStringConvertible {
    
    
    // MARK: Properties
    
    // city
    private var cityMutable: String
    var city: String {
        return cityMutable
    }
    
    // city
    private var streetMutable: String
    var street: String {
        return streetMutable
    }
    
    // string, when print(XMLObject) is used
    public var description: String {
        return "Address_\(id): \(city), \(street)"
    }
    
    
    // MARK: Init
    
    init(id: Int, city: String, street: String) throws {
        // init vars
        self.cityMutable = try Address.getCity(from: city)
        self.streetMutable = try Address.getStreet(from: street)
        
        try super.init(id: id)
    }
    
    
    // MARK: Change Properties Methods
    
    public func change(city: String) throws {
        cityMutable = try Address.getCity(from: city)
    }
    
    public func change(street: String) throws {
        streetMutable = try Address.getStreet(from: street)
    }
    
    
    // MARK: Validation Methods
    
    class func isValid(city: String) -> Bool {
        return city.count >= 2 && city.count <= 50
    }
    
    class func isValid(street: String) -> Bool {
        return street.count >= 3 && street.count <= 60
    }
    
    // MARK: Convert Methods
    
    class func getCity(from city: String) throws -> String {
        guard Address.isValid(city: city) else {
            throw AddressError.invalidCity(value: city)
        }
        return city.capitalized
    }
    
    class func getStreet(from street: String) throws -> String {
        guard Address.isValid(street: street) else {
            throw AddressError.invalidStreet(value: street)
        }
        return street.capitalized
    }
}
