internal struct Stack<E> {
    private var backing = [E]()

    internal mutating func push(data: E) {
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
