# githooks #

This is a collection of [post-receive service hooks](https://help.github.com/articles/post-receive-hooks) to be used in conjunction with [github](http://www.github.com/). It is written in [Sinatra](http://sinatrarb.com).

## Hooks ##

### `/flatten[?source=master&target=flat]` – Flatten Submodules

Creates or replaces a new branch in which all submodules are absorbed into the main repo. This is useful if you want to have a deployment/distribution branch that can be downloaded as a zip/tarball via [nodeload](https://github.com/blog/678-meet-nodeload-the-new-download-server). Since nodeload doesn't include submodules when it archives, having a full, flattened copy of the source is the only way to accomplish this. Using this post-receive hook will ensure that the target branch (default: `flat`) will always be one commit ahead of source (default: `master`).

In order to push the flat branch back to github, the hook requires a valid SSH public key with access to the repo in `config/id_github`, which should be chmod 0600. See [Generating Public Keys](https://help.github.com/articles/generating-ssh-keys) for more information.