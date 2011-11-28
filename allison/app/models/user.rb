class User < ActiveRecord::Base
  class << self
    @@msg = 'off'
    @@master_sender = 'System'
    def subscribe
      Juggernaut.subscribe do |event, data|
        case event
          when :subscribe
	    puts "subscribing! #{event} #{data}"

	    @channel_id = extract_channel_id(data)

	    puts "Subscribe to channel: #{@channel_id}"
	    
	    @channel_inuse = InuseChannel.find_by_name(@channel_id)
	    @channel_free = FreeChannel.find_by_id(Integer(@channel_id))

	    if @channel_inuse != nil
	      @user1 = @channel_inuse.user1
	      @user2 = @channel_inuse.user2

	      puts "with user1 #{@user1}"
	      puts "with user2 #{@user2}"

	    elsif @channel_free != nil
	      @user1 = @channel_free.user1
	      puts "with user1 #{@user1}"
	    end
	    puts ''
          when :unsubscribe
	    # destroy session
	    puts "unsubscribing! #{event} #{data}"
	    # remove user from all existing channel
	    @channel_id = extract_channel_id(data)
	    @channel_inuse = InuseChannel.find_by_name(@channel_id)
	    @channel_free = FreeChannel.find_by_id(Integer(@channel_id))

	    if @channel_inuse != nil
	      @user1 = @channel_inuse.user1
	      @user2 = @channel_inuse.user2
	      
 	      Juggernaut.publish(select_channel(@channel_inuse.name), parse_chat_message(@@msg, 'System'))	

	      puts "user1 #{@user1}"
	      puts User.find_by_id(Integer(@user1))
	      puts "user2 #{@user2}"
	      puts User.find_by_id(Integer(@user2))

	      User.find_by_id(Integer(@user1)).destroy
	      User.find_by_id(Integer(@user2)).destroy

	      @channel_inuse.destroy
	    elsif @channel_free != nil
	      @user1 = @channel_free.user1

	      puts "user1 #{@user1}"
	      User.find_by_id(Integer(@user1)).destroy
	      @channel_free.destroy

	    end
 	    
	    puts ''
        end
      end
    end

    def select_channel(receiver)
      return "/chats/#{receiver}"
    end

    def parse_chat_message(msg, user)
      return "#{user}: #{msg}"
    end

    def extract_channel_id(h)
      # channel is a string in a hash, needs to extract it
      @channel_id = Integer(h['channel'].split('/')[2])
    end

  end

end
