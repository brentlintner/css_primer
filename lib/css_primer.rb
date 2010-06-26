#!/usr/bin/ruby

HELP = <<TEXT

== CSS::Primer
Takes in a markup file (html/xml) and creates a CSS file with a reference to classes/ids.

== Usage
css_primer [options] --in FILE_TO_PRIME [--out] CSS_OUTPUT_FILE

== Options
-h,   --help               Displays help message
-q,   --quiet              Output as little as possible, overrides verbose
-V,   --verbose            Verbose output
-i,   --in                 Markup file to parse
-o,   --out                (optional) CSS file to save out to
-s,   --sort               (optional) Sorts ids/classes alphabetically when set else by the order of parsing

TEXT

class CSSPrimer

  class MarkupFileError < StandardError ; end

  attr_accessor :markup_file, :css_file

  def initialize(argv)

    @config = OpenStruct.new
    @config.HELP = HELP
    @config.DEFAULT_CSS_FILE_OUT = "primed_styles.css"

    @argv = argv

    @options = OpenStruct.new
    @options.verbose = false
    @options.quiet = false
    @options.sort = false

    @attributes = []

    @markup_file = ""
    @css_file = self.config("DEFAULT_CSS_FILE_OUT")

  end

  def prime!

    if self.parsed_options?

      begin

        self.log("Time to pwn...\n")

        # TODO: clean up regex, not tight enough (i.e. will match against inner text and javascript strings if present)
        parser = Proc.new { |full_path|

          self.log("\nOpening up #{full_path}\n") if @options.verbose

          self.read_in_file(full_path) do |line|

            line.scan(/class="((\s|\w|\-)*)"/) do |class_attribute|
              class_attribute[0].split(" ").each do |class_name|
                @attributes << [class_name, "."]
                self.log("Found class => #{class_name}") if @options.verbose
              end
            end

            line.scan(/id="((\w|\-)*)"/) do |id_attribute|
              @attributes << [id_attribute[0], "#"]
              self.log("Found id => #{id_attribute[0]}") if @options.verbose
            end

          end

        }

        if File.directory?(@markup_file)
          self.recurse_directories(@markup_file) do |full_path|
            parser.call(full_path) if full_path =~ /\.(html|xml)$/
          end
        else
          parser.call(@markup_file)
        end

        # TODO: do win or *nix line breaks
        buffer_array = @attributes.uniq
        buffer_array.sort! if @options.sort

        self.save(buffer_array.inject("") { |buffer, item| buffer << "#{item[1]}#{item[0]} {\n\n}\n\n" }, @css_file)

        puts "\nSaved to #{@css_file}\n\nLet's Roll!"

      rescue Exception => e
        self.handle_exception(e)
      end

    end

  end

  protected

  def config(struct)
    @config.send(struct)
  end

  def generate_docs
    begin
      Kernel.exec "rdoc1.8 -U -S -N -o 'rdoc' --main CSSPrimer"
    rescue Exception => e
      self.handle_exception(e)
    ensure
      Kernel.exit!(0)
    end
  end

  def parsed_options?

    opts = OptionParser.new

    opts.on('-v', '--version')            { self.log("0.1") ; exit!(0) }
    opts.on('-h', '--help')               { self.log(self.config("HELP")) ; exit!(0)  }
    opts.on('-V', '--verbose')            { @options.verbose = true }
    opts.on('-q', '--quiet')              { @options.quiet = true }
    opts.on('-r', '--rdoc')               { self.generate_docs }
    opts.on('-s', '--sort')               { @options.sort = true }

    opts.on('-i', '--in MARKUPFILE') do |markup_file|
      @markup_file = markup_file
    end

    opts.on('-o', '--out [CSSFILE]') do |css_file|
      @css_file = css_file
    end

    begin

      opts.parse!(@argv)

    rescue Exception => e
      self.handle_exception(e)
      exit!(0)
    end

    self.process_options

    true

  end

  def process_options
    @options.verbose = false if @options.quiet
    raise MarkupFileError, "No input markup file specified." if !File.exists?(@markup_file)
  end

  def recurse_directories(directory, limit=10, &block)

    raise StandardError, "You should use a block eh!" if !block_given?
    raise StandardError, "Recursive limit reached!" if limit <= 0

    Dir.foreach(directory) do |directory_item|
      full_path = "#{directory}/#{directory_item}"

      if directory_item != "." && directory_item != ".."
        if File.directory?(full_path)
          self.log("\nNavigating into #{full_path}") if @options.verbose          
          recurse_directories(full_path, limit - 1, &block)
        else
          yield(full_path)
        end
      end
    end

  end


  # helpers
  def log(msg)
    puts msg.to_s
  end

  def handle_exception(e)
    msg = e.message

    msg = e.exception.to_s+" :: "+msg if e.message.to_s != e.exception.to_s

    self.log "\nHANDLED EXCEPTION --> #{e.class.to_s}\n\nMESSAGE --> #{msg}"
    self.log "\nBACKTRACE\n\n#{e.backtrace.join("\n")}\n\n"
  end

  def read_in_file(full_path, &block)
    data = ""

    if !File.directory?(full_path)
      IO.foreach full_path do |line|
        data += block_given? ? yield(line) : line
      end
    end

    data
  end

  def save(lines, file_to_write)
    File.open(file_to_write, "w") do |file|
      file.syswrite lines
    end
  end

  def append(lines, file_to_append)
    File.open(file_to_append, "a") do |file|
      file.syswrite lines
    end
  end

end
