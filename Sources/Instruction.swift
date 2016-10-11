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

    internal init(string: String) throws {
        let operationComponents = string.components(separatedBy: LanguageMap.delimiterSet).filter { $0 != "" }
        self.operation = Operation(string: operationComponents[0])!
        self.registerX = .zero
        self.registerY = .zero
        self.registerZ = .zero
        self.offset = 0
        switch operation.type {
        case .register:
            self.registerX = RegisterFile.Register(symbol: operationComponents[1])!
            self.registerY = RegisterFile.Register(symbol: operationComponents[2])!
            self.registerZ = RegisterFile.Register(symbol: operationComponents[3])!
        case .immediate:
            self.registerX = RegisterFile.Register(symbol: operationComponents[1])!
            self.registerY = RegisterFile.Register(symbol: operationComponents[2])!
            if let offset = Int8(operationComponents[3], radix: 10) {
                self.offset = offset
            } else {
                throw AssemblerError.offsetTooLarge(offset: Int(operationComponents[3])!, instruction: string)
            }
        case .jump:
            self.registerX = RegisterFile.Register(symbol: operationComponents[1])!
            self.registerY = RegisterFile.Register(symbol: operationComponents[2])!
        case .sPop:
            if let offset = Int8(operationComponents[1], radix: 10) {
                self.offset = offset
            } else {
                throw AssemblerError.offsetTooLarge(offset: Int(operationComponents[1])!, instruction: string)
            }
        default:
            throw AssemblerError.unrecognizedInstruction(string: string)
        }
        if (offset >= 16 || offset < -16) {
            throw AssemblerError.offsetTooLarge(offset: Int(offset), instruction: string)
        }
    }

    internal var assembledInstruction: UInt16 {
        var instruction: UInt16 = 0x0000
        let operation = self.operation.rawValue
        instruction |= (UInt16(operation) << 13) & 0xE000
        switch self.operation.type {
        case .register:
            instruction |= (UInt16(registerX.rawValue) << 9) & 0x1E00
            instruction |= (UInt16(registerY.rawValue) << 5) & 0x01E0
            instruction |= (UInt16(registerZ.rawValue)) & 0x000F
        case .immediate:
            instruction |= (UInt16(registerX.rawValue) << 9) & 0x1E00
            instruction |= (UInt16(registerY.rawValue) << 5) & 0x01E0
            instruction |= (UInt16(bitPattern: Int16(offset)) & 0x001F)
        case .jump:
            instruction |= (UInt16(registerX.rawValue) << 9) & 0x1E00
            instruction |= (UInt16(registerY.rawValue) << 5) & 0x01E0
        case .sPop:
            instruction |= (UInt16(bitPattern: Int16(offset)) & 0x001F)
        default:
            fatalError("Error - instruction parse failure")
        }
        return instruction
    }

    public var description: String {
        switch operation.type {
        case .register:
            return "Operation: \(self.operation)\tRegX: \(self.registerX)\tRegY: \(self.registerY)\tRegZ: \(self.registerZ)"
        case .immediate:
            return "Operation: \(self.operation)\tRegX: \(self.registerX)\tRegY: \(self.registerY)\tOffset: \(self.offset)"
        case .jump:
            return "Operation: \(self.operation)\tRegX: \(self.registerX)\tRegY: \(self.registerY)"
        case .sPop:
            return "Operation: \(self.operation)\tControl Code: \(self.offset)"
        case .none:
            return "No-op / Illegal Instruction"
        }
    }

    public var debugDescription: String {
        switch operation.type {
        case .register:
            return "\(self.operation) \(self.registerX), \(self.registerY), \(self.registerZ)"
        case .immediate:
            return "\(self.operation) \(self.registerX), \(self.offset)(\(self.registerY))"
        case .jump:
            return "\(self.operation) \(self.registerX), \(self.registerY)"
        case .sPop:
            return "\(self.operation) \(self.offset)"
        case .none:
            return "No-op / Illegal Instruction"
        }
    }

    internal struct Operation: OptionSet, CustomStringConvertible {
        internal enum OperationType {
            case none
            case register
            case immediate
            case jump
            case sPop
        }
        internal let rawValue: UInt8
        var type: OperationType = .immediate
        internal init(rawValue: UInt8) {
            self.rawValue = rawValue
            if rawValue == 0b000 || rawValue == 0b001 {
                self.type = .register
            } else if rawValue == 0b110 {
                self.type = .jump
            } else if rawValue == 0b111 {
                self.type = .sPop
            }
        }
        internal init(rawValue: UInt8, type: OperationType) {
            self.init(rawValue: rawValue)
            self.type = type
        }
        internal init?(string: String) {
            switch string.uppercased() {
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

        internal static let Add = Operation(rawValue: 0b000, type: .register)
        internal static let Nand = Operation(rawValue: 0b001, type: .register)
        internal static let AddImmediate = Operation(rawValue: 0b010, type: .immediate)
        internal static let LoadWord = Operation(rawValue: 0b011, type: .immediate)
        internal static let StoreWord = Operation(rawValue: 0b100, type: .immediate)
        internal static let BranchEq = Operation(rawValue: 0b101, type: .immediate)
        internal static let JumpAndLink = Operation(rawValue: 0b110, type: .jump)
        internal static let SPop = Operation(rawValue: 0b111, type: .sPop)

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

    fileprivate(set) internal var operation: Operation
    fileprivate(set) internal var registerX: RegisterFile.Register
    fileprivate(set) internal var registerY: RegisterFile.Register
    fileprivate(set) internal var registerZ: RegisterFile.Register
    fileprivate(set) internal var offset: Int8
}
