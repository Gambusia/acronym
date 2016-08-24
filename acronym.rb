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

def raw_acronyms(acronyms, words)
    list = Hash.new
    working_acronyms = Array.new
    acronyms.each {|candidate_acronym| working_acronyms.push(candidate_acronym.join)}
    i = 0
    working_acronyms.each do |acronym|
	list[acronym] = words[i].map(&:capitalize).join(" ")
	i = i + 1
    end
    return list
end


def dictionary_acronyms(acronyms, words)
    # Open a dictionary and read all the words
    dict = {}
    File.open("/usr/share/dict/words") do |file|
	file.each do |line|
	    dict[line.strip] = true
	end
    end
    list = Hash.new
    working_acronyms = Array.new
    acronyms.each {|candidate_acronym| working_acronyms.push(candidate_acronym.join)}
    
    # Convert the acronyms array to actual acronyms
    i = 0
    working_acronyms.each do |acronym|
	if dict[acronym] == true
	    list[acronym] = words[i].map(&:capitalize).join(" ")
	end
	i = i + 1
    end
    return list
end

# Output the acronyms: 
# msg = a message indicating the list of acronyms in the output (e.g., 3-letter acronyms)
# format = either into a file or to STOUT
# file = file name or path where output should be directed
# list = a hash containing acronyms (key) and associated phrases (value)
def output(msg, file, list)
    header = "\n== Acronym Maker Output ==\n\n"
    if file != ""
	if File.exists?(file)
	    File.open(file, 'a') do |f|
		f.write msg
		list.each do |acronym, words|
		    f.write("#{acronym.upcase} \t #{words}\n")
		end
	    end
	else
	    begin
		f = File.new(file, "w+")
		File.open(f, "w") do |f|
		    f.write header
		    f.write msg
		    list.each do |acronym, words|
			f.write("#{acronym.upcase} \t #{words}\n")
		    end
		end
	    rescue
		puts "Error: the file name or path provided is incorrect."
		exit
	    end
	end
    else
	puts header
	puts msg
	list.each {|acronym, words| puts "#{acronym.upcase} \t #{words}\n"}
    end
end

mypath = File.dirname(__FILE__)

# Collect options in an array
options = {}

optparse = OptionParser.new do |opts|
   # Display a banner at the top of a help page
   opts.banner = "Usage: Create acronyms from a simple list of words or phrases."

   options[:d] = true
   opts.on("-d", "--[no-]dictionary", "Do not cross-reference acronyms with dictionary.") do |dict|
	options[:d] = false	
   end

   options[:n] = ""
   opts.on("-n", "--number [x-y]x", "The number x or range x-y of characters to use in generated acronyms.") do |number|
	options[:n] = number
   end
   
   options[:l] = 1
   opts.on("-l", "--limit x", Integer, "Restrict acronym characters to the first x characters of each word.") do |limit|
	options[:l] = limit
	puts "Caution: The -l flag has not yet been implemented. Acronyms will be limited to the first letter of each word supplied.\n"
   end
   
   options[:r] = false
   opts.on("-r", "--[no-]order", "Maintain word list order for generating acronyms.") do |order|
	options[:r] = true
   end
   
   options[:o] = ""
   opts.on("-o", "--out FILENAME", "The name (and path if not the current directory) of the output file.") do |output|
	options[:o] = output
   end
   
   options[:s] = false
   opts.on("-s", "--[no-]separate", "Treat each word in a phrase separately.") do |phrase|
	options[:s] = true
	puts "Caution: The -s flag has not yet been implemented. Only first letters will be used to generate acronyms.\n"
   end
   
   # Display the help screen.
    opts.on( "-h", "--help", "Display this screen") do
	puts opts
	exit
    end
end

# This is the parser
optparse.parse!


# Capture all the words that will be used to create acronyms in an array.
words_array = Array.new

ARGF.each_line {|line| words_array.push(line.downcase.strip)}

# This hash will hold letters as arrays indexed by the supplied words.
letters = Hash.new
words_array.each {|word| letters[word] = word.scan(/./)}
# binding.pry

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
    if nmax > words_array.length
	nmax = words_array.length
    end
else
    begin
	if options[:n] == "" || options[:n].to_i > words_array.length
	    n = words_array.length
	else
	    n = options[:n].to_i
	end
    rescue
	msg = "Error: there is a problem with the number of characters to be used for generating acronyms."
	puts msg
	exit
    end
end

# Create an array to hold the first letters of every word; letters to be used in acronym generation.
acarray = Array.new
words_array.each {|word| acarray.push(letters[word][0])}

# Either a named file or output to standard output if left blank.
file = options[:o]

# This is the application logic.
# Start by testing n; if n == "" then just generate acronyms of length corresponding to the number of words provided.
if n == words_array.length 
    # Maintain the letter order according to the order the words were provided if options[:r] == true
    if options[:r] == false
	acronyms = acarray.permutation.to_a
	words = words_array.permutation.to_a
    elsif options[:r] == true
	acronyms = acarray.combination.to_a
	words = words_array.combination.to_a
    else
	puts "Error: the -r flag only accepts true if order matters or false if it doesn't."
	exit
    end
    length = words_array.length

    # options[:d] cross references a dictionary to ensure generated acronyms are actual words.
    if options[:d] == true
	msg = "\nAll #{length}-letter acronyms that are actual words.\n\n"
	list = dictionary_acronyms(acronyms, words)
    else
	msg = "\nAll #{length}-letter acronyms; not necessarily actual words.\n\n"
	list = raw_acronyms(acronyms, words)
    end
    output(msg, file, list)
elsif n.kind_of?(Array)

    # Create an array with all numbers between the supplied minimum and maximum
    i = *(nmin .. nmax)

    # Iterate through each number to generate an array of acronyms that corresponds to each number of characters in the range.
    i.each do |num|
	if options[:r] == false
	    acronyms = acarray.permutation(num).to_a 
	    words = words_array.permutation(num).to_a 
	elsif options[:r] == true
	    acronyms = acarray.combination(num).to_a
	    words = words_array.combination(num).to_a
	else
	    puts "Error: the -r flag only accepts true if order matters or false if it doesn't."
	    exit
	end
	if options[:d] == true
	    msg = "\nAll #{num}-letter acronyms that are actual words.\n\n"
	    list = dictionary_acronyms(acronyms, words)
	else
	    msg = "\nAll #{num}-letter acronyms; not necessarily actual words.\n\n"
	    list = raw_acronyms(acronyms, words)
	end
	output(msg, file, list)
    end
else
    if options[:r] == false
	acronyms = acarray.permutation(n).to_a
	words = words_array.permutation(n).to_a
    elsif options[:r] == true
	acronyms = acarray.combination(n).to_a
	words = words_array.combination(n).to_a
    else
	puts "Error: the -r flag only accepts true if order matters or false if it doesn't."
	exit
    end
    if options[:d] == true
	msg = "\nAll #{n}-letter acronyms that are actual words.\n\n"
	list = dictionary_acronyms(acronyms, words)
    else
	msg = "\nAll #{n}-letter acronyms; not necessarily actual words.\n\n"
	list = raw_acronyms(acronyms, words)
    end
    output(msg, file, list)
end


