
import Darwin

extension UInt8 {
    init(bits: Array<Bit>) {
        self = integerFrom(bits)
    }
}
