class Device: SimulationParticipant {
    var name: String
    init(name: String) {
        self.name = name
        
        super.init()
        
        simulation.add(self)
    }
    override var description: String { return "device" }
    func transistors() -> Int { return 0 }
    func update_TrueIfChanged() -> Bool { return false }
}
