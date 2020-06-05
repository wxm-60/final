# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

shops_table = DB.from(:shops)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
    # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

# homepage to list all coffeeshops
get "/" do
    @shops=shops_table.all
    view "shops"
end

# individual page to show each coffeeshop
get "/shops/:id" do
    @users_table = users_table 
    @shop = shops_table.where(:id => params["id"]).to_a[0]
    @reviews = reviews_table.where(:shop_id => params["id"]).to_a
    @count = reviews_table.where(:shop_id => params["id"]).count
    view "shop"
end

# page to create a new review
get "/shops/:id/reviews/new" do
    @shop = shops_table.where(:id => params["id"]).to_a[0]
    view "new_review"
end

# Receiving end of new comment
post "/shops/:id/reviews/create" do
    reviews_table.insert(:shop_id => params["id"],
                        :user_id => @current_user[:id],
                        :rating => params["rating"],
                        :comments => params["comments"])
    @shop = shops_table.where(:id => params["id"]).to_a[0]
    view "create_review"
end

# Form to create a new user
get "/users/new" do
    view "new_user"
end

# Receiving end of new user form
post "/users/create" do
    users_table.insert(:fname=>params["firstname"],
                       :lname=>params["lastname"],
                       :email=>params["email"],
                       :password=> BCrypt:: Password.create(params["password"]))
    view "create_user"
end

# Form to login
get "/logins/new" do
    view "new_login"
end

# Receiving end of login form
post "/logins/create" do
    email = params["email"]
    password = params["password"]
    user = users_table.where([:email] => email).to_a[0]
    if user
        if BCrypt:: Password.new(user[:password]) == password
            session[:user_id] = user[:id]
            view "create_login"
        else
            view "create_login_fail"
        end
    else 
        view "create_login_fail"
    end
end

# Logout
get "/logout" do
    session[:user_id] = nil
    view "logout"
end