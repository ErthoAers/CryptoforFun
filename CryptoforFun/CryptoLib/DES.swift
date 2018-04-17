
public final class DES {
    public enum Error : Swift.Error {
        case dataPaddingRequired, invalidData
    }
    
    private static let IP: Array<UInt8> = [
        58, 50, 42, 34, 26, 18, 10,  2,
        60, 52, 44, 36, 28, 20, 12,  4,
        62, 54, 46, 38, 30, 22, 14,  6,
        64, 56, 48, 40, 32, 24, 16,  8,
        57, 49, 41, 33, 25, 17,  9,  1,
        59, 51, 43, 35, 27, 19, 11,  3,
        61, 53, 45, 37, 29, 21, 13,  5,
        63, 55, 47, 39, 31, 23, 15,  7
    ]
    private static let FP: Array<UInt8> = [
        40,  8, 48, 16, 56, 24, 64, 32,
        39,  7, 47, 15, 55, 23, 63, 31,
        38,  6, 46, 14, 54, 22, 62, 30,
        37,  5, 45, 13, 53, 21, 61, 29,
        36,  4, 44, 12, 52, 20, 60, 28,
        35,  3, 43, 11, 51, 19, 59, 27,
        34,  2, 42, 10, 50, 18, 58, 26,
        33,  1, 41,  9, 49, 17, 57, 25
    ]
    private static let PC1: Array<UInt8> = [
        57, 49, 41, 33, 25, 17,  9,
         1, 58, 50, 42, 34, 26, 18,
        10,  2, 59, 51, 43, 35, 27,
        19, 11,  3, 60, 52, 44, 36,
        63, 55, 47, 39, 31, 23, 15,
         7, 62, 54, 46, 38, 30, 22,
        14,  6, 61, 53, 45, 37, 29,
        21, 13,  5, 28, 20, 12,  4
    ]
    private static let PC2: Array<UInt8> = [
        14, 17, 11, 24,  1,  5,
         3, 28, 15,  6, 21, 10,
        23, 19, 12,  4, 26,  8,
        16,  7, 27, 20, 13,  2,
        41, 52, 31, 37, 47, 55,
        30, 40, 51, 45, 33, 48,
        44, 49, 39, 56, 34, 53,
        46, 42, 50, 36, 29, 32
    ]
    private static let E: Array<UInt8> = [
        32,  1,  2,  3,  4,  5,
        4,  5,  6,  7,  8,  9,
        8,  9, 10, 11, 12, 13,
        12, 13, 14, 15, 16, 17,
        16, 17, 18, 19, 20, 21,
        20, 21, 22, 23, 24, 25,
        24, 25, 26, 27, 28, 29,
        28, 29, 30, 31, 32,  1
    ]
    private static let iterationShift: Array<UInt8> = [
     /* 1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16 */
        1,  1,  2,  2,  2,  2,  2,  2,  1,  2,  2,  2,  2,  2,  2,  1
    ]
    private static let SBox: Array<Array<UInt8>> = [
        /* S1 */
        [
            14,  4, 13,  1,  2, 15, 11,  8,  3, 10,  6, 12,  5,  9,  0,  7,
             0, 15,  7,  4, 14,  2, 13,  1, 10,  6, 12, 11,  9,  5,  3,  8,
             4,  1, 14,  8, 13,  6,  2, 11, 15, 12,  9,  7,  3, 10,  5,  0,
            15, 12,  8,  2,  4,  9,  1,  7,  5, 11,  3, 14, 10,  0,  6, 13
        ],
        
        /* S2 */
        [
            15,  1,  8, 14,  6, 11,  3,  4,  9,  7,  2, 13, 12,  0,  5, 10,
             3, 13,  4,  7, 15,  2,  8, 14, 12,  0,  1, 10,  6,  9, 11,  5,
             0, 14,  7, 11, 10,  4, 13,  1,  5,  8, 12,  6,  9,  3,  2, 15,
            13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12,  0,  5, 14,  9
        ],
        
        /* S3 */
        [
            10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12,  7, 11,  4,  2,  8,
            13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15,  1,
            13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12,  5, 10, 14,  7,
             1, 10, 13,  0,  6,  9,  8,  7,  4, 15, 14,  3, 11,  5,  2, 12
        ],
        
        /* S4 */
        [
             7, 13, 14,  3,  0,  6,  9, 10,  1,  2,  8,  5, 11, 12,  4, 15,
            13,  8, 11,  5,  6, 15,  0,  3,  4,  7,  2, 12,  1, 10, 14,  9,
            10,  6,  9,  0, 12, 11,  7, 13, 15,  1,  3, 14,  5,  2,  8,  4,
             3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7,  2, 14
        ],
        
        /* S5 */
        [
             2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14,  9,
            14, 11,  2, 12,  4,  7, 13,  1,  5,  0, 15, 10,  3,  9,  8,  6,
             4,  2,  1, 11, 10, 13,  7,  8, 15,  9, 12,  5,  6,  3,  0, 14,
            11,  8, 12,  7,  1, 14,  2, 13,  6, 15,  0,  9, 10,  4,  5,  3
        ],
        
        /* S6 */
        [
            12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11,
            10, 15,  4,  2,  7, 12,  9,  5,  6,  1, 13, 14,  0, 11,  3,  8,
             9, 14, 15,  5,  2,  8, 12,  3,  7,  0,  4, 10,  1, 13, 11,  6,
             4,  3,  2, 12,  9,  5, 15, 10, 11, 14,  1,  7,  6,  0,  8, 13
        ],
        
        /* S7 */
        [
             4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1,
            13,  0, 11,  7,  4,  9,  1, 10, 14,  3,  5, 12,  2, 15,  8,  6,
             1,  4, 11, 13, 12,  3,  7, 14, 10, 15,  6,  8,  0,  5,  9,  2,
             6, 11, 13,  8,  1,  4, 10,  7,  9,  5,  0, 15, 14,  2,  3, 12
        ],
        
        /* S8 */
        [
            13,  2,  8,  4,  6, 15, 11,  1, 10,  9,  3, 14,  5,  0, 12,  7,
             1, 15, 13,  8, 10,  3,  7,  4, 12,  5,  6, 11,  0, 14,  9,  2,
             7, 11,  4,  1,  9, 12, 14,  2,  0,  6, 10, 13, 15,  3,  5,  8,
             2,  1, 14,  7,  4, 10,  8, 13, 15, 12,  9,  0,  3,  5,  6, 11
        ]
    ]
    private static let P: Array<UInt8> = [
        16,  7, 20, 21,
        29, 12, 28, 17,
         1, 15, 23, 26,
         5, 18, 31, 10,
         2,  8, 24, 14,
        32, 27,  3,  9,
        19, 13, 30,  6,
        22, 11,  4, 25
    ]
    
