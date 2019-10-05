//
//  main.swift
//  circuitSimulator
//
//  Created by Taylor Gilbert on 9/8/19.
//  Copyright © 2019 Taylor Gilbert. All rights reserved.
//

import Foundation

enum Driving: String {
    case drivingHigh
    case drivingLow
    case pullingUp
    case pullingDown
    case impeded
}
enum NetValue: String {
    case high
    case low
    case floating
}

class SimulationParticipant: CustomStringConvertible {
    var needsUpdate: Bool = true
    func update_TrueIfChanged() -> Bool { return false }
    func updateIfNeeded() -> Bool { return false }
    var description: String { return "SimulationParticipant" }
    func status() -> String { return "" }
}
class Pin: CustomStringConvertible {
    static var pins: [Pin] = []
    var net: Net?
    var state: Driving = .impeded
    var connectedTo: NetValue = .floating
    var description: String { return "\(self.net == nil ? "*" : "")\(self.state)" }
    
    init() {
        Pin.pins.append(self)
    }
    
    func connectTo(_ pin: Pin) {
        print("proximal pin: \(Unmanaged.passUnretained(self).toOpaque()); distal pin: \(Unmanaged.passUnretained(pin).toOpaque())")
        if let definiteDistalNet = pin.net {
            //print("distal net exists + ", terminator: "")
            if let definiteProximalNet = self.net {
                //print("proximal net exists")
                //kill proximal net, preserve distal net
                //print("net collision")
                for proximalPin in definiteProximalNet.pins {
                    definiteDistalNet.pins.append(proximalPin)
                    proximalPin.net = definiteDistalNet
                }
                self.net = definiteDistalNet
            }
            else {
                //print("proximal net was nil")
                self.net = definiteDistalNet
                definiteDistalNet.append(self)
            }
        }
        else {
            //print("distal net was nil + ", terminator: "")
            if let definiteProximalNet = self.net {
                //print("proximal net exists")
                pin.net = definiteProximalNet
                definiteProximalNet.append(pin)
            }
            else {
                //print("proximal net was nil")
                net = Net(name: "noName", pins: self, pin)
                pin.net = net
            }
        }
    }
}

class Device: SimulationParticipant {
    var name: String
    init(name: String) {
        self.name = name
    }
    override var description: String { return "device" }
    func transistors() -> Int { return 0 }
}
class CircuitInput: Device {
    let output = Pin()
    init(name: String, startingValue: Driving) {
        super.init(name: name)
        output.state = startingValue
        simulation.add(self)
    }
    init(name: String, startingValue: Driving, output: Pin?) {
        if output != nil { self.output.connectTo(output!) }
        super.init(name: name)
        simulation.add(self)
    }
    override var description: String { return "\(name): output: \(output.state)" }
    func toggle() {
        if self.output.net != nil { self.output.net!.needsUpdate = true }
        else { assert(false) }
        switch output.state {
        case .drivingLow:
            output.state = .pullingUp
        case .pullingUp:
            output.state = .drivingLow
        default:
            break
        }
        //paddedPrint("\(name) toggled to: \(output.state). ")
        simulation.resolve()
    }
    func tick() {
        self.toggle()
        self.toggle()
    }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
class Inverter: Device {
    let input = Pin()
    let output = Pin()
    override init(name: String) {
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input: Pin?, output: Pin?) {
        self.init(name: name)
        if input != nil { self.input.connectTo(input!) }
        if output != nil { self.output.connectTo(output!) }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
        //print("arrived at \(name), \(input.net), \(input.net!.updatedThisCycle)")
        //print(Unmanaged.passUnretained((self as! Inverter).output).toOpaque())
        if input.net != nil && input.net!.updatedThisCycle {
            //print("something may have changed")
            let changed = update_TrueIfChanged()
            if changed {
                //print("something changed")
                output.net!.needsUpdate = true
            }
//            else {
//                //print("false alarm")
//            }
            return changed
        }
//        else {
//            print("nothing appears to have changed")
//        }
        return false
    }

