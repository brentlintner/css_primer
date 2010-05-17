module GenericApplication

	def log(msg)
		puts msg
	end

	def handle_exception(e)
		msg = e.message

		msg = e.exception.to_s+" :: "+msg if e.message.to_s != e.exception.to_s

		self.log "\nHANDLED EXCEPTION --> #{e.class.to_s}\n\nMESSAGE --> #{msg}"
		self.log "\nBACKTRACE\n\n#{e.backtrace.join("\n")}\n\n"
	end

end