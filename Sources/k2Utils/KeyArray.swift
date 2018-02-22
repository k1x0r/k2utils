//
// KeyArray.swift
//
// Created by k1x
//

import Foundation

public protocol KeyProtocol {
    associatedtype KeyType : Hashable
    var key : KeyType { get }
}

extension KeyProtocol {
    
    @inline(__always) func match(key : Self.KeyType) -> Bool {
        return self.key.hashValue == key.hashValue && self.key == key
    }
}

public extension Array where Element : KeyProtocol {
    
    subscript(key : Element.KeyType) -> Element? {
        get {
            return element(for: key);
        }
        set {
            if let index = index(for: key) {
                if let element = newValue {
                    self[index] = element;
                } else {
                    remove(at: index)
                }
            } else if let element = newValue {
                append(element);
            }
        }
    }
    
    
    // returns the first element that matches key
    subscript(keys : Element.KeyType...) -> Element? {
        return element(for: keys);
    }
    
    // merge for not sorted array. Complexity is O(m*n). Priority is another array
    mutating func merge(another : [Element], match : (Element, Element) -> (match: Bool, replace : Bool)) {
        for anElement in another {
            var matchedFound = false;
            for (i, selfElement) in self.enumerated() {
                let res = match(selfElement, anElement);
                if res.match {
                    if res.replace {
                        self[i] = anElement;
                    }
                    matchedFound = true;
                    break;
                }
            }
            if !matchedFound {
                append(anElement);
            }
        }
    }
    
    func element(matches : (Element) -> Bool) -> Element? {
        for anElement in self {
            if matches(anElement) {
                return anElement;
            }
        }
        return nil;
    }
    
    func element(for key : Element.KeyType) -> Element? {
        for anElement in self {
            if anElement.match(key: key) {
                return anElement;
            }
        }
        return nil;
    }
    
    func element(for keys : [Element.KeyType]) -> Element? {
        for anElement in self {
            var match = true;
            for key in keys {
                if !anElement.match(key: key) {
                    match = false;
                    break;
                }
            }
            if match {
                return anElement;
            }
        }
        return nil;
    }
    
    // AND &
    func elements(and keys : Element.KeyType...) -> [Element] {
        var array = [Element]();
        for anElement in self {
            var match = true;
            for key in keys {
                if !anElement.match(key: key) {
                    match = false;
                    break;
                }
            }
            if match {
                array.append(anElement);
            }
        }
        return array;
    }
    
    // OR
    func elements(or keys : Element.KeyType...) -> [Element] {
        var array = [Element]();
        for anElement in self {
            var match = false;
            for key in keys {
                if anElement.match(key: key) {
                    match = true;
                    break;
                }
            }
            if match {
                array.append(anElement);
            }
        }
        return array;
    }
    
    // OR + AND
    // Update only for class types
    // , update : ((Element) ->())? = nil
    func elements(for keys : [Element.KeyType]...) -> [Element] {
        var array = [Element]();
        for anElement in self {
            var match = false;
            for andKeys in keys {
                var andMatch = true;
                for key in andKeys {
                    if !anElement.match(key: key) {
                        andMatch = false;
                    }
                }
                if andMatch {
                    match = true;
                    break
                }
            }
            if match {
//                update?(anElement);
                array.append(anElement);
            }
        }
        return array;
    }
    
    func elements(for key : Element.KeyType) -> [Element] {
        var array = [Element]();
        for anElement in self {
            if anElement.match(key: key) {
                array.append(anElement);
            }
        }
        return array;
    }
    
    func index(for key : Element.KeyType) -> Int? {
        var index : Int? = nil;
        for (i, element) in self.enumerated() {
            if element.match(key: key) {
                index = i;
            }
        }
        return index;
    }
    
    func contains(key : Element.KeyType) -> Bool {
        return index(for: key) != nil;
    }
    
}
