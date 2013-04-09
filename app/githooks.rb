#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

class GitHooks < Sinatra::App
  set :root, File.expand_path("../..", __FILE__)

  post '/avalon-installer' do
    payload = JSON.parse(params[:payload])
    repo = payload['repository']
    head = payload['head_commit']
    cmds = [
      "cd #{settings.root}/tmp",
      "git clone #{repo['url']} #{repo['name']}.#{$$}",
      "cd #{repo['name']}.#{$$}",
      "git checkout #{repo['id']}",
      "#{settings.root}/bin/git-flatten flat",
      "git push -f origin flat:flat",
      "cd ..",
      "rm -rf #{repo['name']}.#{$$}"
    ]
    cmd = cmds.join(' && ')
    Kernel.exec(cmd)
    "OK"
  end
end