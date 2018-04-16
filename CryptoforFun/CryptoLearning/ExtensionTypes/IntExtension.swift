
import Darwin

extension FixedWidthInteger {
    func bytes(totalBytes: Int = MemoryLayout<Self>.size) -> Array<UInt8> {
        return arrayOfBytes(value: self, length: totalBytes)
    }
}
