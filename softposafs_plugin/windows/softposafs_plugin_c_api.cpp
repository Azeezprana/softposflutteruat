#include "include/softposafs_plugin/softposafs_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "softposafs_plugin.h"

void SoftposafsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  softposafs_plugin::SoftposafsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
