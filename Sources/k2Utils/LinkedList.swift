//
// LinkedList.swift
//
// Created by k1x
//

import Foundation

public final class LinkedList<T> {
    
    /// Linked List's Node Class Declaration
    public class LinkedListNode<T> {
        public var value: T
        var next: LinkedListNode?
        weak var previous: LinkedListNode?
        
        public init(value: T) {
            self.value = value
        }
    }
    
    /// Typealiasing the node class to increase readability of code
    public typealias Node = LinkedListNode<T>
    
    
    var firstNode: Node?
    var lastNode: Node?
    
    /// Computed property to check if the linked list is empty
    public var isEmpty: Bool {
        return firstNode == nil
    }
    
    /// Computed property to iterate through the linked list and return the total number of nodes
    public var count: Int {
        guard var node = firstNode else {
            return 0
        }
        
        var count = 1
        while let next = node.next {
            node = next
            count += 1
        }
        return count
    }
    
    /// Default initializer
    public init() {}
    
    
    /// Subscript function to return the node at a specific index
    ///
    /// - Parameter index: Integer value of the requested value's index
    public subscript(index: Int) -> T {
        let node = self.node(at: index)
        return node!.value
    }
    
    /// Function to return the node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the node's index to be returned
    /// - Returns: LinkedListNode
    public func node(at index: Int) -> Node? {
        assert(firstNode != nil, "List is empty")
        assert(index >= 0, "index must be greater or equal to 0")
        
        if index == 0 {
            return firstNode
        } else {
            var node = firstNode?.next
            for _ in 1..<index {
                node = node?.next
                if node == nil {
                    break
                }
            }
            return node
        }
    }
    
    /// Append a value to the end of the list
    ///
    /// - Parameter value: The data value to be appended
    public func push(_ value: T) {
        let newNode = Node(value: value)
        push(newNode)
    }
    
    /// Append a copy of a LinkedListNode to the end of the list.
    ///
    /// - Parameter node: The node containing the value to be appended
    public func push(_ node: Node) {
        let newNode = node
        if let lastNode = lastNode {
            newNode.previous = lastNode
            lastNode.next = newNode
            self.lastNode = newNode
        } else {
            firstNode = newNode
            lastNode = newNode
        }
    }
    
    /// Append a copy of a LinkedList to the end of the list.
    ///
    /// - Parameter list: The list to be copied and appended.
    public func append(_ list: LinkedList) {
        var nodeToCopy = list.firstNode
        while let node = nodeToCopy {
            push(node.value)
            nodeToCopy = node.next
        }
    }
    
    /// Insert a value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - value: The data value to be inserted
    ///   - index: Integer value of the index to be insterted at
    public func insert(_ value: T, at index: Int) {
        let newNode = Node(value: value)
        insert(newNode, at: index)
    }
    
    /// Insert a copy of a node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - node: The node containing the value to be inserted
    ///   - index: Integer value of the index to be inserted at
    @discardableResult
    public func insert(_ newNode: Node, at index: Int) -> Bool {
        if index == 0 {
            newNode.next = firstNode
            firstNode?.previous = newNode
            if firstNode == nil {
                lastNode = newNode
            }
            firstNode = newNode
        } else {
            guard let prev = node(at: index - 1) else {
                return false
            }
            let next = prev.next
            newNode.previous = prev
            newNode.next = next
            next?.previous = newNode
            prev.next = newNode
            if next == nil {
                lastNode = newNode
            }
        }
        return true
    }
    
    /// Insert a copy of a LinkedList at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - list: The LinkedList to be copied and inserted
    ///   - index: Integer value of the index to be inserted at
    public func insert(_ list: LinkedList, at index: Int) -> Bool {
        
        
        if index == 0 {
            list.lastNode?.next = firstNode
            firstNode = list.firstNode
            if list.isEmpty {
                lastNode = list.lastNode
            }
        } else if list.isEmpty {
            return false
        } else {
            guard let prev = node(at: index - 1) else {
                return false
            }
            let next = prev.next
            if next == nil {
                lastNode = list.lastNode
            }
            prev.next = list.firstNode
            list.firstNode?.previous = prev
            list.lastNode?.next = next
            next?.previous = list.lastNode
        }
        return true
    }
    
