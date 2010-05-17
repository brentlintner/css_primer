#!/usr/bin/ruby

# example cmd ==> ruby primer.rb HTMLFILE_LOCATION OPTIONAL_FILENAME

class CSSPrimer

    include GenericApplication
    include IOHelper

    MAIN_CONFIG_FILE = '../conf/gem.conf'

    attr_accessor :markup_file
    attr_accessor :css_file

    def initialize(argv, stdin)

        @config = ParseConfig.new(MAIN_CONFIG_FILE)

        @argv = argv
        @stdin = stdin

        @options = OpenStruct.new
        @options.verbose = false
        @options.quiet = false

        @my_ids, @my_classes = [], []

        @markup_file = ""
        @css_file = self.config("DEFAULT_CSS_FILE_OUT")

    end
    
    def config(index)
        @config.params[index]
    end
    
    def prime!

        if self.parsed_options?

            begin

                self.log("what up! lets do some priming\nopening up #{@markup_file}\n") if @options.verbose

                buffer, val, css_type = "", "", ""

                # TODO: clean up
                self.read_in_file(@markup_file).scan(/(id="\S+"|class="\S+")/) do |w|

                    w[0].scan(/"\S+"/) do |val|
                    
                        css_type = (w[0] =~ /^id=/) ? "#" : "."

                        val.gsub!(/"/,"")

                        if css_type == "#"
                            @my_ids.push [val, css_type]
                        else
                            @my_classes.push [val, css_type]
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

    # parses command line options and does its thang
    def parsed_options?

        opts = OptionParser.new

        opts.on('-v', '--version')            { self.log("0.1") ; exit!(0) }
        opts.on('-h', '--help')               { self.log(self.read_in_file(self.config("HELP"))) ; exit!(0)  }
        opts.on('-V', '--verbose')            { @options.verbose = true }  
        opts.on('-q', '--quiet')              { @options.quiet = true }
        
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
    
        raise RuntimeError, "no input markup file specified" if !File.exists?(@markup_file)
    end
  
end