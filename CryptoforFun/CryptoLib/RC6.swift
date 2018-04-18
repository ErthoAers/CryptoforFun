
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
    
    public init(key: Array<UInt8>, blockMode: BlockMode, padding: Padding = .pkcs7) throws {
        self.key = Key(bytes: key)
        self.keySize = key.count
        self.blockMode = blockMode
        self.padding = padding
    }
}

private extension RC6 {
    
}

extension RC6 {
    
}
