import XCTest
@testable import XMLDatabase

class PersonTests: XCTestCase {
    
    
     // MARK: - Init tests
    
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
    
    
    // MARK: - Property `id` tests
    
    func testInvalidId() {
        XCTAssertThrowsError(try Person(id: 0, gender: Person.Gender.male, firstName: "Manuel")) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, 0)
        }
    }
    
    
    // MARK: - Property `gender` tests
    
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
        
        // set gender: female
        gender = "femal"
        XCTAssertThrowsError(try Person(id: 1, gender: gender, firstName: "Manuel")) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, gender)
        }
    }
    
    
    // MARK: - Property `firstName` tests
    
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
    
    
    // MARK: - Property `lastName` tests
    
    func testValidLastNames() {
        // create dummy Person
        var dummyPerson: Person?
        XCTAssertNoThrow(dummyPerson = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        
        // test last name
        XCTAssertNoThrow(try dummyPerson!.set(lastName: "Pauls"))
        XCTAssertEqual(dummyPerson!.lastName!, "Pauls")
    }
    
    func testInvalidLastNames() {
        // create dummy Person
        var dummyPerson: Person?
        XCTAssertNoThrow(dummyPerson = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        
        // lastName is too short (1 character)
        var lastName: String = "A"
        XCTAssert(lastName.count == 1)
        testLastNameException(dummyPerson: dummyPerson!, lastName: lastName)
        
        // lastName is too long (51 characters)
        lastName = "AbcdefghijklmnopqrstuvwxyzAbcdefghijklmnopqrstuvwxa"
        XCTAssert(lastName.count == 51)
        testLastNameException(dummyPerson: dummyPerson!, lastName: lastName)
    }
    
    
    // MARK: - Private methods
    
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
    
    private func testLastNameException(dummyPerson: Person, lastName: String) {
        // set lastName
        XCTAssertThrowsError(try dummyPerson.set(lastName: lastName)) { error in
            guard case PersonError.invalidLastName(let value) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, lastName)
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
        ("testValidFirstNames", testValidFirstNames),
        ("testValidLastNames", testValidLastNames),
        ("testInvalidLastNames", testInvalidLastNames),
    ]
}


