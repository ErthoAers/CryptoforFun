
import Darwin

public protocol _UInt16Type {}
extension UInt16: _UInt16Type {}

extension UInt16 {
    public enum endian {
        case littleEndian, bigEndian
    }
    
    @_specialize(exported: true, where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T, endian: endian = .bigEndian) where T.Element == UInt8, T.Index == Int {
        self = UInt16(bytes: bytes, fromIndex: bytes.startIndex, endian: endian)
    }
    
    @_specialize(exported: true, where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T, fromIndex index: T.Index, endian: endian = .bigEndian) where  T.Element == UInt8, T.Index == Int {
        if bytes.isEmpty {
            self = 0
            return
        }
        
        let count = bytes.count
        if endian == .bigEndian {
            let val0 = count > 0 ? UInt16(bytes[index.advanced(by: 0)]) << 8 : 0
            let val1 = count > 1 ? UInt16(bytes[index.advanced(by: 1)]) : 0
            
            self = val0 | val1
        } else {
            let val0 = count > 0 ? UInt16(bytes[index.advanced(by: 1)]) << 8 : 0
            let val1 = count > 1 ? UInt16(bytes[index.advanced(by: 0)]) : 0
            
            self = val0 | val1
        }
        
    }
    
}

