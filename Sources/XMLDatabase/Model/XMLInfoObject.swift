//
//  XMLInfoObject.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 01.01.21.
//


import Foundation

/// XML info object (not thread safe)
open class XMLInfoObject: XMLObject {
    
    
    // MARK: - Properties

    /// max id of the entries (number from -1)
    /// -1 is set for documents with no entries
    private var maxIdMutable: Int
    public var maxId: Int {
        return maxIdMutable
    }
    
    /// includes all unused ids between 0 and maxId
    private var gapIdsMutable: [Int]
    public var gapIds: [Int] {
        return gapIdsMutable
    }

    /// the amount of saved objects
    private var countMutable: Int
    public var count: Int {
        return countMutable
    }

    /// name of the object
    private var objectNameMutable: String
    public var objectName: String {
        return objectNameMutable
    }

    /// plural name of the object
    private var objectNamePluralMutable: String
    public var objectNamePlural: String {
        return objectNamePluralMutable
    }
    
    
    // MARK: - Init
    
    init(maxId: Int, gapIds: [Int], count: Int, 
        objectName: String, objectNamePlural: String) throws {
        // set dummy values and call super init
        maxIdMutable = -2
        gapIdsMutable = [-1]
        countMutable = -1
        objectNameMutable = ""
        objectNamePluralMutable = ""

        try super.init(id: 1)

        // check and set 
        try set(maxId: maxId)
        try set(gapIds: gapIds)
        try set(count: count)
        try set(objectName: objectName, objectNamePlural: objectNamePlural)
    }

    convenience init(objectName: String, objectNamePlural: String) throws {
        try self.init(maxId: -1, gapIds: [], count: 0, 
            objectName: objectName, objectNamePlural: objectNamePlural)
    }

    convenience init(maxIdString: String, gapIdsString: String, 
        countString: String, objectName: String, objectNamePlural: String) throws {
        let maxId = try XMLInfoObject.getMaxId(from: maxIdString)
        let gapIds = try XMLInfoObject.getGapIds(from: gapIdsString, maxId: maxId)
        let count = try XMLInfoObject.getCount(from: countString)

        try self.init(maxId: maxId, gapIds: gapIds, count: count, 
            objectName: objectName, objectNamePlural: objectNamePlural)
    }


    // MARK: - Set properties
    
    func set(maxId: Int) throws {
        guard XMLInfoObject.isValid(maxId: maxId) else {
            throw XMLInfoObjectError.invaliMaxtId(value: maxId)
        }
        maxIdMutable = maxId
    }

    func set(gapIds: [Int]) throws {
        guard XMLInfoObject.isValid(maxId: maxId, gapIds: gapIds) else {
            throw XMLInfoObjectError.invalidGapIds(value: gapIds)
        }
        gapIdsMutable = gapIds.sorted()
    }

    func add(id: Int) throws {
        let nextMaxId = maxIdMutable + 1
        guard 0 <= id && id <= (nextMaxId) else {
            throw XMLDocumentContainerError.invalidId
        }

        // remove gapId or increment max id
        let oldGapIds = gapIdsMutable
        let oldMaxId = maxIdMutable
        let oldCount = countMutable
        do {
            if id == nextMaxId {
                try incrementMaxId()
            } else {
                try removeGapId(id: id)
            }
            try incrementCount()
        } catch {
            maxIdMutable = oldMaxId
            gapIdsMutable = oldGapIds
            countMutable = oldCount
            
            throw error
        }
    }

    func remove(id: Int) throws {
        guard 0 <= id && id <= maxId else {
            throw XMLDocumentContainerError.invalidId
        }

        // add gapId or decrement max id
        let oldGapIds = gapIdsMutable
        let oldMaxId = maxIdMutable
        let oldCount = countMutable
        do {
            if id < maxId {
                try addGapId(id: id)
            } else {
                try decrementMaxId()
            }
            try decrementCount()
        } catch {
            maxIdMutable = oldMaxId
            gapIdsMutable = oldGapIds
            countMutable = oldCount

            throw error
        }
    }

