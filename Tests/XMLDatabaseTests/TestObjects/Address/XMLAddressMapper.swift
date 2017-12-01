import Foundation
import SWXMLHash
@testable import XMLDatabase

class XMLAddressMapper: XMLObjectMapper {
    typealias ObjectType = Address
    
    static func toObject(element: XMLIndexer, at url: URL) throws -> Address {
        // get value
        let id = try XMLAddressMapper.getId(from: element, at: url)
        
        // elements should exists
        guard let city = element["city"].element?.text else {
            throw XMLObjectsError.requiredElementIsMissing(element: "city", at: url)
        }
        
        guard let street = element["street"].element?.text else {
            throw XMLObjectsError.requiredElementIsMissing(element: "street", at: url)
        }
        
        return try Address(id: id, city: city, street: street)
    }
    
    static func toXML(object: Address) -> Foundation.XMLElement {
        // address with id node
        let addressNode = Foundation.XMLElement(name: "address")
        let addressIdAttribute = Foundation.XMLNode(kind: XMLNode.Kind.attribute)
        addressIdAttribute.name = "id"
        addressIdAttribute.stringValue = "\(object.id)"
        addressNode.addAttribute(addressIdAttribute)
        
        // city node
        let cityNode = Foundation.XMLElement(name: "city", stringValue: object.city)
        
        // street node
        let streetNode = Foundation.XMLElement(name: "street", stringValue: object.street)
        
        // add to personNode
        addressNode.addChild(cityNode)
        addressNode.addChild(streetNode)
        
        return addressNode
    }
}
