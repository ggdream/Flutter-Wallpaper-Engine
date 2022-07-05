import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:get_storage/get_storage.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('wp');
  await hotKeyManager.unregisterAll();
  await windowManager.ensureInitialized();
  await _initSystemTray();
  await DartVLC.initialize();

  const windowOptions = WindowOptions(
    size: Size.zero,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    fullScreen: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
  });

  launchAtStartup.setup(
    appName: '视频壁纸设置器',
    appPath: Platform.resolvedExecutable,
  );
  launchAtStartup.enable();

  runApp(const App());
}

Future<void> _initSystemTray() async {
  final st = SystemTray();
  await st.initSystemTray(
    title: '设置',
    iconPath: 'assets/logo.ico',
  );
  final menus = [
    MenuItem(label: '选择'),
    MenuItem(label: '退出'),
  ];
  await st.setContextMenu(menus);
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
