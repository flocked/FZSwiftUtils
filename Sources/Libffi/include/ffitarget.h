#ifndef SPM_FFITARGET_H
#define SPM_FFITARGET_H

#include <TargetConditionals.h>

#if TARGET_OS_WATCH
  #if defined(__arm64__) && !defined(__LP64__)
    #include "darwin_watchos/ffitarget_arm64_32.h"
  #elif defined(__arm64__)
    #include "darwin_watchos/ffitarget_arm64.h"
  #elif defined(__x86_64__)
    #include "darwin_watchos/ffitarget_x86_64.h"
  #elif defined(__arm__)
    #include "darwin_watchos/ffitarget_armv7k.h"
  #else
    #error Unsupported watchOS architecture
  #endif
#elif TARGET_OS_TV
  #if defined(__arm64__)
    #include "darwin_tvos/ffitarget_arm64.h"
  #elif defined(__x86_64__)
    #include "darwin_tvos/ffitarget_x86_64.h"
  #else
    #error Unsupported tvOS architecture
  #endif
#elif TARGET_OS_IPHONE
  #if defined(__arm64__)
    #include "darwin_ios/ffitarget_arm64.h"
  #elif defined(__x86_64__)
    #include "darwin_ios/ffitarget_x86_64.h"
  #elif defined(__arm__)
    #include "darwin_ios/ffitarget_arm64.h"
  #else
    #error Unsupported iOS architecture
  #endif
#elif TARGET_OS_OSX
  #if defined(__arm64__)
    #include "darwin_osx/ffitarget_arm64.h"
  #elif defined(__x86_64__)
    #include "darwin_osx/ffitarget_x86_64.h"
  #else
    #error Unsupported macOS architecture
  #endif
#else
  #error Unsupported Apple platform
#endif

#endif
