
public protocol PaddingProtocol {
    func add(to: Array<UInt8>, blockSize: Int) -> Array<UInt8>
    func remove(from: Array<UInt8>, blockSize: Int?) -> Array<UInt8>
}

public enum Padding: PaddingProtocol {
    case noPadding, zeroPadding, pkcs7, pkcs5
    
    public func add(to: Array<UInt8>, blockSize: Int) -> Array<UInt8> {
        switch self {
        case .noPadding:
            return NoPadding().add(to: to, blockSize: blockSize)
        case .zeroPadding:
            return ZeroPadding().add(to: to, blockSize: blockSize)
        case .pkcs7:
            return PKCS7.Padding().add(to: to, blockSize: blockSize)
        case .pkcs5:
            return PKCS5.Padding().add(to: to, blockSize: blockSize)
        }
    }
    
    public func remove(from: Array<UInt8>, blockSize: Int?) -> Array<UInt8> {
        switch self {
        case .noPadding:
            return NoPadding().remove(from: from, blockSize: blockSize)
        case .zeroPadding:
            return ZeroPadding().remove(from: from, blockSize: blockSize)
        case .pkcs7:
            return PKCS7.Padding().remove(from: from, blockSize: blockSize)
        case .pkcs5:
            return PKCS5.Padding().remove(from: from, blockSize: blockSize)
        }
    }
}

