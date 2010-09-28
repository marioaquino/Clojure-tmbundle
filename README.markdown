# Clojure.tmbundle

## Prerequisites

The Clojure bundle depends on the following external utilities to work:

* bash
* ruby
* osascript

If either of those aren't on your TextMate's PATH, these commands will fail in unknown and spectacular fashion.

Additionally, if clj is not found on your TextMate's PATH, then it will use the one included in this bundle. You can manually specify it with the TM_CLJ variable.

## Installation

Run this:
 
	$ cd ~/Library/Application\ Support/TextMate/Bundles
	$ git clone git://github.com/marioaquino/Clojure-tmbundle.git Clojure.tmbundle
	$ osascript -e 'tell app "TextMate" to reload bundles'

An update script will :

* Get Clojure and Clojure-contrib from Github.
* Build off-line documentation from clojure source.

Run this :

  $ cd Clojure.tmbundle/Vendor
	$ ./generate-documentation.rb
