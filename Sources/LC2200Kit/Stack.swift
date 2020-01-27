internal struct Stack<E> {
    fileprivate var backing = [E]()

    internal mutating func push(_ data: E) {
        backing.append(data)
    }

    internal mutating func pop() -> E? {
        if backing.isEmpty {
            return nil
        }
        return backing.removeLast()
    }

    internal mutating func removeAll() {
        backing.removeAll()
    }

    internal var isEmpty: Bool {
        return backing.isEmpty
    }

    internal var count: Int {
        return backing.count
    }
}
