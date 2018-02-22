//
// DispatchChain.swift
//
// Created by k1x
//

import Foundation
import Dispatch

public class ChainContext<C> : This {
    public typealias ErrorHandler = (C, Error) -> ()

    internal var chains : [AnyObject] = []
    
    public var errorHandler : ErrorHandler?
    internal var runCommand : (() -> Void)?    
    public var context : C
    
    public init(context : C) {
        self.context = context
    }
    
    deinit {
        print("\(this.self) deinit")
    }
}

public class Chain<T, C> : This {
    
    public typealias NextCommand = (T) -> ()
    public typealias Command<U> = (_ data : T, _ next : @escaping (U)->()) -> ()
    
    private var nextCommand: NextCommand?
    
    public var context : ChainContext<C>
    var isLast = false
    
    private init(context : ChainContext<C>) {
        self.context = context
    }
    
    public static func startWith<U, C>(context : C, command: @escaping (_ context : ChainContext<C>, _ next : @escaping (U) -> Void) -> Void) -> Chain<U, C> {
        let chainContext = ChainContext<C>(context: context)
        let chain = Chain<U, C>(context : chainContext)
        chainContext.runCommand = {
            command(chain.context, { [weak chain] t in
                guard let chain = chain else {
                    print("Chain is released")
                    return
                }
                chain.nextCommand?(t)
                chain.context.runCommand = nil
            })
        }
        return chain
    }
    
    public func then<U>(command: @escaping Command<U>) -> Chain<U, C> {
        let chain = Chain<U, C>(context : context)
        context.chains.append(chain)
        nextCommand = { data in
            command(data, { [weak chain] t in
                guard let chain = chain else {
                    print("Chain is released")
                    return
                }
                chain.nextCommand?(t)
                chain.context.runCommand = nil
                chain.context.chains.remove(byReference: chain)
            })
        }
        return chain
    }
    
    @discardableResult
    public func endWith(command: @escaping NextCommand, errorHandler : ChainContext<C>.ErrorHandler? = nil) -> ChainContext<C> {
        isLast = true
        nextCommand = { [weak self] data in
            command(data)
            self?.context.runCommand = nil
        }
        context.errorHandler = errorHandler
        context.runCommand?()
        return context
    }
    
    deinit {
        print("\(this.self) deinit")
    }

}

extension Chain {
    
    public static func startWith<U, C>(queue : DispatchQueue, context: C, _ closure : @escaping (C) throws -> (U) ) -> Chain<U, C> {
        return startWith(context: context, command: { cmdContext, next in
            queue.async {
                do {
                    next(try closure(context))
                } catch {
                    cmdContext.errorHandler?(context, error)
                }
            }
        })
    }
    
    public func thenNext<U>(queue : DispatchQueue, _ closure : @escaping (C, T, @escaping (U) -> ()) throws -> ()) -> Chain<U, C> {
        return then(command: { [weak self] data, next in
            guard let context = self?.context else {
                print("No Self!")
                return
            }
            queue.async { // [weak self] in
                do {
                    try closure(context.context, data, next)
                } catch {
                    context.errorHandler?(context.context, error)
                }
            }
        })
    }
    
    public func then<U>(queue : DispatchQueue, _ closure : @escaping (C, T) throws -> (U)) -> Chain<U, C> {
        return then(command: { [weak self] data, next in
            guard let context = self?.context else {
                print("No Self!")
                return
            }
            queue.async { // [weak self] in
                do {
                    next(try closure(context.context, data))
                } catch {
                    context.errorHandler?(context.context, error)
                }
            }
        })
    }
    
    @discardableResult
    public func endWith(queue : DispatchQueue, _ closure : @escaping (C, T) throws -> (), errorHandler : ChainContext<C>.ErrorHandler? = nil) -> ChainContext<C> {
        return endWith(command: { [weak self] data in
            guard let context = self?.context else {
                print("No Self!")
                return
            }
            queue.async { //  [weak self] in
                do {
                    try closure(context.context, data)
                } catch {
                    context.errorHandler?(context.context, error)
                }
            }
        }, errorHandler : errorHandler)
    }
}

