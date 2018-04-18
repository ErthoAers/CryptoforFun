
struct OFBModeWorker : BlockModeWorker {
    let cipherOperation: CipherOperationOnBlock
    private let iv: ArraySlice<UInt8>
    private var prev: ArraySlice<UInt8>?
    
    init(iv: ArraySlice<UInt8>, cipherOperation: @escaping CipherOperationOnBlock) {
        self.iv = iv
        self.cipherOperation = cipherOperation
    }
    
    mutating func encrypt(_ plaintext: ArraySlice<UInt8>) -> Array<UInt8> {
        guard let ciphertext = cipherOperation(prev ?? iv) else { return Array(plaintext) }
        prev = ciphertext.slice
        return xor(plaintext, ciphertext.slice)
    }
    
    mutating func decrypt(_ ciphertext: ArraySlice<UInt8>) -> Array<UInt8> {
        guard let decrypted = cipherOperation(prev ?? iv) else { return Array(ciphertext) }
        prev = decrypted.slice
        return xor(ciphertext, decrypted.slice)
    }
}
