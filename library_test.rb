require_relative 'library.rb'
require 'minitest/autorun'

class TestCalendar < MiniTest::Unit::TestCase

  def setup
    @cal = Calendar.instance
  end

  def test_get_date_num
    day = @cal.get_date()
    raise unless day.is_a?(Numeric)
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