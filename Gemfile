source "http://rubygems.org"

gem "sinatra"
gem "data_mapper"
gem "haml"
gem "rack-flash"

group :production do
  gem "dm-postgres-adapter"
end

group :development do
  gem "dm-sqlite-adapter"
  gem "thin"
  gem "heroku"
end
