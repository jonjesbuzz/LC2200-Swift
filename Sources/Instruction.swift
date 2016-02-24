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

    public struct Operation: OptionSetType, CustomStringConvertible {
        public enum OperationType {
            case None
            case Register
            case Immediate
            case Jump
            case SPop
        }
        public let rawValue: UInt8
        var type: OperationType = .Immediate
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
            if rawValue == 0b000 || rawValue == 0b001 {
                self.type = .Register
            } else if rawValue == 0b110 {
                self.type = .Jump
            } else if rawValue == 0b111 {
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
