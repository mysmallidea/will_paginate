plugin_root = File.join(File.dirname(__FILE__), '..')
version = ENV['RAILS_VERSION']
version = nil if version and version == ""

# first look for a symlink to a copy of the framework
if !version and framework_root = ["#{plugin_root}/rails", "#{plugin_root}/../../rails"].find { |p| File.directory? p }
  puts "found framework root: #{framework_root}"
  # this allows for a plugin to be tested outside of an app and without Rails gems
  $:.unshift "#{framework_root}/activesupport/lib", "#{framework_root}/activerecord/lib", "#{framework_root}/actionpack/lib", "#{framework_root}/activeresource/lib"
else
  # simply use installed gems if available
  puts "using Rails#{version ? ' ' + version : nil} gems"
  require 'rubygems'
  
  if version
    gem 'rails', version
  else
    gem 'actionpack', '< 3.0.0.a'
    gem 'activerecord', '< 3.0.0.a'
  end
end
