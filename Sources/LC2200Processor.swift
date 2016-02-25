import Foundation

public struct LC2200Processor {
    public typealias Register = RegisterFile.Register
    private(set) public var registers = RegisterFile()
    private(set) public var memory = [UInt16](count: 64 * 1024, repeatedValue: 0)
    private var originalMemory = [UInt16]()
    private(set) public var currentAddress: UInt16 = 0x0000
    private var shouldRun = true

    private var breakpoints = Set<UInt16>()

    public mutating func setupMemory(words: [UInt16]) {
        self.originalMemory = words
        self.memory[0..<words.count] = words[0..<words.count]
    }

    public mutating func add(rx: Register, _ ry: Register, _ rz: Register) {
        registers[rx] = UInt16(Int16(bitPattern: registers[ry]) + Int16(bitPattern: registers[rz]))
    }

    public mutating func nand(rx: Register, _ ry: Register, _ rz: Register) {
        registers[rx] = ~(registers[ry] & registers[rz])
    }

    public mutating func addi(rx: Register, _ ry: Register, offset: Int8) {
        registers[rx] = UInt16(bitPattern: Int16(bitPattern: registers[ry]) + Int16(offset))
    }

    public mutating func lw(rx: Register, _ ry: Register, offset: Int8) {
        registers[rx] = memory[Int(registers[ry]) + Int(offset)]
    }

    public mutating func sw(rx: Register, _ ry: Register, offset: Int8) {
        memory[Int(registers[ry]) + Int(offset)] = registers[rx]
    }

    public mutating func beq(rx: Register, _ ry: Register, address: UInt16) {
        if registers[rx] == registers[ry] {
            currentAddress = address
        }
    }

    public mutating func jalr(rx: Register, _ ry: Register = .ReturnAddr) {
        registers[ry] = currentAddress
        currentAddress = registers[rx]
    }

    public mutating func spop(controlCode: UInt) {
        if controlCode == 0 {
            shouldRun = false
        }
    }

    public mutating func executeInstruction(instr: Instruction) {
        currentAddress += 1
        switch instr.operation {
        case Instruction.Operation.Add:
            add(instr.registerX, instr.registerY, instr.registerZ)
        case Instruction.Operation.Nand:
            nand(instr.registerX, instr.registerY, instr.registerZ)
        case Instruction.Operation.AddImmediate:
            addi(instr.registerX, instr.registerY, offset: instr.offset)
        case Instruction.Operation.LoadWord:
            lw(instr.registerX, instr.registerY, offset: instr.offset)
        case Instruction.Operation.StoreWord:
            sw(instr.registerX, instr.registerY, offset: instr.offset)
        case Instruction.Operation.BranchEq:
            beq(instr.registerX, instr.registerY, address: UInt16(bitPattern: Int16(currentAddress) + Int16(instr.offset)))
        case Instruction.Operation.JumpAndLink:
            jalr(instr.registerX, instr.registerY)
        case Instruction.Operation.Spop:
            spop(0)
        default:
            print("Illegal operation. Opcode: \(instr.operation.rawValue)")
            abort()
        }
    }

    public mutating func run() {
        while shouldRun {
            if breakpoints.contains(currentAddress) {
                breakpoints.remove(currentAddress)
                break
            } else {
                step()
            }
        }
    }

    public mutating func setBreakpoint(location: UInt16) {
        breakpoints.insert(location)
    }

    public mutating func reset() {
        registers = RegisterFile()
        currentAddress = 0
        memory = [UInt16](count: 64 * 1024, repeatedValue: 0)
        for (i, v) in originalMemory.enumerate() {
            memory[i] = v
        }
        breakpoints = Set<UInt16>()
        shouldRun = true
    }

    public mutating func step() {
        if shouldRun {
            let instruction = Instruction(value: memory[Int(currentAddress)])
            print("0x\(String(currentAddress, radix: 16).uppercaseString):\t\(instruction)")
            executeInstruction(instruction)
        } else {
            print("Execution halted")
        }
    }

    public func stringForCurrentAddress() -> String {
        return stringForAddress(Int(currentAddress))
    }

    public func stringForAddress(addr: Int) -> String {
        let v = self.memory[addr]
        return "0x\(String(addr, radix: 16).uppercaseString):\t\(stringForValue(v))"
    }

    public func stringForValue(v: UInt16) -> String {
        let instr = Instruction(value: v)
        return "\(v)\t0x\(String(v, radix: 16).uppercaseString)\t\(instr.debugDescription)"
    }

}
