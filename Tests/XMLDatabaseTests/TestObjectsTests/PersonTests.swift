import XCTest
@testable import XMLDatabase

class PersonTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private var validPerson: Person?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        do {
            validPerson = try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel")
        } catch {
            print("setUp failed!")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        validPerson = nil
    }
    
    
    
    // MARK: - Init tests
    
    func testValidProperties() {
        // man
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.male, firstName: "Manuel"))
        XCTAssertNoThrow(try Person(id: 1, gender: "male", firstName: "Manuel"))
        
        // woman
        XCTAssertNoThrow(try Person(id: 1, gender: Person.Gender.female, firstName: "Clara"))
        XCTAssertNoThrow(try Person(id: 1, gender: "female", firstName: "Clara"))
    }
    
    func testProperties() {
        XCTAssertEqual(validPerson!.id, 1)
        XCTAssertEqual(validPerson!.gender, Person.Gender.male)
        XCTAssertEqual(validPerson!.firstName, "Manuel")
    }
    
    func testInvalidId() {
        XCTAssertThrowsError(try Person(id: 0, gender: Person.Gender.male, firstName: "Manuel")) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, 0)
        }
    }
    
    
    // MARK: - Method `change(gender:)` tests
    
    func testChangeValidGender() {
        // change to female
        validPerson!.change(gender: Person.Gender.female)
        XCTAssertEqual(validPerson!.gender, Person.Gender.female)
        
        // change to male
        validPerson!.change(gender: Person.Gender.male)
        XCTAssertEqual(validPerson!.gender, Person.Gender.male)
    }
    
    
    // MARK: - Method `change(firstName:)` tests
    
    func testChangeValidFirstName() {
        XCTAssertNoThrow(try validPerson!.change(firstName: "Peter"))
        XCTAssertEqual(validPerson!.firstName, "Peter")
        
        XCTAssertNoThrow(try validPerson!.change(firstName: "Manuel"))
        XCTAssertEqual(validPerson!.firstName, "Manuel")
    }
    
    func testChangeInvalidFirstName() {
        XCTAssertThrowsError(try validPerson!.change(firstName: "M")) { error in
            guard case PersonError.givenValueIsTooShort(_, _, _) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertEqual(validPerson!.firstName, "Manuel")
    }
    
    
    // MARK: - Method `set(lastName:)` tests
    
    func testSetValidLastName() {
        XCTAssertNoThrow(try validPerson!.set(lastName: "Pauls"))
        XCTAssertEqual(validPerson!.lastName, "Pauls")
    }
    
    func testSetInvalidLastName() {
        XCTAssertThrowsError(try validPerson!.set(lastName: "P")) { error in
            guard case PersonError.givenValueIsTooShort(_, _, _) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertEqual(validPerson!.lastName, nil)
    }
    
    
    // MARK: - Method `set(dateOfBirth:)` tests
    
    func testSetValidDateOfBirth() {
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .year, value: -80, to: Date())!
        XCTAssertNoThrow(try validPerson!.set(dateOfBirth: dateOfBirth))
        XCTAssertEqual(validPerson!.dateOfBirth, dateOfBirth)
    }
    
    func testSetDateOfBirthWhichIsInPast() {
        // set valid dateOfBirth
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .year, value: 1, to: Date())!
        XCTAssertThrowsError(try validPerson!.set(dateOfBirth: dateOfBirth)) { error in
            guard case PersonError.givenDateShouldBeInThePast(_) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertEqual(validPerson!.dateOfBirth, nil)
    }
    
    func testSetInvalidDateOfBirth() {
        let calendar = Calendar.current
        
        let dateOfBirth = calendar.date(byAdding: .year, value: 1, to: Date())!
        XCTAssertThrowsError(try validPerson!.set(dateOfBirth: dateOfBirth)) { error in
            guard case PersonError.givenDateShouldBeInThePast(_) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertEqual(validPerson!.dateOfBirth, nil)
    }
    
    func testSetDateOfBirthWhichIsBeforeDeath() {
        let calendar = Calendar.current
        
        // set valid dateOfDeath
        let dateOfDeath = calendar.date(byAdding: .year, value: -10, to: Date())!
        XCTAssertNoThrow(try validPerson!.set(dateOfDeath: dateOfDeath))
        
        // set dateOfBirth
        let dateOfBirth = calendar.date(byAdding: .year, value: -23, to: Date())!
        XCTAssertThrowsError(try validPerson!.set(dateOfBirth: dateOfBirth)) { error in
            guard case PersonError.dateOfDeathShouldBeAfterDateOfBirth(let dateOfBirth2, let dateOfDeath2) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(dateOfBirth, dateOfBirth2)
            XCTAssertEqual(dateOfDeath, dateOfDeath2)
        }
        XCTAssertEqual(validPerson!.dateOfBirth, nil)
    }
    
    
    // MARK: - Method `set(dateOfDeath:)` tests
    
    func testSetValidDateOfDeath() {
        let calendar = Calendar.current
        let dateOfDeath = calendar.date(byAdding: .year, value: -80, to: Date())!
        XCTAssertNoThrow(try validPerson!.set(dateOfDeath: dateOfDeath))
        XCTAssertEqual(validPerson!.dateOfDeath, dateOfDeath)
    }
    
    func testSetInvalidDateOfDeath() {
        let calendar = Calendar.current
        
        let dateOfDeath = calendar.date(byAdding: .year, value: 1, to: Date())!
        XCTAssertThrowsError(try validPerson!.set(dateOfDeath: dateOfDeath)) { error in
            guard case PersonError.givenDateShouldBeInThePast(_) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertEqual(validPerson!.dateOfBirth, nil)
    }
    
    func testSetDateOfDeathWhichIsBeforeBirth() {
        let calendar = Calendar.current
        
        // set valid dateOfDeath
        let dateOfBirth = calendar.date(byAdding: .year, value: -23, to: Date())!
        XCTAssertNoThrow(try validPerson!.set(dateOfBirth: dateOfBirth))
        
        // set dateOfBirth
        let dateOfDeath = calendar.date(byAdding: .year, value: -10, to: Date())!
        XCTAssertThrowsError(try validPerson!.set(dateOfDeath: dateOfDeath)) { error in
            guard case PersonError.dateOfDeathShouldBeAfterDateOfBirth(let dateOfBirth2, let dateOfDeath2) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(dateOfBirth, dateOfBirth2)
            XCTAssertEqual(dateOfDeath, dateOfDeath2)
        }
        XCTAssertEqual(validPerson!.dateOfDeath, nil)
    }
    
    
    // MARK: - Method `isValid(firstName:)` tests
    
    func testValidFirstName() {
        var errors: [PersonError] = []
        XCTAssertTrue(Person.isValid(firstName: "Manuel", errors: &errors))
    }
    
    func testFirstNameIsTooShort() {
        var errors: [PersonError] = []
        XCTAssertFalse(Person.isValid(firstName: "M", errors: &errors))
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, PersonError.givenValueIsTooShort(property: "firstName", value: "M", minCharacters: 2))
    }
    
    func testFirstNameIsTooLong() {
        var errors: [PersonError] = []
        let tooLongFirstName = "Abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxy"
        XCTAssertEqual(tooLongFirstName.count, 51)
        XCTAssertFalse(Person.isValid(firstName: tooLongFirstName, errors: &errors))
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, PersonError.givenValueIsTooLong(property: "firstName", value: tooLongFirstName, maxCharacters: 50))
    }
    
    
    // MARK: - Method `isValid(lastName:)` tests
    
    func testLastNameWithMinCharacters() {
        var errors: [PersonError] = []
        let lastNameWithMinCharacters = "Pa"
        XCTAssertTrue(Person.isValid(lastName: lastNameWithMinCharacters, errors: &errors))
        XCTAssertEqual(errors.count, 0)
    }
    
    func testLastNameWithMaxCharacters() {
        var errors: [PersonError] = []
        let lastNameWithMaxCharacters = "Abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwx"
        XCTAssertEqual(lastNameWithMaxCharacters.count, 50)
        XCTAssertTrue(Person.isValid(lastName: lastNameWithMaxCharacters, errors: &errors))
        XCTAssertEqual(errors.count, 0)
    }
    
    func testLastNameIsTooShort() {
        var errors: [PersonError] = []
        XCTAssertFalse(Person.isValid(lastName: "P", errors: &errors))
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, PersonError.givenValueIsTooShort(property: "lastName", value: "P", minCharacters: 2))
    }
    
    func testLastNameIsTooLong() {
        var errors: [PersonError] = []
        let tooLongFirstName = "Abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxy"
        XCTAssertEqual(tooLongFirstName.count, 51)
        XCTAssertFalse(Person.isValid(firstName: tooLongFirstName, errors: &errors))
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, PersonError.givenValueIsTooLong(property: "firstName", value: tooLongFirstName, maxCharacters: 50))
    }
    
    
    // MARK: - Method `isValid(dateOfBirth:)` tests
    
    func testIsValidDateOfBirthOnToday() {
        var errors: [PersonError] = []
        let today = Date()
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .minute, value: -1, to: today)!
        XCTAssertEqual(Person.isValid(dateOfBirth: dateOfBirth, errors: &errors), true)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testIsValidDateOfBirthMaxDistanceBetween() {
        var errors: [PersonError] = []
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .year, value: -500, to: Date())!
        XCTAssertEqual(Person.isValid(dateOfBirth: dateOfBirth, errors: &errors), true)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testIsValidDateOfBirthIsInFuture() {
        var errors: [PersonError] = []
        let calendar = Calendar.current
        let dayInFuture = calendar.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertEqual(Person.isValid(dateOfBirth: dayInFuture, errors: &errors), false)
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, PersonError.givenDateShouldBeInThePast(property: "dateOfBirth", value: dayInFuture))
    }
    
    func testIsValidDateOfBirthIsTooFarInPast() {
        var errors: [PersonError] = []
        let calendar = Calendar.current
        let dayTooFarInPast = calendar.date(byAdding: .year, value: -501, to: Date())!
        XCTAssertEqual(Person.isValid(dateOfBirth: dayTooFarInPast, errors: &errors), false)
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, PersonError.givenDateIsTooFarInThePast(property: "dateOfBirth", value: dayTooFarInPast, maxYearsBetweenToday: 500))
    }
    
    
    // MARK: - Method `getGender()` tests
    
    func testGetGenderValidValue() {
        var gender: Person.Gender?
        
        // male
        XCTAssertNoThrow(gender = try Person.getGender(from: "male"))
        XCTAssertEqual(gender, Person.Gender.male)
        
        // female
        XCTAssertNoThrow(gender = try Person.getGender(from: "female"))
        XCTAssertEqual(gender, Person.Gender.female)
    }
    
    func testInvalidGenderValidValue() {
        var gender: String
        
        // set gender: males
        gender = "males"
        XCTAssertThrowsError(try Person.getGender(from: gender)) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, gender)
        }
        
        // set gender: mal
        gender = "mal"
        XCTAssertThrowsError(try Person.getGender(from: gender)) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, gender)
        }
        
        // set gender: females
        gender = "females"
        XCTAssertThrowsError(try Person.getGender(from: gender)) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, gender)
        }
        
        // set gender: female
        gender = "femal"
        XCTAssertThrowsError(try Person.getGender(from: gender)) { error in
            guard case PersonError.invalidGender((let value)) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, gender)
        }
    }
    
    
    // MARK: - Method `getFirstName()` tests
    
    func testGetFirstNameValidValue() {
        var firstName: String?
        
        XCTAssertNoThrow(firstName = try Person.getFirstName(from: "manuel"))
        XCTAssertEqual(firstName!, "Manuel")
        
        XCTAssertNoThrow(firstName = try Person.getFirstName(from: "Peter"))
        XCTAssertEqual(firstName, "Peter")
    }
    
    func testGetFirstNameInvalidValue() {
        var firstName: String?
        
        XCTAssertThrowsError(firstName = try Person.getFirstName(from: "M"))
        XCTAssertEqual(firstName, nil)
    }
    
    
    // MARK: - Method `getLastName()` tests
    
    func testGetLastNameValidValue() {
        var lastName: String?
        
        XCTAssertNoThrow(lastName = try Person.getFirstName(from: "pauls"))
        XCTAssertEqual(lastName!, "Pauls")
        
        XCTAssertNoThrow(lastName = try Person.getFirstName(from: "Pauls"))
        XCTAssertEqual(lastName, "Pauls")
    }
    
    func testGetLastNameInvalidValue() {
        var lastName: String?
        
        XCTAssertThrowsError(lastName = try Person.getLastName(from: "P"))
        XCTAssertEqual(lastName, nil)
    }
    
    
    // MARK: - Method `getDateOfBirth()` tests
    
    func testGetDateOfBirthValidValue() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        let today = dateFormatter.date(from: todayString)!
        var dateOfBirth: Date?
        
        XCTAssertNoThrow(dateOfBirth = try Person.getDateOfBirth(from: dateFormatter.string(from: today)))
        XCTAssertEqual(dateOfBirth!, today)
    }
    
    func testGetDateOfBirthInvalidValue() {
        var dateOfBirthString: String
        
        // set dateOfBirthString: 01.01.1990
        dateOfBirthString = "01.01.1990"
        XCTAssertThrowsError(try Person.getDateOfBirth(from: dateOfBirthString)) { error in
            guard case PersonError.givenValueDoesNotIncludeADate(let property, let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(property, "dateOfBirth")
            XCTAssertEqual(value, "01.01.1990")
        }
        
        // set dateOfBirthString: 1990-13-01
        dateOfBirthString = "1990-13-01"
        XCTAssertThrowsError(try Person.getDateOfBirth(from: dateOfBirthString)) { error in
            guard case PersonError.givenValueDoesNotIncludeADate(let property, let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(property, "dateOfBirth")
            XCTAssertEqual(value, "1990-13-01")
        }
    }
    
    
    // MARK: - Method `getDateOfDeath()` tests
    
    func testGetDateOfDeathValidValue() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        let today = dateFormatter.date(from: todayString)!
        var dateOfDeath: Date?
        
        XCTAssertNoThrow(dateOfDeath = try Person.getDateOfDeath(from: dateFormatter.string(from: today)))
        XCTAssertEqual(dateOfDeath!, today)
    }
    
    func testGetDateOfDeathInvalidValue() {
        var dateOfDeathString: String
        
        // set dateOfBirthString: 01.01.1990
        dateOfDeathString = "01.01.1990"
        XCTAssertThrowsError(try Person.getDateOfDeath(from: dateOfDeathString)) { error in
            guard case PersonError.givenValueDoesNotIncludeADate(let property, let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(property, "dateOfDeath")
            XCTAssertEqual(value, "01.01.1990")
        }
        
        // set dateOfBirthString: 1990-13-01
        dateOfDeathString = "1990-13-01"
        XCTAssertThrowsError(try Person.getDateOfDeath(from: dateOfDeathString)) { error in
            guard case PersonError.givenValueDoesNotIncludeADate(let property, let value) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(property, "dateOfDeath")
            XCTAssertEqual(value, "1990-13-01")
        }
    }
}


extension PersonTests {
    static var allTests = [
        ("testValidProperties", testValidProperties),
        ("testProperties", testProperties),
        ("testInvalidId", testInvalidId),
        ("testChangeValidGender", testChangeValidGender),
        ("testChangeValidFirstName", testChangeValidFirstName),
        ("testChangeInvalidFirstName", testChangeInvalidFirstName),
        ("testSetValidLastName", testSetValidLastName),
        ("testSetInvalidLastName", testSetInvalidLastName),
        ("testSetValidDateOfBirth", testSetValidDateOfBirth),
        ("testSetInvalidDateOfBirth", testSetInvalidDateOfBirth),
        ("testValidFirstName", testValidFirstName),
        ("testFirstNameIsTooShort", testFirstNameIsTooShort),
        ("testFirstNameIsTooLong", testFirstNameIsTooLong),
        ("testLastNameWithMinCharacters", testLastNameWithMinCharacters),
        ("testLastNameWithMaxCharacters", testLastNameWithMaxCharacters),
        ("testLastNameIsTooShort", testLastNameIsTooShort),
        ("testLastNameIsTooLong", testLastNameIsTooLong),
        ("testIsValidDateOfBirthOnToday", testIsValidDateOfBirthOnToday),
        ("testIsValidDateOfBirthMaxDistanceBetween", testIsValidDateOfBirthMaxDistanceBetween),
        ("testIsValidDateOfBirthIsInFuture", testIsValidDateOfBirthIsInFuture),
        ("testIsValidDateOfBirthIsTooFarInPast", testIsValidDateOfBirthIsTooFarInPast),
        ("testGetGenderValidValue", testGetGenderValidValue),
        ("testInvalidGenderValidValue", testInvalidGenderValidValue),
        ("testGetFirstNameValidValue", testGetFirstNameValidValue),
        ("testGetFirstNameInvalidValue", testGetFirstNameInvalidValue),
        ("testGetLastNameValidValue", testGetLastNameValidValue),
        ("testGetLastNameInvalidValue", testGetLastNameInvalidValue),
        ("testGetDateOfBirthValidValue", testGetDateOfBirthValidValue),
        ("testGetDateOfBirthInvalidValue", testGetDateOfBirthInvalidValue),
        ("testGetDateOfDeathValidValue", testGetDateOfBirthValidValue),
        ("testGetDateOfDeathInvalidValue", testGetDateOfBirthInvalidValue)
        
    ]
}


