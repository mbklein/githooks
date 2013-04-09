require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'app/githooks'

run GitHooks.new