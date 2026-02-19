#include <TargetConditionals.h>

#if TARGET_OS_WATCH
  #if defined(__arm64__) && !defined(__LP64__)
    #include "vendor/darwin_watchos/src/aarch64/ffi_arm64_32.c"
  #elif defined(__arm64__)
    #include "vendor/darwin_watchos/src/aarch64/ffi_arm64.c"
  #elif defined(__x86_64__)
    #include "vendor/darwin_watchos/src/x86/ffi64_x86_64.c"
    #include "vendor/darwin_watchos/src/x86/ffiw64_x86_64.c"
  #elif defined(__arm__) && defined(__ARM_ARCH_7K__)
    #include "vendor/darwin_watchos/src/arm/ffi_armv7k.c"
  #endif
#elif TARGET_OS_TV
  #if defined(__arm64__)
    #include "vendor/darwin_tvos/src/aarch64/ffi_arm64.c"
  #elif defined(__x86_64__)
    #include "vendor/darwin_tvos/src/x86/ffi64_x86_64.c"
    #include "vendor/darwin_tvos/src/x86/ffiw64_x86_64.c"
  #endif
#elif TARGET_OS_IPHONE
  #if defined(__arm64__)
    #include "vendor/darwin_ios/src/aarch64/ffi_arm64.c"
  #elif defined(__x86_64__)
    #include "vendor/darwin_ios/src/x86/ffi64_x86_64.c"
    #include "vendor/darwin_ios/src/x86/ffiw64_x86_64.c"
  #elif defined(__arm__)
    #include "vendor/darwin_ios/src/arm/ffi_armv7.c"
  #endif
#elif TARGET_OS_OSX
  #if defined(__arm64__)
    #include "vendor/darwin_osx/src/aarch64/ffi_arm64.c"
  #elif defined(__x86_64__)
    #include "vendor/darwin_osx/src/x86/ffi64_x86_64.c"
    #include "vendor/darwin_osx/src/x86/ffiw64_x86_64.c"
  #endif
#endif
