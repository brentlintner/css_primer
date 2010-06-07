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
  -o,   --out                CSS file to save out to (optional)

TEXT

class CSSPrimer

    include GenericApplication
    include IOHelper

    class MarkupFileError < RuntimeError ; end

    MAIN_CONFIG_FILE = '../conf/gem.conf'

    attr_accessor :markup_file, :css_file

    def initialize(argv)

        @config = OpenStruct.new
        @config.HELP = HELP

        @config.DEFAULT_CSS_FILE_OUT = "primed_styles.css"

        @argv = argv

        @options = OpenStruct.new
        @options.verbose = false
        @options.quiet = false

        @my_ids, @my_classes = [], []

        @markup_file = ""
        @css_file = self.config("DEFAULT_CSS_FILE_OUT")

    end
    
    def config(struct)
        @config.send(struct)
    end
    
    def prime!

        if self.parsed_options?

            begin

                self.log("what up! lets do some priming\nopening up #{@markup_file}\n") if @options.verbose

                buffer = ""

                # TODO: clean up
                self.read_in_file(@markup_file).scan(/(id="\S+"|class="\S+")/) do |w|

                    w[0].scan(/"\S+"/) do |rule_attribute|
                    
                        css_type = (w[0] =~ /^id=/) ? "#" : "."

                        rule_attribute.gsub!(/"/,"")

                        if css_type == "#"
                            @my_ids.push [rule_attribute, css_type]
                        else
                            @my_classes.push [rule_attribute, css_type]
                        end

                    end
                    
                end

                @my_ids.uniq.sort.concat(@my_classes.uniq.sort).each do |arr|
                    buffer += "#{arr[1]}#{arr[0]}{\n\n}\n\n"
                end

                self.save(buffer, @css_file)

                puts "saved to #{@css_file}\n\nLet's Roll!" if @options.verbose

            rescue Exception => e  
                self.handle_exception(e)
            end

        end
        
    end

    protected

    def generate_docs
        begin
            Kernel.exec "rdoc1.8 -U -S -N -o '../rdoc' --main CSSPrimer"
        rescue Exception => e
            self.handle_exception(e)
        ensure
            Kernel.exit!
        end
    end

    def parsed_options?

        opts = OptionParser.new

        opts.on('-v', '--version')            { self.log("0.1") ; exit!(0) }
        opts.on('-h', '--help')               { self.log(self.config("HELP")) ; exit!(0)  }
        opts.on('-V', '--verbose')            { @options.verbose = true }  
        opts.on('-q', '--quiet')              { @options.quiet = true }
        opts.on('-r', '--rdoc')               { self.generate_docs }

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
  
end
