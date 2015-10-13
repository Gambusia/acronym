#!/usr/bin/env ruby
require 'optparse'

=begin
	A tool to generate acronyms from a list of words or phrases.
    Copyright (C) 2015  Greg Pyle

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published by
    the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/gpl.html>.
=end

mypath = File.dirname(__FILE__)

# Collect options in an array
options = {}

optparse = OptionParser.new do |opts|
   # Display a banner at the top of a help page
   opts.banner = "Usage: Create acronyms from a simple list of words or phrases."

   options[:n] = ''
   opts.on('-n', '--num', 'The number (or range) of characters to use in generated acronyms.') do |cnumber|
      option[:n] = cnumber
   end
   
   options[:l] = 1
   opts.on('-l', '--limit', 'Restrict acronym characters to the first x characters of each word.') do |limit|
   		options[:l] = limit
   end
   
   options[:o] = ''
   opts.on('-o', '--out', 'The name (and path if not the current directory) of the output file.') do |output|
   		option[:o] = output
   end
   
   options[:p] = false
   opts.on('-p', '--phrase', 'true = only include first letter; false = include first letter of each word.') do |phrase|
   		option[:p] = phrase
   end
   
   # Display the help screen.
	opts.on( '-h', '--help', 'Display this screen') do
		puts opts
		exit
	end
   
   

end

# This is the parser
optparse.parse!

# Capture all the words that will be used to create acronyms.
wordlist = Array.new
ARGF.each_line { |line| wordlist.push(line) }





