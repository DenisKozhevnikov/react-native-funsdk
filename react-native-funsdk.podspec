require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "react-native-funsdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/DenisKozhevnikov/react-native-funsdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"

  s.dependency "React-Core"
  s.dependency "ZXingObjC"
  s.dependency "FunSDK", "1.0.33"
  
  # frameworks и libraries которые нужны для работы FunSDK.framework
  s.frameworks = 'AudioToolbox', 'CoreMedia', 'OpenAL', 'VideoToolbox', 'AVKit', 'GLKit', 'MessageUI'
  s.libraries = 'bz2', 'iconv', 'resolv', 'z'
  # https://github.com/callstack/react-native-builder-bob/discussions/379
  # s.vendored_frameworks = "https://gitlab.xmcloud.io/demo/FunSDKDemo_iOS/-/tree/master/FunSDKDemo/XMFunSDKDemo/Supporting/library/FunSDK.framework"
  s.vendored_frameworks = "ios/frameworks/XMSecurity.framework", "ios/frameworks/XMNetInterface.framework", "ios/frameworks/Masonry.framework"

  s.vendored_libraries = 'ios/libs/libfisheye.a', 'ios/libs/libFSCalendar.a'

  s.prefix_header_file = "ios/pch/PrefixHeader.pch"

  # Don't install the dependencies when we run `pod install` in the old architecture.
  if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
    s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
    s.pod_target_xcconfig    = {
        "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
        "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
        "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
    }
    s.dependency "React-Codegen"
    s.dependency "RCT-Folly"
    s.dependency "RCTRequired"
    s.dependency "RCTTypeSafety"
    s.dependency "ReactCommon/turbomodule/core"
  end
end
