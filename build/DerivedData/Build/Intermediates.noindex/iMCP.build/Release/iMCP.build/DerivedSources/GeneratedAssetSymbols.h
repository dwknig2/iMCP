#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "MenuIcon-Off" asset catalog image resource.
static NSString * const ACImageNameMenuIconOff AC_SWIFT_PRIVATE = @"MenuIcon-Off";

/// The "MenuIcon-On" asset catalog image resource.
static NSString * const ACImageNameMenuIconOn AC_SWIFT_PRIVATE = @"MenuIcon-On";

#undef AC_SWIFT_PRIVATE
