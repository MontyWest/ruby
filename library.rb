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

  def renew(due_date)
    raise 'Book not checked out' if @due_date.nil?
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
    raise "The member does not have book #{book.get_id}." if @books.delete?(book).nil?
    book
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
    unless @members.include?(name_of_member)
      return "#{name_of_member} does not have a library card."
    end
    @serving = @members[name_of_member]
    "Now serving #{name_of_member}."
  end

  def find_overdue_books
    raise 'The library is not open.' unless @is_open
    raise 'No member is currently being served.' if serving.nil?
    od_books = []
    today = @calendar.get_date
    @serving.get_books.each do |book|
      if !book.get_due_date.nil? && book.get_due_date < today
        od_books.push(book.to_s)
      end
    end
    message = 'None.'
    unless od_books.empty?
      message = od_books.join("\n")
    end
    message
  end

  def check_in(*book_numbers)
    raise 'The library is not open.' unless @is_open
    raise 'No member is currently being served.' if serving.nil?

    book_numbers.each do |id|
      book = @books[id]
      @serving.give_back(book)
      book.check_in
    end

    "#{@serving.get_name} has returned #{book_numbers.length} books."
  end

  def search(string)
    raise 'The library is not open.' unless @is_open
    if string.length < 4
      return 'Search string must contain at least four characters.'
    end

    term = string.downcase
    results = []
    @books.each do |id, book|
      if book.get_due_date.nil?
        if book.get_title.downcase.include?(term) || book.get_author.downcase.include?(term)
          add = true
          results.each do |result|
             if result.include?(book.get_title) && result.include?(book.get_author)
               add = false
             end
             break unless add
          end
          if add
            results.push(book.to_s)
          end
        end
      end
    end

    message = 'No books found.'
    unless results.empty?
      message = results.join("\n")
    end
    message
  end

  def check_out(*book_ids)
    raise 'The library is not open.' unless @is_open
    raise 'No member is currently being served.' if serving.nil?

    book_ids.each do |id|
      book = @books[id]
      raise "The library does not have book #{id}." if book.nil? || !book.get_due_date.nil?
      book.check_out(@calendar.get_date + 7)
      @serving.check_out(book)
    end

    "#{book_ids.length} books have been checked out to #{@serving.get_name}."
  end

  def renew(*book_ids)
    raise 'The library is not open.' unless @is_open
    raise 'No member is currently being served.' if serving.nil?

    book_ids.each do |id|
      book = @books[id]
      raise "The member does not have book #{id}." unless @serving.get_books.include?(book)
      book.renew(@calendar.get_date + 7)
    end

    "#{book_ids.length} books have been renewed for #{@serving.get_name}."
  end

  def close
    raise 'The library is not open.' unless @is_open
    @is_open = false
    'Good night.'
  end

  def quit
    puts 'The library is now closed for renovations.'
    exit
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