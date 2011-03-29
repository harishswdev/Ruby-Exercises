require 'test/unit'
require_relative 'grade'

# test class for the variou scenariros of the
# grade class
class GradeTest <Test::Unit::TestCase

  # valid grade- passes!
  def test_createvalidgrade

    begin
      Grade.new("A+")
    rescue => e
      puts e.message
      assert(false) # oops we should not get here
    end
  end

 # try creating an invalid grade not understood by our system
  def test_create_invalidgrade
    begin
      Grade.new("ABD")
    rescue ArgumentError
      assert(true) # this is a specifc error we throw
    rescue
      assert(false) # uncaught exception
    end
  end

  # test for comparison operators >
  def test_greatercomparison
    a_plus = Grade.new("A+")
    a = Grade.new("A")
    assert (a_plus > a) # should return true
  end

  # test for comparison operators <
  def test_lessercomparison
    b_plus = Grade.new("B+")
    a = Grade.new("A")
    assert (b_plus < a) # should return true
  end

  # test for comparison operators ==
  def test_equalcomparison
    a = Grade.new("A")
    anotherA = Grade.new("A")
    assert (a == anotherA) # should return true
  end

  # test for comparison operators >=
  def test_greaterequalcomparison
    a_plus = Grade.new("A+")
    a = Grade.new("A")
    assert (a_plus >= a) # should return true
  end

  # perform enumeration operations like sort
  def test_sort

    a_plus = Grade.new("A+")
    a = Grade.new("A")
    b_minus = Grade.new("B-")

    ordered = [a_plus,b_minus, a].sort # should return [a, a_plus]

    assert(ordered[0] == b_minus)
    assert(ordered[1] == a)
    assert(ordered[2] == a_plus)

  end

  # figure out the min and max of the grades
  def test_min
    a_plus = Grade.new("A+")
    a = Grade.new("A")
    b_minus = Grade.new("B-")
    c_minus = Grade.new("C-")
    assert([a_plus,b_minus, a,c_minus].max == a_plus)
    assert([a_plus,b_minus, a,c_minus].min == c_minus)


  end


end