#!/usr/bin/env ruby
# Copyright 2011 J. Pablo Fernández

require "csv"
require "date"

module ANobii2GoodReads
  def self.convert(shelf_file_name, wishlist_file_name, output_file_name)

    CSV.open(output_file_name, "wb") do |output|
      # Titles
      output << ["Title", "Author", "ISBN", "My Rating", "Average Rating", "Publisher", "Binding",
                 "Year Published", "Original Publication Year", "Date Read", "Date Added",
                 "Bookshelves", "My Review"]

      # Fields: ISBN,Title,Subtitle,Author,Format,Number of pages,Publisher,Publication date,Private Note,Comment title,Comment content,Status,Stars,Tags
      print "Converting shelf #{shelf_file_name}..."
      CSV.foreach(shelf_file_name) do |input|
        if input[0] != "ISBN" # skip titles
          print "."

          title = input[1]
          author = input[3]
          isbn = input[0].gsub(/[^0-9]/, "")
          my_rating = input[12]
          average_rating = nil
          publisher = input[6]
          binding = input[4]
          year_published = input[7].match(/\d\d\d\d/)
          if !year_published.nil?
            year_published = year_published[0]
          end
          original_publication_year = year_published
          date_read = nil
          if input[11].start_with? "Finished on"
            date_read = Date.parse(input[11][11..-1])
            if input[11].start_with? "Finished in"
              m = input[11].match(/\d\d\d\d/)
              if !m.nil?
                date_read = m[0]
              end
            end
          end
          date_added = nil
          bookshelves = [if input[11].start_with? "Finished"
                           "read"
                         elsif input[11].start_with? "Reading since"
                           "currently-reading"
                         elsif input[11].start_with?("Abandoned") || input[11].start_with?("Started on")
                           "abandoned"
                         elsif input[11] == "Not Started"
                           "to-read"
                         elsif input[11] == "Finished"
                           "read"
                         elsif input[11] == "Reference"
                           "reference"
                         else
                           raise "Couldn't figure out the shelf, status is: #{input[11]}"
                         end]
          bookshelves << "from-anobii"
          bookshelves += input[13].split("/").map {|tag| tag.strip.gsub(/[^a-zA-Z0-9]/, "-")}
          bookshelves = bookshelves.join(" ")
          my_review = input[9..10].join("\n").strip
          output << [title, author, isbn, my_rating, average_rating, publisher, binding, year_published, original_publication_year, date_read, date_added, bookshelves, my_review]
        end
      end
      puts " done!"

      # Fields: Priority,ISBN,Title,Subtitle,Author,Format,Number of pages,Publisher,Publication date,Private Note
      print "Converting wishshelf #{wishlist_file_name}..."
      CSV.foreach(wishlist_file_name) do |input|
        if input[1] != "ISBN" # skip titles
          print "."

          title = input[2]
          author = input[4]
          isbn = input[1].gsub(/[^0-9]/, "")
          my_rating = nil
          average_rating = nil
          publisher = input[7]
          binding = nil
          year_published = input[8].match(/\d\d\d\d/)
          if !year_published.nil?
            year_published = year_published[0]
          end
          original_publication_year = year_published
          date_read = nil
          date_added = nil
          bookshelves = ["to-read", "wishlist", "from-anobii", "to-read-#{input[0].downcase}", "wishlist-#{input[0].downcase}"]
          bookshelves = bookshelves.join(" ")
          my_review = nil
          output << [title, author, isbn, my_rating, average_rating, publisher, binding, year_published, original_publication_year, date_read, date_added, bookshelves, my_review]
        end
      end
      puts " done!"
    end
  end
end

if __FILE__ == $0
  if ARGV[0].nil? || ARGV[1].nil? || ARGV[2].nil?
    puts "Invalid call, use:"
    puts "#{$0} shelf.csv wishlist.csv goodreads.csv"
  else
    ANobii2GoodReads.convert(ARGV[0], ARGV[1], ARGV[2])
  end
end