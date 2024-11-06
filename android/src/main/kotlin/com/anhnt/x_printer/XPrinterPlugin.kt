package com.anhnt.x_printer

import PTextAttr
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.posprinter.POSConst
import toDict

/** XPrinterPlugin */
class XPrinterPlugin : FlutterPlugin, MethodCallHandler {
    private val TAG = "XPrinterPlugin";

    private lateinit var channel: MethodChannel
    private lateinit var statusChannel: EventChannel
    private lateinit var scanningChannel: EventChannel
    private lateinit var peripheralChannel: EventChannel
    private lateinit var bleManager: BleManager

    private var statusEventSink: EventChannel.EventSink? = null
    private var scanningEventSink: EventChannel.EventSink? = null
    private var peripheralEventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "x_printer")
        channel.setMethodCallHandler(this)

        statusChannel = EventChannel(flutterPluginBinding.binaryMessenger, "x_printer/status")
        statusChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                statusEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                statusEventSink = null
            }
        })

        scanningChannel = EventChannel(flutterPluginBinding.binaryMessenger, "x_printer/scanning")
        scanningChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                scanningEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                scanningEventSink = null
            }
        })

        peripheralChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "x_printer/peripheral")
        peripheralChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                peripheralEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                peripheralEventSink = null
            }
        })

        bleManager = BleManager(context = flutterPluginBinding.applicationContext,
            onStatusChanged = { status ->
                statusEventSink?.success(status)
                Log.d(TAG, "statusEventSink: ${status}")
            }, onScanningChanged = { isScanning ->
                scanningEventSink?.success(isScanning)
                Log.d(TAG, "scanningEventSink: ${isScanning}")

            }, onDevicesChanged = { devices ->
                peripheralEventSink?.success(devices.map { e -> e.toDict() })

                Log.d(TAG, "peripheralEventSink: ${devices}")
            })
        bleManager.startScan()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startScan" -> {
                Log.d(TAG, "onMethodCall: startScan")
                bleManager.startScan()
                result.success(null)
            }
            "stopScan" -> {
                Log.d(TAG, "onMethodCall: stopScan")
                bleManager.stopScan()
                result.success(null)
            }
            "isScanning" -> {
                result.success(bleManager.isScanning)
            }
            "connect" -> {
                handleConnect(call, result)
            }
            "disconnect" -> {
                Log.d(TAG, "onMethodCall: disconnect ")
                bleManager.disconnect()
            }
            "printerIsConnect" -> {
                Log.d(TAG, "onMethodCall: printerIsConnect")
                result.success(true)
            }
            "printText" -> {
                handlePrinttext(call, result)
            }
            "cutPaper" -> {
                if(bleManager.printer == null){
                    invalidPrinter(result)
                    return
                }
                PosActivity.instance.cutPaper(
                    bleManager.printer!!
                )
            }
            "printImage" -> {
                handlePrintImage(call, result)
            }

            else -> {
                result.notImplemented()
            }

        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun handleConnect(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: run {
            invalidArgs(result)
            return
        }
        val deviceId = args["deviceId"] as? String ?: run {
            invalidArgs(result)
            return
        }

        if (deviceId.isEmpty()) {
            invalidArgs(result)
            return
        }

        bleManager.connectDevice(deviceId)
        result.success(null)
    }

    private fun handlePrinttext(call: MethodCall, result: Result){
        val args = call.arguments as? Map<String, Any> ?: run {
            invalidArgs(result)
            return
        }


        if(bleManager.printer == null){
            invalidPrinter(result)
            return
        }

        val attr = PTextAttr.from(args)
        PosActivity.instance.printText(attr, bleManager.printer!!)
    }

    private fun handlePrintImage(call: MethodCall, result: Result){
        val args = call.arguments as? Map<String, Any> ?: run {
            invalidArgs(result)
            return
        }

        val base64Encoded = args["data"] as? String ?: run {
            invalidArgs(result)
            return
        }

        if(bleManager.printer == null){
            invalidPrinter(result)
            return
        }

        val width = args["width"] as? Int ?: 500

        PosActivity.instance.printImage(
            base64Encoded,
            width,
            bleManager.printer!!
        )
    }

    private fun invalidArgs(result: Result) {
        result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
    }

    private fun invalidPrinter(result: Result) {
        result.error("INVALID_PRINTER", "Invalid printer", null)
    }
}
