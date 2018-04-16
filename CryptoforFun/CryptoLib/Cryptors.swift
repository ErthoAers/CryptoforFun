
import Darwin

public protocol Cryptors: class {
    associatedtype EncryptorType: Updatable
    associatedtype DecryptorType: Updatable
    func makeEncrypter() throws -> EncryptorType
    func makeDecryptor() throws -> DecryptorType
    static func randomIV(_ blockSize: Int) -> Array<UInt8>
}

extension Cryptors {
    public static func randomIV(_ blockSize: Int) -> Array<UInt8> {
        var randomIV: Array<UInt8> = Array<UInt8>()
        randomIV.reserveCapacity(blockSize)
        for randomByte in RandomBytesSequence(size: blockSize) { randomIV.append(randomByte) }
        return randomIV
    }
}
