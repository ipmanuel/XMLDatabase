import XCTest
@testable import XMLDatabase

class PersonTests: XCTestCase {
    
    
    // MARK: Properties tests
    
    func testValidProperties() {
        // different relations
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        
        // different gender
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.female, firstName: "Clara"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.female, firstName: "Clara"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.female, firstName: "Clara"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.female, firstName: "Clara"))
    }
    
    func testProperties() {
        do {
            let person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel")
            
            // init properties
            XCTAssertEqual(person.id, 1)
            XCTAssertEqual(person.gender, Person.Gender.male)
            XCTAssertEqual(person.firstName, "Manuel")
            
            // change gender
            person.change(gender: Person.Gender.female)
            XCTAssertEqual(person.gender, Person.Gender.female)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    // MARK: Property id tests
    
    func testInvalidId() {
        XCTAssertThrowsError(try Person(id: 0, gender: Person.Gender.male, firstName: "Manuel")) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, 0)
        }
    }
    
    
    // MARK: Property gender tests
    
    func testValidGenders() {
        XCTAssertNoThrow(try Person(id: 1, gender: "male", firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: "female", firstName: "Manuel"))
    }
    
    func testInvalidGenders() {
        var gender: String
        
        // set gender: males
        gender = "males"
        XCTAssertThrowsError(try Person(id: 1, gender: gender, firstName: "Manuel")) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, gender)
        }
        
        // set gender: abc
        gender = "abc"
        XCTAssertThrowsError(try Person(id: 1, gender: gender, firstName: "Manuel")) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, gender)
        }
        
        // set gender: females
        gender = "females"
        XCTAssertThrowsError(try Person(id: 1, gender: gender, firstName: "Manuel")) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, gender)
        }
        
        // set gender: femal
        gender = "femal"
        XCTAssertThrowsError(try Person(id: 1, gender: gender, firstName: "Manuel")) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, gender)
        }
    }
    
    
    // MARK: Property firstName tests
    
    func testValidFirstNames() {
        // via init
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Clara"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "He"))
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "AbcdefghijklmnopqrstuvwxyzAbcdefghijklmnopqrstuvwx"))
        
        // via convenience init
        XCTAssertNoThrow(try Person(id: 1, gender: "male", firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: "male", firstName: "Clara"))
        XCTAssertNoThrow(try Person(id: 1, gender: "male", firstName: "He"))
        XCTAssertNoThrow(try Person(id: 1, gender: "male", firstName: "AbcdefghijklmnopqrstuvwxyzAbcdefghijklmnopqrstuvwx"))
    }
    
    func testInvalidFirstNames() {
        var firstName: String
        
        // firstName is too short (1 character)
        firstName = "A"
        XCTAssert(firstName.count == 1)
        testFirstNameException(firstName: firstName)
        
        // firstName is too long (51 characters)
        firstName = "AbcdefghijklmnopqrstuvwxyzAbcdefghijklmnopqrstuvwxa"
        XCTAssert(firstName.count == 51)
        testFirstNameException(firstName: firstName)
    }
    
    private func testFirstNameException(firstName: String) {
        // set firstName
        XCTAssertThrowsError(try Person(id: 1, gender: Person.Gender.male, firstName: firstName)) { error in
            guard case PersonError.invalidFirstName(let value) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, firstName)
        }
        
        // change firstName
        do {
            let person = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel")
            XCTAssertThrowsError(try person.change(firstName: firstName)) { error in
                guard case PersonError.invalidFirstName(let value) = error else {
                    return XCTFail()
                }
                XCTAssertEqual(value, firstName)
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}

extension PersonTests {
    static var allTests = [
        ("testValidProperties", testValidProperties),
        ("testProperties", testProperties),
        ("testInvalidId", testInvalidId),
        ("testValidGenders", testValidGenders),
        ("testInvalidGenders", testInvalidGenders),
        ("testInvalidFirstNames", testInvalidFirstNames),
        ("testValidFirstNames", testValidFirstNames)
    ]
}


