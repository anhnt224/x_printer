import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import net.posprinter.POSPrinter

//
//  PrinterModels.kt
//  x_printer
//
//  Created by AnhNT on 4/11/24.
//

data class PTextAttr(
    var text: String = "",
    var align: Int = 0,
    var attribute: Int = 0,
    var width: Int = 0,
    var height: Int = 0
) {
    companion object {
        fun from(map: Map<String, Any>): PTextAttr {
            return PTextAttr(
                text = map["text"] as? String ?: "",
                align = map["align"] as? Int ?: 0,
                attribute = map["attribute"] as? Int ?: 0,
                width = map["width"] as? Int ?: 0,
                height = map["height"] as? Int ?: 0
            )
        }
    }

    fun print(printer: POSPrinter){
        printer.printText(
            text, align, attribute, height * 16
        )
    }
}

data class PBarCodeAttr(
    var content: String = "",
    var type: Int = 0,
    var encoding: Int = 0
) {
    companion object {
        fun from(map: Map<String, Any>): PBarCodeAttr {
            return PBarCodeAttr(
                content = map["content"] as? String ?: "",
                type = map["type"] as? Int ?: 0,
                encoding = (map["encoding"] as? Number)?.toInt() ?: 0
            )
        }
    }
}

data class PQrcodeAttr(
    var code: String = "",
    var unitSize: Int = 0,
    var errLevel: Int = 0,
    var encoding: Int = 0 // Default encoding
) {
    companion object {
        fun from(map: Map<String, Any>): PQrcodeAttr {
            val encodingValue = map["encoding"] as? Int ?: 0
            return PQrcodeAttr(
                code = map["code"] as? String ?: "",
                unitSize = map["unitSize"] as? Int ?: 0,
                errLevel = map["errLevel"] as? Int ?: 0,
                encoding = encodingValue
            )
        }
    }
}

fun BluetoothDevice.toDict(): Map<String, Any?> {
    return mapOf(
        "name" to name,
        "uuid" to address,
        "state" to bondState,
    )
}

enum class PeripheralStatus(val value: Int) {
    CONNECTING(0),
    CONNECTED(1),
    DISCONNECTED(2),
    CONNECT_FAILED(3)
}
