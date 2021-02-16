//
//  String+CapitablizeFirstLetter.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 16.12.21.
//

extension String {
    
    public var firstLetterCapitalized: String {
    	return capitalizeFirstLetter()
    }

    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}