    func addGapId(id: Int) throws {
        guard id < maxId else {
            throw XMLInfoObjectError.noEmptyGapIdsExists
        }
        let gapIds = gapIdsMutable + [id]
        guard XMLInfoObject.isValid(maxId: maxId, gapIds: gapIds) else {
            throw XMLInfoObjectError.invalidGapIds(value: gapIds)
        }

        gapIdsMutable = gapIds.sorted()
    }

    func removeGapId(id: Int) throws {
        guard let index = gapIdsMutable.firstIndex(of: id) else {
            throw XMLDocumentContainerError.invalidId
        }
        gapIdsMutable.remove(at: index)
    }

    func set(count: Int) throws {
        guard XMLInfoObject.isValid(count: count) else {
            throw XMLInfoObjectError.invaliCount(value: count)
        }
        countMutable = count
    }

    func set(objectName: String, objectNamePlural: String) throws {
        guard XMLInfoObject.isValid(objectName: objectName, objectNamePlural: objectNamePlural) else {
            throw XMLInfoObjectError.invaliObjectName(singular: objectName, plural: objectNamePlural)
        }
        objectNameMutable = objectName
        objectNamePluralMutable = objectNamePlural
    }

    func incrementMaxId() throws {
        try set(maxId: maxIdMutable + 1)
    }

    func decrementMaxId() throws {
        try set(maxId: maxIdMutable - 1)
        var index: Int?
        let newMaxId = maxIdMutable
        while true {
            index = gapIdsMutable.firstIndex(of: newMaxId)
            guard index != nil else {
                break
            }
            gapIdsMutable.remove(at: index!)
            maxIdMutable -= 1
        }
        try set(maxId: newMaxId)
    }

    func incrementCount() throws {
        try set(count: countMutable + 1)
    }

    func decrementCount() throws {
        try set(count: countMutable - 1)
    }
    
    
    // MARK: - Validate

    public class func isValid(maxId: Int) -> Bool {
        return maxId >= -1
    }
    
    public class func isValid(maxId: Int, gapIds: [Int]) -> Bool {
        for gapId in gapIds {
            if gapId < 0 || gapId >= maxId {
                return false
            }
        }
        return true
    }

    public class func isValid(count: Int) -> Bool {
        return count >= 0
    }

    public class func isValid(objectName: String, objectNamePlural: String) -> Bool {
        guard objectName != "" && objectNamePlural != "" else {
            return false
        }

        var isCapitalized = objectName == objectName.firstLetterCapitalized
        isCapitalized = isCapitalized && objectNamePlural == objectNamePlural.firstLetterCapitalized

        return isCapitalized
    }
    
    
    // MARK: - Convert
    
    public class func getMaxId(from maxIdString: String) throws -> Int {
        guard let maxId = Int(maxIdString) else {
            throw XMLInfoObjectError.invalidMaxIdString(value: maxIdString)
        }
        guard XMLInfoObject.isValid(maxId: maxId) else {
            throw XMLInfoObjectError.invaliMaxtId(value: maxId)
        }
        
        return maxId
    }

    public class func getGapIds(from gapsIdsString: String, maxId: Int) throws -> [Int] {
        if gapsIdsString == "" {
            return []
        }

        let stringArray = gapsIdsString.components(separatedBy: ",")
        var intArray: [Int] = []
        var tmpGapId: Int!
        for gapsIdString in stringArray {
            tmpGapId = Int(gapsIdString)
            guard tmpGapId != nil else {
                throw XMLInfoObjectError.invalidGapIdsString(value: gapsIdsString)
            }   
            intArray.append(tmpGapId)
        }

        guard XMLInfoObject.isValid(maxId: maxId, gapIds: intArray) else {
            throw XMLInfoObjectError.invalidGapIds(value: intArray)
        }
        
        return intArray
    }

   public class func getCount(from countString: String) throws -> Int {
        guard let count = Int(countString) else {
            throw XMLInfoObjectError.invalidCountString(value: countString)
        }
        guard XMLInfoObject.isValid(count: count) else {
            throw XMLInfoObjectError.invaliCount(value: count)
        }
        
        return count
    }
}

extension XMLInfoObject: CustomStringConvertible {
    public var description: String {
        var str = "{"
        str += "maxId: \(maxId),"
        str += "gapIds: \(gapIds),"
        str += "count: \(count),"
        str += "objectName: \(objectName),"
        str += "objectNamePlural: \(objectNamePlural)}"

        return str
    }
}
