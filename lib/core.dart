import 'dart:ffi';

import 'package:win32/win32.dart';

class Wallpaper {
  static void set() {
    final hwnd = FindWindowEx(0, 0, nullptr, TEXT('wp'));

    final hProgman = FindWindow(TEXT("Progman"), nullptr);
    SendMessageTimeout(hProgman, 0x52C, 0, 0, 0, 100, nullptr);
    SetParent(hwnd, hProgman); 
    final wndProc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
    EnumWindows(wndProc, 0);
  }

  static int _enumWindowsProc(int hWnd, int lParam) {
    final hDefView = FindWindowEx(hWnd, 0, TEXT("SHELLDLL_DefView"), nullptr);
    if (hDefView != 0) {
      final hWorkerw = FindWindowEx(0, hWnd, TEXT("WorkerW"), nullptr);
      ShowWindow(hWorkerw, SW_HIDE);
      return FALSE;
    }

    return TRUE;
  }
}
