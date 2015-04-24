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

  end
  def get_id()

  end

end