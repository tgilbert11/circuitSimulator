import Foundation


func runMicrocodedInstruction(clock: CircuitInput, lines: CircuitInput...) {
    for line in lines {
        line.toggle()
    }
    clock.tick()
    for line in lines {
        line.toggle()
    }
}

func paddedPrint(_ inputString: String) {
    let printLength = 60
    let padding = Array(repeating: " ", count: max(0, printLength-inputString.count))
    print(inputString + padding.reduce("", { $0 + $1 }), terminator: "")
}

let simulation = Simulation()

// =====  CIRCUIT DESCRIPTION  =====

//let clock = CircuitInput(name: "clock", startingValue: .drivingLow)
//let masterReset = CircuitInput(name: "reset", startingValue: .drivingHigh)
//
//let data = CircuitInput(name: "data", startingValue: .drivingLow)
//let input2 = CircuitInput(name: "input2", startingValue: .drivingLow)
//
//let setEnable_ = CircuitInput(name: "setEnable_", startingValue: .drivingLow)
//let outputEnable = CircuitInput(name: "outputEnable", startingValue: .pullingUp)
//
//let internalPin = Pin()
//
//let reg = Register1(name: "register1", clock: clock.output, setEnable_: setEnable_.output, reset: masterReset.output, outputEnable: outputEnable.output, data_: data.output, internal_: internalPin, output_: data.output)
//simulation.monitor.participants.append(reg)
//
//var dataPins: [Pin] = []; for _ in 0..<16 { dataPins.append(Pin()) }
//var internalPins: [Pin] = []; for _ in 0..<16 { internalPins.append(Pin()) }
//
//let reg16 = Register16(name: "reg16", clock: clock.output, setEnable_: setEnable_.output, reset: masterReset.output, outputEnable: outputEnable.output, data_: dataPins, internal_: internalPins, output_: dataPins)
//simulation.monitor.participants.append(reg16)
//
//simulation.resolve()






//for pin in reg.cell.pulse_.net!.pins {
//    print(pin.state)
//}
//print("")
//print(reg.pulseInverter.output.state)
//print(reg.pulseInverter.input.connectedTo)

//var addressInputs: [CircuitInput] = []; for addressBit in 0..<10 { addressInputs.append(CircuitInput(name: "a\(addressBit)", startingValue: .pullingUp)) }
//let dataBus = busWithValue(value: 0)
//
////addressInputs[5].output.state = .drivingLow
////addressInputs[6].output.state = .drivingLow
////addressInputs[7].output.state = .drivingLow
////addressInputs[8].output.state = .drivingLow
////addressInputs[9].output.state = .drivingLow
////var outputInputs: [CircuitInput] = []; for outputBit in 0..<16 { outputInputs.append(CircuitInput(name: "o\(outputBit)", startingValue: .pullingUp)) }
//
//
//let data: [UInt16] = [0,0,0,0,0,2048,22528,24584,26624,29404,22528,24577,26624,29327,29402,22529,24577,26624,29334,2,18432,29402,22530,24577,26624,29340,18432,29402,22531,24577,26624,29347,2,18432,29402,22532,24577,26624,29354,3,18434,29402,22533,24577,26624,29363,2,3,4,18432,29402,22534,24577,26624,29370,3,18435,29402,22535,24577,26624,29379,2,3,4,18432,29402,22536,24577,26624,29386,3,18437,29402,22537,24577,26624,29395,2,3,4,18432,29402,22538,24577,26624,29402,2,18439,29402,30722,29317,22529,24584,26624,29499,4096,22528,24577,26624,29418,2,14338,30722,18433,29317,22529,24577,26624,29425,14338,30722,29317,22530,24577,26624,29434,3,14339,30723,18436,29317,22531,24577,26624,29443,3,14339,30723,18438,29317,22532,24577,26624,29450,14339,30723,29317,22533,24577,26624,29459,3,14339,30723,18440,29317,22534,24577,26624,29466,14339,30723,29317,22535,24577,26624,29475,2,14338,30722,18442,29317,22536,24577,26624,29483,3,14339,30723,29317,22537,24577,26624,29492,3,14339,30723,18438,29317,22538,24577,26624,29317,14339,30723,29317,22530,24584,26624,29598,22528,24577,26624,29511,30722,6144,18434,29317,22529,24577,26624,29519,30722,6144,18435,29317,22530,24577,26624,29526,6144,30722,29317,22531,24577,26624,29533,6144,30722,29317,22532,24577,26624,29544,16386,3,14339,6144,30723,18435,29317,22533,24577,26624,29553,12290,6144,30724,18441,29317,22534,24577,26624,29562,16386,6144,30722,18435,29317,22535,24577,26624,29572,12290,3,6144,30724,18435,29317,22536,24577,26624,29582,10242,3,6144,30722,18435,29317,22537,24577,26624,29589,6144,30724,29317,22538,24577,26624,29317,3,6144,30722,18435,29317,22531,24584,26624,29317,22528,24577,26624,29608,30722,29317,22529,24577,26624,29614,30722,29317,22530,24577,26624,29621,30722,18432,29317,22531,24577,26624,29630,8195,16388,30724,18437,29317,22532,24577,26624,29638,16388,30724,18439,29317,22533,24577,26624,29646,12291,16388,30724,29317,22534,24577,26624,29654,16388,30724,18439,29317,22535,24577,26624,29662,12290,16388,30724,29317,22536,24577,26624,29670,16388,30724,18439,29317,22537,24577,26624,29679,8195,16388,30724,18439,29317,22538,24577,26624,29317,16388,30724,18439,29317]
//
//let outputEnable = CircuitInput(name: "outputEnable", startingValue: .pullingUp)
//
//let memory = Rom1024x16(name: "FixedRom", addressPins: addressInputs.map({ $0.output }), outputEnable: outputEnable.output, outputPins: dataBus, data: data)
//
//simulation.monitor.participants.append(memory)
//
//paddedPrint("simulation stats: \(simulation.nets.count) nets, \(simulation.devices.count) devices, \(simulation.devices.reduce(0, { $0 + $1.transistors() })) transistors")
//print("")
//addressInputs[0].output.state = .drivingLow
//addressInputs[2].output.state = .drivingLow
//simulation.resolve()
//print(valueOfBus(dataBus))
//addressInputs[3].toggle()
//print(valueOfBus(dataBus))






