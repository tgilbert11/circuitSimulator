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
