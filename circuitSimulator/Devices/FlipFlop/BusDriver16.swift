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
