import XCTest
@testable import k2Utils

class StringUtilsTests: XCTestCase {
    func testEmail() {
        XCTAssertTrue("e@mail.d".isEmail)
        XCTAssertTrue("edasdvf@ma.il.d".isEmail)
//        XCTAssertTrue("edas+df@ma.il.d".isEmail)

        XCTAssertFalse("@ma.il.d".isEmail)
        XCTAssertFalse("asdfasd@".isEmail)
        XCTAssertFalse("edas@dvf@ma.il.d".isEmail)
        XCTAssertFalse("edadvf@mad".isEmail)
        XCTAssertFalse("русиш@мыло.мыло".isEmail)


    }
    
    func testTruncateBegin()  {
        XCTAssert("test".trimmedBeginWhitespaces == "test")
        XCTAssert("             test   ".trimmedBeginWhitespaces == "test   ")
        XCTAssert("                          test".trimmedBeginWhitespaces == "test")
        XCTAssert("abcabcaaabababbtebababst".trimmingCharachersStart(in: CharacterSet(charactersIn: "abc")) == "tebababst")
    }

    func testTruncateEnd()  {
        XCTAssert("test".trimmedEndWhitespaces == "test")
        XCTAssert("             test   ".trimmedEndWhitespaces == "             test")
        XCTAssert("       test".trimmedEndWhitespaces == "       test")
        XCTAssert("       test".trimmedEndWhitespaces == "       test")
        XCTAssert("ababstababababababcaacc".trimmingCharachersEnd(in: CharacterSet(charactersIn: "abc")) == "ababst")
    }

    func testSubstrings() {
        XCTAssertEqual("MAIL FROM: <@>".substring(fromFirst: " "), "FROM: <@>")
        XCTAssertEqual("MAIL_FROM:_<@>".substring(fromFirst: " "), nil)
        XCTAssertEqual("MAIL_FROM:_<@> ".substring(fromFirst: " "), "")
        XCTAssertEqual("MAIL_FROM:_<@>   ".substring(fromFirst: " "), "  ")
        XCTAssertEqual(" MAIL_FROM:_<@> ".substring(fromFirst: " "), "MAIL_FROM:_<@> ")
        XCTAssertEqual("MAIL_FROM: <@> ".substring(fromFirst: " "), "<@> ")
        XCTAssertEqual("".substring(fromFirst: " "), nil)

        XCTAssertEqual("MAIL FROM: <@>".substring(fromLast: " "), "<@>")
        XCTAssertEqual("MAIL_FROM:_<@>".substring(fromLast: " "), nil)
        XCTAssertEqual("MAIL_FROM:_<@> ".substring(fromLast: " "), "")
        XCTAssertEqual("MAIL_FROM:_<@>   ".substring(fromLast: " "), "")
        XCTAssertEqual(" MAIL_FROM:_<@> ".substring(fromLast: " "), "")
        XCTAssertEqual("MAIL_FROM: <@> ".substring(fromLast: " "), "")
        XCTAssertEqual("".substring(fromLast: " "), nil)
        
        XCTAssertEqual("MAIL FROM: <@>".substring(toLast: " "), "MAIL FROM:")
        XCTAssertEqual("MAIL_FROM:_<@>".substring(toLast: " "), nil)
        XCTAssertEqual("MAIL_FROM:_<@> ".substring(toLast: " "), "MAIL_FROM:_<@>")
        XCTAssertEqual("MAIL_FROM:_<@>   ".substring(toLast: " "), "MAIL_FROM:_<@>  ")
        XCTAssertEqual(" MAIL_FROM:_<@> ".substring(toLast: " "), " MAIL_FROM:_<@>")
        XCTAssertEqual("MAIL_FROM: <@> <@>".substring(toLast: " "), "MAIL_FROM: <@>")
        XCTAssertEqual("".substring(toLast: " "), nil)

        XCTAssertEqual("MAIL FROM: <@>".substring(toFirst: " "), "MAIL")
        XCTAssertEqual("MAIL_FROM:_<@>".substring(toFirst: " "), nil)
        XCTAssertEqual("MAIL_FROM:_<@> ".substring(toFirst: " "), "MAIL_FROM:_<@>")
        XCTAssertEqual("MAIL_FROM:_<@>   ".substring(toFirst: " "), "MAIL_FROM:_<@>")
        XCTAssertEqual(" MAIL_FROM:_<@> ".substring(toFirst: " "), "")
        XCTAssertEqual("MAIL_FROM: <@> <@>".substring(toFirst: " "), "MAIL_FROM:")
        XCTAssertEqual("".substring(toFirst: " "), nil)

    }
    
    func testSplitStrings() {
        XCTAssertEqual("MAIL FROM: <@>".split(first: " "), ["MAIL", "FROM: <@>"])
        XCTAssertEqual("MAIL_FROM:_<@>".split(first: " "), ["MAIL_FROM:_<@>"])
        XCTAssertEqual("MAIL_FROM:_<@> ".split(first: " "), ["MAIL_FROM:_<@>", ""])
        XCTAssertEqual("MAIL_FROM:_<@>   ".split(first: " "), ["MAIL_FROM:_<@>", "  "])
        XCTAssertEqual(" MAIL_FROM:_<@> ".split(first: " "), ["", "MAIL_FROM:_<@> "])
        XCTAssertEqual("MAIL_FROM: <@> ".split(first: " "), ["MAIL_FROM:", "<@> "])
        XCTAssertEqual("".split(first: " "), [""])
        
        XCTAssertEqual("MAIL FROM: <@>".split(last: " "), ["MAIL FROM:", "<@>"])
        XCTAssertEqual("MAIL_FROM:_<@>".split(last: " "), ["MAIL_FROM:_<@>"])
        XCTAssertEqual("MAIL_FROM:_<@> ".split(last: " "), ["MAIL_FROM:_<@>", ""])
        XCTAssertEqual("MAIL_FROM:_<@>   ".split(last: " "), ["MAIL_FROM:_<@>  ", ""])
        XCTAssertEqual(" MAIL_FROM:_<@> ".split(last: " "), [" MAIL_FROM:_<@>", ""])
        XCTAssertEqual("MAIL_FROM: <@> ".split(last: " "), ["MAIL_FROM: <@>", ""])
        XCTAssertEqual("".split(last: " "), [""])

    }
    static var allTests = [
        ("testEmail", testEmail),
    ]
}