    private enum options {
        case encrypt, decrypt
    }
    
    public let keySize: Int
    public static let blockSize: Int = 8
    
    let key: Key
    let blockMode: BlockMode
    let padding: Padding
    
    let Nr = 16
    
    private let L64Mask: UInt64 = 0x00000000ffffffff
    private let H64Mask: UInt64 = 0xffffffff00000000
    private let LB32Mask: UInt32 = 0x00000001
    private let LB64Mask: UInt64 = 0x0000000000000001
    
    public init(key: Array<UInt8>, blockMode: BlockMode, padding: Padding = .pkcs7) throws {
        self.key = Key(bytes: key)
        self.keySize = self.key.count
        self.blockMode = blockMode
        self.padding = padding
    }
    
    private func crypt(block: ArraySlice<UInt8>, options: options) -> Array<UInt8> {
        let binData = UInt64(bytes: Array(block))
        var IPData: UInt64 = 0
        for i in 0..<64 {
            IPData <<= 1
            IPData |= (binData >> (64 - DES.IP[i])) & LB64Mask
        }
        
        var L = UInt32((IPData >> 32) & L64Mask)
        var R = UInt32(IPData & L64Mask)
        
        let binKey = UInt64(bytes: key.bytes)
        var exchangeKey: UInt64 = 0
        for i in 0..<56 {
            exchangeKey <<= 1
            exchangeKey |= (binKey >> (64 - DES.PC1[i])) & LB64Mask
        }
        var C = UInt32((exchangeKey >> 28) & 0x000000000fffffff)
        var D = UInt32(exchangeKey & 0x000000000fffffff)
        
        var subKey = UnsafeMutablePointer<UInt64>.allocate(capacity: Nr)
        subKey.initialize(to: 0)
        defer {
            subKey.deinitialize()
            subKey.deallocate(capacity: Nr)
        }
        
        for i in 0..<Nr {
            for _ in 0..<DES.iterationShift[i] {
                C = (0x0fffffff & (C << 1)) | (0x00000001 & (C >> 27))
                D = (0x0fffffff & (D << 1)) | (0x00000001 & (D >> 27))
            }
            
            let permutedChoice: UInt64 = UInt64(C) << 28 | UInt64(D)
            for j in 0..<48 {
                subKey[i] <<= 1
                subKey[i] |= (permutedChoice >> (56 - DES.PC2[j])) & LB64Mask
            }
        }
        
        var sInput: UInt64 = 0
        var sOutput: UInt32 = 0
        var row: UInt8, column: UInt8
        for i in 0..<Nr {
            
            sInput = 0
            for j in 0..<48 {
                sInput <<= 1
                sInput |= UInt64((R >> (32 - DES.E[j])) & LB32Mask)
            }
            
            let index = (options == .encrypt) ? i : 15 - i
            sInput ^= subKey[index]
            for j in 0..<8 {
                // 00 00 RCCC CR00 00 00 00 00 00 sInput
                // 00 00 1000 0100 00 00 00 00 00 row mask
                // 00 00 0111 1000 00 00 00 00 00 column mask
                let tmp1 = sInput & UInt64((0x0000840000000000 >> (6 * j)))
                row = UInt8(tmp1 >> (42 - 6 * j))
                row = (row >> 4) | row & 0x01
                let tmp2 = sInput & UInt64(0x0000780000000000 >> (6 * j))
                column = UInt8(tmp2 >> (43 - 6 * j))
                sOutput <<= 4
                sOutput |= UInt32(DES.SBox[j][Int(16 * row + column)] & 0x0f)
            }
            
            var FFunctionRes: UInt32 = 0
            for j in 0..<32 {
                FFunctionRes <<= 1
                FFunctionRes |= (sOutput >> (32 - DES.P[j])) & LB32Mask
            }

            (L, R) = (R, L ^ FFunctionRes)
        }
        
        let outData = UInt64((UInt64(R) << 32) | UInt64(L))
        var FPData: UInt64 = 0
        for i in 0..<64 {
            FPData <<= 1
            FPData |= (outData >> (64 - DES.FP[i])) & LB64Mask
        }
        
        let encrypted: Array<UInt8> = FPData.bytes()
        return encrypted
    }
    
