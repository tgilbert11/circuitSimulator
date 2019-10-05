class CircuitInput: Device {
    let output = Pin()
    override var description: String { return "\(name): output: \(output.state)" }

    init(name: String, startingValue: Driving, output: Pin?) {
        super.init(name: name)
        if output != nil { self.output.connectTo(output!) }
        self.output.state = startingValue
    }

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
        print("\(name) toggled to: \(self.output.state)")
        simulation.resolve()
    }
    func tick() {
        self.toggle()
        self.toggle()
    }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
