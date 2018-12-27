import Foundation

#if os(iOS)
public let kDocumentsPath : String = {
   let searchArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
   guard searchArray.count > 0 else {
      fatalError("Documents Path is not found")
   }
   return searchArray[0].appendIfNotEnds("/")
}()
#endif

extension CharacterSet {
    public static let charsetEmailAddress = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'*+-/=?^_`{|}~.")
    public static let charsetDomain = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-.")
    public static let customAllowedSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
    public static let whitespacesAndEmailSeparators = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "<>"))
}

var urlCharset : CharacterSet {
    var charset = CharacterSet.urlHostAllowed;
    charset.remove("=");
    return charset;
}

public extension CharacterSet {
    
    func contains(string : String) -> Bool {
        for char in string.unicodeScalars {
            guard contains(char) else {
                return false
            }
        }
        return true
        
    }
}
public extension Data {
    
    @_transparent
    var uint8Array : [UInt8] {
        return withUnsafeBytes { (body : UnsafePointer<UInt8>) -> [UInt8] in
            return [UInt8](UnsafeBufferPointer<UInt8>(start : body, count: count))
        }
    }
    
    @_transparent
    var toString : String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}

public extension UnsafeMutablePointer {
    /// For null terminated cStrings
    @_transparent
    var toString : String {
        return String(cString: unsafeBitCast(self, to: UnsafeMutablePointer<CChar>.self))
    }
}

public extension UnsafePointer {
    /// For null terminated cStrings
    @_transparent
    var toString : String {
        return String(cString: unsafeBitCast(self, to: UnsafePointer<CChar>.self))
    }
    
}


public extension Array where Element == Int8 {
    
    var toString : String {
        return String(bytes: unsafeBitCast(self, to: [UInt8].self), encoding: .utf8) ?? ""
    }
    
    var fromCString : String {
        return withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) -> (String) in
            // FIXME: Used force unwrapping
            ptr.baseAddress!.assuming(is: Int8.self).toString
        })
    }
    
}


public extension UnsafeMutableRawBufferPointer {
    
    @_transparent
    var toString : String {
        return String(bytes: self, encoding: .utf8) ?? ""
    }
    
    @_transparent
    var notMutablePtr : UnsafeRawBufferPointer {
        return UnsafeRawBufferPointer(start: baseAddress, count: count)
    }
    
    func array(count: Int = -1) -> [Int8] {
        var count = count
        if count < 0 {
            count = self.count
        }
        var array =  [Int8](repeating : 0, count: count)
        memcpy(&array, self.baseAddress!, count)
        return array
    }
    
}


public extension UnsafeRawBufferPointer {
    
    var toString : String {
          return String(bytes: self, encoding: .utf8) ?? ""
    }
    
    func array(count: Int = -1) -> [Int8] {
        var count = count
        if count < 0 {
            count = self.count
        }
        var array =  [Int8](repeating : 0, count: count)
        memcpy(&array, self.baseAddress!, count)
        return array
    }
    
}


public extension Array where Element == UInt8 {
    
    var toString : String {
        return String(bytes: self, encoding: .utf8) ?? ""
    }
    
}

public extension Array where Element == String {
    
    
    func cmdArgumenmts() -> [String : String] {
        var dict = [String : String]()
        var key : String = "1st"
        var value : String = ""
        for arg in self {
            if arg.starts(with: "-") {
                dict[key] = value
                key = arg
                value = ""
            } else {
                if !value.isEmpty {
                    value += " "
                }
                value += arg
            }
        }
        dict[key] = value

        return dict
    }
    
}

public extension String {
    
