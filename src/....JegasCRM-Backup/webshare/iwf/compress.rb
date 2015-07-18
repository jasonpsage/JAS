# This ruby script will strip out unnecessary lines, whitespace, etc
# from all .js files in the current directory and create a subfolder
# named "release" if needed and put copies of the stripped files in it
# It also copies over the lgpl.txt file.

# create release directory if needed
Dir.mkdir "./release" if !File.exists?("./release")

js_files = Dir['*.js']
js_files.each do |f|
	# read each javascript file in
	File.open(f, 'r') do |infile|

		# create or overwrite existing file by same name
		File.delete "release/" + f if File.exists?("release/" + f)
		File.open("release/" + f, 'w') do |outfile|
			while (line = infile.gets)

				# strip out logging statements (but not fatal ones)
				line.gsub!(/\/{0,2}*iwfLog\s*\(.*/,'') unless line.include?('//IWFANCHOR')

				# notice we don't handle /* */ style commenting, iwf never uses it by convention anyway...
				if ARGV[0] == 'leavelgpl'
					# strip out only non-lgpl comments, leaving lgpl intact
					line.gsub!(/\/\/([^\/!].*|$)/,'')
				else
					# strip out all comments, even lgpl
					line.gsub!(/\/\/(.*|$)/,'')
				end

				# remove any tabbing or other whitespace preceding any text
				line.lstrip!

				line.chomp! unless line.include?('}')

				# if non-whitespace exists, write out the line
				outfile.write line if line.length > 0

			end
		end
	end
end

# don't forget the LGPL...
require 'FileUtils'
FileUtils.cp "lgpl.txt", "./release/lgpl.txt"