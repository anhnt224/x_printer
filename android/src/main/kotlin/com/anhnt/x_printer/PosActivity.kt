package com.anhnt.x_printer

import PTextAttr
import net.posprinter.POSConst
import net.posprinter.POSPrinter

class PosActivity {
    companion object {
        val instance = PosActivity()
    }

    fun printText(attr: PTextAttr, printer: POSPrinter) {
        val aligns =
            arrayOf(POSConst.ALIGNMENT_LEFT, POSConst.ALIGNMENT_CENTER, POSConst.ALIGNMENT_RIGHT)
        val attributes = arrayOf(
            POSConst.FNT_DEFAULT,
            POSConst.FNT_FONTB,
            POSConst.FNT_FONTB,
            POSConst.FNT_REVERSE,
            POSConst.FNT_UNDERLINE,
            POSConst.FNT_UNDERLINE2
        )
        val textSize = arrayOf(
            POSConst.TXT_1WIDTH,
            POSConst.TXT_2WIDTH,
            POSConst.TXT_3WIDTH,
            POSConst.TXT_4WIDTH,
        )

        printer.initializePrinter().printText(
            "${attr.text}\n",
            aligns[attr.align],
            attributes[attr.attribute],
            textSize[attr.height]
        )
    }

    fun cutPaper(printer: POSPrinter) {
        printer.initializePrinter()
            .cutHalfAndFeed(1)
    }
}