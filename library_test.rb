require_relative 'library.rb'
require 'minitest/autorun'

class TestCalendar < MiniTest::Unit::TestCase

  def setup
    @cal = Calendar.instance
  end

  def test_get_date_num
    day = @cal.get_date
    assert(day.is_a?(Numeric))
  end

  def test_advance
    day = @cal.get_date
    day_plus_one = @cal.advance
    day_plus_two = @cal.advance

    assert_equal(day + 1, day_plus_one)
    assert_equal(day + 2, day_plus_two)
  end

  def test_advance_with_get_date
    day = @cal.get_date
    @cal.advance
    @cal.advance
    @cal.advance
    day_plus_three = @cal.get_date

    assert_equal(day + 3, day_plus_three)
  end

end

class TestBook < MiniTest::Unit::TestCase

  def setup
  end

  def test_getters
    book = Book.new(1, 'Moby Dick', 'Herman Melville', 5)
    assert_equal(1, book.get_id)
    assert_equal('Moby Dick', book.get_title)
    assert_equal('Herman Melville', book.get_author)
    assert_equal(5, book.get_due_date)
  end

  def test_check_out
    book = Book.new(1, 'Moby Dick', 'Herman Melville')
    assert_nil(book.get_due_date)
    book.check_out(5)
    assert_equal(5, book.get_due_date)
  end

  def test_check_in
    book = Book.new(1, 'Moby Dick', 'Herman Melville', 5)
    book.check_in
    assert_nil(book.get_due_date)
  end

  def test_to_s
    book = Book.new(1, 'Moby Dick', 'Herman Melville', 5)
    assert_equal('1: Moby Dick, by Herman Melville', book.to_s)
  end
end

require 'set'

