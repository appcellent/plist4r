


require 'plist4r/plist_type'

module Plist4r
  class PlistType::Launchd < PlistType

    def valid_keys
      {
        :string => %w[Label UserName GroupName LimitLoadToSessionType Program RootDirectory WorkingDirectory StandardInPath StandardOutPath StandardErrorPath],
        :bool => %w[Disabled EnableGlobbing EnableTransactions OnDemand RunAtLoad InitGroups StartOnMount Debug WaitForDebugger AbandonProcessGroup HopefullyExitsFirst HopefullyExitsLast LowPriorityIO LaunchOnlyOnce],
        :integer => %w[Umask TimeOut ExitTimeOut ThrottleInterval StartInterval Nice],
        :array_of_strings => %w[LimitLoadToHosts LimitLoadFromHosts ProgramArguments WatchPaths QueueDirectories],
        :complex_keys => %w[inetdCompatibility KeepAlive EnvironmentVariables StartCalendarInterval SoftResourceLimits, HardResourceLimits MachServices Sockets]
      }
    end
  

    # :call-seq:
    #   inetdCompatibility({:wait => true})
    #   inetdCompatibility -> hash or nil
    #
    # inetd_compatibility <hash>
    # The presence of this key specifies that the daemon expects to be run as if it were launched from inetd.
    # 
    #   :wait <boolean>
    #   This flag corresponds to the "wait" or "nowait" option of inetd. If true, then the listening socket is passed via the standard in/out/error file descriptors.
    #   If false, then accept(2) is called on behalf of the job, and the result is passed via the standard in/out/error descriptors.
    def inetd_compatibility value=nil
      key = "inetdCompatibility"
      case value
      when Hash
        if value[:wait]
          @hash[key] = value[:wait]
        else
          raise "Invalid value: #{method_name} #{value.inspect}. Should be: #{method_name} :wait => true|false"
        end
      when nil
        @hash[key]
      else
        raise "Invalid value: #{method_name} #{value.inspect}. Should be: #{method_name} :wait => true|false"
      end
    end
  
    class KeepAlive < ArrayDict
      def valid_keys
        {
          :bool => %w[SuccessfulExit NetworkState],
          :hash_of_bools => %w[PathState OtherJobEnabled]
        }
      end
    end

    # :call-seq:
    #   keep_alive(true)
    #   keep_alive(false)
    #   keep_alive { block_of_keys }
    #   keep_alive => true, false, Hash, or nil
    #
    # keep_alive <boolean or block of keys>
    # This optional key is used to control whether your job is to be kept continuously running or to let demand and conditions control the invocation. The default is
    # false and therefore only demand will start the job. The value may be set to true to unconditionally keep the job alive. Alternatively, a dictionary of conditions
    # may be specified to selectively control whether launchd keeps a job alive or not. If multiple keys are provided, launchd ORs them, thus providing maximum flexibil-
    # ity to the job to refine the logic and stall if necessary. If launchd finds no reason to restart the job, it falls back on demand based invocation.  Jobs that exit
    # quickly and frequently when configured to be kept alive will be throttled to converve system resources.
    # 
    # keep_alive do
    # 
    #   successful_exit <boolean>
    #   If true, the job will be restarted as long as the program exits and with an exit status of zero.  If false, the job will be restarted in the inverse condi-
    #   tion.  This key implies that "RunAtLoad" is set to true, since the job needs to run at least once before we can get an exit status.
    # 
    #   network_state <boolean>
    #   If true, the job will be kept alive as long as the network is up, where up is defined as at least one non-loopback interface being up and having IPv4 or IPv6
    #   addresses assigned to them.  If false, the job will be kept alive in the inverse condition.
    # 
    #   path_state <hash of booleans>
    #   Each key in this dictionary is a file-system path. If the value of the key is true, then the job will be kept alive as long as the path exists.  If false, the
    #   job will be kept alive in the inverse condition. The intent of this feature is that two or more jobs may create semaphores in the file-system namespace.
    # 
    #   other_job_enabled <hash of booleans>
    #   Each key in this dictionary is the label of another job. If the value of the key is true, then this job is kept alive as long as that other job is enabled.
    #   Otherwise, if the value is false, then this job is kept alive as long as the other job is disabled.  This feature should not be considered a substitute for
    #   the use of IPC.
    # 
    # end
    # 
    # Example:
    # 
    # keep_alive do
    #   successful_exit true
    #   network_state false
    # end
    # 
    def keep_alive value=nil, &blk
      key = "KeepAlive"
    
      case value
      when TrueCass, FalseClass
        @hash[key] = value
      when nil
        if blk
          @hash[key] ||= ::ActiveSupport::OrderedHash.new
          @hash[key] = ::LaunchdPlistStructs::KeepAlive.new(@hash[key],&blk).hash
        else
          @hash[key]
        end
      else
        raise "Invalid value: #{method_name} #{value.inspect}. Should be: #{method_name} true|false, or #{method_name} { block }"
      end
    end

    # :call-seq:
    #   environment_variables({"VAR1" => "VAL1", "VAR2" => "VAL2"})
    #   environment_variables -> hash or nil
    #
    # environment_variables <hash of strings>
    # This optional key is used to specify additional environmental variables to be set before running the job.
    def environment_variables value=nil, &blk
      key = "EnvironmentVariables"
      case value
      when Hash
        value.each do |k,v|
          unless k.class == String
            raise "Invalid key: #{method_name}[#{k.inspect}]. Should be of type String"
          end
          unless v.class == String
            raise "Invalid value: #{method_name}[#{k.inspect}] = #{v.inspect}. Should be of type String"
          end
        end
        @hash[key] = value
      when nil
        @hash[key]
      else
        raise "Invalid value: #{method_name} #{value.inspect}. Should be: #{method_name} { hash_of_strings }"
      end
    end

    class StartCalendarInterval < ArrayDict
      def valid_keys
        { :integer => %w[Minute Hour Day Weekday Month] }
      end
    end

    # :call-seq:
    #   start_calendar_interval(array_index=nil) { block_of_keys }
    #   start_calendar_interval -> array or nil
    #
    # start_calendar_interval <array_index=nil> <block of keys>
    # This optional key causes the job to be started every calendar interval as specified. Missing arguments are considered to be wildcard. The semantics are much like
    # crontab(5).  Unlike cron which skips job invocations when the computer is asleep, launchd will start the job the next time the computer wakes up.  If multiple
    # intervals transpire before the computer is woken, those events will be coalesced into one event upon wake from sleep.
    # 
    # start_calendar_interval index=nil do
    # 
    #   Minute <integer>
    #   The minute on which this job will be run.
    # 
    #   Hour <integer>
    #   The hour on which this job will be run.
    # 
    #   Day <integer>
    #   The day on which this job will be run.
    # 
    #   Weekday <integer>
    #   The weekday on which this job will be run (0 and 7 are Sunday).
    # 
    #   Month <integer>
    #   The month on which this job will be run.
    # 
    # end
    # 
    # Example:
    # 
    # start_calendar_interval 0 do
    #   hour   02
    #   minute 05
    #   day    06
    # end
    # 
    # start_calendar_interval 1 do
    #   hour   02
    #   minute 05
    #   day    06
    # end
    # 
    def start_calendar_interval index=nil, &blk
      key = "StartCalendarInterval"
      unless [Fixnum,NilClass].include? index.class
        raise "Invalid index: #{method_name} #{index.inspect}. Should be: #{method_name} <integer>"
      end
      if blk
        @hash[key] ||= []
        h = ::LaunchdPlistStructs::StartCalendarInterval.new(@hash[key],index,&blk).hash
        if index
          @hash[key][index] = h
        else
          @hash[key] << h
        end
      else
        @hash[key]
      end
    end

    class ResourceLimits < ArrayDict
      def valid_keys
        { :integer => %w[Core CPU Data FileSize MemoryLock NumberOfFiles NumberOfProcesses ResidentSetSize Stack] }
      end
    end
  
    # :call-seq:
    #   soft_resource_limits { block_of_keys }
    #   soft_resource_limits -> hash or nil
    #
    # soft_resource_limits <block of keys>
    # Resource limits to be imposed on the job. These adjust variables set with setrlimit(2).  The following keys apply:
    # 
    # soft_resource_limits do
    # 
    #   Core <integer>
    #   The largest size (in bytes) core file that may be created.
    # 
    #   CPU <integer>
    #   The maximum amount of cpu time (in seconds) to be used by each process.
    # 
    #   Data <integer>
    #   The maximum size (in bytes) of the data segment for a process; this defines how far a program may extend its break with the sbrk(2) system call.
    # 
    #   FileSize <integer>
    #   The largest size (in bytes) file that may be created.
    # 
    #   MemoryLock <integer>
    #   The maximum size (in bytes) which a process may lock into memory using the mlock(2) function.
    # 
    #   NumberOfFiles <integer>
    #   The maximum number of open files for this process.  Setting this value in a system wide daemon will set the sysctl(3) kern.maxfiles (SoftResourceLimits) or
    #   kern.maxfilesperproc (HardResourceLimits) value in addition to the setrlimit(2) values.
    # 
    #   NumberOfProcesses <integer>
    #   The maximum number of simultaneous processes for this user id.  Setting this value in a system wide daemon will set the sysctl(3) kern.maxproc (SoftResource-
    #   Limits) or kern.maxprocperuid (HardResourceLimits) value in addition to the setrlimit(2) values.
    # 
    #   ResidentSetSize <integer>
    #   The maximum size (in bytes) to which a process's resident set size may grow.  This imposes a limit on the amount of physical memory to be given to a process;
    #   if memory is tight, the system will prefer to take memory from processes that are exceeding their declared resident set size.
    # 
    #   Stack <integer>
    #   The maximum size (in bytes) of the stack segment for a process; this defines how far a program's stack segment may be extended.  Stack extension is performed
    #   automatically by the system.
    # 
    # end
    # 
    # Example:
    # 
    # soft_resource_limits do
    #   NumberOfProcesses 4
    #   NumberOfFiles 512
    # end
    # 
    def soft_resource_limits value=nil, &blk
      key = "SoftResourceLimits"
      if blk
        @hash[key] ||= ::ActiveSupport::OrderedHash.new
        @hash[key] = ::LaunchdPlistStructs::ResourceLimits.new(@hash[key],&blk).hash
      else
        @hash[key]
      end
    end

    # :call-seq:
    #   hard_resource_limits { block_of_keys }
    #   hard_resource_limits -> hash or nil
    #
    # hard_resource_limits <block of keys>
    # Resource limits to be imposed on the job. These adjust variables set with setrlimit(2).  The following keys apply:
    # 
    # hard_resource_limits do
    # 
    #   Core <integer>
    #   The largest size (in bytes) core file that may be created.
    # 
    #   CPU <integer>
    #   The maximum amount of cpu time (in seconds) to be used by each process.
    # 
    #   Data <integer>
    #   The maximum size (in bytes) of the data segment for a process; this defines how far a program may extend its break with the sbrk(2) system call.
    # 
    #   FileSize <integer>
    #   The largest size (in bytes) file that may be created.
    # 
    #   MemoryLock <integer>
    #   The maximum size (in bytes) which a process may lock into memory using the mlock(2) function.
    # 
    #   NumberOfFiles <integer>
    #   The maximum number of open files for this process.  Setting this value in a system wide daemon will set the sysctl(3) kern.maxfiles (SoftResourceLimits) or
    #   kern.maxfilesperproc (HardResourceLimits) value in addition to the setrlimit(2) values.
    # 
    #   NumberOfProcesses <integer>
    #   The maximum number of simultaneous processes for this user id.  Setting this value in a system wide daemon will set the sysctl(3) kern.maxproc (SoftResource-
    #   Limits) or kern.maxprocperuid (HardResourceLimits) value in addition to the setrlimit(2) values.
    # 
    #   ResidentSetSize <integer>
    #   The maximum size (in bytes) to which a process's resident set size may grow.  This imposes a limit on the amount of physical memory to be given to a process;
    #   if memory is tight, the system will prefer to take memory from processes that are exceeding their declared resident set size.
    # 
    #   Stack <integer>
    #   The maximum size (in bytes) of the stack segment for a process; this defines how far a program's stack segment may be extended.  Stack extension is performed
    #   automatically by the system.
    # 
    # end
    # 
    # Example:
    # 
    # hard_resource_limits do
    #   NumberOfProcesses 4
    #   NumberOfFiles 512
    # end
    # 
    def hard_resource_limits value=nil, &blk
      key = "HardResourceLimits"
      if blk
        @hash[key] ||= ::ActiveSupport::OrderedHash.new
        @hash[key] = ::LaunchdPlistStructs::ResourceLimits.new(@hash[key],&blk).hash
      else
        @hash[key]
      end
    end

  	class MachServices < ArrayDict
    	class MachService < ArrayDict
    	  def valid_keys
          { :bool => %w[ResetAtClose HideUntilCheckIn] }
        end
      end

  	  def add service, value=nil, &blk
        if value
    	    @hash[service] = value
          set_or_return :bool, service, value
        elsif blk
          @hash[service] = ::ActiveSupport::OrderedHash.new
          @hash[service] = ::LaunchdPlistStructs::MachServices::MachService.new(@hash[service],&blk).hash
        else
          @orig
        end
      end    
    end
  
    # :call-seq:
    #   mach_services { block }
    #   mach_services -> hash or nil
    #
    # mach_services <dictionary of booleans or a dictionary of dictionaries>
    # This optional key is used to specify Mach services to be registered with the Mach bootstrap sub-system.  Each key in this dictionary should be the name of service
    # to be advertised. The value of the key must be a boolean and set to true.  Alternatively, a dictionary can be used instead of a simple true value.
    # 
    #   ResetAtClose <boolean>
    #   If this boolean is false, the port is recycled, thus leaving clients to remain oblivious to the demand nature of job. If the value is set to true, clients
    #   receive port death notifications when the job lets go of the receive right. The port will be recreated atomically with respect to bootstrap_look_up() calls,
    #   so that clients can trust that after receiving a port death notification, the new port will have already been recreated. Setting the value to true should be
    #   done with care. Not all clients may be able to handle this behavior. The default value is false.
    # 
    #   HideUntilCheckIn <boolean>
    #   Reserve the name in the namespace, but cause bootstrap_look_up() to fail until the job has checked in with launchd.
    # 
    # Finally, for the job itself, the values will be replaced with Mach ports at the time of check-in with launchd.
    # 
    # Example:
    # 
    # mach_services do
    #   add "com.apple.afpfs_checkafp", true
    # end
    # 
    # mach_services do
    #   add "com.apple.AppleFileServer" do
    #     hide_until_check_in true
    #     reset_at_close false
    #   end
    # end
    # 
    def mach_services value=nil, &blk
      key = "MachServices"
      if blk
        @hash[key] ||= ::ActiveSupport::OrderedHash.new
        @hash[key] = ::LaunchdPlistStructs::MachServices.new(@hash[key],&blk).hash
      else
        @hash[key]
      end
    end

    class Sockets < ArrayDict
      class Socket < ArrayDict
        def valid_keys
          {
            :string => %w[SockType SockNodeName SockServiceName SockFamily SockProtocol SockPathName SecureSocketWithKey MulticastGroup],
            :bool => %w[SockPassive],
            :integer => %w[SockPathMode],
            :bool_or_string_or_array_of_strings => %w[Bonjour]
          }
        end
      end

      def add_socket_to_dictionary key, &blk
        @hash[key] = ::LaunchdPlistStructs::Sockets::Socket.new(@hash[key],&blk).hash
      end

      def add_socket_to_array key, index, &blk
        @orig[key] = [] unless @orig[key].class == Array
        @hash[key] ||= []
        @hash[key][index] = ::LaunchdPlistStructs::Sockets::Socket.new(@orig[key],index,&blk).hash
      end

      def add_socket plicity, key, index=nil, &blk
        select_all
        if plicity == :implicit
          if index && @orig[key].class != Array
            raise "Implicit \"Listeners\" socket already exists, and is of a different type (not array of hashes). Override with: socket \"Listeners\" #{index} &blk"
          elsif @orig[key]
            raise "Implicit \"Listeners\" socket already exists, value: #{orig[key]}. Override with: socket \"Listeners\" &blk"
          end
        end
        if index
          add_socket_to_array key, index, &blk
        else
          add_socket_to_dictionary key, &blk
        end
      end
    end

    # :call-seq:
    #   sockets(socket_key="Listeners") { block_of_keys }
    #   sockets(socket_key="Listeners", socket_index) { block_of_keys }
    #   sockets -> hash or nil
    #
    # socket <array_index=nil> <block of keys>
    # socket <dictionary... OR dictionary + array index...>
    # 
    # Please See: http://developer.apple.com/mac/library/documentation/MacOSX/Conceptual/BPSystemStartup/Articles/LaunchOnDemandDaemons.html
    # for more information about how to properly use the Sockets feature
    # 
    # This optional key is used to specify launch on demand sockets that can be used to let launchd know when to run the job. The job must check-in to get a copy of the
    # file descriptors using APIs outlined in launch(3).  The keys of the top level Sockets dictionary can be anything. They are meant for the application developer to
    # use to differentiate which descriptors correspond to which application level protocols (e.g. http vs. ftp vs. DNS...).  At check-in time, the value of each Sockets
    # dictionary key will be an array of descriptors. Daemon/Agent writers should consider all descriptors of a given key to be to be effectively equivalent, even though
    # each file descriptor likely represents a different networking protocol which conforms to the criteria specified in the job configuration file.
    # The parameters below are used as inputs to call getaddrinfo(3).
    # 
    # socket "socket_key" do
    # 
    #   SockType <string>
    #   This optional key tells launchctl what type of socket to create. The default is "stream" and other valid values for this key are "dgram" and "seqpacket"
    #   respectively.
    # 
    #   SockPassive <boolean>
    #   This optional key specifies whether listen(2) or connect(2) should be called on the created file descriptor. The default is true ("to listen").
    # 
    #   SockNodeName <string>
    #   This optional key specifies the node to connect(2) or bind(2) to.
    # 
    #   SockServiceName <string>
    #   This optional key specifies the service on the node to connect(2) or bind(2) to.
    # 
    #   SockFamily <string>
    #   This optional key can be used to specifically request that "IPv4" or "IPv6" socket(s) be created.
    # 
    #   SockProtocol <string>
    #   This optional key specifies the protocol to be passed to socket(2).  The only value understood by this key at the moment is "TCP".
    # 
    #   SockPathName <string>
    #   This optional key implies SockFamily is set to "Unix". It specifies the path to connect(2) or bind(2) to.
    # 
    #   SecureSocketWithKey <string>
    #   This optional key is a variant of SockPathName. Instead of binding to a known path, a securely generated socket is created and the path is assigned to the
    #   environment variable that is inherited by all jobs spawned by launchd.
    # 
    #   SockPathMode <integer>
    #   This optional key specifies the mode of the socket. Known bug: Property lists don't support octal, so please convert the value to decimal.
    # 
    #   Bonjour <boolean or string or array of strings>
    #   This optional key can be used to request that the service be registered with the mDNSResponder(8).  If the value is boolean, the service name is inferred from
    #   the SockServiceName.
    # 
    #   MulticastGroup <string>
    #   This optional key can be used to request that the datagram socket join a multicast group.  If the value is a hostname, then getaddrinfo(3) will be used to
    #   join the correct multicast address for a given socket family.  If an explicit IPv4 or IPv6 address is given, it is required that the SockFamily family also be
    #   set, otherwise the results are undefined.
    # 
    # end
    # 
    # NOTE:
    # Sockets is a complex structure. If you are manupilating an existing Sockets entry, then you must fully specify the key you want to modify.
    # so `socket do` should be written as `socket "Listeners" do`, (and in the case of an array of sockets) `socket 0 do` should be written as `socket "Listeners" 0 do`
    # 
    # Examples:
    # 
    # # scenario 1:
    #  socket do
    #    sock_service_name "netbios-ssn"
    #  end
    # # => Result: Ok. The default "Listeners" toplevel key is generated implicitly.
    # 
    # # scenario 2:
    #  socket do
    #    sock_service_name "netbios-ssn"
    #  end
    #  socket do
    #    sock_service_name "netbios"
    #    bonjour ['smb']
    #  end
    # # => Result: Exception error is raise the second time because the "Listeners" key already exists. We can forcefully overwrite this existing sockets key with `socket "Listeners" do`.
    # 
    # # scenario 3:
    #  socket "netbios-ssn" do
    #    sock_service_name "netbios-ssn"
    #  end
    #  socket "netbios" do
    #    sock_service_name "netbios"
    #    bonjour ['smb']
    #  end
    # => Result: Ok. Each Sockets entry has a unique key.
    # 
    # # scenario 4:
    #  socket 0 do
    #    sock_service_name "netbios-ssn"
    #  end
    #  socket 1 do
    #    sock_service_name "netbios"
    #    bonjour ['smb']
    #  end
    # # => Result: Ok. Each Sockets entry has a unique array index. The array of all these sockets is held within the default "Listeners" key (implicit array or sockets).
    # 
    # # scenario 5:
    #  socket do
    #    sock_service_name "netbios-ssn"
    #  end
    #  socket[0] do
    #    sock_service_name "netbios"
    #    bonjour ['smb']
    #  end
    # # => Result: Exception error. because we cant mix and match types with the implicit "Listeners" key. If in doubt then avoid using the arrays.
    # 
    def socket index_or_key=nil, index=nil, &blk
      key = "Sockets"
      if blk
        @hash[key] ||= ::ActiveSupport::OrderedHash.new
        sockets = ::LaunchdPlistStructs::Sockets.new(@hash[key]).hash
      
        case index_or_key
        when nil
          sockets.add_socket :implicit, "Listeners", &blk
        when String
          socket_key = index_or_key
          unless index.class == Fixnum
            raise "Invalid sockect index: #{method_name} #{socket_key} #{index.inspect}. Should be: #{method_name} <socket_key> <socket_index> &blk"          
          end
          socket_index = index
          sockets.add_socket :explicit, socket_key, socket_index, &blk
        when Fixnum
          socket_index = index_or_key
          sockets.add_socket :implicit, "Listeners", socket_index, &blk        
        else
          raise "Invalid socket key: #{method_name} #{index_or_key.inspect}. Should be: #{method_name} <socket_key> &blk"
        end
        @hash[key] = sockets
      else
        @hash[key]
      end
    end
  end
end

