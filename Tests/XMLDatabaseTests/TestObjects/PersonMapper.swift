import Foundation
import SWXMLHash
import XMLDatabase

class PersonMapper: XMLObjectMapper {
    typealias ObjectType = Person
    
    static func toObject(xmlIndexer: XMLIndexer, at url: URL) throws -> Person {
        guard let xmlElement = xmlIndexer.element else {
            throw XMLObjectsError.requiredElementIsMissing(element: String(describing: ObjectType.self).lowercased(), at: url)
        }
        let id = try PersonMapper.getId(from: xmlElement, at: url)
        let genderString = try PersonMapper.getElement(xmlIndexer: xmlIndexer, name: "gender", url: url).text
        let firstName = try PersonMapper.getElement(xmlIndexer: xmlIndexer, name: "firstName", url: url).text
        let newPerson = try Person(id: id, gender: genderString, firstName: firstName)
        
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
        
        // add required elements to personNode
        personNode.addChild(genderNode)
        personNode.addChild(firstNameNode)
        
        return personNode
    }
}
