enum Driving: String {
    case drivingHigh
    case drivingLow
    case pullingUp
    case pullingDown
    case impeded
    case shorted
    
    var netValue: NetValue {
        switch self {
            case .drivingHigh, .pullingUp: return .high
            case .drivingLow, .pullingDown: return .low
            default: return .floating
        }
    }
    
    static func * (lhs: Driving, rhs: Driving) -> Driving {
        switch lhs {
            case .drivingHigh:
                switch rhs {
                    case .drivingHigh: return drivingHigh
                    case .drivingLow: return shorted
                    case .pullingUp: return drivingHigh
                    case .pullingDown: return drivingHigh
                    case .impeded: return drivingHigh
                    case .shorted: return shorted
            }
            case .drivingLow:
                switch rhs {
                    case .drivingHigh: return shorted
                    case .drivingLow: return drivingLow
                    case .pullingUp: return drivingLow
                    case .pullingDown: return drivingLow
                    case .impeded: return drivingLow
                    case .shorted: return shorted
            }
            case .pullingUp:
                switch rhs {
                    case .drivingHigh: return drivingHigh
                    case .drivingLow: return drivingLow
                    case .pullingUp: return pullingUp
                    case .pullingDown: return shorted
                    case .impeded: return pullingUp
                    case .shorted: return shorted
            }
            case .pullingDown:
                switch rhs {
                    case .drivingHigh: return drivingHigh
                    case .drivingLow: return drivingLow
                    case .pullingUp: return shorted
                    case .pullingDown: return pullingDown
                    case .impeded: return pullingDown
                    case .shorted: return shorted
            }
            case .impeded:
                switch rhs {
                    case .drivingHigh: return drivingHigh
                    case .drivingLow: return drivingLow
                    case .pullingUp: return pullingUp
                    case .pullingDown: return pullingDown
                    case .impeded: return impeded
                    case .shorted: return shorted
            }
            case .shorted:
                return shorted
        }
    }
}


class Pin: CustomStringConvertible {
    static var pins: [Pin] = [] // for debugging only
    var net: Net?
    var state: Driving = .impeded
    var connectedTo: NetValue { return net?.storedValue ?? .floating }
    var description: String { return "\(self.net == nil ? "*" : "")\(self.state)" }
    
    init() {
        Pin.pins.append(self)
    }
    
    func connectTo(_ pin: Pin) {
        //print("proximal pin: \(Unmanaged.passUnretained(self).toOpaque()); distal pin: \(Unmanaged.passUnretained(pin).toOpaque())")
        if let definiteDistalNet = pin.net {
            //print("distal net exists + ", terminator: "")
            if let definiteProximalNet = self.net {
                //print("proximal net exists")
                //kill proximal net, preserve distal net
                //print("net collision")
                for proximalPin in definiteProximalNet.pins {
                    definiteDistalNet.pins.append(proximalPin)
                    proximalPin.net = definiteDistalNet
                }
                self.net = definiteDistalNet
            }
            else {
                //print("proximal net was nil")
                self.net = definiteDistalNet
                definiteDistalNet.append(self)
            }
        }
        else {
            //print("distal net was nil + ", terminator: "")
            if let definiteProximalNet = self.net {
                //print("proximal net exists")
                pin.net = definiteProximalNet
                definiteProximalNet.append(pin)
            }
            else {
                //print("proximal net was nil")
                net = Net(name: "noName", pins: self, pin)
                pin.net = net
            }
        }
    }
}
