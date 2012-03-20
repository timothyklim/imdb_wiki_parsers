# -*- coding: utf-8 -*-
# ishe:

require 'bundler/setup'
Bundler.require

require File.expand_path(File.dirname(__FILE__) + "/database.rb")
require File.expand_path(File.dirname(__FILE__) + "/imdb.rb")


namespace :db do
  
  desc "create tables"
  task :create do
    DefaultMigration.migrate :up
  end
  
  
  desc "drop tables"
  task :drop do
    DefaultMigration.migrate :down
  end
  
end


namespace :imdb do
  
  desc "manual uploading from imdb"
  task :upload do
    IMDB::upload
  end
  
end  


# TODO:
namespace :server do
  
  desc "ping eventmachine-server for uploading"
  task :upload do
    exec "telnet 127.0.0.1 8081"
  end
  
end
