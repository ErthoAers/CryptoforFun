
struct ECBModeWorker : BlockModeWorker{
    let cipherOperation: CipherOperationOnBlock
    init(cipherOperation: @escaping CipherOperationOnBlock) {
        self.cipherOperation = cipherOperation
    }
    
    func encrypt(_ plaintext: ArraySlice<UInt8>) -> Array<UInt8> {
        guard let ciphertext = cipherOperation(plaintext) else { return Array(plaintext) }
        return ciphertext
    }
    
    func decrypt(_ ciphertext: ArraySlice<UInt8>) -> Array<UInt8> {
        return encrypt(ciphertext)
    }
}
