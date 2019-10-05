class RomPage: Device {
    let outputEnable = Pin()
    var rowPins: [Pin] = []
    var columnPins: [Pin] = []
    let output = Pin()
    
    let busInverter: Inverter
    let outputNand: Nand2
    
    init(name: String, rows: Int, rowPins: [Pin?], columns: Int, columnPins: [Pin?], outputEnable: Pin?, output: Pin?, data: [[Bool]]) {
        assert(columns == columnPins.count, "RomPage \(name): columns does not match columns count")
        assert(rows == rowPins.count, "RomPage \(name): rowPins does not match rows count")
        assert(columns == data.count, "RomPage \(name): columns does not match data count")
        
        outputNand = Nand2(name: "\(name)-outputNand", input1: nil, input2: outputEnable, output: output)
        busInverter = Inverter(name: "\(name)-busInv", input: nil, output: outputNand.input1)
        
        for column in 0..<columns {
            _ = RomColumn(name: "\(name)-RomCol\(column)", rows: rows, rowPins: rowPins, cEnable_: columnPins[column], output_: busInverter.input, data: data[column])
        }
        
        super.init(name: name)
        simulation.add(self)
    }
        
    override var description: String { return "\(name): inputs: \(outputEnable.connectedTo); output: \(output.state)" }
    override func status() -> String { return "\(name): \(output.connectedTo)" }
}
