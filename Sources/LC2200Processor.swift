import Foundation

public struct LC2200Processor {
    public typealias Register = RegisterFile.Register
    private var registers = RegisterFile()
    private var memory = [UInt16](count: 64 * 1024, repeatedValue: 0)
    private var currentAddress: UInt16 = 0x0000
    private var shouldRun = true

    public mutating func setupMemory(words: [UInt16]) {
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
            let instruction = Instruction(value: memory[Int(currentAddress)])
            print(instruction)
            executeInstruction(instruction)
        }
        print(self.registers)
    }

}
