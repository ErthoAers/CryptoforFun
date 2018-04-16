
@_transparent
func rotateLeft(_ value: UInt8, by: UInt8) -> UInt8 {
    return ((value << by) & 0xff) | (value >> (8 - by))
}

@_transparent
func rotateLeft(_ value: UInt16, by: UInt16) -> UInt16 {
    return ((value << by) & 0xffff) | (value >> (16 - by))
}

@_transparent
func rotateLeft(_ value: UInt32, by: UInt32) -> UInt32 {
    return ((value << by) & 0xffffffff) | (value >> (32 - by))
}

@_transparent
func rotateLeft(_ value: UInt64, by: UInt64) -> UInt64 {
    return (value << by) | (value >> (64 - by))
}

@_transparent
func rotateRight(_ value: UInt8, by: UInt8) -> UInt8 {
    return ((value >> by) & 0xff) | (value << (8 - by))
}

@_transparent
func rotateRight(_ value: UInt16, by: UInt16) -> UInt16 {
    return ((value >> by) & 0xffff) | (value << (16 - by))
}

@_transparent
func rotateRight(_ value: UInt32, by: UInt32) -> UInt32 {
    return ((value >> by) & 0xffffffff) | (value << (32 - by))
}

@_transparent
func rotateRight(_ value: UInt64, by: UInt64) -> UInt64 {
    return (value >> by) | (value << (64 - by))
}

func xor<T, U>(_ left: T, _ right: U) -> ArraySlice<UInt8> where T: RandomAccessCollection, U: RandomAccessCollection, T.Element == UInt8, T.Index == Int, U.Element == UInt8, U.Index == Int {
    return xor(left, right).slice
}

func xor<T, U>(_ left: T, _ right: U) -> Array<UInt8> where T: RandomAccessCollection, U: RandomAccessCollection, T.Element == UInt8, T.Index == Int, U.Element == UInt8, U.Index == Int {
    let length = Swift.min(Int(left.count), Int(right.count))
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
    buffer.initialize(to: 0, count: length)
    defer {
        buffer.deinitialize(count: length)
        buffer.deallocate(capacity: length)
    }
    
    for i in 0..<length {
        buffer[i] = left[left.startIndex.advanced(by: i)] ^ right[right.startIndex.advanced(by: i)]
    }
    return Array(UnsafeBufferPointer(start: buffer, count: length))
}
