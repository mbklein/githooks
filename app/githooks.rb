require 'fileutils'
require 'securerandom'
require 'yaml'

class GitHooks < Sinatra::Base
  set :root, File.expand_path("../..", __FILE__)
  set :logging, true

  helpers do
    def ex cmd
      logger.info  ">> #{cmd}"
      resp = %x[#{cmd}]
      resp.split(/\n/).each { |line| logger.debug "<< #{line}" }
    end
  end

  post '/avalon-installer' do
    payload = params[:payload]
    if payload.is_a?(String)
      payload = JSON.parse(payload)
    end
    $stderr.puts payload.inspect

    if payload['ref'] == 'refs/heads/master'
      repo = payload['repository']
      head = payload['head_commit']
      Dir.chdir(File.join(settings.root, 'tmp')) do
        repo_dir = SecureRandom.hex
        ex %{ssh-agent bash -c 'ssh-add $HOME/.ssh/id_github ; git clone --depth 1 git@github.com:#{repo['owner']['name']}/#{repo['name']} #{repo_dir}'}
        ex "git checkout #{repo['id']}"
        Dir.chdir(repo_dir) do
          ex %{#{settings.root}/bin/git-shallow-submodule}
          ex %{#{settings.root}/bin/git-flatten -m "#{head['message']}" flat}
          ex %{ssh-agent bash -c 'ssh-add $HOME/.ssh/id_github ; git push -f origin flat:flat'}
        end
        FileUtils.rm_rf repo_dir
      end
    end
    "OK"
  end
end