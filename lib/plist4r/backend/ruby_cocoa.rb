
require 'plist4r/backend_base'

# This backend only works on MacOSX. It supports everything except {Backend::Example.to_gnustep}, 
# and saving in the :gnustep file format. This is Because RubyCocoa uses the 
# NSPropertyListSerialization class, which doesnt support writing to OpenStep Format.
# 
# Here we are calling the stock OSX Ruby in a seperate process. 
# It isolates the runtime from any shared lib (.so) LoadErrors. And allows calling from other installed 
# Ruby instances (eg REE), which dont usually have RubyCocoa enabled.
# 
# This Backend should work for any 10.5 (Leopard), 10.6 (Snow Leopard) Mac OSX distribution.
# It will do nothing on non-mac platforms (eg Linux etc).
# @author Dreamcat4 (dreamcat4@gmail.com)
module Plist4r::Backend::RubyCocoa
  class << self
    # A seperate ruby script, which runs in its own process.
    # @see ruby_cocoa_exec
    def ruby_cocoa_wrapper_rb
      @ruby_cocoa_wrapper_rb ||= <<-'EOC'
#!/usr/bin/ruby
raise "No path given to plist4r" unless ARGV[0] && File.exists?("#{ARGV[0]}/plist4r.rb")

dir = ARGV[0]
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'osx/cocoa'
require 'date'
require 'plist4r/mixin/ordered_hash'

# Property list API.
module OSX
  def object_to_plist(object, format=nil)
    format ||= OSX::NSPropertyListXMLFormat_v1_0
    data, error = OSX::NSPropertyListSerialization.objc_send \
      :dataFromPropertyList, object,
      :format, format,
      :errorDescription
    raise error.to_s if data.nil?
    case format
      when OSX::NSPropertyListXMLFormat_v1_0, 
           OSX::NSPropertyListOpenStepFormat
        OSX::NSString.alloc.initWithData_encoding(data, 
          OSX::NSUTF8StringEncoding).to_s
      else
        data.bytes.bytestr(data.length)
    end
  end
  module_function :object_to_plist
end

class OSX::NSObject
  def to_ruby
    case self
    when OSX::NSDate
      self.to_time
    when OSX::NSCFBoolean
      self.boolValue
    when OSX::NSNumber
      self.integer? ? self.to_i : self.to_f
    when OSX::NSString
      self.to_s
    when OSX::NSAttributedString
      self.string.to_s
    when OSX::NSArray
      self.to_a.map { |x| x.is_a?(OSX::NSObject) ? x.to_ruby : x }
    when OSX::NSDictionary
      h = ::Plist4r::OrderedHash.new
      self.each do |x, y| 
        x = x.to_ruby if x.is_a?(OSX::NSObject)
        y = y.to_ruby if y.is_a?(OSX::NSObject)
        h[x] = y
      end
      h
    else
      self
    end
  end
end

module Plist  
  def write_result_file obj
    File.open @result_file, 'w' do |o|
      o << obj
    end
  end

  def to_xml input_file
    # to_plist defaults to NSPropertyListXMLFormat_v1_0
    hash = Marshal.load(File.read(input_file))
    x = hash.to_plist
    write_result_file x
  end

  def to_binary input_file
    # Here 200 == NSPropertyListBinaryFormat_v1_0
    hash = Marshal.load(File.read(input_file))
    x = hash.to_plist 200
    write_result_file x
  end

  def open filename
    plist_dict = ::OSX::NSDictionary.dictionaryWithContentsOfFile(filename)
    unless plist_dict
      plist_array = ::OSX::NSArray.arrayWithContentsOfFile(filename) unless plist_dict
      raise "Couldnt parse file: #{filename}" unless plist_array
      plist_dict = ::Plist4r::OrderedHash.new
      plist_dict["Array"] = plist_array.to_ruby
    end

    File.open @result_file, 'w' do |o|
      o.write Marshal.dump(plist_dict.to_ruby)
    end
  end

  # def save input_file, filename, file_format
  #   hash = Marshal.load(File.read(input_file))
  #   case file_format.to_sym
  #   when :xml
  #     x = hash.to_plist # NSPropertyListXMLFormat_v1_0
  #   when :binary
  #     x = hash.to_plist 200 # NSPropertyListBinaryFormat_v1_0
  #   when :gnustep
  #     raise "File format #{file_format.inspect} is not supported by RubyCocoa"
  #   else
  #     raise "File format #{file_format.inspect} not recognised"
  #   end
  #   # puts x
  #   File.open(filename,'w'){ |o| o << x }
  # end
end

