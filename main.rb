require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'data_mapper'
require 'rack-flash'
require './models'
require './lib/helpers'

DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions
use Rack::Flash

get '/' do
  @all_quotes = Quote.all(:order => [:points.desc])
  haml :index
end

get '/about' do
  haml :about
end

get '/login' do
  haml :login
end

get '/user/new' do
  haml :new_user
end

get '/user/all' do
  if !is_admin?
    flash[:error] = "Not for you!"
    redirect '/'
  end
  @all_users = User.all
  haml :all_users
end

get '/user/:name/delete' do
  if !is_admin?
    flash[:error] = "Not for you!"
    redirect '/'
  end
  @user_to_delete = User.get(params[:name])
  haml :delete_user
end

post '/user/:name/delete' do
  delete_voters(params[:name])
  User.get(params[:name]).destroy
  flash[:success] = "User removed!"
  redirect '/user/all'
end

post '/user/new' do
  if User.exists?(params[:name])
    flash[:error] = "Username is already in use!"
    redirect '/user/new'
  else
    if params[:password].length > 0
      user = User.new(:name => params[:name], :password => Digest::SHA1.hexdigest(params[:password]))
      if user.save
        flash[:success] = "Sign up successful! And now you are signed in awesome!"
        session["logged_in"] = true
        session["username"] = params[:name]
        redirect '/'
      else
        flash[:error] = "Mystic error!"
        redirect '/user/new'
      end
    else
      flash[:error] = "Password field empty!"
      redirect '/user/new'
    end
  end
end

get '/qte/:id' do
  @quote = Quote.get( params[:id] )
  @escaped_quote = escape_quote( @quote.body )
  haml :single_quote
end

get '/qte' do
  if is_logged_in?
    haml :qte
  else
    redirect "/"
  end
end

post '/qte/:id/upvote' do
  @q = Quote.get( params[:id] )
  @temp = @q.points + 1
  @q.points = @temp
  if @q.save
    Voter.create(:voter_name => session["username"], :quote => @q)
    flash[:success] = "upvoted!"
    redirect '/'
  else
    flash[:error] = "Mystic error!"
    redirect '/'
  end
end

post '/qte/:id/downvote' do
  @q = Quote.get( params[:id] )
  @temp = @q.points - 1
  @q.points = @temp
  if @q.save
    Voter.create(:voter_name => session["username"], :quote => @q)
    flash[:success] = "downvoted!"
    redirect '/'
  else
    flash[:error] = "Mystic error!"
    redirect '/'
  end
end

post '/qte' do
  quote = Quote.new(:body => escape_quote( params[:quote] ), :channel => params[:kanava], :posted_by => session["username"])
  if quote.save
    flash[:success] = "Quote added!"
    redirect '/qte'
  else
    flash[:error] = "Mystic errror!"
    redirect '/'
  end
end

get '/qte/:id/delete' do
  if is_admin? || is_users_quote?(:id)
    @qute = Quote.get(params[:id])
    haml :delete_quote
  else
    redirect '/'
  end
end

post '/qte/:id/delete' do
  Quote.get(params[:id]).voters.destroy
  Quote.get(params[:id]).destroy
  flash[:success] = "quote removed"
  redirect '/'
end

post '/login' do
  if(validate(params["username"], params["password"]))
    session["logged_in"] = true
    session["username"] = params["username"]
    flash[:success] = "You've logged in as #{params["username"]}"
    redirect '/'
  else
    flash[:error] = "Wrong username or password!"
    haml :login
  end
end

get '/logout' do
  clear_session
  flash[:success] = "You have now logged out."
  redirect '/'
end
