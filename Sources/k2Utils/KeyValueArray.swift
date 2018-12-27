//
// KeyValueArray.swift
//
// Created by k1x
//

import Foundation

public protocol KeyValueProtocol {
    associatedtype K : Hashable
    associatedtype V
    var k : K { get }
    var v : V { get }
    var hash : Int { get }
    init(_ key : K, _ value : V);
}

public struct Pair<Key, Value> : KeyValueProtocol where Key: Hashable {
    public typealias K = Key
    public typealias V = Value
    
    public var k : K
    public var hash : Int
    public var v : V
    
    public init(_ key : Key, _ value : Value) {
        self.k = key;
        self.hash = key.hashValue
        self.v = value;
    }
}

public func ><K, V> (left : K, right : V) -> Pair<K, V> {
    return Pair(left, right)
}

public struct KeyValueArray<K, V> : This, ExpressibleByDictionaryLiteral where K: Hashable {
    
    public typealias Key = K
    public typealias Value = V
    
    public var array : [Pair<Key, Value>]
    
    public init(dictionaryLiteral elements: (Me.Key, Me.Value)...) {
        array = elements.map({ $0.0 > $0.1 })
    }
}

/// This extension is used to use as Dictionary when order is important
public extension Array where Element : KeyValueProtocol {
    var values : [Element.K] {
        var array : [Element.K] = [];
        for value in self {
            array.append(value.k)
        }
        return array;
    }
    
    subscript (key : Element.K) -> Element.V? {
        get {
            return value(for: key);
        }
        set {
            set(for: key, value: newValue)
        }
    }
    
    mutating func set(_ e: Element) {
        set(for: e.k, value: e.v)
    }
    
    mutating func set(for key : Element.K, value newValue : Element.V?) {
        var index : Int?
        let keyHash = key.hashValue
        for (i, tuple) in self.enumerated() {
            if tuple.hash == keyHash && tuple.k == key {
                index = i
            }
        }
        if let index = index, let value = newValue {
            self[index] = Element(key, value);
        } else if let index = index {
            self.remove(at: index)
        } else if let value = newValue {
            self.append(Element(key, value))
        }
    }
    
    func value(for key : Element.K) ->  Element.V? {
        let keyHash = key.hashValue
        for tuple in self {
            if keyHash == tuple.hash && tuple.k == key {
                return tuple.v
            }
        }
        return nil
    }
    
    func valueAndIndexForKey(key : Element.K) -> (index: Int, value: Element.V)? {
        let keyHash = key.hashValue
        for (index, tuple) in self.enumerated() {
            if keyHash == tuple.hash && tuple.k == key {
                return (index, tuple.v)
            }
        }
        return nil
    }
    
}

