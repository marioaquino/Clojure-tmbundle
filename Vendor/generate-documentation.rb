#!/usr/bin/env ruby
require 'fileutils'

CLOJURE_VERSION = "1.2.0"

def grab(name, version)
  name_ver = "#{name}-#{version}"
  zip_file_name = "#{name_ver}.zip"
  
  msg "Downloading #{zip_file_name} from GitHub"
  
  `curl -OL http://github.com/downloads/clojure/#{name}/#{zip_file_name}`
  
  msg "Unzipping #{zip_file_name}"

	`unzip #{zip_file_name}`

	yield name_ver, name
	
	FileUtils.rm_rf zip_file_name
	FileUtils.mv name_ver, name
end

def msg(text)
  puts <<-MSG

  	=====================================================
  	== #{text}
  	=====================================================

MSG
end

grab("clojure", CLOJURE_VERSION) {|name_ver, name|
  FileUtils.mv "#{name_ver}/#{name}.jar", "#{name}.jar"
}

grab("clojure-contrib", CLOJURE_VERSION) {|name_ver, name|
  FileUtils.mv "#{name_ver}/target/#{name_ver}.jar", "#{name}.jar"
}

msg "Generating documentation for clojure & clojure-contrib"

FileUtils.rm_rf 'clojure-documentation'

FileUtils.cd 'clj-doc'

`ant -q -Dclojure_jar=../clojure.jar -Dclojure_contrib_jar=../clojure-contrib.jar`