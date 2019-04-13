//
// ArrayExtensions.swift
//
// Created by k1x
//

import Foundation

public extension Sequence {
    
    func firstMap<T>(where whereClosure: (Element)->(T?)) -> T? {
        for element in self {
            if let result = whereClosure(element) {
                return result
            }
        }
        return nil
    }
    
}

public extension Array where Element : AnyObject {
    
    @discardableResult
    mutating func remove(byReference element : Element) -> Bool {
        guard let index = index(where: { $0 === element }) else {
            return false
        }
        remove(at: index)
        return true
    }
    
}

public extension Array {
    var lastIndex : Int {
        return endIndex - 1
    }
    
    var rawData : Data {
        return withUnsafeBytes { bufferPtr -> Data in
            guard let baseAddress = bufferPtr.baseAddress else {
                return Data()
            }
            return Data(bytes: baseAddress, count: bufferPtr.count)
        }
    }
    
}

extension Array {
    /**
     Turn into an array of various chunk sizes
     
     Last component may not be equal size as others.
     
     [1,2,3,4,5].chunked(size: 2)
     ==
     [[1,2],[3,4],[5]]
     */
    public func chunked(size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map { startIndex in
            let next = startIndex.advanced(by: size)
            let end = next <= endIndex ? next : endIndex
            return Array(self[startIndex ..< end])
        }
    }
}

extension Array where Element: Hashable {
    /**
     Trims the head and tail of the array to remove contained elements.
     
     [0,1,2,1,0,1,0,0,0,0].trimmed([0])
     // == [1,2,1,0,1]
     
     This function is intended to be as performant as possible, which is part of the reason
     why some of the underlying logic may seem a bit more tedious than is necessary
     */
    public func trimmed(_ elements: [Element]) -> SubSequence {
        guard !isEmpty else { return [] }
        
        let lastIdx = self.count - 1
        var leadingIterator = self.indices.makeIterator()
        var trailingIterator = leadingIterator
        
        var leading = 0
        var trailing = lastIdx
        while let next = leadingIterator.next(), elements.contains(self[next]) {
            leading += 1
        }
        while let next = trailingIterator.next(), elements.contains(self[lastIdx - next]) {
            trailing -= 1
        }
        
        guard trailing >= leading else { return [] }
        return self[leading...trailing]
    }
}

public extension Array where Element == String {
    
    var wireFormat : [Int8] {
        var totalLength = 0
        let cArrays : [[CChar]] = map({
            let cArray = $0.cArray
            totalLength += cArray.count + 1
            return cArray
        })
        let buffer = ByteBuffer(bufferSize: totalLength)
        for array in cArrays {
            _ = try! buffer.write(bytesOf: UInt8(array.count))
            _ = try! buffer.write(byteArray: array)
        }
        return buffer.buffer
    }
    
}

public protocol Sorting {
    associatedtype SortType
    func greater(second : Self, by sortType : SortType) -> Bool;
    
}

public extension Array where Element : Equatable {
    func containsCount(element : Element) -> Int {
        var count = 0;
        for el in self {
            if el == element {
                count += 1;
            }
        }
        return count;
    }
}

public extension Array where Element : Sorting {

    mutating func sort(by sortType : Element.SortType) {
        sort { (first : Element, second : Element) -> Bool in
            return first.greater(second: second, by: sortType);
        }
    }
    
    // Optimize space complexity
    // the order is preserved in comparison to quick sort
    func mergeSort(by sortType : Element.SortType) -> [Element] {
        let n = self.count
        var z = [self, self]
        var d = 0
        
        var width = 1
        while width < n {
            
            var i = 0
            while i < n {
                var j = i
                var l = i
                var r = i + width
                
                let lmax = Swift.min(l + width, n)
                let rmax = Swift.min(r + width, n)
                
                while l < lmax && r < rmax {
                    if !z[d][l].greater(second: z[d][r], by: sortType) {
                        z[1 - d][j] = z[d][l]
                        l += 1
                    } else {
                        z[1 - d][j] = z[d][r]
                        r += 1
                    }
                    j += 1
                }
                
                while l < lmax {
                    z[1 - d][j] = z[d][l]
                    j += 1
                    l += 1
                }
                while r < rmax {
                    z[1 - d][j] = z[d][r]
                    j += 1
                    r += 1
                }
                
                i += width * 2
            }
            
            width *= 2
            d = 1 - d
            
        }
        return z[d]
    }
}


