require ENV['TM_SUPPORT_PATH'] + '/lib/escape.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes.rb'
require 'socket'
require 'timeout'

class Clojure::REPL
  attr_accessor :name, :tempfile
  
  PROMPT = /(.+?)=>/

  def initialize(name)
    self.name = name
  end
  
  def run
    vendor_dir = File.dirname(__FILE__) + "/../../Vendor"
    ENV['CLOJURE_HOME'] = vendor_dir
    ENV['REPL_PORT_FILE'] = port_file
    
    if not(File.exist?("#{vendor_dir}/clojure.jar"))
      msg = <<-MSG
        Didn't find clojure.jar file.

        Would you downlad and install Clojure ?
        MSG
      btn_install_clojure = "Install Clojure"
      btn_cancel = "Cancel"
      res = TextMate::UI.alert(
              :critical,"Error : missing clojure.jar",
              msg,btn_install_clojure,btn_cancel)
      if res == btn_install_clojure
        update_textmate
      else
        exit(1)
      end
    end
    
    cmd = File.expand_path(vendor_dir + "/clj")
    script = File.expand_path(File.dirname(__FILE__) + "/../repl.clj")

    system "screen -dm -S #{shell_name} #{e_sh cmd} -i #{e_sh script}"
    
    self
  end
  
  def update_textmate
    # TODO: Grab output or launch upadte command
    `"$CLOJURE_HOME/clj-update-and-build"`
    if $? != 0
      puts <<-MSG
<pre>
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Installation failed.
!! Try update command for more information
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
</pre>
MSG
      exit(1)
    else
      puts <<-MSG
<pre>
=====================================================
== Clojure is installed, retry your command
=====================================================
</pre>
MSG
      exit(0)
    end
  end
  
  def close
    evaluate("(System/exit 0)")
  end
  
  def restart
    close
    run
  end
  
  def connect_terminal
    Clojure::Util.connect_terminal(shell_name)
  end
  
  def shell_name()
    "ClojureMate-#{name}"
  end
  
  def port_file
    "#{Dir.tmpdir}/#{shell_name}.port"
  end
  
  def port(retries_left = 3)
    @port ||= Integer(IO.read(port_file))
  rescue Errno::ENOENT, ArgumentError
    retries_left -= 1
    if retries_left > 0
      sleep 3
      retry
    end
  end
  
  def evaluate(form)
    if sock = get_socket
      sock.puts <<-EOS
        #{form}
        :repl_eof
      EOS

      sock.flush
      sock.read
    end
  end
  
  private
  def get_socket(retries_left = 3)
    TCPSocket.new("localhost", port)
  rescue Errno::ECONNREFUSED
    retries_left -= 1
    if retries_left > 0
      sleep 3
      retry
    else
      File.unlink(port_file)
      raise "Could not contact the Repl"
    end
  end
end