require 'singleton'

class Calendar
  include Singleton

  def initialize
    @day = 0
  end

  def get_date
    @day
  end

  def advance
    @day = @day + 1
    @day
  end
end

class Book
  def initialize(id, title, author, due_date = nil)
    @id = id
    @title = title
    @author = author
    @due_date = due_date
  end
  def get_id
    @id
  end
  def get_title
    @title
  end
  def get_author
    @author
  end
  def get_due_date
    @due_date
  end

  def check_out(due_date)
    raise 'Book already checked out' unless @due_date.nil?
    @due_date = due_date
  end

  def check_in
    raise 'Book not checked out' if @due_date.nil?
    @due_date = nil
  end

  def ==(other)
    other.is_a?(Book) || @id == other.get_id
  end

  def to_s
    "#{@id}: #{@title}, by #{@author}"
  end
end

require 'set'

class Member
  def initialize(name, library)
    @name = name
    @library = library
    @books = Set.new []
  end
  def get_name
    @name
  end

  def check_out(book)
    raise unless book.is_a?(Book)
    @books.add(book)
  end

  def give_back(book)
    raise unless book.is_a?(Book)
    @books.delete(book)
  end

  def get_books
    @books
  end

  def send_overdue_notice(notice)
    to_print = "Dear #{@name}, #{notice} Signed Your Library"
    puts(to_print)
    to_print
  end
end


class Library
  #For testing
  attr_accessor :books, :calendar, :members, :is_open, :serving

  def initialize
    import_books
    @calendar = Calendar.instance
    @members = {}
    @is_open = false
    @serving = nil
  end

  def open
    raise 'The library is already open!' if @is_open
    @is_open = true
    day = @calendar.advance
    "Today is day #{day}"
  end

  def find_all_overdue_books
    
  end
  def issue_card(name_of_member)

  end
  def serve(name_of_member)

  end
  def find_overdue_books

  end
  def check_in(*book_numbers)

  end
  def search(string)

  end
  def check_out(*book_ids)

  end
  def renew(*book_ids)

  end
  def close

  end
  def quit

  end

  private
  require 'csv'
  def import_books
    @books = {}
    i = 0
    CSV.foreach('collection.txt') do |row|
      arr = row
      i = i + 1
      title = arr[0].gsub('(', '')
      author = arr[1].gsub(')', '')
      book = Book.new(i, title, author)
      @books[i] = book
    end
  end
end