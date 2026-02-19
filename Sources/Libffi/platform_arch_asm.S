#include <TargetConditionals.h>

#if TARGET_OS_WATCH
  #if defined(__arm64__) && !defined(__LP64__)
    #include "vendor/darwin_watchos/src/aarch64/sysv_arm64_32.S"
  #elif defined(__arm64__)
    #include "vendor/darwin_watchos/src/aarch64/sysv_arm64.S"
  #elif defined(__x86_64__)
    #include "vendor/darwin_watchos/src/x86/unix64_x86_64.S"
    #include "vendor/darwin_watchos/src/x86/win64_x86_64.S"
  #elif defined(__arm__) && defined(__ARM_ARCH_7K__)
    #include "vendor/darwin_watchos/src/arm/sysv_armv7k.S"
  #endif
#elif TARGET_OS_TV
  #if defined(__arm64__)
    #include "vendor/darwin_tvos/src/aarch64/sysv_arm64.S"
  #elif defined(__x86_64__)
    #include "vendor/darwin_tvos/src/x86/unix64_x86_64.S"
    #include "vendor/darwin_tvos/src/x86/win64_x86_64.S"
  #endif
#elif TARGET_OS_IPHONE
  #if defined(__arm64__)
    #include "vendor/darwin_ios/src/aarch64/sysv_arm64.S"
  #elif defined(__x86_64__)
    #include "vendor/darwin_ios/src/x86/unix64_x86_64.S"
    #include "vendor/darwin_ios/src/x86/win64_x86_64.S"
  #elif defined(__arm__)
    #include "vendor/darwin_ios/src/arm/sysv_armv7.S"
  #endif
#elif TARGET_OS_OSX
  #if defined(__arm64__)
    #include "vendor/darwin_osx/src/aarch64/sysv_arm64.S"
  #elif defined(__x86_64__)
    #include "vendor/darwin_osx/src/x86/unix64_x86_64.S"
    #include "vendor/darwin_osx/src/x86/win64_x86_64.S"
  #endif
#endif
