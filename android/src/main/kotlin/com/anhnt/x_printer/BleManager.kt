package com.anhnt.x_printer

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import net.posprinter.IConnectListener
import net.posprinter.IDeviceConnection
import net.posprinter.POSConnect
import net.posprinter.POSPrinter

class BleManager(
    private val context: Context,
    val onDevicesChanged: (devices: ArrayList<BluetoothDevice>) -> Unit,
    val onStatusChanged: (status: Map<String, Any?>) -> Unit,
    val onScanningChanged: (isScanning: Boolean) -> Unit,
) {
    private var devices: ArrayList<BluetoothDevice> = arrayListOf()
    private val TAG = "BluetoothManager"
    private val bluetoothAdapter: BluetoothAdapter by lazy {
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    }

    private var curConnect: IDeviceConnection? = null
    val printer: POSPrinter?
        get() = if (curConnect == null) null else POSPrinter(curConnect)

    val isScanning: Boolean
        get() = bluetoothAdapter.isDiscovering

    private var _isConnected: Boolean = false
    val isConnected: Boolean
        get() = _isConnected

    private val mBroadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BluetoothDevice.ACTION_FOUND) {
                val device =
                    intent.getParcelableExtra<BluetoothDevice?>(BluetoothDevice.EXTRA_DEVICE)
                        ?: return
                if (device.type == 2) return
                if (devices.firstOrNull { d -> d.address == device.address } != null) {
                    return
                }

                if (device.bondState != BluetoothDevice.BOND_BONDED && !deviceIsExist(device.address)) {
                    devices.add(device)
                    onDevicesChanged(devices)
                }
            }
        }
    }


    init {
        POSConnect.init(context)
        devices.addAll(bluetoothAdapter.bondedDevices)
        val intentFilter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
        }
        context.registerReceiver(mBroadcastReceiver, intentFilter)

        if (bluetoothAdapter.isDiscovering) {
            onScanningChanged(true)
        } else {
            onScanningChanged(false)
        }
    }

    @SuppressLint("MissingPermission")
    fun startScan() {
        Log.d(TAG, "Start scan")
        onScanningChanged(true)
        bluetoothAdapter.startDiscovery()

        onDevicesChanged(devices)
    }

    @SuppressLint("MissingPermission")
    fun stopScan() {
        Log.d(TAG, "Stop scan")
        onScanningChanged(false)
        bluetoothAdapter.cancelDiscovery()
    }

    @SuppressLint("MissingPermission")
    fun connectDevice(mac: String) {
        Log.d(TAG, "connectDevice: ")
        onStatusChanged(mapOf("status" to PeripheralStatus.CONNECTING.value))
        curConnect?.close()
        curConnect = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH)
        curConnect!!.connect(mac, connectListener)
    }

    fun disconnect() {
        curConnect?.close()
    }

    private val connectListener = IConnectListener { code, address, msg ->
        when (code) {
            POSConnect.CONNECT_SUCCESS -> {
                _isConnected = true
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.CONNECTED.value,
                        "uuid" to address
                    )
                )
            }

            POSConnect.CONNECT_FAIL -> {
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.CONNECT_FAILED.value,
                        "statusMessage" to msg,
                        "uuid" to address
                    )
                )
            }

            POSConnect.CONNECT_INTERRUPT -> {
                _isConnected = false
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.DISCONNECTED.value,
                        "uuid" to address
                    )
                )
            }
        }
    }

    private fun deviceIsExist(address: String): Boolean {
        devices.forEach {
            if (it.address == address) {
                return true
            }
        }
        return false
    }
}