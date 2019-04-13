//
// DispatchChain.swift
//
// Created by k1x
//

import Foundation
import Dispatch
import k2Utils

public protocol ChainIf {
    var value : Bool { get }
}

extension Bool : ChainIf {
    public var value: Bool {
        return self
    }
}

public class ChainContext<C> : This {

    public typealias ErrorHandler = (C, Error) -> ()
    public typealias DeferHandler = (C) -> ()
    
    public var deferHandler : DeferHandler?
    public var errorHandler : ErrorHandler?
    public var endQueue : DispatchQueue?
    
    internal var runCommand : (() -> Void)?
    public var context : C

    internal var chains : [NextCommand] = []
    var head : NextCommand? = nil
    
    public init(context : C) {
        self.context = context
    }
    
    func performOnErrorDefer(error: Error?) {
        if let error = error, let errorHandler = self.errorHandler {
            errorHandler(context, error)
        }
        if let deferHandler = self.deferHandler {
            deferHandler(context)
        }

        head?.clearNextCommand()
        head = nil
        
        chains = []
        runCommand = nil

        print("🏁 ChainContext -> Handle Error Finish")

    }
    
    public func handleErrorDefer(error : Error?) {
        print("⛑ Handling error defer \(String(describing: error))")
        print("🚩 ChainContext -> Handle Error Start")
        if let errorQ = endQueue {
            errorQ.async { [unowned self] in
                self.performOnErrorDefer(error: error)
            }
        } else {
            performOnErrorDefer(error: error)
        }
    }
    
    deinit {
        print("\(Me.self) deinit")
    }
}


var cId : Int = 0

func nextId() -> Int {
    defer {
        cId += 1
    }
    return cId
}

public struct Nothing {
    internal init() {}
}

protocol NextCommand {
    
    func clearNextCommand()
    
    
}

public class Chain<T, C> : This, NextCommand {
    
    public typealias NextCommand = (T) -> ()
    public typealias Command<U> = (_ chain : Chain<T, C>, _ data : T, _ next : @escaping (U)->()) -> ()
    
    internal var nextCommand: NextCommand?
    
    public var context : ChainContext<C>
    var id : Int = nextId()
    public var name : String?
    
    @inlinable
    var runContext : C {
        return context.context
    }
    
    private init(context : ChainContext<C>) {
        self.context = context
    }
    
    public static func startWith<C>(context : C) -> Chain<Nothing, C> {
        let chain = Chain<Nothing, C>(context : ChainContext<C>(context: context))
        chain.context.runCommand = {
            chain.context.runCommand = nil
            chain.nextCommand?(Nothing())
        }
        return chain
    }
    
    public func then<U>(command: @escaping Command<U>) -> Chain<U, C> {
        let chain = Chain<U, C>(context : context)
        nextCommand = { [unowned self] data in
            command(self, data, { nextVal in
                chain.printRetainCount()
                chain.nextCommand?(nextVal)
            })
        }
        return chain
    }
    
    public func union(_ other : Chain<T, C>) -> Chain<T, C> {
        let chain = Chain<T, C>(context : context)
        self.nextCommand = { nextVal in
            chain.printRetainCount()
            chain.nextCommand?(nextVal)
        }
        other.nextCommand = self.nextCommand
        return chain
    }
    
    @discardableResult
    public func endWith(command: @escaping NextCommand, endQueue : DispatchQueue? = nil, errorHandler : ChainContext<C>.ErrorHandler? = nil, deferHandler: ChainContext<C>.DeferHandler? = nil) -> ChainContext<C> {
        nextCommand = { [weak self] data in
            command(data)
            print("🖇 End chain 🖇 ")
            self?.printRetainCount()
            self?.context.runCommand = nil
            self?.context.head = nil
            self?.context.chains = []
        }
        context.endQueue = endQueue
        context.errorHandler = errorHandler
        context.runCommand?()
        return context
    }
    
    
    public func throwError(_ error : Error) {
        context.handleErrorDefer(error: error) 
    }
    
    func printRetainCount() {
        print("🔗 \(id) 🔗 \(name ?? "No Name") 🔗 Retain count: \(CFGetRetainCount(self))")
    }
    
    func clearNextCommand() {
        nextCommand = nil
    }
    
    deinit {
        print("🔗 \(Me.self) \(id) \(name ?? "No Name") deinit")
    }
}

public extension Chain where T : ChainIf {
    
    
    func wrap(_ chainTrue : Chain<T, C>) -> Chain<T, C> {
        name = "Chain Wrap"
        context.chains.append(chainTrue)
        let chainFalse = Chain<T, C>(context : context)
        nextCommand = { [unowned chainTrue] nextVal in
            if nextVal.value {
                chainTrue.printRetainCount()
                chainTrue.nextCommand?(nextVal)
            } else {
                chainFalse.printRetainCount()
                chainFalse.nextCommand?(nextVal)
            }
        }
        return chainFalse
    }
    
    func fork() -> (whenTrue : Chain<T, C>, whenFalse : Chain<T, C>) {
        let chainTrue = Chain<T, C>(context : context)
        chainTrue.name = "Chain true"
        let chainFalse = Chain<T, C>(context : context)
        chainTrue.name = "Chain false"

        name = "Fork"
        nextCommand = { nextVal in
            if nextVal.value {
                chainTrue.printRetainCount()
                chainTrue.nextCommand?(nextVal)
            } else {
                chainFalse.printRetainCount()
                chainFalse.nextCommand?(nextVal)
            }
        }
        return (chainTrue, chainFalse)
    }
    
}

extension Chain {
    
    public func thenNext<U>(queue : DispatchQueue, _ closure : @escaping (C, T, @escaping (U) -> ()) throws -> ()) -> Chain<U, C> {
        return then(command: { [weak self] context, data, next in
            guard let chainContext = self?.context else {
                print("No Self!")
                return
            }
            queue.async {
                do {
                    try closure(chainContext.context, data, next)
                } catch {
                    chainContext.handleErrorDefer(error: error)
                }
            }
        })
    }
    
    public func then<U>(queue : DispatchQueue, _ closure : @escaping (C, T) throws -> (U)) -> Chain<U, C> {
        return then(command: { [weak self] context, data, next in
            guard let chainContext = self?.context else {
                print("No Self!")
                return
            }
            queue.async {
                do {
                    next(try closure(chainContext.context, data))
                } catch {
                    chainContext.handleErrorDefer(error: error)
                }
            }
        })
    }
    
    @discardableResult
    public func endWith(queue : DispatchQueue, _ closure : @escaping (C, T) throws -> (), endQueue : DispatchQueue? = nil, errorHandler : ChainContext<C>.ErrorHandler? = nil, deferHandler: ChainContext<C>.DeferHandler? = nil) -> ChainContext<C> {
        return endWith(command: { [weak self] data in
            guard let chainContext = self?.context else {
                print("No Self!")
                return
            }
            queue.async {
                var e : Error?
                do {
                    try closure(chainContext.context, data)
                } catch {
                    e = error
                }
                chainContext.handleErrorDefer(error: e)
            }
            }, endQueue: endQueue, errorHandler : errorHandler, deferHandler: deferHandler)
    }
}

