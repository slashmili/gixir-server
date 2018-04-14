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

```
mkdir -p sys_dir
mkdir -p git_home_dir
```
- Create SSH server keys using:
```
ssh-keygen -N '' -b 1024 -t rsa -f sys_dir/ssh_host_rsa_key
```

- Add `:gixir_server` to application list

- Create your Auth module :

```
defmodule MyApp.UserAuth do
  @behaviour GixirServer.User

  def get_user_by_key(_pub_key) do
    # look up in your db to find the pub_key
    %GixirServer.User{username: "my_user"}
  end

  def is_allowed?(%GixirServer.User{} = _current_user, _action, _repository) do
    #check if currently user can run the action on this repo
    true
  end
end
```

- Configure your ssh server:
```
config :gixir_server, GixirServer,
    system_dir: "sys_dir/",
    port: 2223,
    auth_user: MyApp.UserAuth,
    git_home_dir: "git_home_dir",
    git_bin_dir: "/usr/local/bin/"
```
