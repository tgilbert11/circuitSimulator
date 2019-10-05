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
    
    init(name: String, clock: Pin?, setEnable_: Pin?, reset: Pin?, outputEnable: Pin?, data_: Pin?, internal_: Pin?, output_: Pin?) {
        clockInverter1 = Inverter(name: "\(name)-clockInverter1", input: self.clock, output: nil)
        clockInverter2 = Inverter(name: "\(name)-clockInverter2", input: clockInverter1.output, output: nil)
        clockInverter3 = Inverter(name: "\(name)-clockInverter3", input: clockInverter2.output, output: nil)
        clockNand = Nand2(name: "\(name)-clockNand", input1: self.clock, input2: clockInverter3.output, output: nil)
        setNor = Nor2(name: "\(name)-setNor", input1: self.setEnable_, input2: clockNand.output, output: nil)
        pulseInverter = Inverter(name: "\(name)-pulseInverter", input: setNor.output, output: nil)
        
        cell = FlipFlopCell(name: "\(name)-cell", pulse_: pulseInverter.output, pulse: setNor.output, reset: self.reset, outputEnable: self.outputEnable, data_: self.data_, internal_: self.internal_, output_: self.output_)
        
        if clock != nil { self.clock.connectTo(clock!) }
        if setEnable_ != nil { self.setEnable_.connectTo(setEnable_!) }
        if reset != nil { self.reset.connectTo(reset!) }
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        if data_ != nil { self.data_.connectTo(data_!) }
        if internal_ != nil { self.internal_.connectTo(internal_!) }
        if output_ != nil { self.output_.connectTo(output_!) }
        
        super.init(name: name)
    }
    
    override var description: String { return "\(name): clock: \(clock.connectedTo), setEnable_: \(setEnable_.connectedTo), reset: \(reset.connectedTo), outputEnable: \(outputEnable.connectedTo), data_: \(data_.connectedTo), internal_: \(internal_.connectedTo)), output_: \(output_.connectedTo)" }
    override func status() -> String { return "\(name): \(data_.connectedTo), \(internal_.connectedTo), \(output_.connectedTo)" }
}
