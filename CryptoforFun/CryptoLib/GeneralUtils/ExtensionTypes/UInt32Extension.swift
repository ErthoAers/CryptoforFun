
import Darwin

public protocol _UInt32Type {}
extension UInt32: _UInt32Type {}

extension UInt32 {
    public enum endian {
        case littleEndian, bigEndian
    }
    
    @_specialize(exported: true, where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T, endian: endian = .bigEndian) where T.Element == UInt8, T.Index == Int {
        self = UInt32(bytes: bytes, fromIndex: bytes.startIndex, endian: endian)
    }
    
    @_specialize(exported: true, where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T, fromIndex index: T.Index, endian: endian = .bigEndian) where  T.Element == UInt8, T.Index == Int {
        if bytes.isEmpty {
            self = 0
            return
        }
        
        let count = bytes.count
        if endian == .bigEndian {
            let val0 = count > 0 ? UInt32(bytes[index.advanced(by: 0)]) << 24 : 0
            let val1 = count > 1 ? UInt32(bytes[index.advanced(by: 1)]) << 16 : 0
            let val2 = count > 2 ? UInt32(bytes[index.advanced(by: 2)]) << 8 : 0
            let val3 = count > 3 ? UInt32(bytes[index.advanced(by: 3)]) : 0
            
            self = val0 | val1 | val2 | val3
        } else {
            let val0 = count > 0 ? UInt32(bytes[index.advanced(by: 3)]) << 24 : 0
            let val1 = count > 1 ? UInt32(bytes[index.advanced(by: 2)]) << 16 : 0
            let val2 = count > 2 ? UInt32(bytes[index.advanced(by: 1)]) << 8 : 0
            let val3 = count > 3 ? UInt32(bytes[index.advanced(by: 0)]) : 0
            
            self = val0 | val1 | val2 | val3
        }
        
    }
    
}

