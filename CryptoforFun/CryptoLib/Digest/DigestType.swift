
public protocol DigestType {
    func caculate(for bytes: Array<UInt8>) throws -> Array<UInt8>
}
