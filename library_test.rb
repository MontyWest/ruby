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
    notice = "GIVE BACK OUR BOOK!"
    printed = @mem.send_overdue_notice(notice)
    assert_equal("Dear Abe, #{notice} Signed Your Library", printed)
  end

end

class TestLibrary < MiniTest::Unit::TestCase

  def setup
    @lib = Library.new
  end

  def test_open
    @lib.is_open = false
    day_before = @lib.calendar.get_date
    message = @lib.open
    day_after = @lib.calendar.get_date
    assert(@lib.is_open)
    assert_equal("Today is day #{day_after}", message)
    assert_equal(day_before+1, day_after)
  end

  def test_open_fail
    @lib.is_open = true
    day_before = @lib.calendar.get_date
    message = assert_raise(RuntimeError){@lib.open}
    day_after = @lib.calendar.get_date
    assert(@lib.is_open)
    assert_equal("The library is already open!", message)
    assert_equal(day_before, day_after)
  end

  def test_find_all_overdue_books_some
    mem = Member.new("Abe", @lib)
    book = Book.new(1, "Moby Dick", "Herman Melville", @lib.calendar.getDate() - 1)
    mem.check_out(book)
    @lib.books[1] = book
    @lib.members[mem.get_name] = mem
    message = @lib.find_all_overdue_books

    assert(message.include? "abe")
    assert(message.include? "Moby Dick")
    assert(message.include? "Herman Melville")
  end

  def test_find_all_overdue_books_none
    mem = Member.new("Abe", @lib)
    book = Book.new(1, "Moby Dick", "Herman Melville", @lib.calendar.getDate() + 1)
    mem.check_out(book)
    @lib.books = {1 => book}
    @lib.members = {mem.get_name => mem}
    message = @lib.find_all_overdue_books

    assert_equal("No books are overdue.", message)
  end

  def test_issue_card
    @lib.is_open = true
    @lib.members = {}
    message = @lib.issue_card("Abe")
    assert_includes(@lib.members, "Abe")
    assert_equal("Library card issued to Abe.", message)
    assert_equal("Abe", @lib.members["Abe"].get_name)
  end

  def test_issue_card_exists
    @lib.is_open = true
    mem = Member.new("Abe", @lib)
    @lib.members = {"Abe" => mem}
    message = @lib.issue_card("Abe")
    assert_equal("Abe already has a library card.", message)
  end

  def test_issue_card_closed
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.issue_card("Abe")}
    assert_equal("The library is not open.", message)
  end

  def test_serve
    @lib.is_open = true
    mem = Member.new("Abe", @lib)
    @lib.members = {"Abe" => mem}
    @lib.serving = nil

    message @lib.serve("Abe")

    assert_equal("Now serving Abe.", message)
    assert(!@lib.serving.nil?)
    assert_equal("Abe", @lib.serving.get_name)
  end

  def test_serve_no_card
    @lib.is_open = true
    @lib.members = {}
    @lib.serving = nil

    message = @lib.serve("Abe")

    assert_equal("Abe does not have a library card.", message)
    assert_nil(@lib.serving)
  end

  def test_serve_existing
    @lib.is_open = true
    mem1 = Member.new("Abe", @lib)
    mem2 = Member.new("Mos", @lib)
    @lib.members = {"Abe" => mem1, "Mos" => mem2}
    @lib.serving = mem2

    message @lib.serve("Abe")

    assert_equal("Now serving Abe.", message)
    assert(!@lib.serving.nil?)
    assert_equal("Abe", @lib.serving.get_name)
  end

  def test_serve_closed
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.serve("Abe")}
    assert_equal("The library is not open.", message)
  end

  def find_overdue_books_no_serve
    @lib.is_open = true
    @lib.serving = nil
    message = assert_raises(RuntimeError){@lib.find_overdue_books}
    assert_equal("No member is currently being served.", message)
  end

  def find_overdue_books_closed
    @lib.is_open = false
    mem = Member.new("Abe", @lib)
    @lib.serving = mem
    message = assert_raises(RuntimeError){@lib.find_overdue_books}
    assert_equal("The library is not open.", message)
  end

  def find_overdue_books_none
    @lib.is_open = ture
    mem = Member.new("Abe", @lib)
    book = Book.new(1, "Moby Dick", "Herman Melville", @lib.calendar.getDate() + 1)
    mem.check_out(book)
    @lib.serving = mem
    @lib.members = {"Abe" => mem}
    @lib.books = {1 => book}
    message = @lib.find_overdue_books
    assert_equal("None.", message)
  end

  def find_overdue_books_some
    @lib.is_open = ture
    mem = Member.new("Abe", @lib)
    book1 = Book.new(1, "Moby Dick", "Herman Melville", @lib.calendar.getDate() - 1)
    book2 = Book.new(2, "Slaughterhouse-Five", "Kurt Vonnegut", @lib.calendar.getDate() - 1)
    book3 = Book.new(3, "Less Than Zero", "Brett Easton Ellis", @lib.calendar.getDate() + 1)
    mem.check_out(book1)
    mem.check_out(book2)
    mem.check_out(book3)
    @lib.serving = mem
    @lib.members = {"Abe" => mem}
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.find_overdue_books
    assert_equal("#{book1.to_s}\n#{book2.to_s}", message)
  end

  def search_bad_query
    message = @lib.search("abc")
    assert_equal("Search string must contain at least four characters.", message)
  end

  def search_no_books_found
    book1 = Book.new(1, "Moby Dick", "Herman Melville")
    book2 = Book.new(2, "Slaughterhouse-Five", "Kurt Vonnegut")
    book3 = Book.new(3, "Less Than Zero", "Brett Easton Ellis")
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.search("The Hobbit")
    assert_equal("No books found.", message)
  end

  def search_no_available_found
    book1 = Book.new(1, "Moby Dick", "Herman Melville")
    book2 = Book.new(2, "Slaughterhouse-Five", "Kurt Vonnegut")
    book3 = Book.new(3, "Less Than Zero", "Brett Easton Ellis", @lib.calendar.getDate() + 1)
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.search("Zero")
    assert_equal("No books found.", message)
  end

  def search_books_found_case
    book1 = Book.new(1, "Moby Dick", "Herman Melville")
    book2 = Book.new(2, "Slaughterhouse-Five", "Kurt Vonnegut")
    book3 = Book.new(3, "Less Than Zero", "Brett Easton Ellis")
    book4 = Book.new(4, "Bleak House", "Charles Dickins")
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}
    message = @lib.search("house")
    assert_equal("#{book2.to_s}\n#{book4.to_s}", message)
  end

  def search_books_no_duplicates
    book1 = Book.new(1, "Moby Dick", "Herman Melville")
    book2 = Book.new(2, "Moby Dick", "Herman Melville")
    book3 = Book.new(3, "Slaughterhouse-Five", "Kurt Vonnegut")
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.search("moby")
    assert_equal("#{book1.to_s}", message)
  end

end