    override var description: String { return "\(name): input: \(input.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 1 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}

class Nor2: Device {
    let input1 = Pin()
    let input2 = Pin()
    let output = Pin()
    override init(name: String) {
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input1: Pin?, input2: Pin?, output: Pin?) {
        self.init(name: name)
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if output != nil { self.output.connectTo(output!) }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        //print("starting to update \(name) with inputs: \(input1.connectedTo), \(input2.connectedTo). from output: \(output.state)")
        if input1.connectedTo == .high || input2.connectedTo == .high {
            //print("one of the is high, should now set to driving low")
            output.state = .drivingLow
        }
        else {
            //print("neither was high, so should now set to pulling up")
            output.state = .pullingUp
        }
        //print("finished updating \(name) to new state: \(output.state)")
        //print(Unmanaged.passUnretained(output).toOpaque())
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
        //print("arrived at \(name), \(input1.net), \(input1.net!.updatedThisCycle), \(input2.net), \(input2.net!.updatedThisCycle)")
        if input1.net != nil && input1.net!.updatedThisCycle || input2.net != nil && input2.net!.updatedThisCycle {
            //print("something may have changed")
            let changed = update_TrueIfChanged()
            if changed {
                //print("something changed")
                output.net!.needsUpdate = true
            }
//            else {
//                print("false alarm")
//            }
            return changed
        }
//        else {
//            print("nothing appears to have changed")
//        }
        return false
    }

    
    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 2 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
//class Nor3: Device {
//    let input1 = Pin()
//    let input2 = Pin()
//    let input3 = Pin()
//    let output = Pin()
//    override init(name: String) {
//        super.init(name: name)
//        simulation.add(self)
//    }
//    convenience init(name: String, input1: Pin?, input2: Pin?, input3: Pin?, output: Pin?) {
//        self.init(name: name)
//        if input1 != nil { self.input1.connectTo(input1!) }
//        if input2 != nil { self.input2.connectTo(input2!) }
//        if input3 != nil { self.input3.connectTo(input3!) }
//        if output != nil { self.output.connectTo(output!) }
//    }
//
//    override func update_TrueIfChanged() -> Bool {
//        let startingState = output.state
//        if input1.connectedTo == .high || input2.connectedTo == .high || input3.connectedTo == .high {
//            output.state = .drivingLow
//        }
//        else {
//            output.state = .pullingUp
//        }
//        return output.state != startingState
//    }
//
//    override func updateIfNeeded() -> Bool {
//        if input1.net != nil && input1.net!.updatedThisCycle || input2.net != nil && input2.net!.updatedThisCycle  || input3.net != nil && input3.net!.updatedThisCycle {
//            let changed = update_TrueIfChanged()
//            if changed && output.net != nil {
//                output.net!.needsUpdate = true
//            }
//            return changed
//        }
//        return false
//    }
//
//    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo), \(input3.connectedTo); output: \(output.state)" }
//    override func transistors() -> Int { return 3 }
//    override func status() -> String { return "\(name): \(output.connectedTo)" }
//}
class Nor5: Device {
    let input1 = Pin()
    let input2 = Pin()
    let input3 = Pin()
    let input4 = Pin()
    let input5 = Pin()
    let output = Pin()
    override init(name: String) {
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input1: Pin?, input2: Pin?, input3: Pin?, input4: Pin?, input5: Pin?, output: Pin?) {
        self.init(name: name)
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if input3 != nil { self.input3.connectTo(input3!) }
        if input4 != nil { self.input4.connectTo(input4!) }
        if input5 != nil { self.input5.connectTo(input5!) }
        if output != nil { self.output.connectTo(output!) }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input1.connectedTo == .high || input2.connectedTo == .high || input3.connectedTo == .high || input4.connectedTo == .high || input5.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
        if input1.net != nil && input1.net!.updatedThisCycle || input2.net != nil && input2.net!.updatedThisCycle || input3.net != nil && input3.net!.updatedThisCycle || input4.net != nil && input4.net!.updatedThisCycle || input5.net != nil && input5.net!.updatedThisCycle {
            let changed = update_TrueIfChanged()
            if changed && output.net != nil {
                output.net!.needsUpdate = true
            }
            return changed
        }
        return false
    }
    
    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo), \(input3.connectedTo), \(input4.connectedTo), \(input5.connectedTo); output: \(output.state)" }
    override func transistors() -> Int { return 5 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}

class Nand2: Device {
    let input1 = Pin()
    let input2 = Pin()
    let output = Pin()
    override init(name: String) {
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input1: Pin?, input2: Pin?, output: Pin?) {
        self.init(name: name)
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if output != nil { self.output.connectTo(output!); }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input1.connectedTo == .high && input2.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
        //print("arrived at \(name), \(input1.net), \(input1.net!.updatedThisCycle), \(input2.net), \(input2.net!.updatedThisCycle)")
        if input1.net != nil && input1.net!.updatedThisCycle || input2.net != nil && input2.net!.updatedThisCycle {
            //print("something may have changed")
            let changed = update_TrueIfChanged()
            if changed {
                //print("something changed")
                output.net!.needsUpdate = true
            }
//            else {
//                //print("false alarm")
//            }
            return changed
        }
//        else {
//            //print("nothing appears to have changed")
//        }
        return false
    }

    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 2 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
class Nand5: Device {
    let input1 = Pin()
    let input2 = Pin()
    let input3 = Pin()
    let input4 = Pin()
    let input5 = Pin()
    let output = Pin()
    override init(name: String) {
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input1: Pin?, input2: Pin?, input3: Pin?, input4: Pin?, input5: Pin?, output: Pin?) {
        self.init(name: name)
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if input3 != nil { self.input3.connectTo(input3!) }
        if input4 != nil { self.input4.connectTo(input4!) }
        if input5 != nil { self.input5.connectTo(input5!) }
        if output != nil { self.output.connectTo(output!) }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input1.connectedTo == .high && input2.connectedTo == .high && input3.connectedTo == .high && input4.connectedTo == .high && input5.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
        if input1.net != nil && input1.net!.updatedThisCycle || input2.net != nil && input2.net!.updatedThisCycle || input3.net != nil && input3.net!.updatedThisCycle || input4.net != nil && input4.net!.updatedThisCycle || input5.net != nil && input5.net!.updatedThisCycle {
            let changed = update_TrueIfChanged()
            if changed && output.net != nil {
                output.net!.needsUpdate = true
            }
            return changed
        }
        return false
    }

    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo), \(input3.connectedTo), \(input4.connectedTo), \(input5.connectedTo); output: \(output.state)" }
    override func transistors() -> Int { return 5 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}

class RomCell: Device {
    let input = Pin()
    let output = Pin()
    
    let inverter: Inverter?
    
    init(name: String, data: Bool) {
        if data {
            self.inverter = Inverter(name: "\(name)-Inv", input: input, output: output)
        }
        else {
            self.inverter = nil
        }
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input: Pin?, output: Pin?, data: Bool) {
        self.init(name: name, data: data)
        if input != nil { self.input.connectTo(input!) }
        if output != nil { self.output.connectTo(output!) }
    }
        
    override var description: String { return "\(name): \(self.inverter != nil ? "1" : "0")" }
    override func status() -> String { return self.inverter != nil ? "1" : "0" }
}
class RomColumn: Device {
    let cEnable_ = Pin()
    let output_ = Pin()
    var rowPins: [Pin] = []
    
    let pullup: Inverter
    let nor: Nor2
    let norInverter: Inverter
    
    init(name: String, rows: Int, data: [Bool]) {
        assert(rows == data.count, "RomColumn \(name): mismatched row count and data count")
        pullup = Inverter(name: "\(name)-pullup", input: nil, output: nil)
        nor = Nor2(name: "\(name)-nor", input1: pullup.output, input2: cEnable_, output: nil)
        norInverter = Inverter(name: "\(name)-norInv", input: nor.output, output: output_)
        
        for row in 0..<rows {
            rowPins.append(Pin())
            _ = RomCell(name: "\(name)-cell\(row)", input: rowPins[row], output: pullup.output, data: data[row])
        }
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, rows: Int, rowPins: [Pin?], cEnable_: Pin?, output_: Pin?, data: [Bool]) {
        assert(rowPins.count == rows, "RomColumn \(name): mismatched row count and pin count")
        self.init(name: name, rows: rows, data: data)
        for row in 0..<rows {
            if rowPins[row] != nil { self.rowPins[row].connectTo(rowPins[row]!) }
        }
        if cEnable_ != nil { self.cEnable_.connectTo(cEnable_!) }
        if output_ != nil { self.output_.connectTo(output_!) }
    }
    override var description: String { return "\(name): inputs: \(cEnable_.connectedTo); output: \(output_.state)" }
    override func status() -> String { return "\(name): \(output_.connectedTo)" }
}

class RomPage2x2: Device {
    let r0 = Pin()
    let r1 = Pin()
    let c0_ = Pin()
    let c1_ = Pin()
    let outputEnable = Pin()
    
    let column0: RomColumn
    let column1: RomColumn
        
    let busInverter: Inverter
    let outputNand: Nand2
    
    let output = Pin()
    
    init(name: String, d00: Bool, d01: Bool, d10: Bool, d11: Bool) {
        
        outputNand = Nand2(name: "\(name)-outputNand", input1: nil, input2: outputEnable, output: output)
        
        busInverter = Inverter(name: "\(name)-busInv", input: nil, output: outputNand.input1)
        
        column0 = RomColumn(name: "\(name)-RomCol0", rows: 2, rowPins: [r0, r1], cEnable_: c0_, output_: busInverter.input, data: [d00, d01])
        column1 = RomColumn(name: "\(name)-RomCol1", rows: 2, rowPins: [r0, r1], cEnable_: c1_, output_: busInverter.input, data: [d10, d11])
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, r0: Pin?, r1: Pin?, c0_: Pin?, c1_: Pin?, outputEnable: Pin?, output: Pin?, d00: Bool, d01: Bool, d10: Bool, d11: Bool) {
        self.init(name: name, d00: d00, d01: d01, d10: d10, d11: d11)
        if r0 != nil { self.r0.connectTo(r0!) }
        if r1 != nil { self.r1.connectTo(r1!) }
        if c0_ != nil { self.c0_.connectTo(c0_!) }
        if c1_ != nil { self.c1_.connectTo(c1_!) }
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        if output != nil { self.output.connectTo(output!) }
    }
        
    override var description: String { return "\(name): inputs: \(r0.connectedTo), \(r1.connectedTo), \(c0_.connectedTo), \(c1_.connectedTo), \(r1.connectedTo), \(outputEnable.connectedTo); output: \(output.state)" }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
class RomPage: Device {
    let outputEnable = Pin()
    var rowPins: [Pin] = []
    var columnPins: [Pin] = []
    let output = Pin()
    
    let busInverter: Inverter
    let outputNand: Nand2
    
    init(name: String, rows: Int, rowPins: [Pin?], columns: Int, columnPins: [Pin?], outputEnable: Pin?, output: Pin?, data: [[Bool]]) {
        assert(columns == columnPins.count, "RomPage \(name): columns does not match columns count")
        assert(rows == rowPins.count, "RomPage \(name): rowPins does not match rows count")
        assert(columns == data.count, "RomPage \(name): columns does not match data count")
        
        outputNand = Nand2(name: "\(name)-outputNand", input1: nil, input2: outputEnable, output: output)
        busInverter = Inverter(name: "\(name)-busInv", input: nil, output: outputNand.input1)
        
        for column in 0..<columns {
            _ = RomColumn(name: "\(name)-RomCol\(column)", rows: rows, rowPins: rowPins, cEnable_: columnPins[column], output_: busInverter.input, data: data[column])
        }
        
        super.init(name: name)
        simulation.add(self)
    }
        
    override var description: String { return "\(name): inputs: \(outputEnable.connectedTo); output: \(output.state)" }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}

class Rom4x8: Device {
    let a0 = Pin()
    let a1 = Pin()
    let outputEnable = Pin()
    
    let o0 = Pin()
    let o1 = Pin()
    let o2 = Pin()
    let o3 = Pin()
    let o4 = Pin()
    let o5 = Pin()
    let o6 = Pin()
    let o7 = Pin()

    let a0Inverter: Inverter
    let a1Inverter: Inverter
    
    init(name: String, data: [UInt8]) {
        assert(data.count == 4, "Rom4x8 \(name): incorrect number of bytes")
        
        a0Inverter = Inverter(name: "\(name)-a0Inv", input: a0, output: nil)
        a1Inverter = Inverter(name: "\(name)-a1Inv", input: a1, output: nil)
        
        var test: UInt8 = 0b0000_0001
        _ = RomPage2x2(name: "\(name)-Page0", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o0, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b0000_0010
        _ = RomPage2x2(name: "\(name)-Page1", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o1, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b0000_0100
        _ = RomPage2x2(name: "\(name)-Page2", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o2, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b0000_1000
        _ = RomPage2x2(name: "\(name)-Page3", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o3, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b0001_0000
        _ = RomPage2x2(name: "\(name)-Page4", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o4, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b0010_0000
        _ = RomPage2x2(name: "\(name)-Page5", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o5, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b0100_0000
        _ = RomPage2x2(name: "\(name)-Page6", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o6, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)
        test = 0b1000_0000
        _ = RomPage2x2(name: "\(name)-Page7", r0: a0, r1: a0Inverter.output, c0_: a1Inverter.output, c1_: a1, outputEnable: outputEnable, output: o7, d00: data[0] & test > 0, d01: data[1] & test > 0, d10: data[2] & test > 0, d11: data[3] & test > 0)

        super.init(name: name)
        simulation.add(self)
    }
    
    convenience init(name: String, a0: Pin?,  a1: Pin?,  outputEnable: Pin?,  o0: Pin?,  o1: Pin?,  o2: Pin?,  o3: Pin?,  o4: Pin?,  o5: Pin?,  o6: Pin?,  o7: Pin?, data: [UInt8]) {
        self.init(name: name, data: data)
        if a0 != nil { self.a0.connectTo(a0!) }
        if a1 != nil { self.a1.connectTo(a1!) }
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        if o0 != nil { self.o0.connectTo(o0!) }
        if o1 != nil { self.o1.connectTo(o1!) }
        if o2 != nil { self.o2.connectTo(o2!) }
        if o3 != nil { self.o3.connectTo(o3!) }
        if o4 != nil { self.o4.connectTo(o4!) }
        if o5 != nil { self.o5.connectTo(o5!) }
        if o6 != nil { self.o6.connectTo(o6!) }
        if o7 != nil { self.o7.connectTo(o7!) }
    }
    
    override var description: String { return "\(name): inputs: \(a0.connectedTo), \(a1.connectedTo), \(outputEnable.connectedTo); output: \(o7.state), \(o6.state), \(o5.state), \(o4.state), \(o3.state), \(o2.state), \(o1.state), \(o0.state)" }
    override func status() -> String {
//        print("o7.connectedTo: \(o7.connectedTo)")
//        print("o6.connectedTo: \(o6.connectedTo)")
//        print("o5.connectedTo: \(o5.connectedTo)")
//        print("o4.connectedTo: \(o4.connectedTo)")
//        print("o3.connectedTo: \(o3.connectedTo)")
//        print("o2.connectedTo: \(o2.connectedTo)")
//        print("o1.connectedTo: \(o1.connectedTo)")
//        print("o0.connectedTo: \(o0.connectedTo)")
        let v7: UInt8 = o7.connectedTo == .low ? 0b1000_0000 : 0
        let v6: UInt8 = o6.connectedTo == .low ? 0b0100_0000 : 0
        let v5: UInt8 = o5.connectedTo == .low ? 0b0010_0000 : 0
        let v4: UInt8 = o4.connectedTo == .low ? 0b0001_0000 : 0
        let v3: UInt8 = o3.connectedTo == .low ? 0b0000_1000 : 0
        let v2: UInt8 = o2.connectedTo == .low ? 0b0000_0100 : 0
        let v1: UInt8 = o1.connectedTo == .low ? 0b0000_0010 : 0
        let v0: UInt8 = o0.connectedTo == .low ? 0b0000_0001 : 0
        
        let value = v7 + v6 + v5 + v4 + v3 + v2 + v1 + v0
        
        return "\(name): \(value)"
    }
}
class Rom1024x16: Device {
    let outputEnable = Pin()
    var outputPins: [Pin] = []
    var pages: [RomPage] = []
        
    init(name: String, addressPins: [Pin], outputEnable: Pin, outputPins: [Pin], data: [UInt16]) {
        assert(data.count <= 1024, "Rom1024x16 \(name): more than 1024 data values")
        assert(outputPins.count == 16, "Rom1024x16 \(name): incorrect number of output pins")
        assert(addressPins.count == 10, "Rom1024x16 \(name): incorrect number of address pins")
        
        // create address pins/inverters
        var inverters: [Inverter] = []
        for addressBit in 0..<10 {
            inverters.append(Inverter(name: "\(name)-addPin\(addressBit)Inv", input: addressPins[addressBit], output: nil))
        }
        
        // create address row/column nors (address decoding)
        var rowNors: [Nor5] = []
        var columnNands: [Nand5] = []
        for lineNumber in 0..<32 {
            let rowNor = Nor5(name: "\(name)-rowNor\(lineNumber)")
            let columnNand = Nand5(name: "\(name)-ColumnNand\(lineNumber)")
            
            if lineNumber & 0b00001 > 0 {
                rowNor.input1.connectTo(addressPins[0])
                columnNand.input1.connectTo(inverters[5].output)
            }
            else {
                rowNor.input1.connectTo(inverters[0].output)
                columnNand.input1.connectTo(addressPins[5])
            }
            if lineNumber & 0b00010 > 0 {
                rowNor.input2.connectTo(addressPins[1])
                columnNand.input2.connectTo(inverters[6].output)
            }
            else {
                rowNor.input2.connectTo(inverters[1].output)
                columnNand.input2.connectTo(addressPins[6])
            }
            if lineNumber & 0b00100 > 0 {
                rowNor.input3.connectTo(addressPins[2])
                columnNand.input3.connectTo(inverters[7].output)
            }
            else {
                rowNor.input3.connectTo(inverters[2].output)
                columnNand.input3.connectTo(addressPins[7])
            }
            if lineNumber & 0b01000 > 0 {
                rowNor.input4.connectTo(addressPins[3])
                columnNand.input4.connectTo(inverters[8].output)
            }
            else {
                rowNor.input4.connectTo(inverters[3].output)
                columnNand.input4.connectTo(addressPins[8])
            }
            if lineNumber & 0b10000 > 0 {
                rowNor.input5.connectTo(addressPins[4])
                columnNand.input5.connectTo(inverters[9].output)
            }
            else {
                rowNor.input5.connectTo(inverters[4].output)
                columnNand.input5.connectTo(addressPins[9])
            }
            rowNors.append(rowNor)
            columnNands.append(columnNand)
        }
        
        // create pages/output pins
        for outputBit in 0..<16 {
            self.outputPins.append(Pin())
            
            let bitMask = UInt16(1) << outputBit
            var thisPageData = Array(repeating: Array(repeating: false, count: 32), count: 32)
            for column in 0..<32 {
                for row in 0..<32 {
                    if column*32 + row < data.count {
                        thisPageData[column][row] = data[column*32 + row] & bitMask > 0
                    }
                }
            }
            
            self.pages.append(RomPage(name: "\(name)-Page\(outputBit)", rows: 32, rowPins: rowNors.map({ $0.output }), columns: 32, columnPins: columnNands.map({ $0.output }), outputEnable: outputEnable, output: outputPins[outputBit], data: thisPageData))
            //self.outputPins[outputBit].connectTo(self.pages[outputBit].output)
        }
        
        self.outputEnable.connectTo(outputEnable)
        
        super.init(name: name)
        simulation.add(self)
    }
    
    override var description: String { return "\(name): inputs: \(outputEnable.connectedTo); output: " }
    override func status() -> String {
        let v15: UInt16 = outputPins[15].connectedTo == .low ? 0b1000_0000_0000_0000 : 0
        let v14: UInt16 = outputPins[14].connectedTo == .low ? 0b0100_0000_0000_0000 : 0
        let v13: UInt16 = outputPins[13].connectedTo == .low ? 0b0010_0000_0000_0000 : 0
        let v12: UInt16 = outputPins[12].connectedTo == .low ? 0b0001_0000_0000_0000 : 0
        let v11: UInt16 = outputPins[11].connectedTo == .low ? 0b0000_1000_0000_0000 : 0
        let v10: UInt16 = outputPins[10].connectedTo == .low ? 0b0000_0100_0000_0000 : 0
        let v9: UInt16 = outputPins[9].connectedTo == .low ? 0b0000_0010_0000_0000 : 0
        let v8: UInt16 = outputPins[8].connectedTo == .low ? 0b0000_0001_0000_0000 : 0
        let v7: UInt16 = outputPins[7].connectedTo == .low ? 0b0000_0000_1000_0000 : 0
        let v6: UInt16 = outputPins[6].connectedTo == .low ? 0b0000_0000_0100_0000 : 0
        let v5: UInt16 = outputPins[5].connectedTo == .low ? 0b0000_0000_0010_0000 : 0
        let v4: UInt16 = outputPins[4].connectedTo == .low ? 0b0000_0000_0001_0000 : 0
        let v3: UInt16 = outputPins[3].connectedTo == .low ? 0b0000_0000_0000_1000 : 0
        let v2: UInt16 = outputPins[2].connectedTo == .low ? 0b0000_0000_0000_0100 : 0
        let v1: UInt16 = outputPins[1].connectedTo == .low ? 0b0000_0000_0000_0010 : 0
        let v0: UInt16 = outputPins[0].connectedTo == .low ? 0b0000_0000_0000_0001 : 0
        
        let value = v15 + v14 + v13 + v12 + v11 + v10 + v9 + v8 + v7 + v6 + v5 + v4 + v3 + v2 + v1 + v0
        
        return "\(name): \(value)"
    }
}


class FlipFlopCell: Device {
    let pulse_ = Pin()
    let pulse = Pin()
    let reset = Pin()
    let outputEnable = Pin()
    let data_ = Pin()
    let internal_ = Pin()
    let output_ = Pin()
    
    let dataInverter: Inverter
    let dataNand: Nand2
    let dataNor: Nor2
    let resetNor: Nor2
    let upperNand: Nand2
    let lowerNand: Nand2
    let outputNand: Nand2
    
    override init(name: String) {
        dataInverter = Inverter(name: "\(name)-dataInverter", input: data_, output: nil)
        dataNand = Nand2(name: "\(name)-dataNand", input1: pulse, input2: dataInverter.output, output: nil)
        dataNor = Nor2(name: "\(name)-dataNor", input1: dataInverter.output, input2: pulse_, output: nil)
        resetNor = Nor2(name: "\(name)-resetNor", input1: reset, input2: dataNor.output, output: nil)
        upperNand = Nand2(name: "\(name)-upperNand", input1: dataNand.output, input2: nil, output: nil)
        lowerNand = Nand2(name: "\(name)-lowerNand", input1: upperNand.output, input2: resetNor.output, output: upperNand.input2)
        outputNand = Nand2(name: "\(name)-outputNand", input1: outputEnable, input2: upperNand.output, output: output_)
        lowerNand.output.connectTo(internal_)
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, pulse_: Pin?, pulse: Pin?, reset: Pin?, outputEnable: Pin?, data_: Pin?, internal_: Pin?, output_: Pin?) {
        self.init(name: name)
        if pulse_ != nil { self.pulse_.connectTo(pulse_!) }
        if pulse != nil { self.pulse.connectTo(pulse!) }
        if reset != nil { self.reset.connectTo(reset!) }
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        if data_ != nil { self.data_.connectTo(data_!) }
        if internal_ != nil { self.internal_.connectTo(internal_!) }
        if output_ != nil { self.output_.connectTo(output_!) }
    }
    override var description: String { return "\(name): pulse_: \(pulse_.connectedTo), pulse: \(pulse.connectedTo), reset: \(reset.connectedTo), outputEnable:\(outputEnable.connectedTo), data_: \(data_.connectedTo), internal_: \(lowerNand.output.state), outputNand.output: \(outputNand.output.state)" }
    override func status() -> String { return "\(name): \(output_.connectedTo)" }
}

class Register1: Device {
    let clock = Pin()
    let setEnable_ = Pin()
    let reset = Pin()
    let outputEnable = Pin()
    let data_ = Pin()
    let output_ = Pin()
    let internal_ = Pin()
    
    let clockInverter1: Inverter
    let clockInverter2: Inverter
    let clockInverter3: Inverter
    let clockNand: Nand2
    let setNor: Nor2
    let pulseInverter: Inverter
    
    let cell: FlipFlopCell
    
    override init(name: String) {
        clockInverter1 = Inverter(name: "\(name)-clockInverter1", input: clock, output: nil)
        clockInverter2 = Inverter(name: "\(name)-clockInverter2", input: clockInverter1.output, output: nil)
        clockInverter3 = Inverter(name: "\(name)-clockInverter3", input: clockInverter2.output, output: nil)
        clockNand = Nand2(name: "\(name)-clockNand", input1: clock, input2: clockInverter3.output, output: nil)
        setNor = Nor2(name: "\(name)-setNor", input1: setEnable_, input2: clockNand.output, output: nil)
        pulseInverter = Inverter(name: "\(name)-pulseInverter", input: setNor.output, output: nil)
        
        cell = FlipFlopCell(name: "\(name)-cell", pulse_: pulseInverter.output, pulse: setNor.output, reset: reset, outputEnable: outputEnable, data_: data_, internal_: internal_, output_: output_)
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, clock: Pin?, setEnable_: Pin?, reset: Pin?, outputEnable: Pin?, data_: Pin?, internal_: Pin?, output_: Pin?) {
        self.init(name: name)
        if clock != nil { self.clock.connectTo(clock!) }
        if setEnable_ != nil { self.setEnable_.connectTo(setEnable_!) }
        if reset != nil { self.reset.connectTo(reset!) }
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        if data_ != nil { self.data_.connectTo(data_!) }
        if internal_ != nil { self.internal_.connectTo(internal_!) }
        if output_ != nil { self.output_.connectTo(output_!) }
    }
    override var description: String { return "\(name): clock: \(clock.connectedTo), setEnable_: \(setEnable_.connectedTo), reset: \(reset.connectedTo), outputEnable: \(outputEnable.connectedTo), data_: \(data_.connectedTo), internal_: \(internal_.connectedTo)), output_: \(output_.connectedTo)" }
    override func status() -> String { return "\(name): \(data_.connectedTo), \(internal_.connectedTo), \(output_.connectedTo)" }
}
class Register16: Device {
    let clock = Pin()
    let setEnable_ = Pin()
    let reset = Pin()
    let outputEnable = Pin()
    
    var data_: [Pin] = []
    var internal_: [Pin] = []
    var output_: [Pin] = []
    
    let clockInverter1: Inverter
    let clockInverter2: Inverter
    let clockInverter3: Inverter
    let clockNand: Nand2
    let setNor: Nor2
    let pulseInverter: Inverter
    
    var cells: [FlipFlopCell] = []
    
    override init(name: String) {
        clockInverter1 = Inverter(name: "\(name)-clockInverter1", input: clock, output: nil)
        clockInverter2 = Inverter(name: "\(name)-clockInverter2", input: clockInverter1.output, output: nil)
        clockInverter3 = Inverter(name: "\(name)-clockInverter3", input: clockInverter2.output, output: nil)
        clockNand = Nand2(name: "\(name)-clockNand", input1: clock, input2: clockInverter3.output, output: nil)
        setNor = Nor2(name: "\(name)-setNor", input1: setEnable_, input2: clockNand.output, output: nil)
        pulseInverter = Inverter(name: "\(name)-pulseInverter", input: setNor.output, output: nil)
        
        for cellNumber in 0..<16 {
            data_.append(Pin())
            output_.append(Pin())
            internal_.append(Pin())
            cells.append(FlipFlopCell(name: "\(name)-cell\(cellNumber < 10 ? "0" : "")\(cellNumber)", pulse_: pulseInverter.output, pulse: setNor.output, reset: reset, outputEnable: outputEnable, data_: data_[cellNumber], internal_: internal_[cellNumber], output_: output_[cellNumber]))
        }
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, clock: Pin?, setEnable_: Pin?, reset: Pin?, outputEnable: Pin?, data_: [Pin]?, internal_: [Pin]?, output_: [Pin]?) {
        self.init(name: name)
        if clock != nil { self.clock.connectTo(clock!) }
        if setEnable_ != nil { self.setEnable_.connectTo(setEnable_!) }
        if reset != nil { self.reset.connectTo(reset!) }
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        
        if let definiteData_ = data_ {
            assert(definiteData_.count == 16, "\(name).data_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.data_[pinNumber].connectTo(definiteData_[pinNumber])
            }
        }
        if let definiteInternal_ = internal_ {
            assert(definiteInternal_.count == 16, "\(name).Internal_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.internal_[pinNumber].connectTo(definiteInternal_[pinNumber])
            }
        }
        if let definiteOutput_ = output_ {
            assert(definiteOutput_.count == 16, "\(name).output_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.output_[pinNumber].connectTo(definiteOutput_[pinNumber])
            }
        }
    }
    override var description: String { return "\(name): clock: \(clock.connectedTo), setEnable_: \(setEnable_.connectedTo), reset: \(reset.connectedTo), outputEnable: \(outputEnable.connectedTo), data_: \(valueOfBus(data_)), internal_: \(valueOfBus(internal_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(data_)), \(valueOfBus(internal_)), \(valueOfBus(output_))" }
}
class BusDriver16: Device {
    let outputEnable = Pin()
    
    var data_: [Pin] = []
    var output_: [Pin] = []
    
    var inverters: [Inverter] = []
    var nands: [Nand2] = []
    
    override init(name: String) {
        for pinNumber in 0..<16 {
            data_.append(Pin())
            output_.append(Pin())
            
            inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: data_[pinNumber], output: nil))
            nands.append(Nand2(name: "\(name)-nand\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: outputEnable, input2: inverters[pinNumber].output, output: output_[pinNumber]))
        }
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, outputEnable: Pin?, data_: [Pin]?, output_: [Pin]?) {
        self.init(name: name)
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        
        if let definiteData_ = data_ {
            assert(definiteData_.count == 16, "\(name).data_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.data_[pinNumber].connectTo(definiteData_[pinNumber])
            }
        }
        if let definiteOutput_ = output_ {
            assert(definiteOutput_.count == 16, "\(name).output_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.output_[pinNumber].connectTo(definiteOutput_[pinNumber])
            }
        }
    }
    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), data_: \(valueOfBus(data_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(data_)), \(valueOfBus(output_))" }
}
class FixedBusDriver16: Device {
    let outputEnable = Pin()
    
    var output_: [Pin] = []
    
    var inverters: [Inverter] = []
    
    init(name: String, value: UInt16) {
        super.init(name: name)
        for pinNumber in 0..<16 {
            output_.append(Pin())
            
            if value & (1 << pinNumber) > 0 {
                inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: outputEnable, output: output_[pinNumber]))
            }
        }
        
        simulation.add(self)
    }
    convenience init(name: String, outputEnable: Pin?, value: UInt16, output_: [Pin]?) {
        self.init(name: name, value: value)
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        
        if let definiteOutput_ = output_ {
            assert(definiteOutput_.count == 16, "\(name).output_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.output_[pinNumber].connectTo(definiteOutput_[pinNumber])
            }
        }
    }
    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(output_))" }
}
class ShiftLeft16: Device {
    let outputEnable = Pin()
    
    var data_: [Pin] = []
    var output_: [Pin] = []
    
    var inverters: [Inverter] = []
    var nands: [Nand2] = []
    
    override init(name: String) {
        for _ in 0..<16 {
            data_.append(Pin())
            output_.append(Pin())
        }
        for pinNumber in 0..<16 {
            inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: pinNumber > 0 ? data_[pinNumber-1] : nil, output: nil))
            nands.append(Nand2(name: "\(name)-nand\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: outputEnable, input2: pinNumber > 0 ? inverters[pinNumber].output : nil, output: output_[pinNumber]))
        }
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, outputEnable: Pin?, data_: [Pin]?, output_: [Pin]?) {
        self.init(name: name)
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        
        if let definiteData_ = data_ {
            assert(definiteData_.count == 16, "\(name).data_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.data_[pinNumber].connectTo(definiteData_[pinNumber])
            }
        }
        if let definiteOutput_ = output_ {
            assert(definiteOutput_.count == 16, "\(name).output_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.output_[pinNumber].connectTo(definiteOutput_[pinNumber])
            }
        }
    }
    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), data_: \(valueOfBus(data_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(data_)), \(valueOfBus(output_))" }
}
class ALUAnd: Device {
    let outputEnable = Pin()
    
    var sideA_: [Pin] = []
    var sideB_: [Pin] = []
    var internal_: [Pin] = []
    var output_: [Pin] = []
    
    var nors: [Nor2] = []
    var inverters: [Inverter] = []
    var nands: [Nand2] = []
    
    override init(name: String) {
        for _ in 0..<16 {
            sideA_.append(Pin())
            sideB_.append(Pin())
            internal_.append(Pin())
            output_.append(Pin())
        }
        for pinNumber in 0..<16 {
            nors.append(Nor2(name: "\(name)-nor\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: sideA_[pinNumber], input2: sideB_[pinNumber], output: nil))
            inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: nors[pinNumber].output, output: internal_[pinNumber]))
            nands.append(Nand2(name: "\(name)-nand\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: outputEnable, input2: nors[pinNumber].output, output: output_[pinNumber]))
        }
        
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, outputEnable: Pin?, sideA_: [Pin]?, sideB_: [Pin]?, internal_: [Pin]?, output_: [Pin]?) {
        self.init(name: name)
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        
        if let definiteA_ = sideA_ {
            assert(definiteA_.count == 16, "\(name).sideA_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.sideA_[pinNumber].connectTo(definiteA_[pinNumber])
            }
        }
        if let definiteB_ = sideB_ {
            assert(definiteB_.count == 16, "\(name).sideB_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.sideB_[pinNumber].connectTo(definiteB_[pinNumber])
            }
        }
        if let definiteInternal_ = internal_ {
            assert(definiteInternal_.count == 16, "\(name).internal_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.internal_[pinNumber].connectTo(definiteInternal_[pinNumber])
            }
        }
        if let definiteOutput_ = output_ {
            assert(definiteOutput_.count == 16, "\(name).output_ has incorrect number of Pins")
            for pinNumber in 0..<16 {
                self.output_[pinNumber].connectTo(definiteOutput_[pinNumber])
            }
        }
    }
    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), sideA_: \(valueOfBus(sideA_)), sideB_: \(valueOfBus(sideB_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(internal_)), \(valueOfBus(output_))" }
}

class Simulation {
    let monitor = Monitor()
    var propogationTime = 0
    var nets: [Net] = []
    var devices: [Device] = []
    
    func add(_ net: Net) {
        nets.append(net)
    }
    func add(_ device: Device) {
        devices.append(device)
    }
    
    func resolve() {
        var netsChanged = true
        var devicesChanged = true
        
        while netsChanged || devicesChanged == true {
            propogationTime = propogationTime + 1
            //print(" ======== resolve loop")
            netsChanged = false
            devicesChanged = false
            for net in nets {
                let changed = net.updateIfNeeded()
                if changed && netsChanged == false {
                    //print("nets changed")
                    netsChanged = true
                }
//                let changed = net.update_TrueIfChanged()
//                netsChanged = netsChanged || changed
                //print("N-\(net); changed: \(changed)")
            }
            for device in devices {
                
                //print("device before change: \(device)")
                let changed = device.updateIfNeeded()
                //print("device after change:  \(device)")
//                if device is Nor2 {
//                    print(Unmanaged.passUnretained((device as! Nor2).output).toOpaque())
//                }
//                if device is Inverter {
//                    print(Unmanaged.passUnretained((device as! Inverter).output).toOpaque())
//                }
                if changed && devicesChanged == false {
                    //print("devices changed")
                    devicesChanged = true
                }
//                let changed = device.update_TrueIfChanged()
//                devicesChanged = devicesChanged || changed
                if device is Register16 || device is FlipFlopCell { print("D-\(device); changed: \(changed)") }
            }
            //print("nets changed: \(netsChanged)")
            //print("devices changed: \(devicesChanged)")
            if netsChanged == false && devicesChanged == false {
                print("===== Resolved To =====")
                for device in devices {
                    if device is Register16 || device is CircuitInput { print(device) }
                }
                print("=====  =====")
            }
            //monitor.printStatus()
        }
        //monitor.printStatus()
    }
}
class Monitor {
    var participants: [SimulationParticipant] = []
    func printStatus() {
        if participants.count == 0 {
            print("nothing being monitored.")
        }
        else {
            print("t = \(simulation.propogationTime): \(participants[0].status())\(participants.dropFirst().reduce("", { $0 + "; " + $1.status() }))")
        }
    }
}

func valueOfBus(_ bus: [Pin]) -> UInt16 {
    assert(bus.count == 16, "value of bus has incorrect number of pins")
    var value: UInt16 = 0
    for pinNumber in 0..<16 {
        if bus[pinNumber].connectedTo == .low {
            value = value + (UInt16(1) << pinNumber)
        }
    }
    return value
}
func setValueToBus(value: UInt16, bus: [Pin]) {
    assert(bus.count == 16, "set value to bus has incorrect number of pins")
    //paddedPrint("bus value set to: \(value)")
    for pinNumber in 0..<16 {
        if value & (UInt16(1) << pinNumber) > 0 {
            bus[pinNumber].state = .drivingLow
        }
        else {
            bus[pinNumber].state = .pullingUp
        }
        bus[pinNumber].net!.needsUpdate = true
    }
    simulation.resolve()
}
func busWithValue(value: UInt16) -> [Pin] {
    var bus: [Pin] = []
    for pinNumber in 0..<16 { bus.append(Pin()); bus[pinNumber].state = .pullingUp }
    return bus
}

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
