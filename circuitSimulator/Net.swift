////
////  main.swift
////  circuitSimulator
////
////  Created by Taylor Gilbert on 9/8/19.
////  Copyright © 2019 Taylor Gilbert. All rights reserved.
////
//
//import Foundation
//
//enum Driving: String {
//    case drivingHigh
//    case drivingLow
//    case pullingUp
//    case pullingDown
//    case impeded
//}
//enum NetValue: String {
//    case high
//    case low
//    case floating
//}
//
//class SimulationParticipant: CustomStringConvertible {
//    func update_TrueIfChanged() -> Bool { return false }
//    var description: String { return "SimulationParticipant" }
//}
//class Pin: CustomStringConvertible {
//    var state: Driving = .impeded
//    var connectedTo: NetValue = .floating
//    var description: String { return "\(self.state)" }
//}
//class Net: SimulationParticipant {
//    let name: String
//    var pins: [Pin] = []
//    var output: NetValue = .floating
//
//    init(name: String, _ simulation: Simulation, pins: Pin...) {
//        self.name = name
//        for pin in pins {
//            self.pins.append(pin)
//        }
//        super.init()
//        simulation.add(self)
//    }
//
//    override var description: String { return "\(self.name): \(pins.count > 0 ? pins[0].description + pins.dropFirst().map({", " + $0.description}).reduce("", {$0 + $1}) : "no pins"): \(self.output)" }
//
//    override func update_TrueIfChanged() -> Bool {
//        let startingOutput = output
//        //print(output)
//        let drivingHigh = self.pins.contains(where: { $0.state == .drivingHigh })
//        let drivingLow = self.pins.contains(where: { $0.state == .drivingLow })
//        let pullingUp = self.pins.contains(where: { $0.state == .pullingUp })
//        let pullingDown = self.pins.contains(where: { $0.state == .pullingDown })
//        //let connectedToHigh = self.pins.contains(where: { $0.connectedTo == .high })
//        //let connectedToLow = self.pins.contains(where: { $0.connectedTo == .low })
//        // assumes this covers all cases excpet impeded
//
//        assert( !((drivingHigh == true) && (drivingLow == true)) , "\(self.name) driven high and low")
//        assert( !(pullingUp == true && pullingDown == true) , "\(self.name) pulled high and low")
//        //assert( !(connectedToHigh == true && connectedToLow == true) , "\(self.name) connected to high and low")
//
//
//        if drivingHigh == true {
//            output = .high
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else if drivingLow == true {
//            output = .low
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else if pullingUp == true {
//            output = .high
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else if pullingDown == true {
//            output = .low
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//            //        else if connectedToHigh == true {
//            //            output = .high
//            //            for pin in pins {
//            //                pin.connectedTo = output
//            //            }
//            //        }
//            //        else if connectedToLow == true {
//            //            output = .low
//            //            for pin in pins {
//            //                pin.connectedTo = output
//            //            }
//            //        }
//        else {
//            output = .floating
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//
//        let finalOutput = output
//
//        return finalOutput != startingOutput
//    }
//
//    func append(_ pin: Pin) {
//        self.pins.append(pin)
//    }
//}
//class Device: SimulationParticipant {
//    var name: String
//    init(name: String) {
//        self.name = name
//    }
//    override var description: String { return "device" }
//}
//
//class NOR2: Device {
//    init(name: String, _ simulation: Simulation) {
//        //self.name = name
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var i1 = Pin()
//    var i2 = Pin()
//    var output = Pin()
//
//    override func update_TrueIfChanged() -> Bool {
//        let startingState = self.output.state
//
//        if i1.connectedTo == .high || i2.connectedTo == .high {
//            self.output.state = .drivingLow
//        }
//        else {
//            self.output.state = .pullingUp
//        }
//
//        let finalState = self.output.state
//
//        return finalState != startingState
//    }
//
//    override var description: String { return "\(name): i1: \(i1.connectedTo), i2: \(i2.connectedTo), output: \(output.state)" }
//}
//
//class NAND2: Device {
//    init(name: String, _ simulation: Simulation) {
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var i1 = Pin()
//    var i2 = Pin()
//    var output = Pin()
//
//    override func update_TrueIfChanged() -> Bool {
//        let startingState = self.output.state
//
//        if i1.connectedTo == .high && i2.connectedTo == .high {
//            self.output.state = .drivingLow
//        }
//        else {
//            self.output.state = .pullingUp
//        }
//
//        let finalState = self.output.state
//
//        return finalState != startingState
//    }
//    override var description: String { return "\(name): i1: \(i1.connectedTo), i2: \(i2.connectedTo), output: \(output.state)" }
//}
//
//class INV: Device {
//    init(name: String, _ simulation: Simulation) {
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var input = Pin()
//    var output = Pin()
//
//    override func update_TrueIfChanged() -> Bool {
//        let startingState = self.output.state
//
//        if input.connectedTo == .high {
//            self.output.state = .drivingLow
//        }
//        else {
//            self.output.state = .pullingUp
//        }
//
//        let finalState = self.output.state
//
//        return finalState != startingState
//    }
//    override var description: String { return "\(name): input: \(input.connectedTo), output: \(output.state)" }
//}
//
//class AND2: Device {
//    private let nand: NAND2
//    private let inv: INV
//    init(name: String, _ simulation: Simulation) {
//        nand = NAND2(name: name+"-NAND", simulation)
//        inv = INV(name: name+"-INV", simulation)
//
//        _ = Net(name: name+"-nand", simulation, pins: nand.output, inv.input)
//        self.i1 = nand.i1
//        self.i2 = nand.i2
//        self.output = inv.output
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var i1: Pin
//    var i2: Pin
//    var output: Pin
//    override var description: String { return "\(name): i1: \(i1.connectedTo), i2: \(i2.connectedTo), output: \(output.state)" }
//}
//
//class OR2: Device {
//    private let nor: NOR2
//    private let inv: INV
//    init(name: String, _ simulation: Simulation) {
//        nor = NOR2(name: name+"-NOR", simulation)
//        inv = INV(name: name+"-INV", simulation)
//        _ = Net(name: name+"-nor", simulation, pins: nor.output, inv.input)
//        self.i1 = nor.i1
//        self.i2 = nor.i2
//        self.output = inv.output
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var i1: Pin
//    var i2: Pin
//    var output: Pin
//    override var description: String { return "\(name): i1: \(i1.connectedTo), i2: \(i2.connectedTo), output: \(output.state)" }
//}
//
//class SR: Device {
//    private let nor1: NOR2
//    private let nor2: NOR2
//    init(name: String, _ simulation: Simulation) {
//        nor1 = NOR2(name: name+"-NOR1", simulation)
//        nor2 = NOR2(name: name+"-NOR2", simulation)
//        _ = Net(name: name+"-upper", simulation, pins: nor1.output, nor2.i1)
//        _ = Net(name: name+"-lower", simulation, pins: nor2.output, nor1.i1)
//        self.set = nor1.i2
//        self.reset = nor2.i2
//        self.q = nor1.output
//        self.q_ = nor2.output
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var set: Pin
//    var reset: Pin
//    var q: Pin
//    var q_: Pin
//    override var description: String { return "\(name): set: \(set.connectedTo), reset: \(reset.connectedTo), q: \(q.state), q_: \(q_.state)" }
//}
//
//class DFF: Device {
//    private let sr: SR
//    private let edgeInv: INV
//    private let edgeAnd: AND2
//    private let enableAnd: AND2
//    private let setAnd: AND2
//    private let resetInv: INV
//    private let resetAnd: AND2
//    private let masterResetOr: OR2
//    init(name: String, _ simulation: Simulation) {
//        sr = SR(name: name+"-sr", simulation)
//        edgeInv = INV(name: name+"-edgeInv", simulation)
//        edgeAnd = AND2(name: name+"-edgeAnd", simulation)
//        enableAnd = AND2(name: name+"-enableAnd", simulation)
//        setAnd = AND2(name: name+"-setAnd", simulation)
//        resetInv = INV(name: name+"-resetInv", simulation)
//        resetAnd = AND2(name: name+"-resetAnd", simulation)
//        masterResetOr = OR2(name: name+"-masterResetOr", simulation)
//
//        edgeInv.input = enableAnd.i2
//        _ = Net(name: name+"-slowEdge", simulation, pins: edgeInv.output, edgeAnd.i2)
//        _ = Net(name: name+"-pulse", simulation, pins: edgeAnd.output, enableAnd.i1)
//
//        _ = Net(name: name+"-enabledPulse", simulation, pins: enableAnd.output, setAnd.i2, resetAnd.i2)
//        resetInv.input = setAnd.i1
//        _ = Net(name: name+"-dataInv", simulation, pins: resetInv.output, resetAnd.i1)
//
//        _ = Net(name: name+"-setPulse", simulation, pins: setAnd.output, sr.set)
//        _ = Net(name: name+"-resetPulse", simulation, pins: resetAnd.output, masterResetOr.i1)
//
//        _ = Net(name: name+"-resetSignal", simulation, pins: masterResetOr.output, sr.reset)
//
//        self.enable = edgeInv.input
//        self.data = setAnd.i1
//        self.clock = resetInv.input
//        self.output = sr.q_
//        self.reset = masterResetOr.i2
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var enable: Pin
//    var data: Pin
//    var clock: Pin
//    var output: Pin
//    var reset: Pin
//    override var description: String { return "\(name): enable: \(enable.connectedTo), data: \(data.connectedTo), clock: \(clock.connectedTo), reset: \(reset.connectedTo), output: \(output.state)" }
//}
//
//class Clock: Device {
//    init(name: String, _ simulation: Simulation) {
//        super.init(name: name)
//        self.output.state = .drivingHigh
//        simulation.add(self)
//    }
//    var output = Pin()
//
//    var currentState = true
//    func flip() {
//        if currentState == true {
//            output.state = .drivingLow
//            currentState = false
//        }
//        else {
//            output.state = .drivingHigh
//            currentState = true
//        }
//    }
//    override var description: String { return "\(name): output: \(output.state)" }
//}
//
//class FixedInput: Device {
//    init(name: String, _ simulation: Simulation, value: Driving) {
//        super.init(name: name)
//        self.output.state = value
//        simulation.add(self)
//    }
//    var output = Pin()
//    override var description: String { return "\(name): output: \(output.state)" }
//}
//class Meter: Device {
//    init(name: String, _ simulation: Simulation) {
//        super.init(name: name)
//        simulation.add(self)
//    }
//    var input = Pin()
//    override var description: String { return "\(name): value: \(input.connectedTo)" }
//}
//
//class Simulation {
//    var nets: [Net] = []
//    var devices: [Device] = []
//
//    func add(_ net: Net) {
//        nets.append(net)
//    }
//    func add(_ device: Device) {
//        devices.append(device)
//    }
//
//    func resolve() {
//        var netsChanged = true
//        var devicesChanged = true
//
//        while netsChanged || devicesChanged == true {
//            print("=== resolve loop ===")
//            netsChanged = false
//            devicesChanged = false
//            for net in nets {
//                let changed = net.update_TrueIfChanged()
//                netsChanged = netsChanged || changed
//                print("N-\(net); changed: \(changed)")
//            }
//            for device in devices {
//                let changed = device.update_TrueIfChanged()
//                devicesChanged = devicesChanged || changed
//                print("D-\(device); changed: \(changed)")
//            }
//            print("nets changed: \(netsChanged)")
//            print("devices changed: \(devicesChanged)")
//        }
//    }
//}
//
//let simulation = Simulation()
//
//// ===== BEGIN CIRCUIT DESCRIPTION =====
//
//
//let masterReset = FixedInput(name: "masterReset", simulation, value: .drivingHigh)
//
//let clock = Clock(name: "clock", simulation)
//let data = FixedInput(name: "data", simulation, value: .drivingHigh)
//let enable = FixedInput(name: "enable", simulation, value: .drivingHigh)
//
//let dff = DFF(name: "dff", simulation)
//
//let meter = Meter(name: "dataOutput", simulation)
//
//_ = Net(name: "clockNet", simulation, pins: clock.output, dff.clock)
//_ = Net(name: "dataNet", simulation, pins: data.output, dff.data)
//_ = Net(name: "enableNet", simulation, pins: enable.output, dff.enable)
//_ = Net(name: "resetNet", simulation, pins: masterReset.output, dff.reset)
//_ = Net(name: "meterNet", simulation, pins: dff.output, meter.input)
//
////let resetOr = OR2(name: "resetOr", simulation)
////
////let sr = SR(name: "sr", simulation)
////
////_ = Net(name: "net4", simulation, pins: masterReset.output, resetOr.i1)
////_ = Net(name: "net1", simulation, pins: clock1.output, sr.set)
////_ = Net(name: "net3", simulation, pins: clock2.output, resetOr.i2)
////_ = Net(name: "net5", simulation, pins: resetOr.output, sr.reset)
////_ = Net(name: "net2", simulation, pins: sr.q)
////
////let edgeInv = INV(name: "eI1", simulation)
////let edgeAnd = AND2(name: "edgeAnd", simulation)
////
////_ = Net(name: "fastLine", simulation, pins: clock1.output, edgeAnd.i1)
////_ = Net(name: "slowLine", simulation, pins: clock1.output, edgeInv.input)
////_ = Net(name: "slowLine2", simulation, pins: edgeInv.output, edgeAnd.i2)
////_ = Net(name: "edgePulse", simulation, pins: edgeAnd.output)
//
//
//
//
//
//
////let clock = Clock(name: "clock", simulation)
////
////let and1 = AND2(name: "and1", simulation)
////let and2 = AND2(name: "and2", simulation)
////let inv = INV(name: "inv", simulation)
////
////let sr = SR(name: "sr", simulation)
////
////_ = Net(name: "net1", simulation, pins: clock.output, and1.i1)
////_ = Net(name: "net2", simulation, pins: sr.q, and1.i2)
////_ = Net(name: "net3", simulation, pins: and1.output, sr.reset)
////
////_ = Net(name: "net4", simulation, pins: sr.q, inv.input)
////_ = Net(name: "net5", simulation, pins: inv.output, and2.i1)
////_ = Net(name: "net6", simulation, pins: clock.output, and2.i2)
//////_ = Net(name: "net7", simulation, pins: and2.output, sr.set)
////
////let meter1 = Meter(name: "meter1", simulation)
////_ = Net(name: "net8", simulation, pins: clock.output, meter1.input)
////let meter2 = Meter(name: "meter2", simulation)
////_ = Net(name: "net9", simulation, pins: sr.q, meter2.input)
//
//// ===== END CIRCUIT DESCRIPTION =====
//
//
//clock.flip()
//simulation.resolve()
//masterReset.output.state = .drivingLow
//simulation.resolve()
//print(meter)
//print("clock: high")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("clock: low")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("clock: high")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("clock: low")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("data: low")
//data.output.state = .drivingLow
//simulation.resolve()
//print(meter)
//print("clock: high")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("clock: low")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("clock: high")
//clock.flip()
//simulation.resolve()
//print(meter)
//print("clock: low")
//clock.flip()
//simulation.resolve()
//print(meter)