class RubyCocoaWrapper
  include Plist

  def exec stdin
    @result_file = ARGV[1]
    instance_eval stdin
    exit 0
  end
end

stdin = $stdin.read()
wrapper = RubyCocoaWrapper.new()
wrapper.exec stdin
EOC
    end

    # Write a temporary script to the filesystem, then execute it
    # @param [String] stdin_str The command to run
    # @return [Array] cmd, status, stdout_result, stderr_result
    def ruby_cocoa_exec stdin_str
      rubycocoa_framework = "/System/Library/Frameworks/RubyCocoa.framework"
      raise "RubyCocoa Framework not found. Searched in: #{rubycocoa_framework}" unless File.exists? rubycocoa_framework

      require 'tempfile'
      require 'plist4r/mixin/popen4'

      unless @rb_script && File.exists?(@rb_script.path)
        @rb_script = Tempfile.new "ruby_cocoa_wrapper.rb."
        @rb_script.puts ruby_cocoa_wrapper_rb
        @rb_script.close
        File.chmod 0755, @rb_script.path
      end

      cmd = @rb_script.path
      plist4r_root = File.expand_path File.join(File.dirname(__FILE__), "..", "..")
      @result_file = Tempfile.new("result_file.rb")
      @result_file.close

      pid, stdin, stdout, stderr = ::Plist4r::Popen4::popen4 [cmd, plist4r_root, @result_file.path]

        stdin.puts stdin_str
        stdin.close

        ignored, status = [nil,nil]
        timeout = 15
        begin
          Timeout::timeout(timeout) do
            ignored, status = Process::waitpid2 pid
          end
        rescue Timeout::Error => exc
          puts "#{exc.message}, killing pid #{pid}"
          Process::kill('TERM', pid)
          # Process::kill('HUP', pid)
          ignored, status = Process::waitpid2 pid
        end

        stdout_result = stdout.read.strip
        stderr_result = stderr.read.strip

      return [cmd, status, stdout_result, stderr_result]    
    end

    def read_result_file
      File.read @result_file.path
    end

    def to_xml plist
      require 'tempfile'
      input_file = Tempfile.new "input_file.rb."
      input_file.puts Marshal.dump(plist.to_hash)
      input_file.close
      result = ruby_cocoa_exec "to_xml(\"#{input_file.path}\")"
      
      case result[1].exitstatus
      when 0
        xml_string = read_result_file
        return xml_string
      else
        $stderr.puts result[3]
        raise "Error executing #{result[0]}. See stderr for more information"
      end
    end

    def to_binary plist
      require 'tempfile'
      input_file = Tempfile.new "input_file.rb."
      input_file.puts Marshal.dump(plist.to_hash)
      input_file.close
      result = ruby_cocoa_exec "to_binary(\"#{input_file.path}\")"

      case result[1].exitstatus
      when 0
        binary_string = read_result_file
        return binary_string
      else
        $stderr.puts result[3]
        raise "Error executing #{result[0]}. See stderr for more information"
      end
    end

    def open_with_args plist, filename
      require 'date'

      result = ruby_cocoa_exec "open(\"#{filename}\")"
      case result[1].exitstatus
      when 0
        hash = ::Plist4r::OrderedHash.new
        hash.replace Marshal.load(read_result_file)
        plist.import_hash hash
      else
        $stderr.puts result[3]
        raise "Error executing #{result[0]}. See stderr for more information"
      end
      return plist
    end

    def from_string plist
      require 'tempfile'
      tf = Tempfile.new "from_string.plist."
      tf.write plist.from_string
      tf.close
      filename = tf.path
      return open_with_args plist, filename
    end

    def from_xml plist
      from_string plist
    end

    def from_binary plist
      from_string plist
    end

    def from_gnustep plist
      from_string plist
    end

    # def open plist
    #   return open_with_args plist, plist.filename_path
    # end

    # def save plist
    #   require 'plist4r/config'
    #   filename = plist.filename_path
    #   file_format = plist.file_format || Plist4r::Config[:default_format]
    #   raise "#{self} - cant save file of format #{file_format}" unless [:xml,:binary].include? file_format.to_sym
    # 
    #   require 'tempfile'
    #   input_file = Tempfile.new "input_file.rb."
    #   input_file.puts Marshal.dump(plist.to_hash)
    #   input_file.close
    # 
    #   result = ruby_cocoa_exec "save(\"#{input_file.path}\",\"#{filename}\",\"#{file_format}\")"
    # 
    #   case result[1].exitstatus
    #   when 0
    #     return true
    #   else
    #     raise "Error executing #{result[0]}. Stderr:" + result[3]
    #   end
    # end
  end
end

