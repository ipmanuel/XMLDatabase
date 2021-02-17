//
//  Person.swift
//  PersonsXMLDatabase
//
//  Created by Manuel Pauls on 14.12.17.
//


import Foundation
import FoundationXML
import SWXMLHash
import XMLDatabase

class PersonMapper: XMLObjectMapper {
    typealias ObjectType = Person
    
    static func toXMLObject(from xmlIndexer: XMLIndexer, at url: URL) throws -> Person {
        // XML elements should exists
        let personXMLElement = try getRootXMLElement(of: xmlIndexer, at: url)
        let id = try PersonMapper.getAttributeId(of: personXMLElement, at: url)
        let genderString = try PersonMapper.getXMLElement(of: xmlIndexer, name: "Gender", at: url).text
        let firstName = try PersonMapper.getXMLElement(of: xmlIndexer, name: "FirstName", at: url).text
        
        // init person
        let newPerson = try Person(id: id, gender: genderString, firstName: firstName)
        
        // optional XML elements
        let lastNameXMLElement = xmlIndexer["LastName"].element
        if lastNameXMLElement != nil {
            try newPerson.set(lastName: lastNameXMLElement!.text)
        }
        
        return newPerson
    }
    
    static func toXMLElement(from person: Person) -> FoundationXML.XMLElement {
        // person XML element
        let personXMLElement = FoundationXML.XMLElement(name: "Person")
        let personIdAttribute = FoundationXML.XMLNode(kind: XMLNode.Kind.attribute)
        personIdAttribute.name = "id"
        personIdAttribute.stringValue = "\(person.id)"
        personXMLElement.addAttribute(personIdAttribute)
        
        // gender XML element
        let genderXMLElement = FoundationXML.XMLElement(name: "Gender", stringValue: person.gender.rawValue)
        
        // fistName XML element
        let firstNameXMLElement = FoundationXML.XMLElement(name: "FirstName", stringValue: person.firstName)
        
        // add XML elements to person XML element
        personXMLElement.addChild(genderXMLElement)
        personXMLElement.addChild(firstNameXMLElement)
        
        // optional lastName XML element
        if person.lastName != nil {
            let lastNameXMLElement = FoundationXML.XMLElement(name: "LastName", stringValue: person.lastName!)
            personXMLElement.addChild(lastNameXMLElement)
        }
        
        return personXMLElement
    }
}
