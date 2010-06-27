
require 'plist4r/backend_base'

# This backend only works on MacOSX. It supports everything using a compiled CoreFoundation helper
# in ext directory, and uses native Cocoa CoreFoundation API calls. This backend invokes 
# CFPropertyListWriteToStream.
# 
# Should work for any 10.5 (Leopard), 10.6 (Snow Leopard) Mac OSX distribution.
# It will do nothing on non-mac platforms (eg Linux etc).
# @author Kevin Ballard (http://github.com/kballard)
# 
# @see Plist4r::Backend
module Plist4r::Backend::OsxPlist
  class << self

    def require_c_ext
      core_foundation_framework = "/System/Library/Frameworks/CoreFoundation.framework"
      unless File.exists? core_foundation_framework
        raise "CoreFoundation Framework not found. Searched in: #{core_foundation_framework}"
      end
      require "#{File.dirname(__FILE__)}/osx_plist/ext/osx_plist"
    end

    def from_string plist
      require_c_ext
      ruby_object = Plist4r::Backend::OsxPlist.load(plist.from_string, nil)

      hash_obj = nil
      if ruby_object.is_a? Hash
        hash_obj = ruby_object

      elsif ruby_object
        hash_obj = { ruby_object.class.to_s => ruby_object }

      else
        raise "Conversion tp plist object failed"
      end

      hash = ::Plist4r::OrderedHash.new
      hash.replace hash_obj
      plist.import_hash hash

      plist_format = Plist4r.string_detect_format plist.from_string
      plist.file_format plist_format

      return plist
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

    def to_xml plist
      require_c_ext
      string = ""
      sio = StringIO.new(string, "w")
      format = :xml1
      Plist4r::Backend::OsxPlist.dump(sio, plist.to_hash, format)
      return string
    end

    def to_binary plist
      require_c_ext
      string = ""
      sio = StringIO.new(string, "w")
      format = :binary1
      Plist4r::Backend::OsxPlist.dump(sio, plist.to_hash, format)
      return string
    end

    def to_gnustep plist
      require_c_ext
      string = ""
      sio = StringIO.new(string, "w")
      format = :openstep
      Plist4r::Backend::OsxPlist.dump(sio, plist.to_hash, format)
      return string
    end

  end
end



