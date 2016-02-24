import Foundation

extension LC2200Processor {
    public func printRegisters() {
        print(self.registers)
    }

    public func printMemory() {
        print("Mem\tDec\tHex\tInstr")
        for (i, v) in memory.enumerate() {
            if (v != 0) {
                print(stringForAddress(i));
            }
        }
    }
}


var processor = LC2200Processor()
if (Process.arguments.count == 1 || (Process.arguments.count == 2 && Process.arguments[1] == "--debug")) {
    print("Loaded default/compiled program")
    processor.setupMemory(Program.program)
} else {
    do {
        let memory = try String(contentsOfFile: Process.arguments[1], encoding: NSUTF8StringEncoding)
        let vals = memory.characters.split { $0 == " " || $0 == "\n" }.map(String.init)
        let things = vals.map { (s) -> (UInt16) in
            if let data = UInt16(s, radix: 16) {
                return data
            }
            print("File \(Process.arguments[1]) is not a valid LC2200 file.")
            exit(1)
        }
        processor.setupMemory(things)
        print("Loaded \(Process.arguments[1])")
    } catch {
        print(error)
        exit(1)
    }
}

if Process.arguments.contains("--debug") {
    var command: String = ""
    var readCommand: String?
    var commandArg: String = ""
    while true {

        print("(LC2200) ", separator: "", terminator: "")

        let readCommand = readLine(stripNewline: true)?.lowercaseString

        // Parse out the argument (used in breakpoint)
        if let readCommand = readCommand where readCommand != "" {
            let args = readCommand.characters.split { $0 == " " }.map(String.init)
            command = args[0]
            commandArg = args.last ?? ""
            if commandArg.containsString("0x") {
                commandArg = commandArg.substringFromIndex(commandArg.startIndex.advancedBy(2))
            }
        }

        switch command {
        case "run", "r":
            processor.reset()
            processor.run()
        case "step", "s":
            processor.step()
        case "continue", "cont", "c":
            processor.run()
        case "register", "reg":
            processor.printRegisters()
        case "reset":
            processor.reset()
        case "memory", "mem":
            processor.printMemory()
        case "break", "br":
            if let addr = UInt16(commandArg, radix: 16) {
                processor.setBreakpoint(addr)
            } else {
                print("Invalid address: \(commandArg)")
            }
        case "list", "l":
            var start = processor.currentAddress
            if (start <= 5) {
                start -= start
            } else {
                start -= 5
            }

            for i in start..<start + 10 {
                if (i == processor.currentAddress) {
                    print("-> ", separator: "", terminator: "")
                }
                print("\t\(processor.stringForAddress(Int(i)))")
            }
        case "print", "p":
            if let addr = UInt16(commandArg, radix: 16) {
                print(processor.stringForAddress(Int(addr)))
            } else {
                print("Invalid address: \(commandArg)")
            }
        case "exit", "quit", "q":
            exit(0)
        case "help", "h":
            print()
            print("LC-2200 Simulator")
            print("Debug Mode")
            print()
            print("[r]un\t\t\tReset the processor and start the program.  All breakpoints are reset.")
            print("[l]ist\t\t\tPrint the current memory address, with 5 lines before and after.")
            print("[p]rint (0xFFFF)\tPrint the memory location.")
            print("[c]ontinue\t\tResume execution, after stopping/setting a breakpoint.")
            print("[br]eak (0xFFFF)\tAdd a breakpoint at a memory location.")
            print("[reg]ister\t\tPrint out the registers.")
            print("[mem]ory\t\tPrint out non-zero locations in the memory bank.")
            print("[q]uit\t\t\tQuit the simulator.")
            print()
        default:
            print("Invalid command: \(command)")
        }
    }
} else {
    processor.run()
}