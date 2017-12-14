//
//  Person.swift
//  PersonsXMLDatabase
//
//  Created by Manuel Pauls on 14.12.17.
//

import Foundation
import XMLDatabase


enum PersonError: Error {
    case invalidGender(value: String)
    case invalidFirstName(value: String)
}


public class Person: XMLObject {
    
    
    // MARK: - Enumerations
    
    /// Possible genders of a person
    public enum Gender: String {
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
    
    
    // MARK: - Init
    
    init(id: Int, gender: Person.Gender, firstName: String) throws {
        // init vars
        self.genderMutable = gender
        self.firstNameMutable = try Person.getFirstName(from: firstName)
        
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

