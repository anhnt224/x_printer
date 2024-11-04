#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint x_printer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'x_printer'
  s.version          = '0.0.2'
  s.summary          = 'XPrinter plugin project.'
  s.description      = <<-DESC
XPrinter plugin project.
                       DESC
  s.homepage         = 'https://github.com/anhnt224/x_printer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'AnhNT' => 'anhnt019@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'PrinterSDK/Headers/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.vendored_libraries = 'PrinterSDK/libPrinterSDK.a'
  s.public_header_files = 'PrinterSDK/Headers/*.h'

  s.preserve_paths = 'PrinterSDK/**/*'
  s.xcconfig = { 
    'LIBRARY_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/PrinterSDK',
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/PrinterSDK/Headers',
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/Headers/Public/x_printer/PrinterSDK/Headers' 
  }
  s.swift_version = '5.0'
end
