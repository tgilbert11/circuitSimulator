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
