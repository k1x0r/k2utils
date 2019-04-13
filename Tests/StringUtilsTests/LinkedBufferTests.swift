//
// LinkedBufferTests.swift
//
// Created by k1x
//

import XCTest
import Foundation
@testable import k2Utils

class LinkedBufferTests: XCTestCase {

    func testLinkedBuffer() throws {
        var b = LinkedBuffer(bufferSize: 5)
        
        
        let testStr = ["🚍Sdf sadlf sadlkfj; asghdufaiwulerfhakjsdznb akl3ewrthwasiekljurgfhasljkdgfliqwa34rfgbvmhzx,dgblkjuq3wearhgiap3uwefghvlzjdkrtyaewkzcvn aoiuerf viuasdfh kawulesjryhqiu234afh akjlsry viqwuo4eryh kjulash gfuiyq34ry ol8 2QWGTKLAWSEHLKRVAERSHGKFJZ SILKJDRYAWIQUKLERHUKLSDRFTK, JGSEDHFJKG AKLJHqwkjhglkjhlfgdkjslhg asjdkltghj keaswjhkt lsdflkjhg sdjlkfhlksaejrthfg asdf asru3q24oaf jsadlkfnmkal;s gjhfesol;dgj;'lzh f.,vmnq;erojktyhq34oi4eh `1 LWEKkl; ghlkjWHGA ;LHLKqh kjalsrdh qklHjk glkjrdshkl asdfjkl asdfkj ahkLAH kljSH kjlSDH kjlSHG kjskjh a l;? / h/SS HSDK Sh wear;raqwhg: fAEkh werh gFBCDVfawkjeltgfhwertg lajekwg vhjsdzvcb jhasd gfhjkawesdgfjhvasdhjfvaweerg fajwkegfhq3ioleiurqtqpweutrypqoeiujf askjdf hgawklsdhfjawskl rgqwfgouvbjskhxgfaujkwhlyeg",
             "\n🚁asd asdkjfhasjkldfuqiwefh iuawerf hiuawerh asduifh awlhsadkl;f ashdfmnxzcvbawejhklf uyawe4r ajhgsdf gakjsehrgwueqayfh asbdfjags hjkdfasghjrghwauye skjdha",
             "\n🚂]qw w[q]erfo q[w]eporqw efjsdaf hjuiweahr bakfsedhkl anvakjsf bvhjeakbfh s,nmvcxbzflkwherfaksl ",
             "\n🚇 aasdf;l asdfkaweufiow ifhdasguadsufjase[fnxzjclkvnzxklvhoegfjdlkzfnvkdsav asldf asldfj l;askdjf l;kasjflk ;awejrwe;loakhruiakwerfkjhsdbfjkl aewhgtrelkajhf lksadhjf kljasdhflkas dhfwqael hurfweaiuf uaweilr"]
        
        for str in testStr {
            try b.write(string: str)
        }
        
        var buffer = [Int8](repeating: 0, count: 8)
        var target = Data()
//        buffer.withUnsafeBytes { b -> Void in
//            b.baseAddress
//        }
        var res : SocketReadResult
        repeat {
            res = try buffer.withUnsafeMutableBytes { dst -> SocketReadResult in
                let res = try b.read(buffer: dst.baseAddress!, count: dst.count)
                let bp = UnsafeBufferPointer<Int8>(start: dst.baseAddress?.assumingMemoryBound(to: Int8.self), count: res.bytes)
                print("BP: \(Array(bp).toString)")
                target.append(bp)
                return res
            }
            
        } while !res.options.contains(.endOfStream)
        let recv = target.toString
        print("Data: \(recv)")
        XCTAssert(recv == testStr.joined())
    }
}
