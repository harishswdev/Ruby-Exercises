require 'test/unit'
require 'rubygems'
require 'diff/lcs/array'
require_relative 'css_compressor'

class CSSCompressorTest < Test::Unit::TestCase

  # check for invalid arguments- null input file name
  def test_nullipfilename

    begin
      compressor = CssCompressor.new('')
    rescue ArgumentError
      assert(true) # this is the expected result
    rescue
      assert(false)
    end
  end

  # check for non existent input file name
  def test_nonexistentipfilename
    begin
      compressor = CssCompressor.new('foobar.css')
    rescue Errno::ENOENT
      assert(true) # this is the expected result
    rescue
      assert(false)
    end

  end

  # The following set of tests here follows a standard pattern
  # Various kinds of input css files with different characteristics
  # in terms of the nature of comments and blank lines are stored in the test folders
  # of the project.
  # In each test case
  #* input src.css file is read and compressed to an actual.css file
  #* expected.css file has been generated and is kept in the same folder
  #* the actual.css and expected.css files are compared with the LCS diffing engine.
  # since i am building on top of a windows machine, i have made sure that the file paths are platform independent


  # This is the example case given as a part of this exercie
  def test_compare
      runtest('case1')
  end

  # takes care of comments following lines
  def test_compare_postfixcomment
    runtest('case2')
  end

  # takes care of comments occuring before lines
  def test_compare_prefixcomment
    runtest('case3')
  end

  # cases where there are multiple instanes of /*.. */ tag
  def test_compare_multiplecomment
    runtest('case4')
  end

  # zero size files, when there is no input to compress
  def test_compare_zerosizefiles
    runtest('case5')

  end
  # remove complete blank lines
  def test_removeblanklines
    runtest('case6')

  end

  # utility method to open, compress, write file and diff actual and expected values
  private
  def runtest(foldername)

    lines1 = lines2 = nil

    if (File.exists?((createplatformindependenfilepath(foldername, 'actual.css'))))

      File.delete((createplatformindependenfilepath(foldername, 'actual.css')))

    end
    css_file = CssCompressor.new((createplatformindependenfilepath(foldername, 'src.css')))
    css_file.compress_to((createplatformindependenfilepath(foldername, 'actual.css')))

    File.open((createplatformindependenfilepath(foldername, 'expected.css'))) { |f| lines2 = f.readlines }
    File.open((createplatformindependenfilepath(foldername, 'actual.css'))) { |f| lines1 = f.readlines }

    diffs = Diff::LCS.diff(lines1, lines2)

    assert_equal(diffs.length, 0)

  end

  # create file paths common to windows and unix platforms
  private
  def createplatformindependenfilepath(foldername, filename)

    File.join('.', File::Separator, 'testfiles', File::Separator, foldername, File::Separator, filename)

  end


end