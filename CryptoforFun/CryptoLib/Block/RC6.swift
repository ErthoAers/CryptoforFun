
public final class RC6 {
    
    public enum Variant: Int {
        case rc128, rc192, rc256
        var Nr: Int {
            return 20
        }
        var Nk: Int {
            return [4, 6, 8][self.rawValue]
        }
    }
    
    let key: Key
    let blockMode: BlockMode
    let padding: Padding
    
    public let keySize: Int
    public static let blockSize: Int = 16
    
    private var variant: Variant {
        switch keySize * 8 {
        case 128:
            return .rc128
        case 192:
            return .rc192
        case 256:
            return .rc256
        default:
            preconditionFailure("Unknown RC6 key size.")
        }
    }
    
    lazy var variantNr: Int = self.variant.Nr
    lazy var variantNk: Int = self.variant.Nk
    
    public init(key: Array<UInt8>, blockMode: BlockMode, padding: Padding = .pkcs7) throws {
        self.key = Key(bytes: key)
        self.keySize = key.count
        self.blockMode = blockMode
        self.padding = padding
    }
    
    private static let P: UInt32 = 0xB7E15163
    private static let Q: UInt32 = 0x9E3779B9
    
    private lazy var expandedKey = expandKey(self.key)
}

private extension RC6 {
    private func expandKey(_ key: Key) -> Array<UInt32> {
        var l = key.bytes.batched(by: 4).map { UInt32(bytes: $0) }
        let sLength = variantNr * 2 + 4
        let s = UnsafeMutablePointer<UInt32>.allocate(capacity: sLength)
        s.initialize(to: 0, count: sLength)
        defer {
            s.deinitialize(count: sLength)
            s.deallocate(capacity: sLength)
        }
        
        s[0] = RC6.P
        for i in 1..<sLength { s[i] = s[i - 1] &+ RC6.Q }
        let v = sLength * 3
        
        var a: UInt32 = 0, b: UInt32 = 0, i: Int = 0, j: Int = 0
        for _ in 1..<v {
            s[i] = rotateLeft((s[i] &+ a &+ b), by: 3)
            a = s[i]
            l[j] = rotateLeft((l[j] &+ a &+ b), by: (a + b))
            b = l[j]
            i = (i + 1) % sLength
            j = (j + 1) % 4
        }
        
        return Array(UnsafeBufferPointer(start: s, count: sLength))
    }
}

extension RC6 {
    internal func encrypt(block: ArraySlice<UInt8>) -> Array<UInt8> {
        if blockMode.options.contains(.paddingRequired) && block.count != RC6.blockSize {
            return Array(block)
        }
        let B = block.batched(by: 4).map {UInt32(bytes: $0, endian: .littleEndian)}
        var b0 = B[0]
        var b1 = B[1] &+ expandedKey[0]
        var b2 = B[2]
        var b3 = B[3] &+ expandedKey[1]
        
        var t: UInt32, u: UInt32
        for i in 1...variantNr {
            t = rotateLeft(b1 * (2 * b1 + 1), by: 5)
            u = rotateLeft(b3 * (2 * b3 + 1), by: 5)
            b0 = rotateLeft(b0 ^ t, by: u) &+ expandedKey[2 * i]
            b2 = rotateLeft(b2 ^ u, by: t) &+ expandedKey[2 * i + 1]
            (b0, b1, b2, b3) = (b1, b2, b3, b0)
        }
        
        b0 = b0 &+ expandedKey[2 * variantNr + 2]
        b2 = b2 &+ expandedKey[2 * variantNr + 3]
        
        var result = Array<UInt8>()
        result += b0.bytes()[4..<8]
        result += b1.bytes()[4..<8]
        result += b2.bytes()[4..<8]
        result += b3.bytes()[4..<8]
        
        return result
    }
    
    internal func decrypt(block: ArraySlice<UInt8>) -> Array<UInt8> {
        if blockMode.options.contains(.paddingRequired) && block.count != RC6.blockSize {
            return Array(block)
        }
        let B = block.batched(by: 4).map {UInt32(bytes: $0, endian: .littleEndian)}
        var b0 = B[0] &- expandedKey[2 * variantNr + 2]
        var b1 = B[1]
        var b2 = B[2] &- expandedKey[2 * variantNr + 3]
        var b3 = B[3]
        
        var t: UInt32, u: UInt32
        for i in variantNr...1 {
            (b0, b1, b2, b3) = (b1, b2, b3, b0)
            u = rotateLeft(b3 * (2 * b3 + 1), by: 5)
            t = rotateLeft(b1 * (2 * b1 + 1), by: 5)
            b0 = rotateRight(b0 &- expandedKey[2 * i], by: u) ^ t
            b2 = rotateRight(b2 &- expandedKey[2 * i + 1], by: t) ^ u
        }
        
        b0 = b0 &- expandedKey[0]
        b2 = b2 &- expandedKey[1]
        
        var result = Array<UInt8>()
        result += b0.bytes()[4..<8]
        result += b1.bytes()[4..<8]
        result += b2.bytes()[4..<8]
        result += b3.bytes()[4..<8]
        
        return result
    }
}
