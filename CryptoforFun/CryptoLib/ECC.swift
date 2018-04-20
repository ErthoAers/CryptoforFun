
public final class ECC {
    public enum Variant {
        case secp256k1
        
        var p: Bignum {
            switch self {
            case .secp256k1:
                return Bignum(hex: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")
            }
        }
        var a: Int {
            switch self {
            case .secp256k1:
                return 0
            }
        }
        var b: Int {
            switch self {
            case .secp256k1:
                return 7
            }
        }
        var G: (Bignum, Bignum) {
            switch self {
            case .secp256k1:
                return (Bignum(hex: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798"),
                        Bignum(hex: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8"))
            }
        }
        var n: Bignum {
            switch self {
            case .secp256k1:
                return Bignum(hex: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
            }
        }
        var h: Int {
            switch self {
            case .secp256k1:
                return 1
            }
        }
    }
}
