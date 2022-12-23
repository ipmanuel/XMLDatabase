//
//  XMLDocumentContainerHelpers.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 08.03.21.
//

import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
@testable import XMLDatabase

func initContainerWithObjects(amount: Int) throws -> XMLDocumentContainer {
    let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
    var xmlElement: FXMLElement
    var newPerson: Person
    for id in 0..<amount {
        newPerson = try Person(id: id, gender: .male, firstName: "Manuel")
        xmlElement = PersonMapper.toXMLElement(from: newPerson)
        try container.add(xmlElement: xmlElement, withId: id)
    }

    return container
}
