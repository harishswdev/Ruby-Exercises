
# class that implements a letter-based grading
#system (A+, A, A-, ...).  The class should be able to naturally
#sort by the value of grade (i.e., A+ > A > A-).  The class
#should be constructed with a string-value for the grade.
class Grade

  include Comparable
  include Enumerable

  attr_accessor :gpa

  # initialize the value of the gpa from the grade entered by the user
  #also map it to its corresponding numeric value
  public
  def initialize(grades)
    @validgpastrings=["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-"]
    upcasegpa = grades.to_s.upcase
    raise ArgumentError.new("#{grades} is not a valid grade") unless @validgpastrings.include?(upcasegpa)
    @gpa = case upcasegpa
             when "A+"
               4.0
             when "A"
               3.75
             when "A-"
               3.5
             when "B+"
               3.25
             when "B"
               3.0
             when "B-"
               2.75
             when "C+"
               2.5
             when "C"
               2.25
             when "C-"
               2.0
             else
               -1.0 # we should not reach here

           end
  end


  # overload the comparison operators
  # since we are dealing with underlying numeric values
  # the comparison of their values comes to us automatically

  def <=>(another)
    @gpa<=>another.gpa
  end

# overload the 'each' method for enumeration operations like sort
  def each
    @gpa
  end

end
