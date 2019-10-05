class Inverter: Device {
    let input = Pin()
    let output = Pin()
    
    init(name: String, input: Pin?, output: Pin?) {
        super.init(name: name)
        if input != nil { self.input.connectTo(input!) }
        if output != nil { self.output.connectTo(output!) }
    }
    
    override func update_TrueIfChanged() -> Bool {
        let startingState = output.state
        if input.connectedTo == .high {
            output.state = .drivingLow
        }
        else {
            output.state = .pullingUp
        }
        return output.state != startingState
    }
    
    override func updateIfNeeded() -> Bool {
//        //print("arrived at \(name), \(input.net), \(input.net!.updatedThisCycle)")
//        //print(Unmanaged.passUnretained((self as! Inverter).output).toOpaque())
//        if input.net != nil && input.net!.updatedThisCycle {
//            //print("something may have changed")
//            let changed = update_TrueIfChanged()
//            if changed {
//                //print("something changed")
//                output.net!.needsUpdate = true
//            }
////            else {
////                //print("false alarm")
////            }
//            return changed
//        }
////        else {
////            print("nothing appears to have changed")
////        }
        return update_TrueIfChanged()
    }

    override var description: String { return "\(name): input: \(input.connectedTo); output: \(output)" }
    override func transistors() -> Int { return 1 }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
