class IWFAction {

	def initialize(type, target, content)
		@type = type
		@target = target
		@content = content
		@emitted = false
	end

	def error(code, msg)
		@code = code
		@msg = msg
		@content = ''
		self
	end

	def emit_start(pretty_print)
		puts "\n\t" if pretty_print
		puts "<action type='{#@type}'"
		puts " target='{#@target}'" if @target
		puts " errorCode='{#@code}'" if @code
		puts " message='{#@message}'" if @msg
		puts ">"
		puts "\n\t" if pretty_print

		@emitted = true
		self
	end

	def emit_end(pretty_print)
		puts "\n\t" if pretty_print
		puts "</action>"
		self
	end

	def emit(end_emit, pretty_print)
		emit_start pretty_print
		puts @content
		emit_end if end_emit
		self
	end

}

class IWFController {

	def initialize()
		@actions = []
		@current_action = nil
		@currently_emitting = false
		@started_emitting = false
		@debugging = false
		@pretty_print = false
	end

	def debug(on)
		@debugging = on
		@pretty_print = true if on
	end

	def pretty(on)
		@pretty_print = on
	end

	def start_action(type, target)
		emit false
		@current_action = new IWFAction(type, target, '')
		@current_action.emit false, @pretty_print
		@currently_emitting = type
		return @current_action
	end


	def end_action
		if @current_action != nil {
			@current_action.emit true, @pretty_print
			@currently_emitting = ''
			@current_action = nil
		} else {
			puts "called end action when no action was current!"
		}
	end

	def add_html(html, target)
		action = new IWFAction('html', target, html)
		@actions.push action
		action
	end

	def start_html(target)
		start_action 'html', target
	end

	def end_html(close)
		unless @currently_emitting == 'html' {
			error -2163, "iwf.end_html called, but iwf believes it should be emitting {#@currently_emitting}"
		} else {
			end_action
		}
		self.close if close
	end

	def error(code, msg)
		if @current_action == nil
			add_error code, msg
		else
			@current_action.error(code, msg)
	end

	def end_xml(finished)
		unless @currently_emitting == 'xml' {
			error -2164, "iwf.end_xml called, but iwf believes it should be emitting {#@currently_emitting}"
		} else {
			end_action
		}

		close if finished

	end

	def add_js(js)
		add_javascript js
	end

#	alias add_js add_javascript
	def add_javascript(javascript)
		action = new IWFAction('javascript', '', "<![CDATA[ {#javascript} ]]>")
		@actions.push action
		action
	end

	def popup(text)
		add_javascript "alert('Server-side IWF popup:\n{#text}');"
	end

	def add_xml(xml)
		action = new IWFAction('xml', '', xml)
		@actions.push action
		action
	end

	def start_xml
		start_action xml, ''
	end

	def add_error(code, msg)
		action = new IWFAction('', '', '')
		action.error code, msg
		@actions.push action
		action
	end

	def emit(end_emit)
		unless @started_emitting {
			puts "<response"
			puts " debugging='true'" if @debugging
			puts " pretty='true'" if @pretty_print
			puts ">"
			@started_emitting = true
		}

		end_action unless @current_action == nil

		@actions.each { |act|,
			act.emit true, @pretty_print
		}

		actions = []

		if end_emit {
			puts '\n' if @pretty_print
			puts '</response>'
		}

	end

	def close
		emit true
		@debugging = false
	end

}


# create a singleton IWF object to use
# iwf = new IWFController()
# iwf.pretty(params[:iwfPretty] == 'true')

# debugging always sets prettyprint to true, so we must set debug last.
# iwf.debug(params[:iwfDebug] == 'true')

# load the default vars...
#iwf.mode = params[:iwfMode]
# iwf.id = params[:iwfId]
# iwf.target = params[:iwfTarget]
