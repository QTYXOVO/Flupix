#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  // Fit the window to the available work area on smaller screens.
  RECT work_area;
  ::SystemParametersInfo(SPI_GETWORKAREA, 0, &work_area, 0);
  const int screen_width = work_area.right - work_area.left;
  const int screen_height = work_area.bottom - work_area.top;
  const int window_width = screen_width > 1320 ? 1280 : screen_width - 40;
  const int window_height = screen_height > 800 ? 760 : screen_height - 40;
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(window_width, window_height);
  if (!window.Create(L"Flupix", origin, size)) {
    return EXIT_FAILURE;
  }

  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
