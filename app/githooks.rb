class GitHooks < Sinatra::Base
  set :root, File.expand_path("../..", __FILE__)

  post '/avalon-installer' do
    payload = JSON.parse(params[:payload])
    if payload['ref'] == 'refs/heads/master'
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
    end
    "OK"
  end
end