import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pcm_player/flutter_pcm_player.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterPcmPlayer player = FlutterPcmPlayer();
  FlutterPcmPlayer player1 = FlutterPcmPlayer();

  @override
  void initState() {
    super.initState();
    testPlayPcm();
    testPlayPcm1();
  }

  void testPlayPcm() async {
    final List files = ['王后', '白方'];

    await player.initialize();
    await player.play();
    for (int i = 0; i < files.length; i++) {
      try {
        ByteData byteDate = await rootBundle.load("assets/${files[i]}.pcm");
        if (byteDate != null) {
          Uint8List stream = Uint8List.sublistView(byteDate);
          await player.feed(stream);
        } else {
          print('file content is null!');
        }
      } catch (e) {
        print(e.toString());
      }
    }
    //player.stop();
  }

  void testPlayPcm1() async {
    final List files = ['王后', '白方'];

    await player1.initialize();
    await player1.play();
    for (int i = 0; i < files.length; i++) {
      try {
        ByteData byteDate = await rootBundle.load("assets/${files[i]}.pcm");
        if (byteDate != null) {
          Uint8List stream = Uint8List.sublistView(byteDate);
          await player1.feed(stream);
        } else {
          print('file content is null!');
        }
      } catch (e) {
        print(e.toString());
      }
    }
    //player.stop();
  }

  void testPlayPcmNew() async {
    final List files = ['王后', '白方'];
    // PcmPlayer xxplayer1 = PcmPlayer();
    // await player.initialize();
    // await player.play();
    for (int i = 0; i < files.length; i++) {
      print(DateTime.now());
      try {
        ByteData byteDate = await rootBundle.load("assets/${files[i]}.pcm");
        print(byteDate.lengthInBytes);
        if (byteDate != null) {
          Uint8List stream = Uint8List.sublistView(byteDate);
          await player.feed(stream);
        } else {
          print('file content is null!');
        }
      } catch (e) {
        print(e.toString());
      }
      print(DateTime.now());
      print(player.isPlaying);
    }
    //xxplayer1.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            testPlayPcmNew();
          },
          tooltip: 'Play',
          child: Icon(Icons.play_arrow),
        ),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            // child: Text('Running on: $_platformVersion\n'),
            ),
      ),
    );
  }
}
