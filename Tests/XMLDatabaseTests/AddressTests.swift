import XCTest
@testable import XMLDatabase

class AddressTests: XCTestCase {
    
    
    // MARK: Properties tests
    
    func testValidProperties() {
        // different relations
        XCTAssertNoThrow(try Address(id: 1, city: "Cologne", street: "Ehrenstraße"))
        XCTAssertNoThrow(try Address(id: 1, city: "Berlin", street: "Spandauer Straße"))
        XCTAssertNoThrow(try Address(id: 1, city: "Amsterdam", street: "Rozengracht"))
    }
    
    func testProperties() {
        do {
            let address = try Address(id: 1, city: "Berlin", street: "Spandauer Straße")
            
            // init properties
            XCTAssertEqual(address.id, 1)
            XCTAssertEqual(address.city, "Berlin")
            XCTAssertEqual(address.street, "Spandauer Straße")
            
            // change city and street
            try address.change(city: "Munich")
            try address.change(street: "Kaufingerstraße")
            XCTAssertEqual(address.city, "Munich")
            XCTAssertEqual(address.street, "Kaufingerstraße")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    // MARK: Property id tests
    
    func testInvalidId() {
        XCTAssertThrowsError(try Address(id: 0, city: "Berlin", street: "Spandauer Straße")) { error in
            guard case XMLObjectError.invalidId(let value) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, 0)
        }
    }
    
    
    // MARK: Property city tests
    
    func testInvalidCities() {
        var city: String
        
        // firstName is too short (1 character)
        city = "A"
        XCTAssertThrowsError(try Address(id: 1, city: city, street: "ABC")) { error in
            guard case AddressError.invalidCity((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, city)
        }
        do {
            let address = try Address(id: 1, city: "Berlin", street: "Spandauer Straße")
            XCTAssertThrowsError(try address.change(city: city)) { error in
                guard case AddressError.invalidCity(let value) = error else {
                    return XCTFail()
                }
                XCTAssertEqual(value, city)
            }
        } catch {
            XCTFail("\(error)")
        }
        
        
        // city is too long (51 characters)
        city = "AbcdefghijklmnopqrstuvwxyzAbcdefghijklmnopqrstuvwxa"
        XCTAssert(city.count == 51)
        XCTAssertThrowsError(try Address(id: 1, city: city, street: "ABC")) { error in
            guard case AddressError.invalidCity((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, city)
        }
        do {
            let address = try Address(id: 1, city: "Berlin", street: "ABC")
            XCTAssertThrowsError(try address.change(city: city)) { error in
                guard case AddressError.invalidCity(let value) = error else {
                    return XCTFail()
                }
                XCTAssertEqual(value, city)
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    // MARK: Property street tests
    
    func testInvalidStreets() {
        var street: String
        
        // firstName is too short (2 character)
        street = "AB"
        XCTAssertThrowsError(try Address(id: 1, city: "ABC", street: street)) { error in
            guard case AddressError.invalidStreet((let value)) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(value, street)
        }
        do {
            let address = try Address(id: 1, city: "Berlin", street: "Spandauer Straße")
            XCTAssertThrowsError(try address.change(street: street)) { error in
                guard case AddressError.invalidStreet(let value) = error else {
                    return XCTFail()
                }
                XCTAssertEqual(value, street)
            }
        } catch {
            XCTFail("\(error)")
        }
        
        
        // city is too long (51 characters)
        street = "AbcdefghijklmnopqrstuvwxyzAbcdefghijklmnopqrstuvwxyzAbcdefghi"
        XCTAssert(street.count == 61)
        XCTAssertThrowsError(try Address(id: 1, city: "ABC", street: street)) { error in
            guard case AddressError.invalidStreet((let value)) = error else {
                return XCTFail()
            }
            XCTAssertEqual(value, street)
        }
        do {
            let address = try Address(id: 1, city: "Berlin", street: "ABC")
            XCTAssertThrowsError(try address.change(street: street)) { error in
                guard case AddressError.invalidStreet(let value) = error else {
                    return XCTFail()
                }
                XCTAssertEqual(value, street)
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}

extension AddressTests {
    static var allTests = [
        ("testValidProperties", testValidProperties),
        ("testProperties", testProperties),
        ("testInvalidId", testInvalidId),
        ("testInvalidCities", testInvalidCities),
        ("testInvalidStreets", testInvalidStreets)
    ]
}