class TestMember < MiniTest::Unit::TestCase
  def setup
    @mem = Member.new('Abe', nil)
  end

  def test_getters
    assert_equal('Abe', @mem.get_name)
    assert(@mem.get_books.is_a?(Set))
  end

  def test_check_out
    book = Book.new(1, 'Moby Dick', 'Herman Melville', 5)
    @mem.check_out(book)
    books = @mem.get_books
    assert(books.include?(book))
  end

  def test_give_back
    book = Book.new(1, 'Moby Dick', 'Herman Melville', 5)
    @mem.check_out(book)
    books = @mem.get_books
    assert(books.include?(book))
    @mem.give_back(book)
    books_after = @mem.get_books
    assert(!books_after.include?(book))
  end

  def test_send_overdue_notice
    notice = 'GIVE BACK OUR BOOK!'
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
    message = assert_raises(RuntimeError){@lib.open}.to_s
    day_after = @lib.calendar.get_date
    assert(@lib.is_open)
    assert_equal('The library is already open!', message)
    assert_equal(day_before, day_after)
  end

  def test_find_all_overdue_closed
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.find_all_overdue_books}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_find_all_overdue_books
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book = Book.new(1, 'Moby Dick', 'Herman Melville', @lib.calendar.get_date - 1)
    mem.check_out(book)
    @lib.books[1] = book
    @lib.members[mem.get_name] = mem
    message = @lib.find_all_overdue_books

    assert(message.include?('Abe'), 'Message should contain Abe')
    assert(message.include?('Moby Dick'), 'Message should contain Moby Dick')
    assert(message.include?('Herman Melville'), 'Message should contain Herman Melville')
  end

  def test_find_all_overdue_books_n
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book = Book.new(1, 'Moby Dick', 'Herman Melville', @lib.calendar.get_date + 1)
    mem.check_out(book)
    @lib.books = {1 => book}
    @lib.members = {mem.get_name => mem}
    message = @lib.find_all_overdue_books

    assert_equal('No books are overdue.', message)
  end

  def test_issue_card
    @lib.is_open = true
    @lib.members = {}
    message = @lib.issue_card('Abe')
    assert_includes(@lib.members, 'Abe')
    assert_equal('Library card issued to Abe.', message)
    assert_equal('Abe', @lib.members['Abe'].get_name)
  end

  def test_issue_card_exists
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    @lib.members = {'Abe' => mem}
    message = @lib.issue_card('Abe')
    assert_equal('Abe already has a library card.', message)
  end

  def test_issue_card_closed
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.issue_card('Abe')}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_serve
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    @lib.members = {'Abe' => mem}
    @lib.serving = nil

    message = @lib.serve('Abe')

    assert_equal('Now serving Abe.', message)
    assert(!@lib.serving.nil?)
    assert_equal('Abe', @lib.serving.get_name)
  end

  def test_serve_no_card
    @lib.is_open = true
    @lib.members = {}
    @lib.serving = nil

    message = @lib.serve('Abe')

    assert_equal('Abe does not have a library card.', message)
    assert_nil(@lib.serving)
  end

  def test_serve_existing
    @lib.is_open = true
    mem1 = Member.new('Abe', @lib)
    mem2 = Member.new('Mos', @lib)
    @lib.members = {'Abe' => mem1, 'Mos' => mem2}
    @lib.serving = mem2

    message = @lib.serve('Abe')

    assert_equal('Now serving Abe.', message)
    assert(!@lib.serving.nil?)
    assert_equal('Abe', @lib.serving.get_name)
  end

  def test_serve_closed
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.serve('Abe')}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_find_overdue_no_serve
    @lib.is_open = true
    @lib.serving = nil
    message = assert_raises(RuntimeError){@lib.find_overdue_books}.to_s
    assert_equal('No member is currently being served.', message)
  end

  def test_find_overdue_books_closed
    @lib.is_open = false
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    message = assert_raises(RuntimeError){@lib.find_overdue_books}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_find_overdue_books_none
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book = Book.new(1, 'Moby Dick', 'Herman Melville', @lib.calendar.get_date + 1)
    mem.check_out(book)
    @lib.serving = mem
    @lib.members = {'Abe' => mem}
    @lib.books = {1 => book}
    message = @lib.find_overdue_books
    assert_equal('None.', message)
  end

  def test_find_overdue_books_some
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville', @lib.calendar.get_date - 1)
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut', @lib.calendar.get_date - 1)
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis', @lib.calendar.get_date + 1)
    mem.check_out(book1)
    mem.check_out(book2)
    mem.check_out(book3)
    @lib.serving = mem
    @lib.members = {'Abe' => mem}
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.find_overdue_books
    assert_equal("#{book1.to_s}\n#{book2.to_s}", message)
  end

  def test_check_in_no_serve
    @lib.is_open = true
    @lib.serving = nil
    message = assert_raises(RuntimeError){@lib.check_in(1,2)}.to_s
    assert_equal('No member is currently being served.', message)
  end

  def test_check_in_closed
    @lib.is_open = false
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    message = assert_raises(RuntimeError){@lib.check_in(1,2)}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_check_in_not_coed
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    @lib.serving = mem
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}

    message = assert_raises(RuntimeError){@lib.check_in(1)}.to_s
    assert_equal('The member does not have book 1.', message)
  end

  def test_check_in
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville', 10)
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut', 10)
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    mem.check_out(book1)
    mem.check_out(book2)
    @lib.serving = mem
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}

    message = @lib.check_in(1, 2)
    assert_equal('Abe has returned 2 books.', message)
    assert_nil(book2.get_due_date)
    assert_nil(book3.get_due_date)
    assert(!mem.get_books.include?(book2))
    assert(!mem.get_books.include?(book3))
  end

  def test_search_closed
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.search('abc')}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_search_bad_query
    @lib.is_open = true
    message = @lib.search('abc')
    assert_equal('Search string must contain at least four characters.', message)
  end

  def test_search_no_books_found
    @lib.is_open = true
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.search('The Hobbit')
    assert_equal('No books found.', message)
  end

  def test_search_no_available_found
    @lib.is_open = true
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis', 10)
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.search('Zero')
    assert_equal('No books found.', message)
  end

  def test_search_books_found_case
    @lib.is_open = true
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}
    message = @lib.search('house')
    assert_equal("#{book2.to_s}\n#{book4.to_s}", message)
  end

  def test_search_books_no_dupes
    @lib.is_open = true
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Moby Dick', 'Herman Melville')
    book3 = Book.new(3, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    @lib.books = {1 => book1, 2 => book2, 3 => book3}
    message = @lib.search('moby')
    assert_equal("#{book1.to_s}", message)
  end

  def test_check_out_no_serve
    @lib.is_open = true
    @lib.serving = nil
    message = assert_raises(RuntimeError){@lib.check_out(1,2)}.to_s
    assert_equal('No member is currently being served.', message)
  end

  def test_check_out_closed
    @lib.is_open = false
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    message = assert_raises(RuntimeError){@lib.check_out(1,2)}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_check_out_no_book
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}
    message = assert_raises(RuntimeError){@lib.check_out(5)}.to_s
    assert_equal('The library does not have book 5.', message)
  end

  def test_check_out_book_unav
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut', 10)
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}
    message = assert_raises(RuntimeError){@lib.check_out(2,3)}.to_s
    assert_equal('The library does not have book 2.', message)
  end

  def test_check_out
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}
    message = @lib.check_out(2, 3)
    assert_equal('2 books have been checked out to Abe.', message)
    assert(!book2.get_due_date.nil?)
    assert(!book3.get_due_date.nil?)
    assert(mem.get_books.include?(book2))
    assert(mem.get_books.include?(book3))
  end

  def test_renew_no_serve
    @lib.is_open = true
    @lib.serving = nil
    message = assert_raises(RuntimeError){@lib.renew(1,2)}.to_s
    assert_equal('No member is currently being served.', message)
  end

  def test_renew_closed
    @lib.is_open = false
    mem = Member.new('Abe', @lib)
    @lib.serving = mem
    message = assert_raises(RuntimeError){@lib.renew(1,2)}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_renew_not_coed
    @lib.is_open = true
    mem = Member.new('Abe', @lib)
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville')
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut')
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    @lib.serving = mem
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}

    message = assert_raises(RuntimeError){@lib.renew(1)}.to_s
    assert_equal('The member does not have book 1.', message)
  end

  def test_renew
    @lib.is_open = true
    today = @lib.calendar.get_date
    mem = Member.new('Abe', @lib)
    book1 = Book.new(1, 'Moby Dick', 'Herman Melville', 3)
    book2 = Book.new(2, 'Slaughterhouse-Five', 'Kurt Vonnegut', 3)
    book3 = Book.new(3, 'Less Than Zero', 'Brett Easton Ellis')
    book4 = Book.new(4, 'Bleak House', 'Charles Dickens')
    mem.check_out(book1)
    mem.check_out(book2)
    @lib.serving = mem
    @lib.books = {1 => book1, 2 => book2, 3 => book3, 4 => book4}

    message = @lib.renew(1, 2)
    assert_equal('2 books have been renewed for Abe.', message)
    assert_equal(today + 7, book1.get_due_date)
    assert_equal(today + 7, book2.get_due_date)
    assert(mem.get_books.include?(book1))
    assert(mem.get_books.include?(book2))
  end

  def test_close_not_open
    @lib.is_open = false
    message = assert_raises(RuntimeError){@lib.close}.to_s
    assert_equal('The library is not open.', message)
  end

  def test_close
    @lib.is_open = true
    message = @lib.close
    assert(!@lib.is_open)
    assert_equal('Good night.', message)
  end

  def test_quit_open
    @lib.is_open = true
    assert_raises(SystemExit){@lib.quit}
  end

  def test_quit_closed
    @lib.is_open = false
    assert_raises(SystemExit){@lib.quit}
  end
end