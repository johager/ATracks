//
//  SearchHelper.swift
//  ATracks
//
//  Created by James Hager on 5/2/22.
//

import Foundation

class SearchHelper {
    
    var inWord = false
    var and = false
    var not = false
    var match = false
    var pieceChars = [Character]()
    
    var predicate: NSPredicate!
    
    //lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    func resetParams() {
        inWord = false
        and = false
        not = false
        match = false
        pieceChars = [Character]()
    }
    
    func predicate(from stringIn: String) -> NSPredicate? {
        //print("=== \(file).\(#function) - stringIn: '\(stringIn)' ===")
        
        guard stringIn.count > 0 else { return nil }
        
        let string = stringIn.replacingOccurrences(of: "“", with: "\"").replacingOccurrences(of: "”", with: "\"")
        //print("--- \(file).\(#function) -   string: '\(string)'")
        
        var index = 0
        let indexMax = string.count - 1
        let stringStartIndex = string.startIndex
        var stringIndex = stringStartIndex
        var char = string[stringIndex]
        
        while index < string.count {
            stringIndex = string.index(stringStartIndex, offsetBy: index)
            char = string[stringIndex]
            //print("--- \(file).\(#function) - char: '\(char)'")
            if !inWord && char == "+" {
                and = true
            } else if !inWord && char == "-" {
                not = true
            } else if !inWord && char == "\"" {
                inWord = true
                match = true
            } else if char == "\"" && match {
                setPredicate()
            } else if char == " " && !match {
                if pieceChars.count > 0 {
                    setPredicate()
                }
            } else if index == indexMax {
                pieceChars.append(char)
                setPredicate()
            } else {
                inWord = true
                pieceChars.append(char)
            }
            index += 1
        }
        
        return predicate
    }
    
    func setPredicate() {
        //print("=== \(file).\(#function) ===")
        
        let string = String(pieceChars).lowercased()
        
        //print("--- \(file).\(#function) - string: '\(string)', and: \(and), not: \(not), match: \(match)")
        
        let newPredicateComponent: NSPredicate
        if not {
            newPredicateComponent = NSPredicate(format: "NOT %K CONTAINS [c] %@", Track.nameKey, string)
        } else {
            newPredicateComponent = NSPredicate(format: "%K CONTAINS [c] %@", Track.nameKey, string)
        }
        
        //print("--- \(file).\(#function) - newPredicateComponent: \(newPredicateComponent)")
        
        if predicate == nil {
            predicate = newPredicateComponent
            
        } else {
            if and || not {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, newPredicateComponent])
                
            } else {
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, newPredicateComponent])
            }
        }
        
        //print("--- \(file).\(#function) - predicate: '\(predicate!)'")
        
        resetParams()
    }
}
