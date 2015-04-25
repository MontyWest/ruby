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
    raise 'The library is not open.' unless @is_open
    exists_od = false
    od_mems = []
    today = @calendar.get_date
    @members.each do |name, mem|
      has_overdue = false
      od_books = []
      mem.get_books.each do |book|
        if !book.get_due_date.nil? && book.get_due_date < today
          has_overdue = true
          od_books.push(book.to_s)
        end
      end
      if has_overdue
        exists_od = true
        od_mems.push(
            "#{name}:\n\t#{od_books.join("\n\t")}"
        )
      end
    end
    message = "No books are overdue."
    if exists_od
      message = "#{od_mems.join("\n")}"
    end
    message
  end

  def issue_card(name_of_member)
    raise 'The library is not open.' unless @is_open
    if @members.include?(name_of_member)
      return "#{name_of_member} already has a library card."
    end
    new_member = Member.new(name_of_member, self)
    @members[name_of_member] = new_member
    "Library card issued to #{name_of_member}."
  end

  def serve(name_of_member)
    raise 'The library is not open.' unless @is_open

  end
  def find_overdue_books
    raise 'The library is not open.' unless @is_open

  end
  def check_in(*book_numbers)
    raise 'The library is not open.' unless @is_open

  end
  def search(string)
    raise 'The library is not open.' unless @is_open

  end
  def check_out(*book_ids)
    raise 'The library is not open.' unless @is_open

  end
  def renew(*book_ids)
    raise 'The library is not open.' unless @is_open

  end
  def close
    raise 'The library is not open.' unless @is_open

  end
  def quit
    raise 'The library is not open.' unless @is_open

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