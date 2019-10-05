class Device: SimulationParticipant {
    var name: String
    init(name: String) {
        self.name = name
    }
    override var description: String { return "device" }
    func transistors() -> Int { return 0 }
}
