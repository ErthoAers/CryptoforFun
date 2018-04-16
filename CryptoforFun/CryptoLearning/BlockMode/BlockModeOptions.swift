
struct BlockModeOptions : OptionSet {
    let rawValue: Int
    
    static let none = BlockModeOptions(rawValue: 1 << 0)
    static let initializationVectorRequired = BlockModeOptions(rawValue: 1 << 1)
    static let paddingRequired = BlockModeOptions(rawValue: 1 << 2)
}
