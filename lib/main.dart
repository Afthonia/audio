import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _init();
  }

  _init() async {
    try {
      //await player.setAudioSource(AudioSource.uri(Uri.parse("https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")));
      var totalTime = await player.setAsset('assets/audio/frequency.mp3');
      print(totalTime);

      duration = player.duration!;
      setState(() {});
      player.positionStream.listen((event) {
        if (event != null) {
          Duration temp = event as Duration;
          position = temp;
          setState(() {});
        }
      });
    } catch (e) {
      print('Error loading the audio: $e');
    }
  }

  Future<void> playAudio() async {
    await player.play();
  }

  Future<void> pauseAudio() async {
    await player.pause();
  }

  @override
  Widget build(BuildContext context) {
    Icon icon = Icon(Icons.play_arrow_rounded);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) {
                final seekPosition = Duration(seconds: value.toInt());
                player.seek(seekPosition);
                setState(() {});
              }),
          Text('${formatTime(position)} / ${formatTime(duration)}'),
          const SizedBox(height: 20),
          Controls(player: player),
        ],
      ),
    );
  }

  String formatTime(Duration value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(value.inHours);
    final minutes = twoDigits(value.inMinutes.remainder(60));
    final seconds = twoDigits(value.inSeconds.remainder(60));

    return [if (value.inHours > 0) hours, minutes, seconds].join(':');
  }
}

class Controls extends StatelessWidget {
  const Controls({super.key, required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: player.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;

          if (!(playing ?? false)) {
            return IconButton(
              onPressed: player.play,
              iconSize: 80,
              color: Colors.black,
              icon: const Icon(Icons.play_arrow_rounded),
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              onPressed: player.pause,
              iconSize: 80,
              color: Colors.black,
              icon: const Icon(Icons.pause_rounded),
            );
          }
          return const Icon(
            Icons.play_arrow_rounded,
            size: 80,
            color: Colors.white,
          );
        });
  }
}
