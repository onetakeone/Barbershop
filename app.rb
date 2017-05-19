#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'SQLite3'

#enable sessions
#---------------------------------
configure do
  enable :sessions     	  
end

def loggedin tempo
	if session[:id].nil?
		erb 'Sorry, you need to be <a href="/login"> logged in</a>'
	else
		erb tempo
	end
end

#if not logged in - redirect to login form
#-------------------------------------------
get '/' do
	if session[:id].nil?  
		erb :login
	else
		erb :about
	end

end

#requesting login form - directs to login.erb
#-----------------------------------------------
get '/login' do	
	erb :login
end

#gets login info from login.erb / sets session id and password
#---------------------------------------------------------------
post '/login' do
	session[:id] = params[:login]
	session[:pass] = params[:pass]
	loginarr = { :login => "enter login", :pass => "enter pass" }
	
	@error = loginarr.select {|key, _| params[key] == "" }.values.join(", ")
	if @error != ''
		session[:id] = nil
		erb :login
	else
		erb :about
	end
	
end

#if not logged in - redirects to login form / else - opens about.erb
#--------------------------------------------------------------------
get '/about' do
	loggedin :about
end

#admin
#--------------------------------------------------------
get '/admin' do	
	@output = File.open "./public/visits.txt", "r"
	@messoutput = File.open "./public/messages.txt", "r"

	if session[:id] == 'admin' && session[:pass] == '123'
		erb :list
	else
		erb :admin
	end

	db = SQLite3::Database.new("./public/records.sqlite3")
	db.execute "SELECT * FROM Records" do |var|
		puts var
		puts "===="
	end
	db.close
end

post '/admin' do
	@output = File.open "./public/visits.txt", "r"
	@messoutput = File.open "./public/messages.txt", "r"
	@login = params[:login]
	@pass = params[:pass]s


	if @login == 'admin' && @pass == '123'
		erb :list
	else
		erb :admin
	end
end

#visit list
#---------------------------------------------------------
get '/visit' do
	loggedin :visit
end

post '/visit' do

	@name = params[:name]
	@number = params[:number]
	@comments = params[:comments]
	@barber = params[:barber]
	@color = params[:color]

	array = { :name => "name?", :number => "number?" }
	@error = array.select {|key,_| params[key] == "" }.values.join(", ")
	if @error != ''
		erb :visit
	else
		input = File.open "./public/visits.txt", "a"
		input.write "Client: #{@name} <br> Cell: #{@number} <br> Comment: #{@comments} <br> Barber: #{@barber} <br> Color: #{@color} <br><br>" 
		input.close
		
		erb :about
			
	end
end

#CONTACT
#---------------------------------------------------------
get '/contact' do
	loggedin :contact
end

post '/contact' do
#	@name = params[:name]
	@email = params[:email]
#	@message = params[:message]
require 'pony'

Pony.mail(	
    	:to => 'limepassion@gmail.com',
    	:from => params[:email],
  		:body => params[:message],
  		:subject => params[:name] + " has contacted you",
   		:via => :smtp,
  		:via_options => { 
    		:address              => 'smtp.gmail.com', 
    		:port                 => '587', 
    		:enable_starttls_auto => true, 
    		:user_name            => 'limepassion', 
    		:password             => '1e7loki777', 
    		:authentication       => :plain, 
    		:domain               => 'localhost.localdomain'
		  })
erb :contact

#	contactarr = { :email => "enter email", :message => "enter message" }
#	@error = contactarr.select {|key, _| params[key] == ""}.values.join(", ")
#	if @error != ''
#		erb :contact
#	else
#		messinput = File.open "./public/messages.txt", "a"
#		messinput.write "#{@email} <br> #{@message}<br><br>" 
#		messinput.close
#		erb :about
#	end

	
end

#LOGOUT
#If logged in, else - need to login to logout ) 
#------------------------------------------------------------
get '/logout' do
	unless session[:id].nil?
		a = session[:id]		#copy id to add in text message 
		session.delete :id
		erb "<div class='alert alert-message'> <b>#{a.capitalize}</b> logged out</div>"
 	else
 		erb 'Sorry, you need to be <a href="/login"> logged in</a> to logout'
 	end
end

