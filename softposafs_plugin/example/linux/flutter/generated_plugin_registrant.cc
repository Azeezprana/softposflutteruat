//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <softposafs_plugin/softposafs_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) softposafs_plugin_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SoftposafsPlugin");
  softposafs_plugin_register_with_registrar(softposafs_plugin_registrar);
}
