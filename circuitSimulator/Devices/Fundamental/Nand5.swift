class Nand5: Device {
    let input1 = Pin()
    let input2 = Pin()
    let input3 = Pin()
    let input4 = Pin()
    let input5 = Pin()
    let output = Pin()
    
    init(name: String, input1: Pin?, input2: Pin?, input3: Pin?, input4: Pin?, input5: Pin?, output: Pin?) {
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if input3 != nil { self.input3.connectTo(input3!) }
        if input4 != nil { self.input4.connectTo(input4!) }
        if input5 != nil { self.input5.connectTo(input5!) }
        if output != nil { self.output.connectTo(output!) }

        super.init(name: name)
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input1.connectedTo == .high && input2.connectedTo == .high && input3.connectedTo == .high && input4.connectedTo == .high && input5.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }

    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo), \(input3.connectedTo), \(input4.connectedTo), \(input5.connectedTo); output: \(output.state)" }
    override func transistors() -> Int { return 5 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
