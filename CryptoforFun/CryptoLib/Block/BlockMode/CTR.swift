
public func buildNonce (_ iv: ArraySlice<UInt8>, counter: UInt64) -> Array<UInt8>  {
    let noncePartLen = AES.blockSize / 2
    let noncePrefix = Array(iv[iv.startIndex..<iv.startIndex.advanced(by: noncePartLen)])
    let nonceSuffix = Array(iv[iv.startIndex.advanced(by: noncePartLen)..<iv.startIndex.advanced(by: iv.count)])
    let c = UInt64(bytes: nonceSuffix) + counter
    return noncePrefix + c.bytes()
}

struct CTRModeWorker : BlockModeWorker {
    let cipherOperation: CipherOperationOnBlock
    private let iv: ArraySlice<UInt8>
    var counter: UInt = 0
    
    init(iv: ArraySlice<UInt8>, cipherOperation: @escaping CipherOperationOnBlock) {
        self.iv = iv
        self.cipherOperation = cipherOperation
    }
    
    mutating func encrypt(_ plaintext: ArraySlice<UInt8>) -> Array<UInt8> {
        let nonce = buildNonce(iv, counter: UInt64(counter))
        counter = counter + 1
        
        guard let ciphertext = cipherOperation(nonce.slice) else { return Array(plaintext) }
        return xor(plaintext, ciphertext.slice)
    }
    
    mutating func decrypt(_ ciphertext: ArraySlice<UInt8>) -> Array<UInt8> {
        return encrypt(ciphertext)
    }
    
    
}
