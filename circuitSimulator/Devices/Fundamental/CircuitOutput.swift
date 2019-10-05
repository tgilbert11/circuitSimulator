class CircuitOutput: Device {
    let input = Pin()

    init(name: String, input: Pin?) {
        if input != nil { self.input.connectTo(input!) }

        super.init(name: name)
    }
    
    override var description: String { return "\(name): value: \(input.net?.output ?? .floating)" }
    override func status() -> String { return "\(name): \(input.net?.output ?? .floating)" }
}
