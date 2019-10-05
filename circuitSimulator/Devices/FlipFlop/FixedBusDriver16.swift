class FixedBusDriver16: Device {
    let outputEnable = Pin()
    
    var output_: [Pin] = []
    
    var inverters: [Inverter] = []
    
    init(name: String, value: UInt16, outputEnable: Pin?, output_: [Pin]?) {
        
        for pinNumber in 0..<16 {
            self.output_.append(Pin())
            
            if value & (1 << pinNumber) > 0 {
                inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: self.outputEnable, output: self.output_[pinNumber]))
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

    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(output_))" }
}
