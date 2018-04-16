
protocol BlockModeWorker {
    var cipherOperation: CipherOperationOnBlock { get }
    mutating func encrypt(_ plaintext: ArraySlice<UInt8>) -> Array<UInt8>
    mutating func decrypt(_ ciphertext: ArraySlice<UInt8>) -> Array<UInt8>
}
