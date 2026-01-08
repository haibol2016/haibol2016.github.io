#!/usr/bin/env ruby
# Script to update post dates in front matter to match filename dates
# encoding: utf-8

require 'date'

posts_dir = File.join(__dir__, '_posts')
Dir.glob(File.join(posts_dir, '*.md')).each do |file_path|
  filename = File.basename(file_path)
  
  # Extract date from filename (format: YYYY-MM-DD-title.md)
  if filename =~ /^(\d{4}-\d{2}-\d{2})-(.+)$/
    filename_date = $1
    puts "Processing: #{filename}"
    puts "  Filename date: #{filename_date}"
    
    # Read the file with UTF-8 encoding
    content = File.read(file_path, encoding: 'UTF-8')
    
    # Check if file has front matter
    if content =~ /^---\s*\n(.*?)\n---\s*\n/m
      front_matter = $1
      body = $' # Everything after the front matter
      
      # Update or add date field
      if front_matter =~ /^date:\s*(.+)$/
        old_date = $1.strip
        puts "  Old date in front matter: #{old_date}"
        
        # Replace the date line
        front_matter.gsub!(/^date:\s*.+$/, "date: #{filename_date}")
        puts "  Updated date to: #{filename_date}"
      else
        # Add date field after title or at the beginning
        if front_matter =~ /^title:\s*(.+)$/
          front_matter += "\ndate: #{filename_date}"
          puts "  Added date: #{filename_date}"
        else
          front_matter = "date: #{filename_date}\n" + front_matter
          puts "  Added date at beginning: #{filename_date}"
        end
      end
      
      # Write back the file
      File.write(file_path, "---\n#{front_matter}\n---\n#{body}")
      puts "  ✓ Updated successfully\n\n"
    else
      puts "  ⚠ No front matter found, skipping\n\n"
    end
  else
    puts "Skipping #{filename} (doesn't match date format)\n\n"
  end
end

puts "Done! All post dates have been updated to match their filenames."

