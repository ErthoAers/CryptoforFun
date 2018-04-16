
typealias CipherOperationOnBlock = (_ block: ArraySlice<UInt8>) -> Array<UInt8>?

public enum BlockMode {
    case ECB, CBC(iv: Array<UInt8>), PCBC(iv: Array<UInt8>), CFB(iv: Array<UInt8>), OFB(iv: Array<UInt8>), CTR(iv: Array<UInt8>)
    
    public enum Error : Swift.Error {
        case invalidKeyOrInitializationVector
        case invalidInitializationVector
    }
    
    func worker(blockSize: Int, cipherOperation: @escaping CipherOperationOnBlock) throws -> BlockModeWorker {
        switch self {
        case .ECB:
            return ECBModeWorker(cipherOperation: cipherOperation)
        case let .CBC(iv):
            if iv.count != blockSize { throw Error.invalidInitializationVector }
            return CBCModeWorker(iv: iv.slice, cipherOperation: cipherOperation)
        case let .PCBC(iv):
            if iv.count != blockSize { throw Error.invalidInitializationVector }
            return PCBCModeWorker(iv: iv.slice, cipherOperation: cipherOperation)
        case let .CFB(iv):
            if iv.count != blockSize { throw Error.invalidInitializationVector }
            return CFBModeWorker(iv: iv.slice, cipherOperation: cipherOperation)
        case let .OFB(iv):
            if iv.count != blockSize { throw Error.invalidInitializationVector }
            return OFBModeWorker(iv: iv.slice, cipherOperation: cipherOperation)
        case let .CTR(iv):
            if iv.count != blockSize { throw Error.invalidInitializationVector }
            return CTRModeWorker(iv: iv.slice, cipherOperation: cipherOperation)
        }
    }
    
    var options: BlockModeOptions {
        switch self {
        case .ECB:
            return .paddingRequired
        case .CBC:
            return [.initializationVectorRequired, .paddingRequired]
        case .PCBC:
            return [.initializationVectorRequired, .paddingRequired]
        case .CFB:
            return .initializationVectorRequired
        case .OFB:
            return .initializationVectorRequired
        case .CTR:
            return .initializationVectorRequired
        }
    }
}
