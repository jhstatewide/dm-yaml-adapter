require 'rubygems'
require 'dm-core'
require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-yaml-adapter'

class Post
  include DataMapper::Resource
 
  property :post_id, Serial
  property :title, String
  
  belongs_to :user
end
 
class User
  include DataMapper::Resource
  
  property :user_id, Serial
  property :name, String
  property :age, Integer
  
  has n, :posts
end
