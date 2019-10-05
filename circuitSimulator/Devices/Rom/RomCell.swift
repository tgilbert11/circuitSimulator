class RomCell: Device {
    let input = Pin()
    let output = Pin()
    
    let inverter: Inverter?
    
    init(name: String, data: Bool) {
        if data {
            self.inverter = Inverter(name: "\(name)-Inv", input: input, output: output)
        }
        else {
            self.inverter = nil
        }
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input: Pin?, output: Pin?, data: Bool) {
        self.init(name: name, data: data)
        if input != nil { self.input.connectTo(input!) }
        if output != nil { self.output.connectTo(output!) }
    }
        
    override var description: String { return "\(name): \(self.inverter != nil ? "1" : "0")" }
    override func status() -> String { return self.inverter != nil ? "1" : "0" }
}
