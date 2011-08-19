helpers do

  include Rack::Utils
  alias_method :r, :escape_html

  if !User.exists?("admin")
    User.create(:name => "admin", :password => Digest::SHA1.hexdigest("admin"), :admin => true)
  end

  def validate(username, password)
    @user = User.first(:name => username, :password => Digest::SHA1.hexdigest(password))
    return @user
  end

  def escape_quote(quote)
    @temp = quote
    @temp.gsub!("\r\n", "<br/>")
    return @temp
  end

  def is_admin?
    if !is_logged_in?
      return false
    else
      return User.get(session["username"]).admin
    end
  end
  
  def is_logged_in?
    session["logged_in"] == true
  end
  
  def clear_session
    session.clear
  end
  
  def the_user_name
    if is_logged_in? 
      session["username"] 
    else
      "not logged in"
    end
  end
  
  def is_users_quote?(quote_id)
    return Quote.get(quote_id).posted_by == session["username"]
  end

  def has_voted?(quote_id)
    Quote.get(quote_id).voters.all.each do |voter|
      if voter.voter_name == session["username"]
        return true
      end
    end
    return false 
  end

  def delete_voters(name)
    Voter.all.each do |vote|
      if vote.voter_name == params[:name]
        vote.destroy
      end
     end
  end
end