// --- register tester ---


let clock = CircuitInput(name: "clock", startingValue: .drivingLow)
let reset = CircuitInput(name: "reset", startingValue: .pullingUp)

let dataBus = busWithValue(value: 0)
//let aluBus = busWithValue(value: 0)


let value3OutputEnable = CircuitInput(name: "value3OutputEnable", startingValue: .drivingLow)
let value3 = FixedBusDriver16(name: "fixedValue3", outputEnable: value3OutputEnable.output, value: 3, output_: dataBus)

let memoryData = busWithValue(value: 0)
let memoryOutputEnable = CircuitInput(name: "memoryOutputEnable", startingValue: .drivingLow)
let memory = BusDriver16(name: "Memory", outputEnable: memoryOutputEnable.output, data_: memoryData, output_: dataBus)
simulation.monitor.participants.append(memory)

let aSetEnable_ = CircuitInput(name: "aSetEnable_", startingValue: .pullingUp)
let aOutputEnable = CircuitInput(name: "aOutputEnable", startingValue: .drivingLow)
let aRegister = Register16(name: "A", clock: clock.output, setEnable_: aSetEnable_.output, reset: reset.output, outputEnable: aOutputEnable.output, data_: dataBus, internal_: nil, output_: dataBus)
simulation.monitor.participants.append(aRegister)

let bSetEnable_ = CircuitInput(name: "bSetEnable_", startingValue: .pullingUp)
let bOutputEnable = CircuitInput(name: "bOutputEnable", startingValue: .drivingLow)
let bRegister = Register16(name: "B", clock: clock.output, setEnable_: bSetEnable_.output, reset: reset.output, outputEnable: bOutputEnable.output, data_: dataBus, internal_: nil, output_: dataBus)
simulation.monitor.participants.append(bRegister)

let andOutputEnable = CircuitInput(name: "andOutputEnable", startingValue: .drivingLow)
let aluAnd = ALUAnd(name: "AandB", outputEnable: andOutputEnable.output, sideA_: aRegister.internal_, sideB_: bRegister.internal_, internal_: nil, output_: dataBus)
simulation.monitor.participants.append(aluAnd)

paddedPrint("simulation stats: \(simulation.nets.count) nets, \(simulation.devices.count) devices, \(simulation.devices.reduce(0, { $0 + $1.transistors() })) transistors")

// ===== SIMULATION POWER UP =====
simulation.resolve()
reset.toggle()

// ===== SIMULATION STEPS =====

setValueToBus(value: 10, bus: memoryData)
runMicrocodedInstruction(clock: clock, lines: memoryOutputEnable, aSetEnable_)
//
//setValueToBus(value: 6, bus: memoryData)
//runMicrocodedInstruction(clock: clock, lines: memoryOutputEnable, bSetEnable_)
//
////runMicrocodedInstruction(clock: clock, lines: value3OutputEnable, bSetEnable_)
////runMicrocodedInstruction(clock: clock, lines: andOutputEnable, aSetEnable_)
//
//runMicrocodedInstruction(clock: clock, lines: aOutputEnable, bSetEnable_)
//
//print(valueOfBus(dataBus))

//print(Pin.pins.count)
//print(Pin.pins.filter({ $0.net == nil }).count)
//print(Pin.pins)
//print(Pin.pins.filter({ $0.connectedTo == .floating }).count)