    /// Function to remove all nodes/value from the list
    public func removeAll() {
        lastNode = nil
        firstNode = nil
    }
    
    /// Function to remove a specific node.
    ///
    /// - Parameter node: The node to be deleted
    /// - Returns: The data value contained in the deleted node.
    @discardableResult public func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            firstNode = next
        }
        if next == nil {
            lastNode = prev
        }
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    /// Function to remove the last node/value in the list. Crashes if the list is empty
    ///
    /// - Returns: The data value contained in the deleted node.
    @discardableResult
    public func pop() -> T? {
        guard let lastNode = lastNode else {
            return nil
        }
        return remove(node: lastNode)
    }
    
    
    @discardableResult
    public func popFirst() -> T? {
        guard let firstNode = firstNode else {
            return nil
        }
        return remove(node: firstNode)
    }
    
    
    /// Function to remove a node/value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the index of the node to be removed
    /// - Returns: The data value contained in the deleted node
    @discardableResult
    public func remove(at index: Int) -> T? {
        let node = self.node(at: index)
        if let node = node {
            return remove(node: node)
        } else {
            return nil
        }
    }
    
    @discardableResult
    public func remove(where whereClosure: (T) -> Bool) -> T? {
        var node = firstNode
        while let nd = node {
            if whereClosure(nd.value) {
                return remove(node: nd)
            }
            node = nd.next
        }
        return nil
    }
    
}

//: End of the base class declarations & beginning of extensions' declarations:
// MARK: - Extension to enable the standard conversion of a list to String
extension LinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = firstNode
        while let nd = node {
            s += "\(nd.value)"
            node = nd.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

// MARK: - Extension to add a 'reverse' function to the list
extension LinkedList {
    public func reverse() {
        var node = firstNode
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            firstNode = currentNode
        }
    }
}

// MARK: - An extension with an implementation of 'map' & 'filter' functions
extension LinkedList {
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        var node = firstNode
        while let nd = node {
            result.push(transform(nd.value))
            node = nd.next
        }
        return result
    }
    
    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        var node = firstNode
        while let nd = node {
            if predicate(nd.value) {
                result.push(nd.value)
            }
            node = nd.next
        }
        return result
    }
    

}

// MARK: - Extension to enable initialization from an Array
extension LinkedList {
    convenience init(array: Array<T>) {
        self.init()
        
        array.forEach { push($0) }
    }
}

// MARK: - Extension to enable initialization from an Array Literal
extension LinkedList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        
        elements.forEach { push($0) }
    }
}

// MARK: - Collection
extension LinkedList: Collection {
    
    public typealias Index = LinkedListIndex<T>
    
    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    /// - Complexity: O(1)
    public var startIndex: Index {
        get {
            return LinkedListIndex<T>(node: firstNode, tag: 0)
        }
    }
    
    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    /// - Complexity: O(n), where n is the number of elements in the list. This can be improved by keeping a reference
    ///   to the last node in the collection.
    public var endIndex: Index {
        get {
            if let h = self.firstNode {
                return LinkedListIndex<T>(node: h, tag: count)
            } else {
                return LinkedListIndex<T>(node: nil, tag: startIndex.tag)
            }
        }
    }
    
    public subscript(position: Index) -> T {
        get {
            return position.node!.value
        }
    }
    
    public func index(after idx: Index) -> Index {
        return LinkedListIndex<T>(node: idx.node?.next, tag: idx.tag + 1)
    }
}

// MARK: - Collection Index
/// Custom index type that contains a reference to the node at index 'tag'
public struct LinkedListIndex<T>: Comparable {
    fileprivate let node: LinkedList<T>.LinkedListNode<T>?
    fileprivate let tag: Int
    
    public static func==<T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
        return (lhs.tag == rhs.tag)
    }
    
    public static func< <T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
        return (lhs.tag < rhs.tag)
    }
}
