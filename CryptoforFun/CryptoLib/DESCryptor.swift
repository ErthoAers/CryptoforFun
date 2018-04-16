
extension DES {
    public struct Encryptor : Updatable {
        private var worker: BlockModeWorker
        private let padding: Padding
        private var accumulated = Array<UInt8>()
        private var processedBytesTotalCount: Int = 0
        private let paddingRequired: Bool
        
        init(des: DES) throws {
            padding = des.padding
            worker = try des.blockMode.worker(blockSize: DES.blockSize, cipherOperation: des.encrypt)
            paddingRequired = des.blockMode.options.contains(.paddingRequired)
        }
        
        public mutating func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool) throws -> Array<UInt8> {
            accumulated += bytes
            
            if isLast {
                accumulated = padding.add(to: accumulated, blockSize: DES.blockSize)
            }
            
            var processedBytes = 0
            var encrypted = Array<UInt8>(reserveCapacity: accumulated.count)
            for chunk in accumulated.batched(by: DES.blockSize) {
                if isLast || (accumulated.count - processedBytes) >= DES.blockSize {
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

extension DES {
    public struct Decryptor : RandomAccessCryptor {
        private var worker: BlockModeWorker
        private let padding: Padding
        private var accumulated = Array<UInt8>()
        private var processedBytesTotalCount: Int = 0
        private var paddingRequired: Bool
        
        private var offset: Int = 0
        private var offsetToRemove: Int = 0
        
        init(des: DES) throws {
            padding = des.padding
            
            switch des.blockMode {
            case .CFB, .OFB, .CTR:
                worker = try des.blockMode.worker(blockSize: DES.blockSize, cipherOperation: des.encrypt)
            default:
                worker = try des.blockMode.worker(blockSize: DES.blockSize, cipherOperation: des.decrypt)
            }
            
            paddingRequired = des.blockMode.options.contains(.paddingRequired)
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
            for chunk in accumulated.batched(by: DES.blockSize) {
                if isLast || (accumulated.count - processedBytes) > DES.blockSize {
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
                plaintext = padding.remove(from: plaintext, blockSize: DES.blockSize)
            }
            
            return plaintext
        }
        
        @discardableResult mutating public func seek(to position: Int) -> Bool {
            guard var worker = self.worker as? RandomAccessBlockModeWorker else { return false }
            
            worker.counter = UInt(position / DES.blockSize)
            self.worker = worker
            
            offset = position % DES.blockSize
            accumulated = []
            return true
        }
    }
}

extension DES : Cryptors {
    public func makeEncrypter() throws -> DES.Encryptor {
        return try DES.Encryptor(des: self)
    }
    
    public func makeDecryptor() throws -> DES.Decryptor {
        return try DES.Decryptor(des: self)
    }
}