    internal func encrypt(block: ArraySlice<UInt8>) -> Array<UInt8> {
        if blockMode.options.contains(.paddingRequired) && block.count != DES.blockSize { return Array(block) }
        
        return crypt(block: block, options: .encrypt)
    }
    
    internal func decrypt(block: ArraySlice<UInt8>) -> Array<UInt8> {
        if blockMode.options.contains(.paddingRequired) && block.count != DES.blockSize { return Array(block) }
        
        return crypt(block: block, options: .decrypt)
    }
}

extension DES : Cipher {
    public func encrypt(_ bytes: ArraySlice<UInt8>) throws -> Array<UInt8> {
        let chunks = bytes.batched(by: DES.blockSize)
        
        var oneTimeCryptor = try makeEncrypter()
        var out = Array<UInt8>(reserveCapacity: bytes.count)
        for chunk in chunks {
            out += try oneTimeCryptor.update(withBytes: chunk, isLast: false)
        }
        out += try oneTimeCryptor.finish()
        
        if blockMode.options.contains(.paddingRequired) && (out.count % DES.blockSize != 0) {
            throw Error.dataPaddingRequired
        }
        return out
    }
    
    public func decrypt(_ bytes: ArraySlice<UInt8>) throws -> Array<UInt8> {
        if blockMode.options.contains(.paddingRequired) && (bytes.count % DES.blockSize != 0) {
            throw Error.dataPaddingRequired
        }
        
        var oneTimeCryptor = try makeDecryptor()
        let chunks = bytes.batched(by: DES.blockSize)
        if chunks.isEmpty {
            throw Error.invalidData
        }
        
        var out = Array<UInt8>(reserveCapacity: bytes.count)
        var lastIdx = chunks.startIndex
        chunks.indices.formIndex(&lastIdx, offsetBy: chunks.count - 1)
        for idx in chunks.indices {
            out += try oneTimeCryptor.update(withBytes: chunks[idx], isLast: idx == lastIdx)
        }
        
        return out
    }
}

extension DES {
    public convenience init(key: String, iv: String, padding: Padding = .pkcs7) throws {
        try self.init(key: key.bytes, blockMode: .CBC(iv: iv.bytes), padding: padding)
    }
}


