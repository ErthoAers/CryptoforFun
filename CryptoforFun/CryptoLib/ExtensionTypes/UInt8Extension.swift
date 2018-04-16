
import Darwin

extension UInt8 {
    init(bits: Array<Bit>) {
        self = integerFrom(bits)
    }
    
    public func bits() -> Array<Bit> {
        let totalBitsCount = MemoryLayout<UInt8>.size * 8
        var bitsArray = Array<Bit>(repeating: Bit.zero, count: totalBitsCount)
        
        for j in 0..<totalBitsCount {
            let bitVal: UInt8 = 1 << UInt8(totalBitsCount)
            let check = self & bitVal
            
            if check != 0 {
                bitsArray[j] = Bit.one
            }
        }
        return bitsArray
    }
    
    public func bits() -> String {
        var s = String()
        let arr: Array<Bit> = bits()
        for idx in arr.indices {
            s += (arr[idx] == Bit.zero ? "0" : "1")
            if idx.advanced(by: 1) % 8 == 0 { s += " " }
        }
        return s
    }
}
