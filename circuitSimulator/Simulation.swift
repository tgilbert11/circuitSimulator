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
        var devicesChanged = true
        
        while devicesChanged == true {
            propogationTime = propogationTime + 1
            //print(" ======== resolve loop")
            print("t = \(propogationTime):")
            devicesChanged = false
            for net in nets {
                let changed = net.updateIfNeeded()
                //if changed { print("      \(net.name) changed") }
//                if changed && netsChanged == false {
//                    //print("nets changed")
//                    netsChanged = true
//                }
//                let changed = net.update_TrueIfChanged()
//                netsChanged = netsChanged || changed
                //print("N-\(net); changed: \(changed)")
            }
            for device in devices {
                
                //print("device before change: \(device)")
                let changed = device.updateIfNeeded()
                //if changed { print("      \(device.name) changed") }
                devicesChanged = devicesChanged || changed
                //print("device after change:  \(device)")
//                if device is Nor2 {
//                    print(Unmanaged.passUnretained((device as! Nor2).output).toOpaque())
//                }
//                if device is Inverter {
//                    print(Unmanaged.passUnretained((device as! Inverter).output).toOpaque())
//                }
//                if changed && devicesChanged == false {
//                    //print("devices changed")
//                    devicesChanged = true
//                }
//                let changed = device.update_TrueIfChanged()
//                devicesChanged = devicesChanged || changed
//                if device is Register16 || device is FlipFlopCell { print("D-\(device); changed: \(changed)") }
            }
            //print("nets changed: \(netsChanged)")
            //print("devices changed: \(devicesChanged)")
            
            
//            for net in nets {
//                print("   \(net)")
//            }
//            for device in devices {
//                print("   \(device)")
//            }
            for device in devices {
                if device is CircuitOutput { print("   \(device.status())") }
            }
            
            
//            if devicesChanged == false {
//                print("===== Resolved To =====")
//                print("=====  =====")
//            }
        }
    }
}
