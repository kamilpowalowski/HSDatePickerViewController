Pod::Spec.new do |s|
  s.name         = "HSDatePickerViewController"
  s.version      = "1.0.4"
  s.summary      = "Customizable iOS view controller in Mailbox app style for picking date and time."

  s.description  = <<-DESC
`HSDatePickerViewController` is an iOS ViewController for date and time picking, based on awesome look&feel of Dropbox [Mailbox](http://www.mailboxapp.com/) application with some customization options.

Developers can change color of component, picker values formaters, default button texts and minut step.
                   DESC

  s.homepage     = "https://github.com/EmilYo/HSDatePickerViewController"
  s.screenshots  = "https://raw.githubusercontent.com/EmilYo/HSDatePickerViewController/master/screen1.png", "https://raw.githubusercontent.com/EmilYo/HSDatePickerViewController/master/screen2.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author    = "Kamil Powałowski"
  s.social_media_url   = "http://twitter.com/kamilpowalowski"

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/EmilYo/HSDatePickerViewController.git", :tag => "v#{s.version}" }
  s.source_files  = "Classes", "HSDatePickerViewControllerDemo/HSDatePickerViewController/*.{h,m}"
  s.resource  = "HSDatePickerViewControllerDemo/HSDatePickerViewController/HSDatePickerViewController.xib"
  s.requires_arc = true
end
