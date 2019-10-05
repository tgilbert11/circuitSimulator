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
    
    init(name: String, clock: Pin?, setEnable_: Pin?, reset: Pin?, outputEnable: Pin?, data_: [Pin]?, internal_: [Pin]?, output_: [Pin]?) {
        clockInverter1 = Inverter(name: "\(name)-clockInverter1", input: self.clock, output: nil)
        clockInverter2 = Inverter(name: "\(name)-clockInverter2", input: clockInverter1.output, output: nil)
        clockInverter3 = Inverter(name: "\(name)-clockInverter3", input: clockInverter2.output, output: nil)
        clockNand = Nand2(name: "\(name)-clockNand", input1: self.clock, input2: clockInverter3.output, output: nil)
        setNor = Nor2(name: "\(name)-setNor", input1: self.setEnable_, input2: clockNand.output, output: nil)
        pulseInverter = Inverter(name: "\(name)-pulseInverter", input: setNor.output, output: nil)
        
        for cellNumber in 0..<16 {
            self.data_.append(Pin())
            self.output_.append(Pin())
            self.internal_.append(Pin())
            self.cells.append(FlipFlopCell(name: "\(name)-cell\(cellNumber < 10 ? "0" : "")\(cellNumber)", pulse_: pulseInverter.output, pulse: setNor.output, reset: self.reset, outputEnable: self.outputEnable, data_: self.data_[cellNumber], internal_: self.internal_[cellNumber], output_: self.output_[cellNumber]))
        }
        
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
        
        super.init(name: name)
    }

    override var description: String { return "\(name): clock: \(clock.connectedTo), setEnable_: \(setEnable_.connectedTo), reset: \(reset.connectedTo), outputEnable: \(outputEnable.connectedTo), data_: \(valueOfBus(data_)), internal_: \(valueOfBus(internal_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(data_)), \(valueOfBus(internal_)), \(valueOfBus(output_))" }
}
