require 'fileutils'
require 'securerandom'
require 'yaml'

class GitHooks < Sinatra::Base
  configure do
    set :root, File.expand_path("../..", __FILE__)
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  before do
    logger.level = 0
  end

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
    payload = params[:payload]
    if payload.is_a?(String)
      payload = JSON.parse(payload)
    end
    if payload['ref'] !~ /\/flat$/
      source = params[:source] || payload['ref'].split(/\//).last
      target = params[:target] || "#{source}/flat"

      repo = payload['repository']
      head = payload['head_commit']
      Dir.chdir(File.join(settings.root, 'tmp')) do
        repo_dir = SecureRandom.hex
        ex "git clone --depth 1 --recursive git@github.com:#{repo['owner']['name']}/#{repo['name']} #{repo_dir}", true
        Dir.chdir(repo_dir) do
          ex "git checkout #{source}"
          ex "git submodule update"
          ex %{#{settings.root}/bin/git-flatten -f -m "#{head['message']}" #{target}}
          ex "git push -f origin #{target}:#{target}", true
        end
        FileUtils.rm_rf repo_dir
      end
    end
    "OK"
  end
end
