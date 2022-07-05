import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:get_storage/get_storage.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'core.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _setAlready = false;
  final _player = Player(
    id: 0,
    commandlineArguments: ['--no-audio'],
  );
  final _gs = GetStorage('wp');

  @override
  void initState() {
    super.initState();
    _trayListener();
    _initPlayer();
    _initHotKey();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _trayListener() {
    SystemTray().registerSystemTrayEventHandler((eventName) async {
      switch (eventName) {
        case 'leftMouseDblClk':
          await _pickAndPlayVideo();
          break;
        case 'rightMouseUp':
          exit(0);
        default:
      }
    });
  }

  void _initPlayer() {
    _player.setPlaylistMode(PlaylistMode.single);
    _player.setVolume(0);

    Future.delayed(const Duration(seconds: 3), () {
      final path = _gs.read<String>('video');
      if (path == null) return;
      _playVideo(path);
    });
  }

  void _initHotKey() async {
    final hotKey = HotKey(
      KeyCode.f5,
      modifiers: [KeyModifier.control],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyUpHandler: (_) => _pickAndPlayVideo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Video(
        player: _player,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        showControls: false,
      ),
    );
  }

  Future<void> _pickAndPlayVideo() async {
    final typeGroup = XTypeGroup(
      label: '选择视频',
      extensions: <String>['mp4', 'flv', 'webm', 'mkv', 'avi'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    await _gs.write('video', file.path);
    await _playVideo(file.path);
  }

  Future<void> _playVideo(String path) async {
    final file = File(path);
    if (!await file.exists()) return;

    final media = Media.file(file);
    _player.open(media, autoStart: true);

    if (!_setAlready) {
      Wallpaper.set();
      await windowManager.maximize();
      await windowManager.show();
      _setAlready = true;
    }
  }
}
