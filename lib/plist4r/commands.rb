require 'plist4r/config'
require 'fileutils'

module Plist4r
  # This objects manages all of the commands to be executed by an instance of {Plist4r::Application}
  # @see Plist4r::Application
  # @see Plist4r::CLI
  class Commands
    PriorityOrder = [:ruby_lib]

    # To be executed once. Branches out to subroutines, and handles the order-of-execution of
    # those main subrountines.
    def run
      PriorityOrder.each do |command|
        send command if self.class.method_defined?(command) && Plist4r::Config[:args][command]
      end

      left_to_execute = Plist4r::Config[:args].keys - PriorityOrder
      Plist4r::Config[:args].each do |command, value|
        send command if left_to_execute.include?(command) && self.class.method_defined?(command) && value
      end
    end

    # Implements the +plist4r --ruby-lib+ subcommand.
    # @see Plist4r::CLI
    def ruby_lib
      plist4r_root = File.expand_path "../../", File.dirname(__FILE__)
      plist4r_lib = File.expand_path "../../lib", File.dirname(__FILE__)
      dest = File.expand_path(Plist4r::Config[:args][:dir] || FileUtils.pwd)

      raise "sorry, cant write to the same source and destination" if plist4r_lib == dest
      raise "sorry, cant write to a destination within the source folder" if dest =~ /^#{plist4r_lib}/

      FileUtils.mkdir_p dest
      FileUtils.rm_rf "#{dest}/plist4r"
      FileUtils.cp_r Dir.glob("#{plist4r_lib}/*"), dest
      FileUtils.cp_r Dir.glob("#{plist4r_root}/VERSION"), "#{dest}/plist4r"
      
      if Plist4r::Config[:args][:brew]
        backends = Dir.glob "#{dest}/plist4r/backend/*"
        docs = Dir.glob "#{dest}/plist4r/docs*"
        haml4r = Dir.glob "#{dest}/plist4r/mixin/haml4r*"
        non_brew_files = [
          "#{dest}/plist4r/application.rb",
          backends - ["#{dest}/plist4r/backend/ruby_cocoa.rb"],
          "#{dest}/plist4r/cli.rb",
          "#{dest}/plist4r/commands.rb",
          docs,
          haml4r,
          "#{dest}/plist4r/mixin/mixlib_cli.rb",
          "#{dest}/plist4r/mixin/script.rb",
          "#{dest}/plist4r/mixin/table.rb",
        ].flatten
        FileUtils.rm_rf(non_brew_files)

        config = File.read "#{dest}/plist4r/config.rb"
        config.gsub! /backends default_backends/,"backends default_backends :brew"

        File.open("#{dest}/plist4r/config.rb",'w') do |o|
          o << config
        end
      end

    end
  end
end
