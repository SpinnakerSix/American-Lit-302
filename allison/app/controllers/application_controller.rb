require "juggernaut"
class ApplicationController < ActionController::Base
	def send_message
        render_text "<li>" + params[:msg_body] + "</li>"
        Juggernaut.publish("/chats", parse_chat_message(params[:msg_body], "Prabhat"))
        end
        def parse_chat_message(msg, user)
        return "#{user} says: #{msg}"
        end

	# customize file for download
	# takes in a file and a user name
	# creates a new file with the original file name and the username as the name
	def customize_file(user_id, filename)
	  handle = File.open(filename, 'r')
	  content = handle.read
	  
	end
  protect_from_forgery
end
