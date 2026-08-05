#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint x_printer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'x_printer'
  s.version          = '0.0.8'
  s.summary          = 'XPrinter plugin project.'
  s.description      = <<-DESC
XPrinter plugin project.
                       DESC
  s.homepage         = 'https://github.com/anhnt224/x_printer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'AnhNT' => 'anhnt019@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'x_printer/Sources/x_printer/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.vendored_frameworks = 'x_printer/PrinterSDK.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
