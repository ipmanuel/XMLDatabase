import Foundation
import SWXMLHash
@testable import XMLDatabase


class XMLPersonMapper: XMLObjectMapper {
    typealias ObjectType = Person
    
    static func toObject(element: XMLIndexer, at url: URL) throws -> Person {
        // get value
        let id = try XMLPersonMapper.getId(from: element, at: url)
        
        // elements should exists
        guard let genderString = element["gender"].element?.text else {
            throw XMLObjectsError.requiredElementIsMissing(element: "gender", at: url)
        }
        guard let firstName = element["firstName"].element?.text else {
            throw XMLObjectsError.requiredElementIsMissing(element: "firstName", at: url)
        }
        let newPerson = try Person(id: id, gender: genderString, firstName: firstName)
        
        // elements should not exists
        let addressesString = element["addresses"].element?.text
        let addressesObjects = element["addresses"]["address"].all
        if addressesString != nil {
            for address in addressesObjects {
                guard let type = address.element?.attribute(by: "type")?.text else {
                    throw XMLObjectsError.requiredAttributeIsMissing(element: "address", attribute: "type", at: url)
                }
                try newPerson.add(addressId: XMLAddressMapper.getId(from: address, at: url), type: type)
            }
        }
        
        return newPerson
    }
    
    static func toXML(object person: Person) -> Foundation.XMLElement {
        // person node
        let personNode = Foundation.XMLElement(name: "person")
        let personIdAttribute = Foundation.XMLNode(kind: XMLNode.Kind.attribute)
        personIdAttribute.name = "id"
        personIdAttribute.stringValue = "\(person.id)"
        personNode.addAttribute(personIdAttribute)
        
        // gender node
        let genderNode = Foundation.XMLElement(name: "gender", stringValue: person.gender.rawValue)
        
        // fistName node
        let firstNameNode = Foundation.XMLElement(name: "firstName", stringValue: person.firstName)
        
        // addresses node
        var addressesNode: Foundation.XMLElement?
        if person.addressesIds.count > 0 {
            addressesNode = Foundation.XMLElement(name: "addresses")
            var addressNode: Foundation.XMLElement
            var addressIdAttribute: Foundation.XMLNode
            var addressTypeAttribute: Foundation.XMLNode
            
            for (index, address) in person.addressesIds.enumerated() {
                addressNode = Foundation.XMLElement(name: "address")
                addressTypeAttribute = Foundation.XMLNode(kind: XMLNode.Kind.attribute)
                addressTypeAttribute.name = "type"
                addressTypeAttribute.stringValue = "\(person.addressesTypes[index])"
                addressIdAttribute = Foundation.XMLNode(kind: XMLNode.Kind.attribute)
                addressIdAttribute.name = "id"
                addressIdAttribute.stringValue = "\(address)"
                addressNode.addAttribute(addressTypeAttribute)
                addressNode.addAttribute(addressIdAttribute)
                
                addressesNode!.addChild(addressNode)
            }
        }
        
        // add required elements to personNode
        personNode.addChild(genderNode)
        personNode.addChild(firstNameNode)
        
        // add optional elements to personNode
        if addressesNode != nil {
            personNode.addChild(addressesNode!)
        }
        
        return personNode
    }
}
