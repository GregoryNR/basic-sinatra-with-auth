require "sinatra"
require "rack-flash"

require "./lib/user_database"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  # IF YOU CLOSE CHROME AFTER SUCCESSFULLY LOGGING IN (without logout) THEN
  # CHROME STORES A COOKIE FOR 'LOCAL' THAT WILL MAKE THE WHOLE THING NOT WORK
  # JUST DELETE THE COOKIE FROM CHROME TO MAKE IT BETTER

  def initialize
    super
    @user_database = UserDatabase.new
  end

  get "/" do
    # ADDED stuff here to load the proper layout based on whether a user has logged in
    # basically this logic checks to see if 'session[:user]' exists, and if it does it
    # will assign @user to their user hash. I changed the erb to display the login name
    # and you'll notice the erb logic to determine what to display now is contingent
    # on 'session[:user]' working.
    if session[:user]
      @user = @user_database.find(session[:user])
      erb :root, :locals => { :user => @user }, :layout => :main_layout
    end
    erb :root, :locals => { }, :layout => :main_layout
  end

  get "/register/" do
    erb :register, :layout => :main_layout
  end

  post "/form_submit/" do
    # the following takes the params hash and turns their string keys into symbol keys
    # and puts them into 'params_sym'. Look up .inject method to see how it works.
    # You don't need to know this for the assessment!
    params_sym = params.inject({}){|memo,(key,value)| memo[key.to_sym] = value; memo}

    # this is the form checker which determines if the user entered blank spaces
    # for either 'username' or 'password'. Also 'redirect "/register/"' acts kind of like
    # a break or return in that it kicks us out of the 'post "/form_submit/" do' immediately
    # and takes us back to /register/ with a flash message. I've added a flash[:input_failure]
    # to the register.erb file
    # YOU DON'T NEED TO KNOW THIS PART FOR THE ASSESSMENT
    if params_sym[:password] == "" && params_sym[:username] == ""
      flash[:input_failure] = "Please enter a username and password."
      redirect "/register/"
    elsif params_sym[:password] == ""
      flash[:input_failure] = "Please enter a password."
      redirect "/register/"
    elsif params_sym[:username] == ""
      flash[:input_failure] = "Please enter a username."
      redirect "/register/"
    end

    # if we make it here, then something valid was entered for 'username' and 'password'
    flash[:register_notice] = "Thank you for registering"
    # This .insert is the method defined for the UserDatabase class. Remember that
    # @user_database is an instance of the UserDatabase class, so it inherits from
    # that class and therefore has the .insert method. I insert into @user_database with the
    # {:username => "name", :password => "password"} hash declared with 'params_sym'
    @user_database.insert(params_sym)
    redirect "/"
  end

  post "/" do
    # this is just turning the 'params' hash keys into symbols again
    params_sym = params.inject({}){|memo,(key,value)| memo[key.to_sym] = value; memo}

    # the next three lines create an 'active_user' variable which only becomes true if
    # the params :username and :password match an existing username and password in the
    # @user_database. 'user_hashes' represent each hash of a user in the database
    # next week we will be using actual database software instead of this .all.find stuff
    active_user = @user_database.all.find do |user_hashes|
      params_sym[:username] == user_hashes[:username] && params_sym[:password] == user_hashes[:password]
    end

    # when active_user is true, store their id into a cookie
    # session[:user] or flash a 'user not found' (I added another flash for this on our root)
    if active_user
      session[:user] = active_user[:id]
    else
      flash[:not_found] = "User not found."
    end
    redirect "/"
  end

  # to logout reset the cookie to nil and return to the root page
  get '/logout/' do
    session[:user] = false
    redirect "/"
  end

end
