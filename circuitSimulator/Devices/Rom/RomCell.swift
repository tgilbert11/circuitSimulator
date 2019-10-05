class RomCell: Device {
    let input = Pin()
    let output = Pin()
    
    let inverter: Inverter?
    
    init(name: String, data: Bool, input: Pin?, output: Pin?) {
        if data {
            self.inverter = Inverter(name: "\(name)-Inv", input: input, output: output)
        }
        else {
            self.inverter = nil
        }
        if input != nil { self.input.connectTo(input!) }
        if output != nil { self.output.connectTo(output!) }
        
        super.init(name: name)
    }

    override var description: String { return "\(name): \(self.inverter != nil ? "1" : "0")" }
    override func status() -> String { return self.inverter != nil ? "1" : "0" }
}
