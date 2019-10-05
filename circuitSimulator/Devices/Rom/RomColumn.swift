class RomColumn: Device {
    let cEnable_ = Pin()
    let output_ = Pin()
    var rowPins: [Pin] = []
    
    let pullup: Inverter
    let nor: Nor2
    let norInverter: Inverter
    
    init(name: String, rows: Int, data: [Bool]) {
        assert(rows == data.count, "RomColumn \(name): mismatched row count and data count")
        pullup = Inverter(name: "\(name)-pullup", input: nil, output: nil)
        nor = Nor2(name: "\(name)-nor", input1: pullup.output, input2: cEnable_, output: nil)
        norInverter = Inverter(name: "\(name)-norInv", input: nor.output, output: output_)
        
        for row in 0..<rows {
            rowPins.append(Pin())
            _ = RomCell(name: "\(name)-cell\(row)", input: rowPins[row], output: pullup.output, data: data[row])
        }
        
        super.init(name: name)
    }
    convenience init(name: String, rows: Int, rowPins: [Pin?], cEnable_: Pin?, output_: Pin?, data: [Bool]) {
        assert(rowPins.count == rows, "RomColumn \(name): mismatched row count and pin count")
        self.init(name: name, rows: rows, data: data)
        for row in 0..<rows {
            if rowPins[row] != nil { self.rowPins[row].connectTo(rowPins[row]!) }
        }
        if cEnable_ != nil { self.cEnable_.connectTo(cEnable_!) }
        if output_ != nil { self.output_.connectTo(output_!) }
    }
    override var description: String { return "\(name): inputs: \(cEnable_.connectedTo); output: \(output_.state)" }
    override func status() -> String { return "\(name): \(output_.connectedTo)" }
}
