enum NetValue: String {
    case high
    case low
    case floating
}

class Net: SimulationParticipant {
    let name: String
    var pins: [Pin]
    var storedValue: NetValue = .floating
    
    var output: NetValue { return pins.map({ $0.state }).reduce(.impeded, *).netValue }
    
    init(name: String, pins: Pin...) {
        self.name = name
        self.pins = pins
        
        super.init()
        
        simulation.add(self)
    }
    
    func update() {
        storedValue = output
    }
    
    override var description: String { return "\(self.name): \(pins.count > 0 ? pins[0].description + pins.dropFirst().map({", " + $0.description}).reduce("", {$0 + $1}) : "no pins"): \(self.output)" }

    func append(_ pin: Pin) {
        self.pins.append(pin)
    }
    override func status() -> String {
        return "\(name): \(self.output)"
    }
}
