internal struct RewindInfo {
    internal var value: UInt16
    internal var programCounter: UInt16
    internal var register: RegisterFile.Register?
    internal var memoryAddress: Int?

    internal init(value: UInt16, programCounter: UInt16) {
        self.value = value
        self.programCounter = programCounter
    }
    internal init(value: UInt16, programCounter: UInt16, register: RegisterFile.Register) {
        self.value = value
        self.programCounter = programCounter
        self.register = register
    }

    internal init(value: UInt16, programCounter: UInt16, memoryAddress: Int) {
        self.value = value
        self.programCounter = programCounter
        self.memoryAddress = memoryAddress
    }
}
