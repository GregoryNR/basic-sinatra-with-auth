require "sinatra"
require "rack-flash"

require "./lib/user_database"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @user_database = UserDatabase.new
  end

  get "/" do
    erb :root, :layout => :main_layout
  end

  get "/register/" do
    erb :register, :layout => :main_layout
  end

  post "/form_submit/" do
    flash[:register_notice] = "Thank you for registering"

    redirect "/"
  end

  post "/" do
    # p params
    the_user = params["username"]
    p the_user
    erb :root, :locals => { :the_user => the_user }, :layout => :main_layout



  end
end
