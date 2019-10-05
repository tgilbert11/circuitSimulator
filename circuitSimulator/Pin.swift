class Pin: CustomStringConvertible {
    static var pins: [Pin] = []
    var net: Net?
    var state: Driving = .impeded
    var connectedTo: NetValue = .floating
    var description: String { return "\(self.net == nil ? "*" : "")\(self.state)" }
    
    init() {
        Pin.pins.append(self)
    }
    
    func connectTo(_ pin: Pin) {
        print("proximal pin: \(Unmanaged.passUnretained(self).toOpaque()); distal pin: \(Unmanaged.passUnretained(pin).toOpaque())")
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
