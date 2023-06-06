
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNFunsdkSpec.h"

@interface Funsdk : NSObject <NativeFunsdkSpec>
#else
#import <React/RCTBridgeModule.h>

@interface Funsdk : NSObject <RCTBridgeModule>
#endif

@end
