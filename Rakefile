# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'yamaari_taniari'
  app.frameworks += ['ScriptingBridge']
  app.bridgesupport_files << 'vendor/Numbers.bridgesupport'
  app.codesign_for_release = false
end
