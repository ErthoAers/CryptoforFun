
import Darwin

typealias Key = SecureBytes

final class SecureBytes {
    let bytes: Array<UInt8>
    let count: Int
    
    init(bytes: Array<UInt8>) {
        self.bytes = bytes
        self.count = bytes.count
        self.bytes.withUnsafeBufferPointer { (pointer) -> Void in
            mlock(pointer.baseAddress, pointer.count)
        }
    }
    
    deinit {
        self.bytes.withUnsafeBufferPointer { (pointer) -> Void in
            munlock(pointer.baseAddress, pointer.count)
        }
    }
}

extension SecureBytes: Collection {
    typealias Index = Int
    
    var startIndex: Int {
        return bytes.startIndex
    }
    var endIndex: Int {
        return bytes.endIndex
    }
    subscript(position: Index) -> UInt8 {
        return bytes[position]
    }
    subscript(bounds: Range<Int>) -> ArraySlice<UInt8> {
        return bytes[bounds]
    }
    func formIndex(after i: inout Int) {
        bytes.formIndex(after: &i)
    }
    func index(after i: Int) -> Int {
        return bytes.index(after: i)
    }
}

extension SecureBytes: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: UInt8...) {
        self.init(bytes: elements)
    }
}
