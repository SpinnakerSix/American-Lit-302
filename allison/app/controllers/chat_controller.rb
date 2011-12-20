require "juggernaut"

# main issue might be to get the @channel variable consistent

class ChatController < ApplicationController

	def index
	  @user = User.create.id
	  @count = User.all.size
	  puts "Creating User #{@user}"
          # get ip
          @ip = request.remote_ip
          UserRecord.create(:user_id => @user, :ip=>@ip)
	  @channel, @role1, @role2, @location1, @location2, @joining = join_channel(@user)

	  if (@joining)
	    puts "Joining Joining!"
            @msg = 'Joining'
 	    Juggernaut.publish(select_channel(@channel_id), parse_chat_message(@msg, 'System'))	
	  end
          if (@location1 != nil and @location2 != nil ) 
            @city2 = @location2.city
  	    @state2 = @location2.state         
            @city1 = @location1.city
	    @state1 = @location1.state         
          end
	end
	
	def next
	   @current_channel_id = params[:channel]
	   @user_id = params[:sender]
           @user = @user_id
	   exit_channel(@current_channel_id, @user_id)
	   @channel, @role1, @role2, @location2 = join_channel(@user_id)
           @city = @location2.city
	   @state = @location2.state         
	end
        
        def download
          @user = params[:sender]
          @channel = params[:channel]
          send_file "app/views/logs/#{@channel}.txt", :type=>"application/text" 
        end
	def send_message
	  @messg = params[:msg_body]
  	  @sender = params[:sender]
	  @channel = params[:channel]
	  puts 'send message'
	  puts "messg: #{@messg}"
	  puts "sender: #{@sender}"
	  puts "channel: #{@channel}"
 	  Juggernaut.publish(select_channel(@channel), parse_chat_message(params[:msg_body], params[:sender]))	

          f = File.open("app/views/logs/#{@channel}.txt",'a')
          f.write("<#{@sender}>: #{@messg} \n")
          f.close

	  respond_to do |format|
	    format.js
  	  end
	end
	
	def parse_chat_message(msg, user)
	  #return "#{user}: #{msg}"
          return "#{user}: #{msg}"
	end

	def select_channel(receiver)
	  return "/chats/#{receiver}"
	end

	def no_free_channel?
	  if FreeChannel.all.count==0
	    return true
	  else
	    return false
	  end
	end

	def make_free_channel(user_id)
          # get a role
          role_arr = Role.all
          n = role_arr.size
          i = rand(n)
          @tmp = role_arr[i]
          @role1 = @tmp.role1
          # @users_and_roles = @role1+':'+@role2

	  puts "Create free channel"
	  @channel = FreeChannel.create(:user1=>user_id, :role1=>@role1)
          return [@channel, @role1]
	end

	def get_free_channel
	  # check if there is existing free channel
	  # if not create channel with the user
	  puts "Randomly picking a channel"
	  arr = FreeChannel.all
	  return arr[rand(arr.size)].id
	end

	def join_free_channel(free_channel_id, user_id)
	  @free_channel_id = free_channel_id
	  @user2 = Integer(user_id)
	  @user1 = FreeChannel.find_by_id(@free_channel_id).user1
	  
	  FreeChannel.find_by_id(free_channel_id).destroy
	  # InuseChannel's name is free_channel's id
	  InuseChannel.create(:name=>free_channel_id, :user1=>@user1, :user2=>@user2)
	end

	def join_channel(user_id)
	  puts "Joining Channel..."
	  @user_id = user_id
	  if no_free_channel?

	    puts "No free Channel, #{@user_id} is Making a free channel"
	    @channel, @role1 = make_free_channel(@user_id)

            @role2 = Role.find_by_role1(@role1).role2
	    @loc1 = find_location_by_user_id(@user_id)

 	    #@msg = 'Matching you with a friend. Please wait...'
	    #Juggernaut.publish(select_channel(@channel.id), parse_chat_message(@msg, 'System'))	
	    return [@channel.id, @role1, @role2, @loc1, @loc2, false]

	  else
	    puts "There are free channels!"

	    @channel_id = get_free_channel

            @role2, @role1 = parse_channel_roles(@channel_id) 
	    @channel = join_free_channel(@channel_id, @user_id)
	    @user1 = @channel.user1
            @user2 = @channel.user2

            # record's file name is going to be the channel's name
            Record.create(:channel=>@channel_id, :user1=>@user1, :user2=>@user2, :role1=>@role1, :role2=>@role2)
            File.new("app/views/logs/#{@channel_id}.txt", "w")

	    @loc1 = find_location_by_user_id(@user1)
	    @loc2 = find_location_by_user_id(@user2)
	    #@msg = "Joining Channel #{@channel_id}. Your friend is here. Say hi!"
	    puts "user #{@user_id} is joining channel #{@channel_id}"
	    return [@channel.name, @role1, @role2, @loc1, @loc2, true]
	  end
	end

	# database cleanups during a session exit event
	def exit_channel(channel_id, user_id)
	  # clean up inuse channels
	  if InuseChannel.find_by_name(channel_id) != nil
	    inuse_channel = InuseChannel.find_by_name(channel_id)
	    user1 = inuse_channel.user1
	    user2 = inuse_channel.user2
	    if user1 == user_id
	      User.find_by_id(user1)
	    else
	      User.find_by_id(user2)
	    end
	    inuse_channel.destroy 
	  else
	    free_channel = FreeChannel.find_by_id(free_channel_id)
	    user = free_channel.user1
	    User.find_by_name(user).destroy
	    free_channel.destroy
	  end
	  
	end
        def parse_channel_roles(channel_id)
          puts "Parse Channel Roles of #{channel_id}"
          @role1 = FreeChannel.find_by_id(channel_id).role1 
          @role2 = Role.find_by_role1(@role1).role2
          return [@role1, @role2]
        end

	def find_location_by_user_id(user_id)
	    @user_id = user_id
	    @ip = UserRecord.find_by_user_id(@user_id).ip
	    @location = Geokit::Geocoders::MultiGeocoder.geocode(@ip)
	end
end
