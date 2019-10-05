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
