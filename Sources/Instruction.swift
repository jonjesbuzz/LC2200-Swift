public struct Instruction: CustomStringConvertible, CustomDebugStringConvertible {

    public init(value: UInt16) {
        let opcode: UInt8 = UInt8((value & 0xE000) >> 13)
        self.operation = Operation(rawValue: opcode)
        let regX = UInt8((value & 0x1E00) >> 9)
        self.registerX = RegisterFile.Register(rawValue: regX)!
        let regY = UInt8((value & 0x01E0) >> 5)
        self.registerY = RegisterFile.Register(rawValue: regY)!
        let regZ = UInt8((value & 0x000F))
        self.registerZ = RegisterFile.Register(rawValue: regZ)!
        if value & 0x10 == 0b10000 {
            self.offset = Int8(((~value & 0xF) + 1)) * -1
        } else {
            self.offset = Int8(value & 0xF)
        }
    }

    internal init(string: String) {
        let operationComponents = string.componentsSeparatedByCharactersInSet(LanguageMap.delimiterSet).filter { $0 != "" }
        self.operation = Operation(string: operationComponents[0])!
        self.registerX = .Zero
        self.registerY = .Zero
        self.registerZ = .Zero
        self.offset = 0
        switch operation.type {
        case .Register:
            self.registerX = RegisterFile.Register(symbol: operationComponents[1])!
            self.registerY = RegisterFile.Register(symbol: operationComponents[2])!
            self.registerZ = RegisterFile.Register(symbol: operationComponents[3])!
        case .Immediate:
            self.registerX = RegisterFile.Register(symbol: operationComponents[1])!
            self.registerY = RegisterFile.Register(symbol: operationComponents[2])!
            self.offset = Int8(operationComponents[3], radix: 10)!
        case .Jump:
            self.registerX = RegisterFile.Register(symbol: operationComponents[1])!
            self.registerY = RegisterFile.Register(symbol: operationComponents[2])!
        case .SPop:
            self.offset = Int8(operationComponents[1], radix: 10)!
        default:
            fatalError("Error - instruction parse failure")
        }
    }

    internal var assembledInstruction: UInt16 {
        var instruction: UInt16 = 0x0000
        let operation = self.operation.rawValue
        instruction |= (UInt16(operation) << 13) & 0xE000
        switch self.operation.type {
        case .Register:
            instruction |= (UInt16(registerX.rawValue) << 9) & 0x1E00
            instruction |= (UInt16(registerY.rawValue) << 5) & 0x01E0
            instruction |= (UInt16(registerZ.rawValue)) & 0x000F
        case .Immediate:
            instruction |= (UInt16(registerX.rawValue) << 9) & 0x1E00
            instruction |= (UInt16(registerY.rawValue) << 5) & 0x01E0
            instruction |= (UInt16(bitPattern: Int16(offset)) & 0x001F)
        case .Jump:
            instruction |= (UInt16(registerX.rawValue) << 9) & 0x1E00
            instruction |= (UInt16(registerY.rawValue) << 5) & 0x01E0
        case .SPop:
            instruction |= (UInt16(bitPattern: Int16(offset)) & 0x001F)
        default:
            fatalError("Error - instruction parse failure")
        }
        return instruction
    }

    public var description: String {
        switch operation.type {
        case .Register:
            return "Operation: \(self.operation)\tRegX: \(self.registerX)\tRegY: \(self.registerY)\tRegZ: \(self.registerZ)"
        case .Immediate:
            return "Operation: \(self.operation)\tRegX: \(self.registerX)\tRegY: \(self.registerY)\tOffset: \(self.offset)"
        case .Jump:
            return "Operation: \(self.operation)\tRegX: \(self.registerX)\tRegY: \(self.registerY)"
        case .SPop:
            return "Operation: \(self.operation)\tControl Code: \(self.offset)"
        case .None:
            return "No-op / Illegal Instruction"
        }
    }

    public var debugDescription: String {
        switch operation.type {
        case .Register:
            return "\(self.operation) \(self.registerX), \(self.registerY), \(self.registerZ)"
        case .Immediate:
            return "\(self.operation) \(self.registerX), \(self.offset)(\(self.registerY))"
        case .Jump:
            return "\(self.operation) \(self.registerX), \(self.registerY)"
        case .SPop:
            return "\(self.operation) \(self.offset)"
        case .None:
            return "No-op / Illegal Instruction"
        }
    }

    internal struct Operation: OptionSetType, CustomStringConvertible {
        internal enum OperationType {
            case None
            case Register
            case Immediate
            case Jump
            case SPop
        }
        internal let rawValue: UInt8
        var type: OperationType = .Immediate
        internal init(rawValue: UInt8) {
            self.rawValue = rawValue
            if rawValue == 0b000 || rawValue == 0b001 {
                self.type = .Register
            } else if rawValue == 0b110 {
                self.type = .Jump
            } else if rawValue == 0b111 {
                self.type = .SPop
            }
        }
        internal init(rawValue: UInt8, type: OperationType) {
            self.init(rawValue: rawValue)
            self.type = type
        }
        internal init?(string: String) {
            switch string.uppercaseString {
            case "ADD":
                self = Operation.Add
            case "ADDI":
                self = Operation.AddImmediate
            case "NAND":
                self = Operation.Nand
            case "LW":
                self = Operation.LoadWord
            case "SW":
                self = Operation.StoreWord
            case "BEQ":
                self = Operation.BranchEq
            case "JALR":
                self = Operation.JumpAndLink
            case "SPOP":
                self = Operation.SPop
            default:
                return nil
            }
        }

        internal static let Add = Operation(rawValue: 0b000, type: .Register)
        internal static let Nand = Operation(rawValue: 0b001, type: .Register)
        internal static let AddImmediate = Operation(rawValue: 0b010, type: .Immediate)
        internal static let LoadWord = Operation(rawValue: 0b011, type: .Immediate)
        internal static let StoreWord = Operation(rawValue: 0b100, type: .Immediate)
        internal static let BranchEq = Operation(rawValue: 0b101, type: .Immediate)
        internal static let JumpAndLink = Operation(rawValue: 0b110, type: .Jump)
        internal static let SPop = Operation(rawValue: 0b111, type: .SPop)

        internal var description: String {
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
            case Instruction.Operation.SPop:
                return "SPOP"
            default:
                return "???"
            }
        }
    }

    private(set) internal var operation: Operation
    private(set) internal var registerX: RegisterFile.Register
    private(set) internal var registerY: RegisterFile.Register
    private(set) internal var registerZ: RegisterFile.Register
    private(set) internal var offset: Int8
}
