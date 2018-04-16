
struct BatchedCollectionIndex<Base: Collection> {
    let range: Range<Base.Index>
}

extension BatchedCollectionIndex: Comparable {
    static func == <Base>(lhs: BatchedCollectionIndex<Base>, rhs: BatchedCollectionIndex<Base>) -> Bool {
        return lhs.range.lowerBound == rhs.range.lowerBound
    }
    
    static func < <Base>(lhs: BatchedCollectionIndex<Base>, rhs: BatchedCollectionIndex<Base>) -> Bool {
        return lhs.range.lowerBound < rhs.range.lowerBound
    }
}

protocol BatchedCollectionType: Collection {
    associatedtype Base: Collection
}

struct BatchedCollection<Base: Collection>: Collection {
    let base: Base
    let size: Int
    typealias Index = BatchedCollectionIndex<Base>
    private func nextBreak(after idx: Base.Index) -> Base.Index {
        var tmp = idx
        for _ in 0..<size{
            tmp = base.index(after: tmp)
            if tmp > base.endIndex { return base.endIndex }
        }
        return tmp
    }
    
    var startIndex: Index {
        return Index(range: base.startIndex..<nextBreak(after: base.startIndex))
    }
    
    var endIndex: Index {
        return Index(range: base.endIndex..<base.endIndex)
    }
    
    func index(after idx: Index) -> Index {
        return Index(range: idx.range.upperBound..<nextBreak(after: idx.range.upperBound))
    }
    
    subscript(idx: Index) -> Base.SubSequence {
        return base[idx.range]
    }
}

extension Collection {
    func batched(by size: Int) -> BatchedCollection<Self> {
        return BatchedCollection(base: self, size: size)
    }
}

