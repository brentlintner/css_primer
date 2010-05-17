module GenericApplication

    def log(msg)
        puts msg.to_s
    end

    #handle exceptions the DRY way, or at least start to.
	def handle_exception(e)
        msg = e.message

        if e.message.to_s != e.exception.to_s
          msg = e.exception.to_s+" :: "+msg
        end

        self.log "\nHANDLED EXCEPTION --> #{e.class.to_s}\n\nMESSAGE --> #{msg}"
        self.log "\nBACKTRACE\n\n#{e.backtrace.join("\n")}\n\n"
    end

end