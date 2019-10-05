enum NetValue: String {
    case high
    case low
    case floating
}

class Net: SimulationParticipant {
    //var updatedThisCycle = false
    let name: String
    var pins: [Pin]
    var storedValue: NetValue = .floating
    //var output: NetValue = .floating
    
    var output: NetValue { return pins.map({ $0.state }).reduce(.impeded, *).netValue }
    
    init(name: String, pins: Pin...) {
        self.name = name
        self.pins = pins
        super.init()
        simulation.add(self)
    }
    
    override func updateIfNeeded() -> Bool {
        update_TrueIfChanged()
    }
    
    override func update_TrueIfChanged() -> Bool {
        let previousValue = storedValue
        storedValue = output
        return storedValue != previousValue
    }
    
    override var description: String { return "\(self.name): \(pins.count > 0 ? pins[0].description + pins.dropFirst().map({", " + $0.description}).reduce("", {$0 + $1}) : "no pins"): \(self.output)" }
    
//    override func updateIfNeeded() -> Bool {
//        updatedThisCycle = false
//        if needsUpdate {
//            updatedThisCycle = update_TrueIfChanged()
//            needsUpdate = false
//        }
//        return updatedThisCycle
//    }
    
//    override func update_TrueIfChanged() -> Bool {
//        let startingOutput = output
//
//        let drivingHigh = self.pins.contains(where: { $0.state == .drivingHigh })
//        let drivingLow = self.pins.contains(where: { $0.state == .drivingLow })
//        let pullingUp = self.pins.contains(where: { $0.state == .pullingUp })
//        let pullingDown = self.pins.contains(where: { $0.state == .pullingDown })
//        // assumes this covers all cases excpet impeded
//
//        assert( !((drivingHigh == true) && (drivingLow == true)) , "\(self.name) driven high and low")
//        assert( !(pullingUp == true && pullingDown == true) , "\(self.name) pulled high and low")
//
//        if drivingHigh == true {
//            output = .high
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else if drivingLow == true {
//            output = .low
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else if pullingUp == true {
//            output = .high
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else if pullingDown == true {
//            output = .low
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//        else {
//            output = .floating
//            for pin in pins {
//                pin.connectedTo = output
//            }
//        }
//
//        let finalOutput = output
//
//        return finalOutput != startingOutput
//    }

    func append(_ pin: Pin) {
        self.pins.append(pin)
    }
    override func status() -> String {
        return "\(name): \(self.output)"
    }
}
