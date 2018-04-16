
public protocol RandomAccessCryptor : Updatable {
    @discardableResult mutating func seek(to: Int) -> Bool
}
