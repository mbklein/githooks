class GitHooks < Sinatra::Base
  set :root, File.expand_path("../..", __FILE__)

  post '/avalon-installer' do
    payload = JSON.parse(params[:payload])
    if payload['ref'] == 'refs/heads/master'
      repo = payload['repository']
      head = payload['head_commit']
      cmds = [
        "cd #{settings.root}/tmp",
        %{ssh-agent bash -c 'ssh-add $HOME/.ssh/id_github ; git clone --depth 1 git@github.com:#{repo['owner']['name']}/#{repo['name']} #{repo['name']}.#{$$}'},
        "cd #{repo['name']}.#{$$}",
        "git checkout #{repo['id']}",
        "#{settings.root}/bin/git-shallow-submodule",
        %{#{settings.root}/bin/git-flatten -m "#{head['message']}" flat},
        %{ssh-agent bash -c 'ssh-add $HOME/.ssh/id_github ; git push -f origin flat:flat'},
        "cd ..",
        "rm -rf #{repo['name']}.#{$$}"
      ]
      cmd = cmds.join(' && ')
      Kernel.exec(cmd)
    end
    "OK"
  end
end