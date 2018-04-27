
@_transparent
func carryAdd(_ lhs: UInt32, _ rhs: UInt32, flag: UInt32) -> (UInt32, UInt32) {
    let tmp = UInt64(lhs) + UInt64(rhs) + UInt64(flag)
    return (UInt32(tmp & 0x00000000FFFFFFFF), UInt32((tmp & 0xFFFFFFFF00000000) >> 8))
}

struct Bignum {
    var d = Array<UInt32>()
    var count: Int {
        return d.count
    }
    var neg: Bool = false
    
    
}

extension Bignum {
    public init(hex: String) {
        var buffer: UInt32 = 0
        var h: String = (hex.hasPrefix("0x") ? String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.endIndex]) : hex)
        h = String(repeating: "0", count: (8 - (h.count % 8)) % 8) + h
        var i: Int = 0
        for char in h.unicodeScalars.lazy {
            i += 1
            guard char.value >= 48 && char.value <= 102 else { d.removeAll(); return }
            
            let v: UInt32
            let c: UInt32 = UInt32(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                d.removeAll()
                return
            }
            buffer <<= 4
            buffer |= v
            if i == 8 {
                d.append(buffer)
                buffer = 0
                i = 0
            }
        }
        d = d.reversed()
    }
    
    public func toHexString() -> String {
        return "0x" + d.reversed().reduce("") {
            return $0 + String(format: "%08X", $1)
        }
    }
    
    public static func == (_ lhs: Bignum, _ rhs: Bignum) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for i in 0..<lhs.count { guard lhs.d[i] == rhs.d[i] else { return false } }
        return true
    }
    
    public static func != (_ lhs: Bignum, _ rhs: Bignum) -> Bool {
        return !(lhs == rhs)
    }
    
    public static func >= (_ lhs: Bignum, _ rhs: Bignum) -> Bool {
        if lhs.count > rhs.count { return true }
        if lhs.count < rhs.count { return false }
        for i in (0...(lhs.count - 1)).reversed() {
            if lhs.d[i] > rhs.d[i] { return true }
            if lhs.d[i] < rhs.d[i] { return false }
        }
        return true
    }
    
    public static func > (_ lhs: Bignum, _ rhs: Bignum) -> Bool {
        return (lhs >= rhs) && (lhs != rhs)
    }
    
    public static func <= (_ lhs: Bignum, _ rhs: Bignum) -> Bool {
        return !(lhs > rhs)
    }
    
    public static func < (_ lhs: Bignum, _ rhs: Bignum) -> Bool {
        return !(lhs >= rhs)
    }
    
    private static func positiveAdd(_ lhs: Bignum, _ rhs: Bignum) -> Bignum {
        var result = Bignum()
        var flag: UInt32 = 0, tmp: UInt32
        let count = max(lhs.count, rhs.count)
        
        for idx in 0..<count {
            (tmp, flag) = carryAdd(idx < lhs.count ? lhs.d[idx] : 0, idx < rhs.count ? rhs.d[idx] : 0, flag: flag)
            result.d.append(tmp)
        }
        
        if flag != 0 { result.d.append(flag) }
        return result
    }
    
    private static func positiveSub(_ lhs: Bignum, _ rhs: Bignum) -> Bignum {
        if (lhs <= rhs) { return -positiveSub(rhs, lhs) }
        
        var result = Bignum()
        var flag: UInt32 = 0, tmp: UInt32
        let count = max(lhs.count, rhs.count)
        
        for idx in 0..<count {
            (tmp, flag) = carryAdd(idx < lhs.count ? lhs.d[idx] : 0, idx < rhs.count ? (~rhs.d[idx] &+ 1) : 0, flag: ~flag &+ 1)
            flag = (flag == 0) ? 1 : 0
            result.d.append(tmp)
        }
        
        return result
    }
    
    public static prefix func - (_ operand: Bignum) -> Bignum {
        var result = operand
        result.neg = !result.neg
        return result
    }
    
    public static func + (_ lhs: Bignum, _ rhs: Bignum) -> Bignum {
        if lhs.neg && rhs.neg {
            return -positiveAdd(lhs, rhs)
        } else if lhs.neg && !rhs.neg {
            return -positiveSub(lhs, rhs)
        } else if !lhs.neg && rhs.neg {
            return positiveSub(lhs, rhs)
        } else {
            return positiveAdd(lhs, rhs)
        }
    }
    
    public static func - (_ lhs: Bignum, _ rhs: Bignum) -> Bignum {
        if lhs.neg && rhs.neg {
            return -positiveSub(lhs, rhs)
        } else if lhs.neg && !rhs.neg {
            return -positiveAdd(lhs, rhs)
        } else if !lhs.neg && rhs.neg {
            return positiveAdd(lhs, rhs)
        } else {
            return positiveSub(lhs, rhs)
        }
    }
    
    public static func * (_ lhs: Bignum, _ rhs: Bignum) -> Bignum {
        
        return lhs
    }
}
