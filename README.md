# GixirServer

Gixir is a small and extendable Git server currently only working over SSH using [Erlang :ssh](http://erlang.org/doc/man/ssh.html) as SSH server.

## Installation

The package can be installed
by adding `gixir_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gixir_server, github: "slashmili/gixir-server"}
  ]
end
```

## Docs

- Create required directory:
```bash
mkdir -p sys_dir
mkdir -p git_home_dir/foo
git init --bare git_home_dir/foo/my-app.git
```

- Create SSH server keys using:
```bash
ssh-keygen -N '' -b 1024 -t rsa -f sys_dir/ssh_host_rsa_key
```

- Add `:gixir_server` to application list(if running old format mix)

- Create your Auth module :
```elixir
defmodule MyApp.UserAuth do
  @behaviour GixirServer.User

  def get_user_by_key(_pub_key) do
    # look up in your db to find the pub_key
    %GixirServer.User{username: "my_user"}
  end

  def is_allowed?(%GixirServer.User{} = _current_user, _action, _repository) do
    #check if current user can run the action on this repo
    true
  end
end
```

- Configure your ssh server:
```elixir
config :gixir_server, GixirServer,
    system_dir: "sys_dir/",
    port: 2223,
    auth_user: MyApp.UserAuth,
    git_home_dir: "git_home_dir",
    git_bin_dir: "/usr/local/bin/"
```

- Run your Elixir app:
```elixir
iex -S mix
iex(1)>
```

- Clone your repo:
```bash
$ git clone ssh://git@localhost:2223/foo/my-app.git
$ cd my-app
$ touch README.md
$ git add README.md
$ git commit -m "hello"
[master (root-commit) e1aa6d0] hello
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 README.md
$ git push origin HEAD
Counting objects: 3, done.
Writing objects: 100% (3/3), 212 bytes | 212.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://localhost:2223/foo/my-app.git
 * [new branch]      HEAD -> master
```

# TODO:

- bring tests from [gitwerk](https://github.com/carloslima/gitwerk/tree/master/test/git_werk_guts) ssh section to here
