//
//  Person.swift
//  PersonsXMLDatabase
//
//  Created by Manuel Pauls on 14.12.17.
//

import Foundation
import SWXMLHash
import XMLDatabase

class PersonMapper: XMLObjectMapper {
    typealias ObjectType = Person
    
    static func toXMLObject(from xmlIndexer: XMLIndexer, at url: URL) throws -> Person {
        // XML elements should exists
        let personXMLElement = try getRootXMLElement(of: xmlIndexer, at: url)
        let id = try PersonMapper.getAttributeId(of: personXMLElement, at: url)
        let genderString = try PersonMapper.getXMLElement(of: xmlIndexer, name: "gender", at: url).text
        let firstName = try PersonMapper.getXMLElement(of: xmlIndexer, name: "firstName", at: url).text
        
        // init person
        let newPerson = try Person(id: id, gender: genderString, firstName: firstName)
        
        return newPerson
    }
    
    static func toXMLElement(from person: Person) -> Foundation.XMLElement {
        // person XML element
        let personXMLElement = Foundation.XMLElement(name: "person")
        let personIdAttribute = Foundation.XMLNode(kind: XMLNode.Kind.attribute)
        personIdAttribute.name = "id"
        personIdAttribute.stringValue = "\(person.id)"
        personXMLElement.addAttribute(personIdAttribute)
        
        // gender XML element
        let genderXMLElement = Foundation.XMLElement(name: "gender", stringValue: person.gender.rawValue)
        
        // fistName XML element
        let firstNameXMLElement = Foundation.XMLElement(name: "firstName", stringValue: person.firstName)
        
        // add XML elements to person XML element
        personXMLElement.addChild(genderXMLElement)
        personXMLElement.addChild(firstNameXMLElement)
        
        return personXMLElement
    }
}
