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
            answer += "\(Register(rawValue: UInt8(i))!):\t \(Int16(bitPattern: v))\n"
        }
        return answer
    }
}