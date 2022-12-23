//
//  String+Extenstion.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 05.11.20.
//

import Foundation

extension String {
    
    public var uint8: [UInt8] {// delete it in the future
        return Array(self.utf8)
    }

    public var byteArray: [UInt8] {// delete it in the future
        return Array(self.utf8)
    }

    public var utf8ByteArray: [UInt8] {
        return Array(self.utf8)
    }

    public func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: self)
    }

    // Source: https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    public static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
