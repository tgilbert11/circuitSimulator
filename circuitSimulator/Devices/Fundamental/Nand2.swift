class Nand2: Device {
    let input1 = Pin()
    let input2 = Pin()
    let output = Pin()
    override init(name: String) {
        super.init(name: name)
        simulation.add(self)
    }
    convenience init(name: String, input1: Pin?, input2: Pin?, output: Pin?) {
        self.init(name: name)
        if input1 != nil { self.input1.connectTo(input1!) }
        if input2 != nil { self.input2.connectTo(input2!) }
        if output != nil { self.output.connectTo(output!); }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input1.connectedTo == .high && input2.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
        //print("arrived at \(name), \(input1.net), \(input1.net!.updatedThisCycle), \(input2.net), \(input2.net!.updatedThisCycle)")
        if input1.net != nil && input1.net!.updatedThisCycle || input2.net != nil && input2.net!.updatedThisCycle {
            //print("something may have changed")
            let changed = update_TrueIfChanged()
            if changed {
                //print("something changed")
                output.net!.needsUpdate = true
            }
//            else {
//                //print("false alarm")
//            }
            return changed
        }
//        else {
//            //print("nothing appears to have changed")
//        }
        return false
    }

    override var description: String { return "\(name): inputs: \(input1.connectedTo), \(input2.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 2 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
