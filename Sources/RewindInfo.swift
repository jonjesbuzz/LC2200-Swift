public struct RewindInfo {
    public var value: UInt16
    public var programCounter: UInt16
    public var register: RegisterFile.Register?
    public var memoryAddress: Int?

    public init(value: UInt16, programCounter: UInt16) {
        self.value = value
        self.programCounter = programCounter
    }
    public init(value: UInt16, programCounter: UInt16, register: RegisterFile.Register) {
        self.value = value
        self.programCounter = programCounter
        self.register = register
    }

    public init(value: UInt16, programCounter: UInt16, memoryAddress: Int) {
        self.value = value
        self.programCounter = programCounter
        self.memoryAddress = memoryAddress
    }
}