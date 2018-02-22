//
// ArraySelect.swift
//
// Created by k1x
//

import Foundation

public enum Loop : Error {
    case lbreak
}

public extension Collection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}

public enum CompResult {
    case equal
    case less
    case great
}

public extension Array {
    
    public mutating func inoutFirst(_ filter : (Element) -> Bool, element elementClosure: (inout Element)->Void)  {
        try! loop { index, element in
            if filter(element) {
                elementClosure(&element)
                throw Loop.lbreak
            }
        }
    }
    
    @available(deprecated, message: "Should not be used because Swift 4 single access memory management. Will be deleted in future")
    mutating public func loop(_ iterator : (inout Int, inout Element) throws -> ()) rethrows {
        var i = 0;
        while i < count {
            do {
                try iterator(&i, &self[i])
            } catch Loop.lbreak {
                break;
            } catch {
                throw error
            }
            i += 1
        }
    }
    
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
    

    
    public mutating func insert(newElement: Element, by sorted : (Element, Element) -> (CompResult)) -> Int {
        let i = findInsertionPoint(newElement: newElement, by: sorted);
        insert(newElement, at: i);
        return i
    }
    
    private func findInsertionPoint(newElement: Element, by sorted : (Element, Element) -> (CompResult)) -> Int {
        var range = (startIndex : 0, endIndex : self.count)
        while range.startIndex < range.endIndex {
            let midIndex = range.startIndex + (range.endIndex - range.startIndex) / 2
            let result = sorted(self[midIndex], newElement);
            if result == .equal {
                return midIndex
            } else if result == .less {
                range.startIndex = midIndex + 1
            } else {
                range.endIndex = midIndex
            }
        }
        return range.startIndex
    }
    

}
