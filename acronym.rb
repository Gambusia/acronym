#!/usr/bin/env ruby
require "optparse"
require "pry"

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

# Open a dictionary and read all the words
dict = {}
File.open("/usr/share/dict/words") do |file|
    file.each do |line|
	dict[line.strip] = true
    end
end

def dictionary_acronyms(pa, wa)
    list = Hash.new
    pa.each do |acronym.join("")|
	if dict[acronym.join("")] == true
	    list.push(acronym.join("") => wa[pa.index].join(" "))
	end
    end
    return list
end

mypath = File.dirname(__FILE__)

# Collect options in an array
options = {}

optparse = OptionParser.new do |opts|
   # Display a banner at the top of a help page
   opts.banner = "Usage: Create acronyms from a simple list of words or phrases."

   options[:n] = ""
   opts.on("-n", "--num number", "The number (or range) of characters to use in generated acronyms.") do |number|
      options[:n] = number
   end
   
   options[:l] = 1
   opts.on("-l", "--limit", "Restrict acronym characters to the first x characters of each word.") do |limit|
   		options[:l] = limit
		puts "Caution: The -l flag has not yet been implemented. Acronyms will be limited to the first letter of each word supplied."
   end
   
   options[:r] = false
   opts.on("-r", "--order", "true = maintain word order; false = do not maintain word order") do |order|
   		options[:r] = order
   end
   
   options[:o] = ""
   opts.on("-o", "--out", "The name (and path if not the current directory) of the output file.") do |output|
   		options[:o] = output
   end
   
   options[:p] = false
   opts.on("-p", "--phrase", "true = only include first letter; false = include first letter of each word.") do |phrase|
   		options[:p] = phrase
   end
   
   # Display the help screen.
	opts.on( "-h", "--help", "Display this screen") do
		puts opts
		exit
	end
end

# This is the parser
optparse.parse!

# Determine the length of acronym to be generated based on user input
if options[:n].to_s.include?("-")
    n = options[:n].split("-")
    begin    
        nmin = n.min.to_i
        nmax = n.max.to_i
    rescue
	msg = "Error: there is a problem with the number range for characters to be used to generate acronyms."
	puts msg
	exit
    end
else
    begin
	n = options[:n].to_i
    rescue
	msg = "Error: there is a problem with the number of characters to be used for generating acronyms."
	puts msg
	exit
    end
end

# Capture all the words that will be used to create acronyms in an array.
words = Array.new
ARGF.each_line {|line| words.push(line.downcase)}

# This hash will hold letters as arrays indexed by the supplied words.
letters = Hash.new
words.each {|word| letters[word] = word.scan(/./)}

# Create an array to hold the first letters of every word; letters to be used in acronym generation.
acarray = Array.new
words.each {|word| acarray.push(letters[word][0])}

# Make use of Ruby"s permutation or combination functions--because they"re awesome!!
if options[:r] == false
    if n == ""
	pa = acarray.permutation.to_a
	wa = words.permutation.to_a
    elsif n.length > 1
	i = *(nmin .. nmax)
	i.each do |num|
	    pa = acarray.permutation(num).to_a # All potential acronyms of length "num"
	    wa = words.permutation(num).to_a # Words permuted similarly as acronyms. Can pull words corresponding to acronyms by index.
	end
    elsif n.length == 1
	pa = acarray.permutation(n).to_a
	wa = words.permutation(n).to_a
    end
	
elsif options[:r] == true # Order matters
    pa = acarray.combination.to_a
    wa = words.combination.to_a
end

# pa.each {|acronym| p "Acronym #{acronym.join} is a word: #{dict[acronym.join]}."}
binding.pry
dictionary_acronyms(pa.join(""), wa.strip.join(" ")).each {|acronym, phrase| puts "#{acronym} \t #{phrase}\n"}
