class Monitor {
    var participants: [SimulationParticipant] = []
    func printStatus() {
        if participants.count == 0 {
            print("nothing being monitored.")
        }
        else {
            print("t = \(simulation.propogationTime): \(participants[0].status())\(participants.dropFirst().reduce("", { $0 + "; " + $1.status() }))")
        }
    }
}
