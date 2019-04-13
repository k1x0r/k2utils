import Foundation

autoreleasepool {
let begin = Chain<Int, Void>.startWith(context: 0)
  
    
let first = begin.then(command: { (ctx : Chain<Nothing, Int>, val , next : @escaping (Bool) -> ()) in
    print("Then \(val)")
    next(true)
})
  
    
var retry = 100

let start = first.then(command: { (ctx : Chain<Bool, Int>, val , next : @escaping (Int) -> ()) in
    print("Then \(val)")
    next(120)
}).then(queue: DispatchQueue.global(), { (c, c1) -> (Int) in
    print("This one is in queue \(c1)")
    return 4
}).then(command: { (ctx : Chain<Int, Int>, val , next : @escaping (Int) -> ()) in
    ctx.name = "Before Fork - 1"
    print("Then \(val)")
    next(120)
}).then(command: { (ctx : Chain<Int, Int>, val , next : @escaping (Bool) -> ()) in
    ctx.name = "Before Fork"
    print("Then \(val)")
    retry -= 1
    if retry > 0 {
        next(true)
    } else {
        ctx.throwError("An error".error())
    }
}).fork()
start.whenTrue.name = "Fork true"
start.whenFalse.name = "Fork false"

let st = start.whenTrue.then { (c : Chain<Bool, Int>, val, next: @escaping (Bool) -> ()) in
    print("Value is true")
    next(true)
}

let sf = start.whenFalse.then { (c : Chain<Bool, Int>, val, next: @escaping (Bool) -> ()) in
    print("Value is false")
    next(false)
}
    
st.union(sf).then(command: { (c : Chain<Bool, Int>, val, next: @escaping (Bool) -> ()) in
    c.name = "Union"
    print("After union")
    next(true)
}).wrap(first).endWith(command: { val in
    print("End with \(val)")
})
}


print("Done")

sleep(3)

print("End")

