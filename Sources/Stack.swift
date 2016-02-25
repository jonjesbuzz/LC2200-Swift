public struct Stack<E> {
    private var head: Node<E>?
    private var tail: Node<E>?

    public mutating func push(data: E) {
        if head == nil {
            head = Node(data: data)
            tail = head
        } else {
            tail!.next = Node(data: data)
            tail = tail!.next
        }
    }

    public mutating func pop() -> E? {
        if head == nil {
            return nil
        }
        let data = head!.data
        head = head!.next
        if head == nil {
            tail = nil
        }
        return data
    }
}
private class Node<E> {
    var next: Node<E>?
    var data: E
    init(data: E) {
        self.data = data
    }
}