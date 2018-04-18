
extension Twofish {
    public struct Encryptor : Updatable {
        private var worker: BlockModeWorker
        private let padding: Padding
        private var accumulated = Array<UInt8>()
        private var processedBytesTotalCount: Int = 0
        private let paddingRequired: Bool
        
        init(twofish: Twofish) throws {
            padding = twofish.padding
            worker = try twofish.blockMode.worker(blockSize: AES.blockSize, cipherOperation: twofish.encrypt)
            paddingRequired = twofish.blockMode.options.contains(.paddingRequired)
        }
        
        public mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool) throws -> Array<UInt8> {
            accumulated += bytes
            
            if isLast {
                accumulated = padding.add(to: accumulated, blockSize: AES.blockSize)
            }
            
            var processedBytes = 0
            var encrypted = Array<UInt8>(reserveCapacity: accumulated.count)
            for chunk in accumulated.batched(by: AES.blockSize) {
                if isLast || (accumulated.count - processedBytes) >= AES.blockSize {
                    encrypted += worker.encrypt(chunk)
                    processedBytes += chunk.count
                }
            }
            accumulated.removeFirst(processedBytes)
            processedBytesTotalCount += processedBytes
            return encrypted
        }
    }
}

extension Twofish {
    public struct Decryptor : RandomAccessCryptor {
        private var worker: BlockModeWorker
        private let padding: Padding
        private var accumulated = Array<UInt8>()
        private var processedBytesTotalCount: Int = 0
        private var paddingRequired: Bool
        
        private var offset: Int = 0
        private var offsetToRemove: Int = 0
        
        init(twofish: Twofish) throws {
            padding = twofish.padding
            
            switch twofish.blockMode {
            case .CFB, .OFB, .CTR:
                worker = try twofish.blockMode.worker(blockSize: AES.blockSize, cipherOperation: twofish.encrypt)
            default:
                worker = try twofish.blockMode.worker(blockSize: AES.blockSize, cipherOperation: twofish.decrypt)
            }
            
            paddingRequired = twofish.blockMode.options.contains(.paddingRequired)
        }
        
        public mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false) throws -> Array<UInt8> {
            if offset > 0 {
                accumulated += Array<UInt8>(repeating: 0, count: offset)
                offsetToRemove = offset
                offset = 0
            } else {
                accumulated += bytes
            }
            
            var processedBytes = 0
            var plaintext = Array<UInt8>(reserveCapacity: accumulated.count)
            for chunk in accumulated.batched(by: AES.blockSize) {
                if isLast || (accumulated.count - processedBytes) > AES.blockSize {
                    plaintext += worker.decrypt(chunk)
                    
                    if offsetToRemove > 0 {
                        plaintext.removeFirst(offsetToRemove)
                        offsetToRemove = 0
                    }
                    
                    processedBytes += chunk.count
                }
            }
            accumulated.removeFirst(processedBytes)
            processedBytesTotalCount += processedBytes
            
            if isLast {
                plaintext = padding.remove(from: plaintext, blockSize: AES.blockSize)
            }
            
            return plaintext
        }
        
        @discardableResult mutating public func seek(to position: Int) -> Bool {
            guard var worker = self.worker as? RandomAccessBlockModeWorker else { return false }
            
            worker.counter = UInt(position / AES.blockSize)
            self.worker = worker
            
            offset = position % AES.blockSize
            accumulated = []
            return true
        }
    }
}

extension Twofish : Cryptors {
    public func makeEncryptor() throws -> Twofish.Encryptor {
        return try Twofish.Encryptor(twofish: self)
    }
    
    public func makeDecryptor() throws -> Twofish.Decryptor {
        return try Twofish.Decryptor(twofish: self)
    }
}

