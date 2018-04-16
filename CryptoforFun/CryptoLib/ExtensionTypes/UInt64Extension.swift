
extension UInt64 {
    init(bits: Array<Bit>) {
        self = integerFrom(bits)
    }
    
    @_specialize(exported: true, where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T) where T.Element == UInt8, T.Index == Int {
        self = UInt64(bytes: bytes, fromIndex: bytes.startIndex)
    }
    
    @_specialize(exported: true, where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T, fromIndex index: T.Index) where T.Element == UInt8, T.Index == Int {
        if bytes.isEmpty {
            self = 0
            return
        }
        
        let count = bytes.count
        let val0 = count > 0 ? UInt64(bytes[index.advanced(by: 0)]) << 56 : 0
        let val1 = count > 0 ? UInt64(bytes[index.advanced(by: 1)]) << 48 : 0
        let val2 = count > 0 ? UInt64(bytes[index.advanced(by: 2)]) << 40 : 0
        let val3 = count > 0 ? UInt64(bytes[index.advanced(by: 3)]) << 32 : 0
        let val4 = count > 0 ? UInt64(bytes[index.advanced(by: 4)]) << 24 : 0
        let val5 = count > 0 ? UInt64(bytes[index.advanced(by: 5)]) << 16 : 0
        let val6 = count > 0 ? UInt64(bytes[index.advanced(by: 6)]) << 8 : 0
        let val7 = count > 0 ? UInt64(bytes[index.advanced(by: 7)]) : 0
        
        self = val0 | val1 | val2 | val3 | val4 | val5 | val6 | val7
    }
    
    public func bits() -> Array<Bit> {
        let totalBitsCount = MemoryLayout<UInt64>.size * 8
        var bitsArray = Array<Bit>(repeating: Bit.zero, count: totalBitsCount)
        
        for j in 0..<totalBitsCount {
            let bitVal: UInt64 = 1 << UInt64(totalBitsCount - 1 - j)
            let check = self & bitVal
            
            if check != 0 {
                bitsArray[j] = Bit.one
            }
        }
        return bitsArray
    }
}
