class Simulation {
    let monitor = Monitor()
    var propogationTime = 0
    var nets: [Net] = []
    var devices: [Device] = []
    
    func add(_ net: Net) {
        nets.append(net)
    }
    func add(_ device: Device) {
        devices.append(device)
    }
    
    func resolve() {
        var netsChanged = true
        var devicesChanged = true
        
        while netsChanged || devicesChanged == true {
            propogationTime = propogationTime + 1
            //print(" ======== resolve loop")
            netsChanged = false
            devicesChanged = false
            for net in nets {
                let changed = net.updateIfNeeded()
                if changed && netsChanged == false {
                    //print("nets changed")
                    netsChanged = true
                }
//                let changed = net.update_TrueIfChanged()
//                netsChanged = netsChanged || changed
                //print("N-\(net); changed: \(changed)")
            }
            for device in devices {
                
                //print("device before change: \(device)")
                let changed = device.updateIfNeeded()
                //print("device after change:  \(device)")
//                if device is Nor2 {
//                    print(Unmanaged.passUnretained((device as! Nor2).output).toOpaque())
//                }
//                if device is Inverter {
//                    print(Unmanaged.passUnretained((device as! Inverter).output).toOpaque())
//                }
                if changed && devicesChanged == false {
                    //print("devices changed")
                    devicesChanged = true
                }
//                let changed = device.update_TrueIfChanged()
//                devicesChanged = devicesChanged || changed
                if device is Register16 || device is FlipFlopCell { print("D-\(device); changed: \(changed)") }
            }
            //print("nets changed: \(netsChanged)")
            //print("devices changed: \(devicesChanged)")
            if netsChanged == false && devicesChanged == false {
                print("===== Resolved To =====")
                for device in devices {
                    if device is Register16 || device is CircuitInput { print(device) }
                }
                print("=====  =====")
            }
            //monitor.printStatus()
        }
        //monitor.printStatus()
    }
}
