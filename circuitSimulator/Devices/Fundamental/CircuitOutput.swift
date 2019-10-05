class CircuitOutput: Device {
    let input = Pin()
    override var description: String { return "\(name): value: \(input.net?.output ?? .floating)" }

    init(name: String, input: Pin?) {
        super.init(name: name)
        if input != nil { self.input.connectTo(input!) }
    }
    
    override func updateIfNeeded() -> Bool {
        return update_TrueIfChanged()
    }
    
    override func update_TrueIfChanged() -> Bool {
        return false
    }
    
    override func status() -> String { return "\(name): \(input.net?.output ?? .floating)" }
}
