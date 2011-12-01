    
function control(user, state1, state2, channel, joining) {
    var jug = new Juggernaut();
    
    //$("#header").append("<h3>There are <%= @count %> users online.t");
    //very ugly hack to bring together the users and their roles
    //users_and_roles gives both roles
    //$("#header").append(" You are <%= @role1 %>. Your friend is <%= @role2 %></h3>");
    
    //var user = '<%= @user %>';
    //var state1 = '<%= @state1 %>'; 
    //var state2= '<%= @state2 %>'; 
    var user = user;
    var state1 = state1; 
    var state2 = state2; 
    var joining = joining;
    if (state1 =='') {state1 = 'Mystery Spot'}
    if (state2 =='') {state2 = 'Mystery Spot'}
    if (joining == 'true'){
      $("#headerbox-l").append("<h3>Your friend is from "+ state2 +" !</h3>");
      var txt = "<h3><font color='#116600'>System</font>: Your friend has just joined the channel. Say hi!</h3>";
      $("#mesg").append(txt);
      $("#channel_maker").hide();
    } else {
      var txt = "<h3 id='channel_maker'><font color='#116600'>System</font>: Matching you with a friend. Please wait...</h3>";
      $("#mesg").append(txt);
    }
    jug.subscribe("/chats/" + channel, function(data){
      var tmp = data.split(':');
      var msg = tmp[1];
      var sender = tmp[0];
      //if (joining == 'true'){
      //  $("#headerbox-l").append("<h3>Your friend is from "+ state2 +" !</h3>");
      //  var txt = "<h3><font color='#116600'>System</font>: Your friend has just joined the channel. Say hi!";
      //  $("#mesg").append(txt);
      //}
      if (msg == ' off') {
        msg = "Your friend has logged off.";
        data = 'System: '+ msg;
        var li = $("<li/>");
        li.text(data);

        $("#mesg").append("<p></p>");
        $("#mesg").append("<h3>System: Your friend has logged off. <a href='/chat/'>Start a New Role.</a></h3>");
        $("#mesg").append("<h3><a href='javascript: submitDownloadForm()'>Download this Conversation</a></h3>");
        $("#mesg").scrollTop($("#mesg")[0].scrollHeight);
        
        document.getElementById("send_msg").disabled = true;
      } else if (msg = 'Joining') {
	
        $("#headerbox-l").append("<h3>Your friend is from "+ state2 +" !</h3>");
	var txt = "<h3><font color='#116600'>System</font>: Your friend has just joined the channel. Say hi!";
        $("#mesg").append(txt);
      } else if (msg == ' ') {
        $('#msg_body').attr('placeholder', 'Please enter something...'); 
      } else {
        if (sender == user){
          sender = "<font color='#ff7711'>You</font>";
          data = sender + ': ' + msg;
        } else if (sender == "System"){
          sender = "<font color='#116600'>System</font>";
          data = sender + ': ' + msg;
        } else {
          sender = "<font color='#1155ff'>Friend</font>";
          data = sender + ': ' + msg;
        }
        var li = $("<li/>");
        li.text('<li>'+data+'</li>');
        txt = '<h4><li>'+data+'</li></h4>';
        $("#mesg").append(txt);
        $("#mesg").scrollTop($("#mesg")[0].scrollHeight);
      }
    }); 
}
