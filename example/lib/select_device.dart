import 'package:flutter/material.dart';
import 'package:x_printer/x_printer.dart';

class SelectDevice extends StatefulWidget {
  const SelectDevice({super.key, required this.plugin});

  final XPrinter plugin;

  @override
  State<SelectDevice> createState() => _SelectDeviceState();
}

class _SelectDeviceState extends State<SelectDevice> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        widget.plugin.startScan();

        widget.plugin.statusStream.listen((value) {
          print(">>> status: ${value.status.name}");
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    widget.plugin.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Device"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.plugin.startScan();
                },
                child: const Text("Scan"),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.plugin.stopScan();
                },
                child: const Text("Stop"),
              ),
            ],
          ),
          StreamBuilder(
            stream: widget.plugin.isScanningStream,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return const LinearProgressIndicator();
              }
              return Container();
            },
          ),
          Expanded(
            child: StreamBuilder<List<Peripheral>>(
              stream: widget.plugin.peripheralsStream,
              builder: (context, snapshot) {
                if (snapshot.data?.isNotEmpty != true) {
                  return Container();
                }

                final peripherals = snapshot.data!;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final peripheral = peripherals[index];
                    return ListTile(
                      title: Text(peripheral.name ?? ''),
                      subtitle: Text(peripheral.uuid ?? ''),
                      onTap: () {
                        if (peripheral.uuid == null ||
                            peripheral.state == PeripheralState.connected) {
                          return;
                        }
                        widget.plugin.connect(peripheral.uuid!);
                      },
                    );
                  },
                  itemCount: peripherals.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
