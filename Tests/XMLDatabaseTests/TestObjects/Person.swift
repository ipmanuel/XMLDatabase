//
//  Person.swift
//  PersonsXMLDatabase
//
//  Created by Manuel Pauls on 14.12.17.
//

import Foundation
import XMLDatabase


enum PersonError: Error, Equatable {
    case invalidGender(value: String)
    case invalidFirstName(value: String)
    case invalidLastName(value: String)
    case givenValueIsTooShort(property: String, value: String, minCharacters: Int)
    case givenValueIsTooLong(property: String, value: String, maxCharacters: Int)
    case givenValueDoesNotIncludeADate(property: String, value: String)
    case givenDateShouldBeInThePast(property: String, value: Date)
    case givenDateIsTooFarInThePast(property: String, value: Date, maxYearsBetweenToday: Int)
    
    static func ==(lhs: PersonError, rhs: PersonError) -> Bool {
        switch lhs {
        case .invalidGender(let value):
            if case .invalidGender(let value2) = rhs, value == value2 {
                return true
            }
        case .invalidFirstName(let value):
            if case .invalidFirstName(let value2) = rhs, value == value2 {
                return true
            }
        case .invalidLastName(let value):
            if case .invalidLastName(let value2) = rhs, value == value2 {
                return true
            }
        case .givenValueIsTooShort(let property, let value, let minCharacters):
            if case .givenValueIsTooShort(let property2, let value2, let minCharacters2) = rhs, property == property2, value == value2, minCharacters == minCharacters2 {
                return true
            }
        case .givenValueIsTooLong(let property, let value, let maxCharacters):
            if case .givenValueIsTooLong(let property2, let value2, let minCharacters2) = rhs, property == property2, value == value2, maxCharacters == minCharacters2 {
                return true
            }
        case .givenValueDoesNotIncludeADate(let property, let value):
            if case .givenValueDoesNotIncludeADate(let property2, let value2) = rhs, property == property2, value == value2 {
                return true
            }
        case .givenDateShouldBeInThePast(let property, let value):
            if case .givenDateShouldBeInThePast(let property2, let value2) = rhs, property == property2, value == value2 {
                return true
            }
        case .givenDateIsTooFarInThePast(let property, let value, let maxYearsBetweenToday):
            if case .givenDateIsTooFarInThePast(let property2, let value2, let maxYearsBetweenToday2) = rhs, property == property2, value == value2, maxYearsBetweenToday == maxYearsBetweenToday2  {
                return true
            }
        }
        return false
    }
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
    
    /// Optional last name of the person
    private var lastNameMutable: String?
    var lastName: String? {
        return lastNameMutable
    }
    
    /// Optional date of birth of the person
    private var dateOfBirthMutable: Date?
    var dateOfBirth: Date? {
        return dateOfBirthMutable
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
    
    
    // MARK: - Change properties
    
    public func change(gender: Person.Gender) {
        genderMutable = gender
    }
    
    public func change(firstName: String) throws {
        firstNameMutable = try Person.getFirstName(from: firstName)
    }
    
    
    // MARK: - set/add optional properties
    
    public func set(lastName: String) throws {
        lastNameMutable = try Person.getLastName(from: lastName)
    }
    
    public func set(dateOfBirth: Date) throws {
        var errors: [PersonError] = []
        guard Person.isValid(dateOfBirth: dateOfBirth, errors: &errors) else {
            throw errors.first!
        }
        self.dateOfBirthMutable = dateOfBirth
    }
    
    
    // MARK: - Validate
    
    class func isValid(firstName: String, errors: inout [PersonError]) -> Bool {
        var returnValue = true
        
        if firstName.count < 2 {
            errors.append(PersonError.givenValueIsTooShort(property: "firstName", value: firstName, minCharacters: 2))
            returnValue = false
        }
        if firstName.count > 50 {
            errors.append(PersonError.givenValueIsTooLong(property: "firstName", value: firstName, maxCharacters: 50))
            returnValue = false
        }
        
        return returnValue
    }
    
    class func isValid(lastName: String, errors: inout [PersonError]) -> Bool {
        var returnValue = true
        if lastName.count < 2 {
            errors.append(PersonError.givenValueIsTooShort(property: "lastName", value: lastName, minCharacters: 2))
            returnValue = false
        }
        
        if lastName.count > 50 {
            errors.append(PersonError.givenValueIsTooLong(property: "lastName", value: lastName, maxCharacters: 50))
            returnValue = false
        }
        
        return returnValue
    }
    
    class func isValid(dateOfBirth: Date, errors: inout [PersonError]) -> Bool {
        var returnValue = true
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dateOfBirth, to: today)
        let years = components.year
        
        if today < dateOfBirth {
            errors.append(PersonError.givenDateShouldBeInThePast(property: "dateOfBirth", value: dateOfBirth))
            returnValue = false
        }
        if years != nil && years! > 500 {
            errors.append(PersonError.givenDateIsTooFarInThePast(property: "dateOfBirth", value: dateOfBirth, maxYearsBetweenToday: 500))
            returnValue = false
        }
        
        return returnValue
    }
    
    
    // MARK: - Convert
    
    class func getGender(from genderString: String) throws -> Person.Gender {
        guard let gender = Person.Gender(rawValue: genderString) else {
            throw PersonError.invalidGender(value: genderString)
        }
        return gender
    }
    
    class func getFirstName(from firstName: String) throws -> String {
        var errors: [PersonError] = []
        guard Person.isValid(firstName: firstName, errors: &errors) else {
            throw errors.first!
        }
        return firstName.capitalized
    }
    
    class func getLastName(from lastName: String) throws -> String {
        var errors: [PersonError] = []
        guard Person.isValid(lastName: lastName, errors: &errors) else {
            throw errors.first!
        }
        return lastName.capitalized
    }
    
    class func getDateOfBirth(from dateString: String) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dateOfBirth = dateFormatter.date(from: dateString) else {
            throw PersonError.givenValueDoesNotIncludeADate(property: "dateOfBirth", value: dateString)
        }
        return dateOfBirth
    }
}

