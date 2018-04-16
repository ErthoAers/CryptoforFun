
struct CBCModeWorker : BlockModeWorker {
    let cipherOperation: CipherOperationOnBlock
    private let iv: ArraySlice<UInt8>
    private var prev: ArraySlice<UInt8>?
    
    init(iv: ArraySlice<UInt8>, cipherOperation: @escaping CipherOperationOnBlock) {
        self.cipherOperation = cipherOperation
        self.iv = iv
    }
    
    mutating func encrypt(_ plaintext: ArraySlice<UInt8>) -> Array<UInt8> {
        guard let ciphertext = cipherOperation(xor(prev ?? iv, plaintext)) else { return Array(plaintext) }
        prev = ciphertext.slice
        return ciphertext
    }
    
    mutating func decrypt(_ ciphertext: ArraySlice<UInt8>) -> Array<UInt8> {
        guard let plaintext = cipherOperation(ciphertext) else { return Array(ciphertext) }
        let result: Array<UInt8> = xor(prev ?? iv, plaintext)
        prev = ciphertext
        return result
    }
}
