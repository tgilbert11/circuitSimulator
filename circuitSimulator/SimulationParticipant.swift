class SimulationParticipant: CustomStringConvertible {
    var needsUpdate: Bool = true
    func update_TrueIfChanged() -> Bool { return false }
    func updateIfNeeded() -> Bool { return false }
    var description: String { return "SimulationParticipant" }
    func status() -> String { return "" }
}
