class Simulation {
    private let monitor = Monitor()
    var propogationTime = 0
    var nets: [Net] = []
    var devices: [Device] = []
    
    func monitor(_ participant: SimulationParticipant) {
        self.monitor.participants.append(participant)
    }
    
    func add(_ net: Net) {
        nets.append(net)
    }
    func add(_ device: Device) {
        devices.append(device)
    }
    
    func resolve() {
        var devicesChanged = false
        
        repeat {
            propogationTime = propogationTime + 1
            
            nets.forEach({ $0.update() })
            devicesChanged = devices.reduce(false, { $0 || $1.updateIfNeeded() })
            
        } while devicesChanged == true
        
        print("t = \(propogationTime):")
        devices.forEach({ if $0 is CircuitOutput {print($0.status()) } })
    }
}
