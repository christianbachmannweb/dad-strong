import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final _player = AudioPlayer();

  AudioService() {
    // Play over silent mode and duck other audio (e.g. YouTube)
    AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.duckOthers},
      ),
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        usageType: AndroidUsageType.notification,
        contentType: AndroidContentType.sonification,
        isSpeakerphoneOn: false,
      ),
    ));
  }

  Future<void> playTenSeconds() async {
    await _player.play(AssetSource('audio/10sek.mp3'));
  }

  Future<void> playStart() async {
    await _player.play(AssetSource('audio/start.mp3'));
  }
}
