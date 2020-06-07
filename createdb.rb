# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :shops do
  primary_key :id
  String :name
  String :description, text: true
  String :location
end

DB.create_table! :reviews do
  primary_key :id
  foreign_key :shop_id
  foreign_key :user_id
  Integer :rating
  String :comments, text: true
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
shops_table = DB.from(:shops)

shops_table.insert(name: "Newport Coffee House", 
                    description: "A coffee roaster offering exclusively certified organic coffee, online and in our coffee shops on the Chicago North Shore.",
                    location: "622 Davis St, Evanston, IL 60201")

shops_table.insert(name: "Brothers K Coffeehouse", 
                    description: "Buzzy coffee shop serving Chicago-roasted Metropolis java, Italian-style espresso & baked goods.",
                    location: "500 Main St, Evanston, IL 60202")

shops_table.insert(name: "Pâtisserie Coralie", 
                    description: "Classic French baked goods including macarons plus Julius Meinl coffee drinks in a quaint setting.",
                    location: "600 Davis St, Evanston, IL 60201")

shops_table.insert(name: "Coffee Lab Evanston", 
                    description: "Eco-friendly, nonprofit storefront with a collegial vibe providing pour-over coffee, tea & pastries.",
                    location: "910 Noyes St, Evanston, IL 60201")

shops_table.insert(name: "Unicorn Cafe", 
                    description: "Beverages, baked goods & other light fare in a mellow coffeehouse setting with free WiFi.",
                    location: "1723 Sherman Ave, Evanston, IL 60201")