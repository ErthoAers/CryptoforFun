
public final class MD5 : DigestType {
    public func caculate(for bytes: Array<UInt8>) throws -> Array<UInt8> {
        return try update(withBytes: bytes.slice, isLast: true)
    }
}

extension MD5 : Updatable {
    public func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool) throws -> Array<UInt8> {
        return Array(bytes)
    }
}
