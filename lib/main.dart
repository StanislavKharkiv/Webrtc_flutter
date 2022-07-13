import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_tutorial/signaling.dart';
import 'components/camera_cover.dart';

const buttonMargin = 10.0;
RoundedRectangleBorder buttonBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(0),
    side: BorderSide(color: Colors.transparent));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  bool _isStart = false;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter WebRTC"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Room ID: ".toUpperCase(),
                ),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: buttonMargin),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(
                      child: _isStart
                          ? RTCVideoView(_localRenderer, mirror: true)
                          : CameraCover(color: Colors.green)),
                  // Expanded(child: RTCVideoView(_remoteRenderer)),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: _isStart
                          ? RTCVideoView(_remoteRenderer)
                          : CameraCover())
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    roomId = await signaling.createRoom(_remoteRenderer);
                    textEditingController.text = roomId!;
                  },
                  child: Text(
                    "CREATE ROOM",
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                      shape: buttonBorder),
                ),
                flex: 2,
              ),
              SizedBox(
                width: 2,
              ),
              Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await signaling.openUserMedia(
                          _localRenderer, _remoteRenderer);
                      setState(() => _isStart = true);
                    },
                    child: Icon(Icons.camera_alt_outlined),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                        shape: buttonBorder),
                  ),
                  flex: 1),
              SizedBox(
                width: 2,
              ),
              Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      signaling.hangUp(_localRenderer);
                      setState(() => _isStart = false);
                    },
                    child: Icon(Icons.videocam_off_outlined),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                        shape: buttonBorder),
                  ),
                  flex: 1),
              SizedBox(
                width: 2,
              ),
              Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add roomId
                      signaling.joinRoom(
                        textEditingController.text,
                        _remoteRenderer,
                      );
                    },
                    child: Text(
                      "JOIN ROOM",
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        shape: buttonBorder),
                  ),
                  flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
