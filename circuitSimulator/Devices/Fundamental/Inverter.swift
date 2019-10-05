class Inverter: Device {
    let input = Pin()
    let output = Pin()
    
    init(name: String, input: Pin?, output: Pin?) {
        if input != nil { self.input.connectTo(input!) }
        if output != nil { self.output.connectTo(output!) }

        super.init(name: name)
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override var description: String { return "\(name): input: \(input.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 1 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
