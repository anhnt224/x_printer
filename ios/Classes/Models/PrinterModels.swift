//
//  PrinterModels.swift
//  x_printer
//
//  Created by AnhNT on 4/11/24.
//

class PTextAttr {
    var align: Int32 = 0
    var attribute: Int32 = 0
    var width: Int32 = 0
    var height: Int32 = 0
    
    static func from(map: [String: Any]) -> PTextAttr {
        let attr = PTextAttr()
        
        attr.align = map["align"] as? Int32 ?? 0
        attr.attribute = map["attribute"] as? Int32 ?? 0
        attr.width = map["width"] as? Int32 ?? 0
        attr.height = map["height"] as? Int32 ?? 0
        
        return attr
    }
}

class PBarCodeAttr {
    var content: String = ""
    var type: Int32 = 0
    var encoding: UInt = 0
    
    static func from(map: [String: Any]) -> PBarCodeAttr {
        let attr = PBarCodeAttr()
        
        attr.content = map["content"] as? String ?? ""
        attr.type = map["type"] as? Int32 ?? 0
        attr.encoding = map["encoding"] as? UInt ?? 0
        
        return attr
    }
}


class PQrcodeAttr {
    var code: String = ""
    var unitSize: Int32 = 0
    var errLevel: Int32 = 0
    var encoding: UInt = NSUTF8StringEncoding
    
    static func from(map: [String: Any]) -> PQrcodeAttr {
        let attr = PQrcodeAttr()
        
        attr.code = map["code"] as? String ?? ""
        attr.unitSize = map["unitSize"] as? Int32 ?? 0
        attr.errLevel = map["errLevel"] as? Int32 ?? 0
        let encodingValue = map["encoding"] as? Int ?? 0
        
        attr.encoding = stringEncodings[encodingValue] ?? NSUTF8StringEncoding

        return attr
    }
}

let stringEncodings: [Int: UInt] = [
    0: NSUTF8StringEncoding,
    1: NSASCIIStringEncoding,
    2: NSUTF16StringEncoding,
]

extension CBPeripheral {
    func toDict() -> [String: Any?] {
        return [
            "name": self.name,
            "uuid": self.identifier.uuidString,
            "state": self.state.rawValue, // CBPeripheralState is an enum, so use rawValue to get its integer representation
            "services": self.services?.map { $0.uuid.uuidString }, // Get UUIDs of services if available
            "canSendWriteWithoutResponse": self.canSendWriteWithoutResponse,
        ]
    }
}

enum PeripheralStatus: Int {
    case connecting = 0
    case connected = 1
    case disconnected = 2
    case connectFailed = 3
}
