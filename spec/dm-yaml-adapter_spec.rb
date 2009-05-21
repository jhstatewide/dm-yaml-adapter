require 'rubygems'
require 'dm-core'
require 'dm-yaml-adapter'
require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::Adapters::YamlAdapter do
  before(:all) do
	  @adapter = DataMapper.setup(:default, {:adapter => 'yaml', :directory => 'db'})
	  User.auto_migrate!
          @user1 = User.create(:name => 'tom')
          @user2 = User.create(:name => 'jim')
  end

  describe "CRUD" do
  
     describe "create" do
        it "should create" do
           @user1.user_id.should_not == nil
        end 
     end
     
     describe "read" do
	     it "should read all" do
		     begin
			     users = User.all
	     	     rescue Exception => e
			     puts e
			     puts e.backtrace
		     end
		     users.size.should_not == 0
	     end
     end
     
     describe "delete" do 
	     it "should delete someone" do
		     user = User.create
		     user.destroy.should == true
     	     end     
     end
 
     describe "find not" do
             it "should find someone with a not clause" do
                     users = User.all(:user_id.not => @user1.id) 
                     users.first.user_id.should_not == @user1.id 
             end
     end
 
  end
  

end

