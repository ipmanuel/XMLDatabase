import Foundation
@testable import XMLDatabase


enum PersonError: Error {
    case invalidGender(value: String)
    case invalidFirstName(value: String)
}


class Person: XMLObject, CustomStringConvertible {
    
    
    // MARK: enumerations
    
    /// possible genders
    enum Gender: String {
        case male
        case female
    }
    
    
    // MARK: vars
    
    // gender
    private var genderMutable: Person.Gender
    var gender: Person.Gender {
        return genderMutable
    }
    
    // firstName
    private var firstNameMutable: String
    var firstName: String {
        return firstNameMutable
    }
    
    // addresses (optional)
    var addressesIds: [Int]
    var addressesTypes: [String]
    
    // string, when print(XMLObject) is used
    var description: String {
        return "Person_\(id): \(firstName); \(gender)"
    }
    
    
    // MARK: init
    
    init(id: Int, gender: Person.Gender, firstName: String) throws {
        // init vars
        self.genderMutable = gender
        self.firstNameMutable = try Person.getFirstName(from: firstName)
        self.addressesIds = []
        self.addressesTypes = []
        
        try super.init(id: id)
    }
    
    convenience init(id: Int, gender genderString: String, firstName: String) throws {
        // validate
        let gender = try Person.getGender(from: genderString)
        
        // init
        try self.init(id: id, gender: gender, firstName: firstName)
    }
    
    
    // MARK: change required values
    
    public func change(gender: Person.Gender) {
        genderMutable = gender
    }
    
    public func change(firstName: String) throws {
        firstNameMutable = try Person.getFirstName(from: firstName)
    }
    
    
    // MARK: set optional values
    
    public func add(addressId: Int, type: String) {
        self.addressesIds.append(addressId)
        self.addressesTypes.append(type)
    }
    
    
    // MARK: validate
    
    class func isValid(gender: String) -> Bool {
        return Person.Gender(rawValue: gender) != nil
    }
    
    class func isValid(firstName: String) -> Bool {
        return firstName.count >= 2 && firstName.count <= 50
    }
    
    
    // MARK: convert
    
    class func getGender(from gender: String) throws -> Person.Gender {
        guard isValid(gender: gender) else {
            throw PersonError.invalidGender(value: gender)
        }
        return Person.Gender(rawValue: gender)!
    }
    
    class func getFirstName(from firstName: String) throws -> String {
        guard Person.isValid(firstName: firstName) else {
            throw PersonError.invalidFirstName(value: firstName)
        }
        return firstName.capitalized
    }
}
