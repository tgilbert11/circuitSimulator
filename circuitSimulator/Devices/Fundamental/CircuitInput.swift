class CircuitInput: Device {
    let output = Pin()
    init(name: String, startingValue: Driving) {
        super.init(name: name)
        output.state = startingValue
        simulation.add(self)
    }
    init(name: String, startingValue: Driving, output: Pin?) {
        if output != nil { self.output.connectTo(output!) }
        super.init(name: name)
        simulation.add(self)
    }
    override var description: String { return "\(name): output: \(output.state)" }
    func toggle() {
        if self.output.net != nil { self.output.net!.needsUpdate = true }
        else { assert(false) }
        switch output.state {
        case .drivingLow:
            output.state = .pullingUp
        case .pullingUp:
            output.state = .drivingLow
        default:
            break
        }
        //paddedPrint("\(name) toggled to: \(output.state). ")
        simulation.resolve()
    }
    func tick() {
        self.toggle()
        self.toggle()
    }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
