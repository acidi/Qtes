require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Quote
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :body, Text, :required => true
  property :posted_by, String, :required => true
  property :created_at, DateTime
  property :points, Integer, :default => 0
  property :channel, String

  has n, :voters
end

class User
  include DataMapper::Resource
  property :name, String, :required => true, :key => true
  property :password, String, :required => true
  property :admin, Boolean, :default => false

  def self.exists?(username)
    self.first(:name => username)
  end
    
end

class Voter
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :voter_name, String 
  belongs_to :quote
end

