import XCTest
@testable import k2Utils
import Foundation

class Foo : This {
    deinit {
        print("\(this.self) deinit")
    }
}

class StringUtilsTests: XCTestCase {

    func testDispatchChain() {
//        Foo()
//        ChainContext(context: Void())
        Chain<Void, Void>.startWith(context: Void(), command: { _, next in
            next(Void())
        }).then(command: { (none : Void, next: (Int) -> Void) -> () in
            next(120)
        }).then(command: { (none : Int, next: (Int) -> Void) -> () in
            print("val \(none)")

            next(123)
        }).endWith(command: { val in
            print("val \(val)")
        })
        print("Test finished...")

    }
    
    func testDispatchChainQueue() {
        //        Foo()
        //        ChainContext(context: Void())
        let queue = DispatchQueue(label: "q1")
        let queue1 = DispatchQueue(label: "q2")
        let queue2 = DispatchQueue(label: "q3")

        Chain<Void, Void>.startWith(queue: queue, context: Void()) { _ -> Int in
            return 123
        }.then(queue: queue2, { _, val -> Int in
            print("val1: \(val)")
            return 1111
        }).then(queue: queue, { _, val -> Int in
            print("val3: \(val)")
            return 124
        }).endWith(queue: queue1, { _, val in
            print("val \(val)")
        })
        let exp = XCTestExpectation()
        wait(for: [exp], timeout: 2000)
        
//        Chain<Void, Void>.startWith(queue: queue, context: <#T##C#>, <#T##closure: (C) throws -> (U)##(C) throws -> (U)#>)
//            .startWith(context: Void(), command: { _, next in
//            next(Void())
//        }).then(command: { (none : Void, next: (Int) -> Void) -> () in
//            next(120)
//        }).then(command: { (none : Int, next: (Int) -> Void) -> () in
//            print("val \(none)")
//            
//            next(123)
//        }).endWith(command: { val in
//            print("val \(val)")
//        }).disposed(by: bag)
//        print("Test finished...")
        
    }
    
}
