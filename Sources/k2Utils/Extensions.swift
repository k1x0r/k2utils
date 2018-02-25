//
// Extensions.swift
//
// Created by k1x
//

import Foundation
import Dispatch

public let 📱64bit = MemoryLayout<Int>.size == MemoryLayout<Int64>.size

infix operator =+;

/// FIXME: Maybe remove?
public func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    guard let l = lhs, let r = rhs else { return false }
    return l < r
}
public func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    guard let l = lhs, let r = rhs else { return false }
    return l > r
}
public func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    guard let l = lhs, let r = rhs else { return false }
    return l <= r
}
public func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    guard let l = lhs, let r = rhs else { return false }
    return l >= r
}

public func &= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}

public func |= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs || rhs
}

public func += <T>(lhs: inout Array<T>, rhs: Array<T>.Element) {
    lhs.append(rhs)
}

public func =+ <T>(lhs: inout Array<T>, rhs: Array<T>.Element) {
    lhs.insert(rhs, at: 0)
}

public func += <T, S>(lhs: inout Array<T>, rhs: S) where S : Sequence, S.Iterator.Element == T {
    lhs.append(contentsOf: rhs)
}

public extension Array where Element == Int8 {
    
    public init(count: Int) {
        self.init(repeating: 0, count: count)
    }
    
    var uint8array : [UInt8] {
        return unsafeBitCast(self, to: [UInt8].self)
    }
}

public extension Decodable {
    
    public static func readFromDisk(path: String) -> Self? {
        do {
            let jsonDecoder = JSONDecoder()
            let configData : Data = try Data(contentsOf: URL(fileURLWithPath: path))
            let serverConfig = try jsonDecoder.decode(Self.self, from: configData)
            return serverConfig
        } catch {
            print("Couldn't load json from disk: \(error)")
            return nil
        }
        
    }
}

public extension Array where Element == UInt8 {

    public init(count: Int) {
        self.init(repeating: 0, count: count)
    }

    var int8array : [Int8] {
        return unsafeBitCast(self, to: [Int8].self)
    }
}

public extension SignedInteger {
//    
//    mutating func advanced(by value: Self) -> Self {
//        self = self + value
//        return self
//    }
//
    var moreZero: Self {
        return self > 0 ? self : 0
    }
    
    func subtract(_ value : Self, more : Self) -> Self {
        let newValue = self - value
        guard newValue >= more else {
            return more
        }
        return newValue
    }
    
    func add(_ value : Self, less : Self) -> Self {
        let newValue = self + value
        guard newValue <= less else {
            return less
        }
        return newValue
    }

}

public extension TimeInterval {

    public var umillis : UInt64 {
        return UInt64(self * 1000);
    }

    public var millis : Int64 {
        return Int64(self * 1000);
    }
    var seconds : Int64 {
        return Int64(self);
    }
}

public extension Int {

    static public let uint8max = Int(UInt8.max)
    static public let uint16max = Int(UInt16.max)
    #if (arch(x86_64) || arch(arm64))
    static public let uint32max = Int(UInt32.max)
    #endif
    public var int32 : Int32 {
        return Int32(self)
    }
    
    public var uint16 : UInt16 {
        return UInt16(self)
    }
    
    public var uint8 : UInt8 {
        return UInt8(self)
    }
}

public protocol This {
}

extension NSObject : This {}

public extension This {
    public typealias this = Self
}

public extension UUID {
    
    @_transparent
    public var data : Data {
        return Data(bytes: uuidBytes)
    }
    
    @_transparent
    public var uuidBytes : [UInt8] {
        return Mirror(reflecting: self.uuid).children.map { $0.1 as! UInt8 }
    }
}

extension URLQueryItem : KeyValueProtocol {
    public init(_ key: String, _ value: String) {
        NSLog("Warning. Recursion... Don't use set subscript with URLQueryItem!!!")
        self.init(key, value);
    }

    public typealias K = String
    public typealias V = String

    @_transparent
    public var k : K {
        return name;
    }
    
    @_transparent
    public var hash : Int {
        return k.hashValue
    }
    
    @_transparent
    public var v : V {
        return value ?? "";
    }
    
}

extension Int32 : RawRepresentable {

    @_transparent
    public var rawValue: Int32 {
        return self
    }
    
    public typealias RawValue = Int32
    
    @_transparent
    public init?(rawValue: Int32.RawValue) {
        self = rawValue
    }

    
}

public extension DispatchQueue {
    
    func asynce(_ closure : @escaping () throws -> (), error errorClosure : ((Error) -> ())? = nil) {
        async {
            do {
                try closure()
            } catch {
                errorClosure?(error)
            }
        }
    }
    
}


extension String {
    public func error(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) -> StringError {
       return StringError(description: "\(Date()): <\(fileName)> \(functionName) [#\(lineNumber)]| \(self)")
    }
    
    public var rawError : StringError {
        return StringError(description : self)
    }
}


public struct StringError : LocalizedError {
    
    @_transparent
    public var errorDescription: String? {
        return description
    }
    
    public var description : String
}

public extension Dictionary where Key : ExpressibleByStringLiteral {

    var jsonDataOrEmpty : Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: (0~)!)
        } catch {
            return Data()
        }
    }

    var jsonData : Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: (0~)!)
        } catch {
            return nil
        }
    }
    
    var jsonString : String? {
        do {
            let json = try JSONSerialization.data(withJSONObject: self, options: (0~)!);
            return String(data: json, encoding: .utf8);
        } catch {
            return nil;
        }
    }
    
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

public extension Data {
    var json : [String : Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: (0~)!) as? [String : Any];
        } catch {
            return nil;
        }
    }
    
    var jsonArray : [Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: (0~)!) as? [Any];
        } catch {
            return nil;
        }
    }

}
