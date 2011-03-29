#opens a CSS file, and does a
#compression of it by
#*removing all the blank lines, and
#lines that are only comments.
# i have also implemented additional logic to remove comments even that are found as prefixes and suffixes to lines:-)!
#(some of the test cases cover the additional cases)
class CssCompressor

  # opens the given css file if valid and present and reads the contents of the file and
  # pushes into a buffer
  # while it pushes each line from the file it scans for <b>blank lines</b> and <b>lines that are only comments</b>
  public
  def initialize(css_file_name)

    @input_file_name = nil
    @text = ''
    @ipcssfile = nil
    @opcssfile = nil

    # check if the file name sent by the user are are non null values
    if (css_file_name.nil? || css_file_name == '')
      raise ArgumentError.new (" No valid input file name present.Please specify the full path to input css file.")
    else
      @input_file_name = css_file_name
    end

    # Now lets try to open the file name specified by the user
    begin
      @ipcssfile = File.open(@input_file_name, "r")
      @ipcssfile.each do |line|

        # if this is a blank line dont bother stuffing it into the buffer. ignore blank lines
        if (!isblankline(line))
          #if the line is simply a line comment then ignore it.. if the line has text and comments we would be pushing
          # it into the buffer
          if (!iscommentonlyline(line))
            @text << line
          end
        end
      end

    end
  rescue Errno::ENOENT # file not found exception
    @input_file_name = nil
    puts "Unable to open the file #{css_file_name}. Please check if it exists"
    raise $!
  rescue # catch all exception
    @input_file_name = nil
    raise $! # rethrow the same
  ensure
    @ipcssfile.close if @ipcssfile # close this file handle if its  still open
  end

  # utility method to remove blocks of code within /* .. */ if they are the only contents of the
  # line
  private
  def iscommentonlyline(inputline)

    # check to see if we have some lines in the input file before we try to scan
    if !(inputline.to_s.empty?)
      inputline.scan(/^\/\*((.)*)\*\/$/).length >= 1
    end

  end


  # utility method to remove blank lines from the file
  private
  def isblankline(inputline)

    # we need to have some lines in the input file to compress
    # the value of 2 comes from the fact that blank lines have a length of 2 e.g('\','n')
    if !(inputline.to_s.empty?)
      inputline.scan(/\S/).to_s.length == 2
    end
  end

  def removeleadingtrailingcomments

    @text = @text.gsub(/\/\*((.)*)\*\//, '')

  end


  #the compresssion method that calls the utility methods to perform
  #various file compression actions
  private
  def compressfile()
    # this is the additional logic i implemented to remove any text found
    # within /*.. */ anywhere else in the file
    removeleadingtrailingcomments
  end

  # writes the content of the buffer to the specified file
  # in case the file already exists it prompts the user if we want to overwrite
  public
  def compress_to(css_file_name)

    # Proceed to compress the file only if we were able to open the
    # input css file successfully
    if (@input_file_name != nil)

      # check if the file name sent by the user are are non null values
      if (css_file_name.nil? || css_file_name == '')
        raise ArgumentError.new(" Invalid file name.Please specify the full path to output css file.")
      else
        @output_file_name = css_file_name
      end

      # the input and output files are expected to be different.
      if (@output_file_name == @input_file_name)
        puts "Input Css file name #{@input_file_name} output css file name #{@output_file_name}. Please enter different input and output css file names"
        puts "Exiting.. Please try with a different file name"
        return
      end

      # Now lets try to open the file name specified by the user
      # prompt the user in case the file with the same name already exists
      begin
        if (File.exist?(@output_file_name))
          puts "Do you want to overwrite existing file #{@output_file_name}. Press 'y' to continue (y/n)"
          ip = gets
          # chomp of the tailing new lines when getting input from the user
          if (ip.chomp().to_s.downcase != 'y')
            puts "Exiting.. Please try with a different file name"
            return
          end
        end
        @opcssfile = File.open(@output_file_name, "w")
        compressfile
        @opcssfile << @text.strip

        # if we are here then we have succeeded
        if (@output_file_name)
          puts "CSS File compression succeeded"
        end
      end
    end

  rescue => e #catch any exception
    raise e # rethrow the same

  ensure
    @opcssfile.close if @opcssfile # close this file handle if its still open


  end
end

