class CircuitInput: Device {
    let output = Pin()
    override var description: String { return "\(name): output: \(output.state)" }

    init(name: String, startingValue: Driving, output: Pin?) {
        self.output.state = startingValue
        
        if output != nil { self.output.connectTo(output!) }
        
        super.init(name: name)
    }

    func toggle() {
        
        switch output.state {
            case .drivingLow:
                output.state = .pullingUp
            case .drivingHigh:
                output.state = .pullingDown
            case .pullingUp:
                output.state = .drivingLow
            case .pullingDown:
                output.state = .drivingHigh
            case .impeded, .shorted:
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