    /// Workaround for Linux as 'contentsOfFile' is not yet implemented
    public init(fromFile : String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: fromFile))
        guard let string = String(data: data, encoding: .utf8) else {
            throw "Could not convert data to string".error()
        }
        self = string
    }
    
    @_transparent
    public var url : URL {
        guard let url = URL(string: self) else {
            fatalError("Couldn't create url from \(self)")
        }
        return url
    }

    @_transparent
    public var fileUrl : URL {
        return URL(fileURLWithPath: self)
    }
    
    @_transparent
    public var trimmed : String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    @_transparent
    public var trimmedSmtp : String {
        return self.trimmingCharacters(in: .whitespacesAndEmailSeparators)
    }
    
    public var trimmedBeginWhitespaces : String {
        return trimmingCharachersStart(in: CharacterSet.whitespacesAndNewlines)
    }

    public var trimmedEndWhitespaces : String {
        return trimmingCharachersEnd(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func header(value : String) -> String {
        return value.isEmpty ? "" : "\(self): \(value)\r\n"
    }
    
    /// C String without \0 in the end
    @_transparent
    var cArray : [CChar] {
        return utf8.map { CChar(bitPattern: $0) }
    }

    @_transparent
    var uint8Array : [UInt8] {
        return utf8.map { $0 }
    }
    
    @_transparent
    var cString : [CChar] {
        return cString(using: .utf8) ?? []
    }
    
    @_transparent
    var cStringUInt8 : [UInt8] {
        return (cString(using: .utf8) ?? []).uint8array
    }
    
    var isEmail : Bool {
        let components = self.components(separatedBy: "@")
        guard components.count == 2 else {
            return false
        }
        guard !components[0].isEmpty, CharacterSet.charsetEmailAddress.contains(string: components[0]) else {
            return false
        }
        guard !components[1].isEmpty, CharacterSet.charsetDomain.contains(string: components[1]), components[1].contains(".") else {
            return false
        }
        return true
    }
    
    /// FIXME: Replace with k2io method
    func matches(regex: String) -> Int? {
        do {
//            #if os(Linux)
//                let regex = try RegularExpression(pattern: regex, options: [])
//            #else
                let regex = try NSRegularExpression(pattern: regex, options: [])
//            #endif
            //            let nsString = NSString(string: text)
            return regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
            //            return results.map { nsString.substring(with: $0.range) }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func index(of char: Character) -> Int? {
        if let idx = characters.index(of: char) {
            return characters.distance(from: startIndex, to: idx)
        }
        return nil

    }
    
    public func indexLast(of char: Character) -> Int? {
        if let idx = characters.reversed().index(of: char) {
            return characters.distance(from: startIndex, to: idx.base)
        }
        return nil
        
    }
    
    var urlComponents : [KV] {
        let items = components(separatedBy: "&");
        var array = [KV]()
        for item in items {
            let kv = item.split(first: "=")
            guard kv.count == 2 else {
                continue;
            }
            array.append(KV(kv[0], kv[1]));
        }
        return array;
    }
    
    
    @_transparent
    var percentEncoding : String {
        return addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
    }
    
    @_transparent
    var oauth1percentEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: .customAllowedSet) ?? ""
    }
    
    @_transparent
    var utf8data : Data {
        guard let data = data(using: .utf8) else {
            fatalError("Couldn't convert \(self) to Data")
        }
        return data
    }
    
    @_transparent
    var utf8cString : [CChar] {
        guard let cString = cString(using: .utf8) else {
            fatalError("Couldn't convert \(self) to c string")
        }
        return cString
    }
    
    var json : [String : Any]? {
        do {
            return try JSONSerialization.jsonObject(with: utf8data) as? [String : Any]
        } catch {
            return nil;
        }
    }
    
    var jsonArray : [Any]? {
        do {
            return try JSONSerialization.jsonObject(with: utf8data) as? [Any]
        } catch {
            return nil;
        }
    }
    
    var flag : String {
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in self.utf16 {
            usv.append(UnicodeScalar(base + Int(i))!)
        }
        return String(usv)
    }
    
    
    func appendIfNotEnds(_ string : String) -> String {
        if self.hasSuffix(string) {
            return self
        } else {
            return self + string
        }
    }
    
    func replaceCharacterAtIndex(_ i : Int, char : Character) -> String {
        let start = index(startIndex, offsetBy : i)
        let end = index(startIndex, offsetBy: i + 1)
        return replacingCharacters(in: start..<end, with: "\(char)");
    }
    
    func split(maxSplits : Int, chars char : Character) -> [String] {
        return characters.split(separator: char, maxSplits: maxSplits, omittingEmptySubsequences: false).map(String.init)
    }
    
    func split(first string : String) -> [String] {
        guard let i = range(of: string) else {
            return [self]
        }
//        let endIndex = characters.distance(from: startIndex, to: i.upperBound)
        return [substring(to: i.lowerBound), substring(from: i.upperBound)]
    }
    
    func split(first char : Character) -> [String] {
        guard let i = index(of: char) else {
            return [self]
        }
        return [substring(to: i), substring(from: i+1)]
    }
    
    func split(last char : Character) -> [String] {
        guard let i = indexLast(of: char) else {
            return [self]
        }
        return [substring(to: i - 1), substring(from: i)]
    }
    
    func substring(fromFirst: Character) -> String? {
        guard let i = index(of: fromFirst) else {
            return nil
        }
        return substring(from: i + 1)
    }
    
    func substring(fromLast: Character) -> String? {
        guard let i = indexLast(of: fromLast) else {
            return nil
        }
        return substring(from: i)
    }

    
    func substring(from: Int) -> String {
        return substring(from: index(startIndex, offsetBy : from))
    }

    func substring(toFirst: Character) -> String? {
        guard let i = index(of: toFirst) else {
            return nil
        }
        return i > 0 ? substring(to: i - 1) : ""
    }

    
    func substring(toLast: Character) -> String? {
        guard let i = indexLast(of: toLast) else {
            return nil
        }
        return i > 0 ? substring(to: i - 1) : ""
    }

    
    
    
    func substring(to: Int) -> String {
        return substring(to: index(startIndex, offsetBy : to))
    }
    
    
    
    func trimmingCharachersStart(in charset : CharacterSet) -> String {
        var index : Int = 0
        for (i, c) in unicodeScalars.enumerated() {
            if !charset.contains(c) {
                index = i;
                break;
            }
        }
        return substring(from: index);
    }
    
    func trimmingCharachersEnd(in charset: CharacterSet) -> String {
        var index : Int = characters.count
        for (i, c) in unicodeScalars.enumerated().reversed() {
            if !charset.contains(c) {
                index = i + 1;
                break;
            }
        }
        return substring(to: index);
    }
    
    func substring(with r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy : r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return substring(with: start..<end)
    }
    
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64DecodedFacebook() -> String? {
        var needPadding = characters.count % 4;
        var string = self;
        if (needPadding > 0) {
            needPadding = 4 - needPadding;
            string = padding(toLength: characters.count + needPadding, withPad: "=", startingAt: 0);
        }
        if let data = Data(base64Encoded: string) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    
    public func equals(caseInsensitive: String) -> Bool {
        return lowercased() == caseInsensitive.lowercased()
    }

}
