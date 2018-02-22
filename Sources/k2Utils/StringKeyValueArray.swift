//
// StringKeyValueArray.swift
//
// Created by k1x
//

import Foundation

public struct KV : KeyValueStringProtocol {

    public typealias K = String
    public typealias V = String
    
    public var k : K
    public var v : V
    public var hash: Int
    
    public init(_ key : String, _ value : String) {
        self.k = key;
        self.hash = key.hashValue
        self.v = value;
    }
}

public protocol KeyValueStringProtocol : KeyValueProtocol {
    init(_ key : String, _ value : String)
}

public func ^<T> (lhs : String, rhs : String) -> T where T : KeyValueStringProtocol {
    return T(lhs, rhs)
}

public extension Array where Element : KeyValueProtocol, Element.K == String, Element.V == String {
    public var queryStringPercent : String {
        var string = "";
        for (i, e) in self.enumerated() {
            string += i == 0 ? "\(e.k)=\("\(e.v)".percentEncoding)" : "&\(e.k)=\("\(e.v)".percentEncoding)"
        }
        return string;
    }
    
    public var queryString : String {
        var string = "";
        for (i, e) in self.enumerated() {
            string += i == 0 ? "\(e.k)=\(e.v)" : "&\(e.k)=\(e.v)"
        }
        return string;
    }
    
    public var queryOAuth1String : String {
        var string = "";
        for (i, e) in self.enumerated() {
            string += i == 0 ? "\(e.k)=\("\(e.v)".oauth1percentEncoding)" : "&\(e.k)=\("\(e.v)".oauth1percentEncoding)"
        }
        return string;
    }
    
    public var oauth1String : String {
        var string = "";
        for (i, e) in self.enumerated() {
            string += i == 0 ? "\(e.k)=\"\(e.v.oauth1percentEncoding)\"" : ", \(e.k)=\"\(e.v.oauth1percentEncoding)\""
        }
        return string;
    }
}
