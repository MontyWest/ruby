require 'singleton'

class Calendar
  include Singleton

  def initialize
    @day = 0
  end
  def get_date
    return @day
  end
  def advance
    @day = @day + 1
    return @day
  end
end

class Book
  def initialize(id, title, author, due_date = nil)
    @id = id
    @title = title
    @author = author
    @due_date = due_date
  end
  def get_id()
    return @id
  end
  def get_title()
    return @title
  end
  def get_author()
    return @author
  end
  def get_due_date()
    return @due_date
  end
  def check_out(due_date)

  end
  def check_in()

  end
  def to_s()

  end
end