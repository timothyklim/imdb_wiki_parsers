#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# ishe.

require "bundler/setup"
Bundler.require

require "eventmachine"
require File.expand_path(File.dirname(__FILE__) + "/imdb.rb")


# TODO: 
module MovieServer
  
  def receive_data command
    IMDB::upload
  end
  
end


EventMachine::run do
  EventMachine::start_server "127.0.0.1", 8081, MovieServer
  puts "Start server at 127.0.0.1 on 8081"
end
