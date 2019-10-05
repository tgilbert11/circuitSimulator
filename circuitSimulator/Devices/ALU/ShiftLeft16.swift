class ShiftLeft16: Device {
    let outputEnable = Pin()
    
    var data_: [Pin] = []
    var output_: [Pin] = []
    
    var inverters: [Inverter] = []
    var nands: [Nand2] = []
    
    init(name: String, outputEnable: Pin?, data_: [Pin]?, output_: [Pin]?) {
        for _ in 0..<16 {
            self.data_.append(Pin())
            self.output_.append(Pin())
        }
        for pinNumber in 0..<16 {
            inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: pinNumber > 0 ? self.data_[pinNumber-1] : nil, output: nil))
            nands.append(Nand2(name: "\(name)-nand\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: self.outputEnable, input2: pinNumber > 0 ? self.inverters[pinNumber].output : nil, output: self.output_[pinNumber]))
        }
        
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
        
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }
        
        super.init(name: name)
    }

    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), data_: \(valueOfBus(data_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(data_)), \(valueOfBus(output_))" }
}
