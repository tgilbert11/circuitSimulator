class Nor2: Device {
    let input1 = Pin()
    let input2 = Pin()
    let output = Pin()
    
    init(name: String, input1: Pin?, input2: Pin?, output: Pin?) {
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if output != nil { self.output.connectTo(output!) }

        super.init(name: name)
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input1.connectedTo == .high || input2.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
   
    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 2 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
