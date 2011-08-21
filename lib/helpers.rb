
  include Rack::Utils
  

  def validate(username, password)
    @user = User.first(:name => username, :password => Digest::SHA1.hexdigest(password))
    return @user
  end

  def escape_quote(quote)
    @temp = quote
    @temp.chomp!
    @temp.gsub!(/^(\r\n)*/, '') #Tyhjät rivit pois alusta
    @temp.gsub!(/(\r\n)*$/, '') #Sama lopusta
    @temp.gsub!("<", "&lt;")
    @temp.gsub!(">", "&gt;")
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
  
  def is_users_quote?(id)
      return Quote.get(id).posted_by == session["username"]
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


