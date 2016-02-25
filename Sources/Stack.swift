public struct Stack<E> {
    private var backing = [E]()
    private(set) public var size = 0

    public mutating func push(data: E) {
        backing.append(data)
    }

    public mutating func pop() -> E? {
        if backing.isEmpty {
            return nil
        }
        return backing.removeLast()
    }

    public var isEmpty: Bool {
        return backing.isEmpty
    }

    public var count: Int {
        return backing.count
    }
}