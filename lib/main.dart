// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:developer';

import 'package:dartzmq/dartzmq.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero MQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Zero MQ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ZContext _context = ZContext();
  late final MonitoredZSocket _socket;
  String _receivedData = '';
  late StreamSubscription _subscription;
  int _presses = 0;

  @override
  void initState() {
    _socket = _context.createMonitoredSocket(SocketType.dealer);
    _socket.connect("tcp://localhost:5566");

    _subscription = _socket.messages.listen((message) {
      // * message of socket ...
      setState(() {
        _receivedData = message.toString();
      });
    });

    super.initState();
  }

  void _sendMessage() {
    ++_presses;
    _socket.send([_presses], nowait: true);
  }

  @override
  void dispose() {
    _socket.close();
    _context.stop();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            children: [
              Text("Press To Send Message "),
              MaterialButton(
                onPressed: () => {_sendMessage()},
                color: Colors.blue,
                child: Text("Send"),
              ),
              StreamBuilder<SocketEvent>(
                stream: _socket.events,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final event = snapshot.data!;
                    log('Socket event: ${event.event}, value: ${event.value}');
                    return Text(
                      'Event: ${event.event}, value: ${event.value}',
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
              Text("Received"),
              Text("result : " + _receivedData.toString())
            ],
          ),
        ),
      ),
    );
  }
}
