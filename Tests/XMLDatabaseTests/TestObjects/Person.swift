import Foundation
import XMLDatabase


enum PersonError: Error {
    case invalidGender(value: String)
    case invalidFirstName(value: String)
}


class Person: XMLObject {
    
    
    // MARK: - Enumerations
    
    /// possible genders
    enum Gender: String {
        case male
        case female
    }
    
    
    // MARK: - Properties
    
    /// Gender of the person
    private var genderMutable: Person.Gender
    var gender: Person.Gender {
        return genderMutable
    }
    
    /// First name of the person
    private var firstNameMutable: String
    var firstName: String {
        return firstNameMutable
    }
    
    /// Optional addresses ids of the person
    private var addressesIdsMutable: [Int]
    public var addressesIds: [Int] {
        let addressesIds = addressesIdsMutable
        return addressesIds
    }
    
    /// Optional addresses types of the person
    private var addressesTypesMutable: [String]
    public var addressesTypes: [String] {
        let addressesTypes = addressesTypesMutable
        return addressesTypes
    }
    
    
    // MARK: - Init
    
    init(id: Int, gender: Person.Gender, firstName: String) throws {
        // init vars
        self.genderMutable = gender
        self.firstNameMutable = try Person.getFirstName(from: firstName)
        self.addressesIdsMutable = []
        self.addressesTypesMutable = []
        
        try super.init(id: id)
    }
    
    convenience init(id: Int, gender genderString: String, firstName: String) throws {
        // validate
        let gender = try Person.getGender(from: genderString)
        
        // init
        try self.init(id: id, gender: gender, firstName: firstName)
    }
    
    
    // MARK: - Change required properties
    
    public func change(gender: Person.Gender) {
        genderMutable = gender
    }
    
    public func change(firstName: String) throws {
        firstNameMutable = try Person.getFirstName(from: firstName)
    }
    
    
    // MARK: - Add optional properties
    
    public func add(addressId: Int, type: String) {
        self.addressesIdsMutable.append(addressId)
        self.addressesTypesMutable.append(type)
    }
    
    
    // MARK: - Validate
    
    class func isValid(gender: String) -> Bool {
        return Person.Gender(rawValue: gender) != nil
    }
    
    class func isValid(firstName: String) -> Bool {
        return firstName.count >= 2 && firstName.count <= 50
    }
    
    
    // MARK: - Convert
    
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
