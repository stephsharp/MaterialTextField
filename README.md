#MaterialTextField

A [Material Design](https://www.google.com/design/spec/components/text-fields.html#text-fields-single-line-text-field) inspired UITextField with animated placeholder label and error message.

![MaterialTextField screenshot](https://raw.githubusercontent.com/stephsharp/MaterialTextField/develop/Screenshots/materialtextfield.png)

##Features

- Floating placeholder label
  - Animates on focus or on text input
  - Supports attributed placeholder text with custom fonts
  - Can be turned off to use the text field with the default iOS placeholder
- Text field underline
  - Line height expands when editing
  - Customize colour for default, editing and error states
- Error message
  - Animated error message appears below the text field
  - Long error messages wrap onto multiple lines 
- IBDesignable view
  - Adjust the appearance of your text field in Interface Builder with inspectable properties

##Setup

###CocoaPods

To install via CocoaPods, add to your podfile:

    pod 'MaterialTextField', '~> 0.1'

###Carthage

TBC

##Acknowledgements

I found the following libraries to be useful references when creating MaterialTextField:

- [MaterialKit](https://github.com/nghialv/MaterialKit)
- [JVFloatLabeledTextField](https://github.com/jverdi/JVFloatLabeledTextField)


##License

The MIT License (MIT)

Copyright (c) 2015 Stephanie Sharp
