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
    raise unless @due_date.nil?
    @due_date = due_date
  end
  def check_in
    raise if @due_date.nil?
    @due_date = nil
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
    
  end
  def give_back(book)

  end
  def get_books
    @books
  end
  def send_overdue_notice(notice)

  end

end