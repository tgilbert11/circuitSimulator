class Rom1024x16: Device {
    let outputEnable = Pin()
    var outputPins: [Pin] = []
    var pages: [RomPage] = []
        
    init(name: String, addressPins: [Pin], outputEnable: Pin, outputPins: [Pin], data: [UInt16]) {
        assert(data.count <= 1024, "Rom1024x16 \(name): more than 1024 data values")
        assert(outputPins.count == 16, "Rom1024x16 \(name): incorrect number of output pins")
        assert(addressPins.count == 10, "Rom1024x16 \(name): incorrect number of address pins")
        
        // create address pins/inverters
        var inverters: [Inverter] = []
        for addressBit in 0..<10 {
            inverters.append(Inverter(name: "\(name)-addPin\(addressBit)Inv", input: addressPins[addressBit], output: nil))
        }
        
        // create address row/column nors (address decoding)
        var rowNors: [Nor5] = []
        var columnNands: [Nand5] = []
        for lineNumber in 0..<32 {
            let rowNor = Nor5(name: "\(name)-rowNor\(lineNumber)", input1: nil, input2: nil, input3: nil, input4: nil, input5: nil, output: nil)
            let columnNand = Nand5(name: "\(name)-ColumnNand\(lineNumber)", input1: nil, input2: nil, input3: nil, input4: nil, input5: nil, output: nil)
            
            if lineNumber & 0b00001 > 0 {
                rowNor.input1.connectTo(addressPins[0])
                columnNand.input1.connectTo(inverters[5].output)
            }
            else {
                rowNor.input1.connectTo(inverters[0].output)
                columnNand.input1.connectTo(addressPins[5])
            }
            if lineNumber & 0b00010 > 0 {
                rowNor.input2.connectTo(addressPins[1])
                columnNand.input2.connectTo(inverters[6].output)
            }
            else {
                rowNor.input2.connectTo(inverters[1].output)
                columnNand.input2.connectTo(addressPins[6])
            }
            if lineNumber & 0b00100 > 0 {
                rowNor.input3.connectTo(addressPins[2])
                columnNand.input3.connectTo(inverters[7].output)
            }
            else {
                rowNor.input3.connectTo(inverters[2].output)
                columnNand.input3.connectTo(addressPins[7])
            }
            if lineNumber & 0b01000 > 0 {
                rowNor.input4.connectTo(addressPins[3])
                columnNand.input4.connectTo(inverters[8].output)
            }
            else {
                rowNor.input4.connectTo(inverters[3].output)
                columnNand.input4.connectTo(addressPins[8])
            }
            if lineNumber & 0b10000 > 0 {
                rowNor.input5.connectTo(addressPins[4])
                columnNand.input5.connectTo(inverters[9].output)
            }
            else {
                rowNor.input5.connectTo(inverters[4].output)
                columnNand.input5.connectTo(addressPins[9])
            }
            rowNors.append(rowNor)
            columnNands.append(columnNand)
        }
        
        // create pages/output pins
        for outputBit in 0..<16 {
            self.outputPins.append(Pin())
            
            let bitMask = UInt16(1) << outputBit
            var thisPageData = Array(repeating: Array(repeating: false, count: 32), count: 32)
            for column in 0..<32 {
                for row in 0..<32 {
                    if column*32 + row < data.count {
                        thisPageData[column][row] = data[column*32 + row] & bitMask > 0
                    }
                }
            }
            
            self.pages.append(RomPage(name: "\(name)-Page\(outputBit)", rows: 32, rowPins: rowNors.map({ $0.output }), columns: 32, columnPins: columnNands.map({ $0.output }), outputEnable: outputEnable, output: outputPins[outputBit], data: thisPageData))
            //self.outputPins[outputBit].connectTo(self.pages[outputBit].output)
        }
        
        self.outputEnable.connectTo(outputEnable)
        
        super.init(name: name)
    }
    
    override var description: String { return "\(name): inputs: \(outputEnable.connectedTo); output: " }
    override func status() -> String {
        let v15: UInt16 = outputPins[15].connectedTo == .low ? 0b1000_0000_0000_0000 : 0
        let v14: UInt16 = outputPins[14].connectedTo == .low ? 0b0100_0000_0000_0000 : 0
        let v13: UInt16 = outputPins[13].connectedTo == .low ? 0b0010_0000_0000_0000 : 0
        let v12: UInt16 = outputPins[12].connectedTo == .low ? 0b0001_0000_0000_0000 : 0
        let v11: UInt16 = outputPins[11].connectedTo == .low ? 0b0000_1000_0000_0000 : 0
        let v10: UInt16 = outputPins[10].connectedTo == .low ? 0b0000_0100_0000_0000 : 0
        let v9: UInt16 = outputPins[9].connectedTo == .low ? 0b0000_0010_0000_0000 : 0
        let v8: UInt16 = outputPins[8].connectedTo == .low ? 0b0000_0001_0000_0000 : 0
        let v7: UInt16 = outputPins[7].connectedTo == .low ? 0b0000_0000_1000_0000 : 0
        let v6: UInt16 = outputPins[6].connectedTo == .low ? 0b0000_0000_0100_0000 : 0
        let v5: UInt16 = outputPins[5].connectedTo == .low ? 0b0000_0000_0010_0000 : 0
        let v4: UInt16 = outputPins[4].connectedTo == .low ? 0b0000_0000_0001_0000 : 0
        let v3: UInt16 = outputPins[3].connectedTo == .low ? 0b0000_0000_0000_1000 : 0
        let v2: UInt16 = outputPins[2].connectedTo == .low ? 0b0000_0000_0000_0100 : 0
        let v1: UInt16 = outputPins[1].connectedTo == .low ? 0b0000_0000_0000_0010 : 0
        let v0: UInt16 = outputPins[0].connectedTo == .low ? 0b0000_0000_0000_0001 : 0
        
        let value = v15 + v14 + v13 + v12 + v11 + v10 + v9 + v8 + v7 + v6 + v5 + v4 + v3 + v2 + v1 + v0
        
        return "\(name): \(value)"
    }
}
