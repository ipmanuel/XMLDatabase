# XMLDatabase

XMLDatabase is a simple library to save, fetch and remove objects of XML documents.
Beside that, it is possible to integrate validations.
This database is a great way to ex- and import XML documents or to have a very good human readable and editable database.

## Installation

XMLDatabase can be installed using Swift Package Manager or manually.

### Swift Package Manager

Add the following line to *Package.swift*.
```swift
dependencies: [
    .package(url: "https://github.com/ipmanuel/XMLDatabase.git", from: "1.3.0")
]
```

Notice: XMLDatabase is only compatible with swift 5.2 or newer.

### Manually

Clone the repository and copy the directory *Sources/XMLDatabase* with all the files to your project.
You don't need to write `import XMLDatabase` as it is shown in the example further below.

## Example


### New entity
To add a new entity. 
You need to create two files.
One file defines the properties with validations, getter and setter methods.
The other file is neccessary to convert the object to xml.
Look for an example [here](https://github.com/ipmanuel/XMLDatabase/tree/master/Tests/XMLDatabaseTests/TestObjects).

### Import
```swift
import Foundation
import XMLDatabase
```

### Initialization
You can initialize an empty xml document in the following way:
```swift
let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Persons.xml")
let container = try XMLDocumentContainer(objectName: "Person", objectNamePlural: "Persons")
let xmlDocumentManager = try XMLDocumentManager(at: url, with: container)
```
### Manage objects
Init the manager for objects.
```swift
let manager = XMLObjectsManager<PersonMapper>(xmlDocumentManager: xmlDocumentManager)
```
Initialize instances, which you want to save.
Attention: The id of a new object will be set automatically.
Therefore it is set with 0.
```swift
var newPerson1 = try Person(id: 0, gender: .male, firstName: "Max")
var newPerson2 = try Person(id: 0, gender: .male, firstName: "Mary")
var newPerson3 = try Person(id: 0, gender: .male, firstName: "Willi")
var newPerson4 = try Person(id: 0, gender: .male, firstName: "Kate")
```
Add all the objects to the container.
Keep in mind, each operation includes the following process: 
1. load the xml document
2. change the xml document 
3. save the xml document. 
So that this is inefficient:
```swift
try manager.addObject(object: &newPerson1)
try manager.addObject(object: &newPerson2)
try manager.addObject(object: &newPerson3)
try manager.addObject(object: &newPerson4)
try manager.removeObject(object: &newPerson2)
```
More efficent way:
```swift
var objects = [newPerson1, newPerson2, newPerson3, newPerson4]
try manager.addObjects(objects: &objects)
try manager.removeObject(object: newPerson2)
```

## Test Enviroment

For now, the XMLDatabase is tested in Ubuntu 20.04 and in MacOs 12.

## License

The XMLDatabase is available under [MIT licence](https://github.com/ipmanuel/XMLDatabase/blob/master/LICENSE).
