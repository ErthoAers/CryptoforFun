
public enum CipherError: Error {
    case encrypt, decrypt
}

public protocol Cipher: class {
    var keySize: Int { get }
    
    func encrypt(_ bytes: ArraySlice<UInt8>) throws -> Array<UInt8>
    func encrypt(_ bytes: Array<UInt8>) throws -> Array<UInt8>
    
    func decrypt(_ bytes: ArraySlice<UInt8>) throws -> Array<UInt8>
    func decrypt(_ bytes: Array<UInt8>) throws -> Array<UInt8>
}

extension Cipher {
    public func encrypt(_ bytes: Array<UInt8>) throws -> Array<UInt8> {
        return try encrypt(bytes.slice)
    }
    public func decrypt(_ bytes: Array<UInt8>) throws -> Array<UInt8> {
        return try decrypt(bytes.slice)
    }
}
