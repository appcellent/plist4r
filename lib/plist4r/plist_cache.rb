
require 'plist4r/backend'

class Plist4r::PlistCache
  def initialize plist, *args, &blk
    @plist = plist
    @backend = Backend.new plist, *args, &blk
  end
  
  def checksum
    @plist.to_hash.hash
  end
  
  def last_checksum
    @checksum
  end

  def update_checksum
    @checksum = @plist.to_hash.hash
  end

  def needs_update
    checksum != last_checksum
  end

  def to_xml
    if needs_update
      update_checksum
      @xml = @backend.call :to_xml
    else
      @xml
    end
  end
  
  def to_binary
    if needs_update
      update_checksum
      @binary = @backend.call :to_binary
    else
      @binary
    end
  end

  def to_next_step
    if needs_update
      update_checksum
      @next_step = @backend.call :to_next_step
    else
      @next_step
    end
  end
  
  def open
    @backend.call :load
    update_checksum    
  end
  
  def save
    if needs_update
      update_checksum
      @backend.call :save
    else
      true
    end
  end
end
