import Foundation
public struct RegisterFile: CustomStringConvertible {

    var registers = [UInt16](count: 16, repeatedValue: 0)

    public enum Register: UInt8 {
        case Zero = 0
        case AsmRsrv = 1
        case ReturnVal = 2
        case Arg0 = 3
        case Arg1 = 4
        case Arg2 = 5
        case Temp0 = 6
        case Temp1 = 7
        case Temp2 = 8
        case Saved0 = 9
        case Saved1 = 10
        case Saved2 = 11
        case OSTrap = 12
        case StackPtr = 13
        case FramePtr = 14
        case ReturnAddr = 15

    }

    public subscript(r: Register) -> UInt16 {
        get {
            return registers[Int(r.rawValue)]
        }
        set(newValue) {
            if r == .Zero {
                return
            }
            registers[Int(r.rawValue)] = newValue
        }
    }

    public var description: String {
        var answer = ""
        for (i, v) in registers.enumerate() {
            answer += "\(Register(rawValue: UInt8(i))!):\t \(v)\n"
        }
        return answer
    }
}

public struct Instruction: CustomStringConvertible {

    public init(value: UInt16) {
        let opcode: UInt8 = UInt8((value & 0xE000) >> 13)
        self.operation = Operation(rawValue: opcode)
        let regX = UInt8((value & 0x1E00) >> 9)
        self.registerX = RegisterFile.Register(rawValue: regX)!
        let regY = UInt8((value & 0x01E0) >> 5)
        self.registerY = RegisterFile.Register(rawValue: regY)!
        let regZ = UInt8((value & 0x001E) >> 1)
        self.registerZ = RegisterFile.Register(rawValue: regZ)!
        self.offset = Int8(value & 0xF)
        if (value & 0x10 == 0b10000) {
            self.offset = -self.offset
        }

    }

    public var description: String {
        return "Operation: \(self.operation), RegX: \(self.registerX), RegY: \(self.registerY), RegZ: \(self.registerZ), Offset: \(self.offset)"
    }
    public struct Operation: OptionSetType, CustomStringConvertible {
        public enum OperationType {
            case None
            case Register
            case Immediate
            case Jump
            case SPop
        }
        public let rawValue: UInt8
        var type: OperationType = .None
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
            if rawValue == 0b000 || rawValue == 0b001 {
                self.type = .Register
            } else if rawValue >= 0b010 && rawValue <= 0b101 {
                self.type == .Immediate
            } else if rawValue == 0b110 {
                self.type = .Jump
            } else {
                self.type = .SPop
            }
        }
        public init(rawValue: UInt8, type: OperationType) {
            self.init(rawValue: rawValue)
            self.type = type
        }

        public static let Add = Operation(rawValue: 0b000, type: .Register)
        public static let Nand = Operation(rawValue: 0b001, type: .Register)
        public static let AddImmediate = Operation(rawValue: 0b010, type: .Immediate)
        public static let LoadWord = Operation(rawValue: 0b011, type: .Immediate)
        public static let StoreWord = Operation(rawValue: 0b100, type: .Immediate)
        public static let BranchEq = Operation(rawValue: 0b101, type: .Immediate)
        public static let JumpAndLink = Operation(rawValue: 0b110, type: .Jump)
        public static let Spop = Operation(rawValue: 0b111, type: .SPop)

        public var description: String {
            switch self {
            case Instruction.Operation.Add:
                return "ADD"
            case Instruction.Operation.Nand:
                return "NAND"
            case Instruction.Operation.AddImmediate:
                return "ADDI"
            case Instruction.Operation.LoadWord:
                return "LW"
            case Instruction.Operation.StoreWord:
                return "SW"
            case Instruction.Operation.BranchEq:
                return "BEQ"
            case Instruction.Operation.JumpAndLink:
                return "JALR"
            case Instruction.Operation.Spop:
                return "SPOP"
            default:
                return "???"
            }
        }
    }

    public let operation: Operation
    public let registerX: RegisterFile.Register
    public let registerY: RegisterFile.Register
    public let registerZ: RegisterFile.Register
    public var offset: Int8
}

public struct LC2200Processor {
    public typealias Register = RegisterFile.Register
    private var registers = RegisterFile()
    private var memory = [UInt16](count: 16 * 1024, repeatedValue: 0)
    private var currentAddress: UInt16 = 0x0000
    private var shouldRun = true

    public mutating func setupMemory(words: [UInt16]) {
        self.memory[0..<words.count] = words[0..<words.count]
    }

    public mutating func add(rx: Register, _ ry: Register, _ rz: Register) {
        registers[rx] = registers[ry] + registers[rz]
        currentAddress += 1
    }

    public mutating func nand(rx: Register, _ ry: Register, _ rz: Register) {
        registers[rx] = ~(registers[ry] & registers[rz])
        currentAddress += 1
    }

    public mutating func addi(rx: Register, _ ry: Register, offset: Int8) {
        registers[rx] = UInt16(Int16(registers[ry]) + Int16(offset))
        currentAddress += 1
    }

    public mutating func lw(rx: Register, _ ry: Register, offset: Int8) {
        registers[rx] = memory[Int(registers[ry]) + Int(offset)]
        currentAddress += 1
    }

    public mutating func sw(rx: Register, _ ry: Register, offset: Int8) {
        memory[Int(registers[ry]) + Int(offset)] = registers[rx]
        currentAddress += 1
    }

    public mutating func beq(rx: Register, _ ry: Register, address: UInt16) {
        if registers[rx] == registers[ry] {
            currentAddress = address
        } else {
            currentAddress += 1
        }
    }

    public mutating func jalr(rx: Register, _ ry: Register = .ReturnAddr) {
        currentAddress += 1
        registers[ry] = currentAddress
        currentAddress = registers[rx]
    }

    public mutating func spop(controlCode: UInt) {
        if controlCode == 0 {
            shouldRun = false
        }
    }

    public mutating func executeInstruction(instr: Instruction) {
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
            beq(instr.registerX, instr.registerY, address: UInt16(Int16(currentAddress) + Int16(instr.offset)))
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
    }
}