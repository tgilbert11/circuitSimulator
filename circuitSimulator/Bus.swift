func valueOfBus(_ bus: [Pin]) -> UInt16 {
    assert(bus.count == 16, "value of bus has incorrect number of pins")
    var value: UInt16 = 0
    for pinNumber in 0..<16 {
        if bus[pinNumber].connectedTo == .low {
            value = value + (UInt16(1) << pinNumber)
        }
    }
    return value
}
func setValueToBus(value: UInt16, bus: [Pin]) {
    assert(bus.count == 16, "set value to bus has incorrect number of pins")
    //paddedPrint("bus value set to: \(value)")
    for pinNumber in 0..<16 {
        if value & (UInt16(1) << pinNumber) > 0 {
            bus[pinNumber].state = .drivingLow
        }
        else {
            bus[pinNumber].state = .pullingUp
        }
        bus[pinNumber].net!.needsUpdate = true
    }
    simulation.resolve()
}
func busWithValue(value: UInt16) -> [Pin] {
    var bus: [Pin] = []
    for pinNumber in 0..<16 { bus.append(Pin()); bus[pinNumber].state = .pullingUp }
    return bus
}
