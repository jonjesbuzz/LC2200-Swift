public struct RegisterFile: CustomStringConvertible {

    var registers = [UInt16](repeating: 0, count: 16)

    public var count: Int {
        return registers.count
    }

    public enum Register: UInt8, CustomStringConvertible {
        case zero = 0
        case asmRsrv = 1
        case returnVal = 2
        case arg0 = 3
        case arg1 = 4
        case arg2 = 5
        case temp0 = 6
        case temp1 = 7
        case temp2 = 8
        case saved0 = 9
        case saved1 = 10
        case saved2 = 11
        case osTrap = 12
        case stackPtr = 13
        case framePtr = 14
        case returnAddr = 15

        public var description: String {
            switch self {
            case .zero:
                return "$zero"
            case .asmRsrv:
                return "$at"
            case .returnVal:
                return "$v0"
            case .arg0:
                return "$a0"
            case .arg1:
                return "$a1"
            case .arg2:
                return "$a2"
            case .temp0:
                return "$t0"
            case .temp1:
                return "$t1"
            case .temp2:
                return "$t2"
            case .saved0:
                return "$s0"
            case .saved1:
                return "$s1"
            case .saved2:
                return "$s2"
            case .osTrap:
                return "$k0"
            case .stackPtr:
                return "$sp"
            case .framePtr:
                return "$fp"
            case .returnAddr:
                return "$ra"
            }
        }

        internal init?(symbol: String) {
            switch symbol {
            case "$zero":
                self = .zero
            case "$at":
                self = .asmRsrv
            case "$v0":
                self = .returnVal
            case "$a0":
                self = .arg0
            case "$a1":
                self = .arg1
            case "$a2":
                self = .arg2
            case "$t0":
                self = .temp0
            case "$t1":
                self = .temp1
            case "$t2":
                self = .temp2
            case "$s0":
                self = .saved0
            case "$s1":
                self = .saved1
            case "$s2":
                self = .saved2
            case "$k0":
                self = .osTrap
            case "$sp":
                self = .stackPtr
            case "$fp":
                self = .framePtr
            case "$ra":
                self = .returnAddr
            default:
                return nil
            }
        }
    }

    public subscript(r: Register) -> UInt16 {
        get {
            return registers[Int(r.rawValue)]
        }
        set(newValue) {
            if r == .zero {
                return
            }
            registers[Int(r.rawValue)] = newValue
        }
    }

    public subscript(r: Int) -> UInt16 {
        get {
            if r >= count {
                return 0
            }
            return registers[r]
        }
        set(newValue) {
            if r == 0 || r >= count {
                return
            }
            registers[r] = newValue
        }
    }
    
    public subscript(s: String) -> UInt16? {
        get {
            if let register = Register(symbol: s) {
                return registers[Int(register.rawValue)]
            }
            return nil
        }
    }

    public var description: String {
        var answer = ""
        for (i, v) in registers.enumerated() {
            if i < 13 {
                answer += "\(Register(rawValue: UInt8(i))!):\t \(Int16(bitPattern: v))\n"
            } else {
                answer += "\(Register(rawValue: UInt8(i))!):\t \(v)\n"
            }
        }
        return answer
    }
}
