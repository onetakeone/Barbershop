#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'SQLite3'

#enable sessions
#---------------------------------
configure do
  enable :sessions 
  def database_function
  	SQLite3::Database.new 'barbershop.db3' 
  end
  create_db = database_function
  create_db.execute 'CREATE TABLE IF NOT EXISTS 
  	"Clients"
  		(
		  "ID" INTEGER PRIMARY KEY AUTOINCREMENT, 
		  "client" TEXT, 
		  "number" TEXT,
		  "date" TEXT, 
		  "barber" TEXT, 
		  "color" TEXT
		)'   
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
	login_hash = { :login => "enter login", :pass => "enter pass" }
	@error = login_hash.select {|key, _| params[key] == "" }.values.join(", ")
	if @error != ''
		session[:id] = nil
		erb :login
	else
		erb :about
	end	
end

#if not logged in - redirects to login form / else - opens about.erb
#----------------------	----------------------------------------------
get '/about' do
	loggedin :about
end

#admin
#--------------------------------------------------------
get '/admin' do	
	if session[:id] == 'admin' && session[:pass] == '123'
		redirect :list 
   	else
   		erb :login
	end
end

get '/list' do
		db_output = database_function
		@list = db_output.execute 'select * from Clients order by id desc' 
   		erb :list
end

#visit list
#---------------------------------------------------------
get '/visit' do
	loggedin :visit
end

post '/visit' do
	@name = params[:name]
	@number = params[:number]
	@dates = params[:dates]
	@barber = params[:barber]
	@color = params[:color]

	error_hash = { :name => "name?", :number => "number?", :barber => "Barber?" }
	@error = error_hash.select {|key,_| params[key] == "" }.values.join(", ")
	if @error != ''
		erb :visit
	else
		set_record = database_function
		set_record.execute 'INSERT INTO "Clients" (client, number, date, barber, color) values (?, ?, ?, ?, ?)', [@name, @number, @dates, @barber, @color] #instead values (xxx, yyy) to secure from ' exploite
		erb 'record set'
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

