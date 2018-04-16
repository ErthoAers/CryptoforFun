
public enum Bit : Int{
    case zero, one
}

extension Bit {
    func inverted() -> Bit {
        return self == .zero ? .one : .zero
    }
}
