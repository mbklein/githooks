require 'fileutils'
require 'securerandom'
require 'yaml'

class GitHooks < Sinatra::Base
  set :root, File.expand_path("../..", __FILE__)
  set :logging, true

  helpers do
    def ex cmd, ssh=false
      if ssh
        keyfile = File.join(settings.root,'config','id_github')
        cmd = %{ssh-agent bash -c 'ssh-add #{keyfile} ; #{cmd}'}
      end
      logger.info  ">> #{cmd}"
      resp = %x[#{cmd}]
      resp.split(/\n/).each { |line| logger.debug "<< #{line}" }
    end
  end

  post '/flatten' do
    source = params[:source] || 'master'
    target = params[:target] || 'flat'
    payload = params[:payload]
    if payload.is_a?(String)
      payload = JSON.parse(payload)
    end

    if payload['ref'] == "refs/heads/#{source}"
      repo = payload['repository']
      head = payload['head_commit']
      Dir.chdir(File.join(settings.root, 'tmp')) do
        repo_dir = SecureRandom.hex
        ex "git clone --depth 1 git@github.com:#{repo['owner']['name']}/#{repo['name']} #{repo_dir}", true
        ex "git checkout #{source}"
        Dir.chdir(repo_dir) do
          ex %{#{settings.root}/bin/git-shallow-submodule}
          ex %{#{settings.root}/bin/git-flatten -f -m "#{head['message']}" #{target}}
          ex "git push -f origin #{target}:#{target}", true
        end
        FileUtils.rm_rf repo_dir
      end
    end
    "OK"
  end
end
