require_relative 'library.rb'
require 'minitest/autorun'

class TestCalendar < MiniTest::Unit::TestCase

  def setup
    @cal = Calendar.instance
  end

  def test_get_date_num
    day = @cal.get_date()
    assert(day.is_a?(Numeric))
  end

  def test_advance
    day = @cal.get_date()
    day_plus_one = @cal.advance
    day_plus_two = @cal.advance

    assert_equal(day + 1, day_plus_one)
    assert_equal(day + 2, day_plus_two)
  end

  def test_advance_with_get_date
    day = @cal.get_date()
    @cal.advance
    @cal.advance
    @cal.advance
    day_plus_three = @cal.get_date()

    assert_equal(day + 3, day_plus_three)
  end

end

class TestBook < MiniTest::Unit::TestCase

  def setup
  end

  def test_getters
    book = Book.new(1, "Moby Dick", "Herman Melville", 5)
    assert_equal(1, book.get_id)
    assert_equal("Moby Dick", book.get_title)
    assert_equal("Herman Melville", book.get_author)
    assert_equal(5, book.get_due_date)
  end

  def test_check_out
    book = Book.new(1, "Moby Dick", "Herman Melville")
    assert_nil(book.get_due_date)
    book.check_out(5)
    assert_equal(5, book.get_due_date)
  end

  def test_check_in
    book = Book.new(1, "Moby Dick", "Herman Melville", 5)
    book.check_in
    assert_nil(book.get_due_date)
  end

  def test_to_s
    book = Book.new(1, "Moby Dick", "Herman Melville", 5)
    assert_equal("1: Moby Dick, by Herman Melville", book.to_s)
  end
end

require 'set'

class TestMember < MiniTest::Unit::TestCase
  def setup
    @mem = Member.new("Abe", nil)
  end

  def test_getters
    assert_equal("Abe", @mem.get_name)
    assert(@mem.get_books.is_a?(Set))
  end

  def test_check_out
    book = Book.new(1, "Moby Dick", "Herman Melville", 5)
    @mem.check_out(book)
    books = @mem.get_books
    assert(books.include?(book))
  end

  def test_give_back
    book = Book.new(1, "Moby Dick", "Herman Melville", 5)
    @mem.check_out(book)
    books = @mem.get_books
    assert(books.include?(book))
    @mem.give_back(book)
    books_after = @mem.get_books
    assert(!books.include?(book))
  end

  def test_send_overdue_notice
    # Just tests no exception is thrown
    notice = "GIVE BACK OUR BOOK!"
    @mem.send_overdue_notice(notice)
  end

end