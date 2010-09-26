#!/usr/bin/env ruby

def grab(name, version)
  name_ver = "#{name}-#{version}"
  zip_file_name = "#{name_ver}.zip"
  
  msg "Downloading #{zip_file_name} from GitHub"
  
  `curl -OL http://github.com/downloads/clojure/#{name}/#{zip_file_name}`
  
  msg "Unzipping #{zip_file_name}"
	`unzip #{zip_file_name}`
	yield name_ver, name
	
	`rm -rf #{zip_file_name} #{name_ver}`
end

def msg(text)
  puts <<-MSG

  	=====================================================
  	== #{text}
  	=====================================================

MSG
end

grab("clojure", "1.2.0") {|name_ver, name|
  `mv -f #{name_ver}/#{name}.jar .`
}

grab("clojure-contrib", "1.2.0") {|name_ver, name|
  `mv -f #{name_ver}/target/#{name_ver}.jar #{name}.jar`
}

msg "Successfully updated clojure and clojure-contrib libraries"

# `./clj-update-documentation`