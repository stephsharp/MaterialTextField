Pod::Spec.new do |s|
  s.name         = "MaterialTextField"
  s.version      = "1.0.1"
  s.summary      = "Material design UITextField with animated placeholder label and error message"
  s.homepage     = "https://github.com/stephsharp/MaterialTextField"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Stephanie Sharp"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/stephsharp/MaterialTextField.git", :tag => "v#{s.version}" }
  s.source_files = "MaterialTextField"
  s.public_header_files = [ "MaterialTextField/MaterialTextField.h", 
                            "MaterialTextField/MFTextField.h", 
                            "MaterialTextField/UIColor+MaterialTextField.h" ]
  s.requires_arc = true
end
