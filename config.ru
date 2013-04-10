require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require './app/githooks.rb'

run GitHooks.new