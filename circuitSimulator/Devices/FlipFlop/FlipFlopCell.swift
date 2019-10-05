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
