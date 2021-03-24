#import "FlutterIconNetworkPlugin.h"
#if __has_include(<flutter_icon_network/flutter_icon_network-Swift.h>)
#import <flutter_icon_network/flutter_icon_network-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_icon_network-Swift.h"
#endif

@implementation FlutterIconNetworkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterIconNetworkPlugin registerWithRegistrar:registrar];
}
@end
