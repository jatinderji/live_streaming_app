import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as realtime_remote_view;
import 'package:permission_handler/permission_handler.dart';

const appId = "374e8205f5c646f4a0ad03dbcbb2bb35";
const token =
    "006afe7c52a3b62494186fa2264cee11a5eIABED9aZacykJDVG8HfJR3eIC/SF60fJsHr6Tkp5KHg8XEOQEggAAAAAIgC3KIpZ3ilyYgQAAQDcKXJiAgDcKXJiAwDcKXJiBADcKXJi";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Streaming',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Live Streaming'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _remoteUid = 0;
  late RtcEngine _engine;

  Future<void> initForAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _engine.enableAudio();
    _engine.enableVideo();
    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      log('Local user joinded: $uid');
    }, userJoined: (int uid, int elapsed) {
      log('Remote user joinded: $uid');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      log('Remote user left: $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));
    await _engine.joinChannel(token, 'myChannel', null, 0);
  }

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(child: _renderRemoteVideo()),
          ),
          Expanded(
              child: Container(
            color: Colors.green,
          ))
        ],
      ),
    );
  }

  Widget _renderRemoteVideo() {
    //
    if (_remoteUid != 0) {
      return realtime_remote_view.SurfaceView(
        uid: _remoteUid,
        channelId: 'myChannel',
      );
    } else {
      return const Text('Waiting for remote user to join');
    }
    //
  }
}
