class And16: Device {
    let outputEnable = Pin()
    
    var sideA_: [Pin] = []
    var sideB_: [Pin] = []
    var internal_: [Pin] = []
    var output_: [Pin] = []
    
    var nors: [Nor2] = []
    var inverters: [Inverter] = []
    var nands: [Nand2] = []
    
    init(name: String, outputEnable: Pin?, sideA_: [Pin]?, sideB_: [Pin]?, internal_: [Pin]?, output_: [Pin]?) {
        for _ in 0..<16 {
            self.sideA_.append(Pin())
            self.sideB_.append(Pin())
            self.internal_.append(Pin())
            self.output_.append(Pin())
        }
        for pinNumber in 0..<16 {
            nors.append(Nor2(name: "\(name)-nor\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: self.sideA_[pinNumber], input2: self.sideB_[pinNumber], output: nil))
            inverters.append(Inverter(name: "\(name)-inverter\(pinNumber < 10 ? "0" : "")\(pinNumber)", input: self.nors[pinNumber].output, output: self.internal_[pinNumber]))
            nands.append(Nand2(name: "\(name)-nand\(pinNumber < 10 ? "0" : "")\(pinNumber)", input1: self.outputEnable, input2: self.nors[pinNumber].output, output: self.output_[pinNumber]))
        }
        
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
        
        if outputEnable != nil { self.outputEnable.connectTo(outputEnable!) }

        super.init(name: name)
    }

    override var description: String { return "\(name): outputEnable: \(outputEnable.connectedTo), sideA_: \(valueOfBus(sideA_)), sideB_: \(valueOfBus(sideB_)), output_: \(valueOfBus(output_))" }
    override func status() -> String { return "\(name): \(valueOfBus(internal_)), \(valueOfBus(output_))" }
}
