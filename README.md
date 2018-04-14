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

- Create SSH server keys using :
```
mkdir -p sys_dir
ssh-keygen -N '' -b 1024 -t rsa -f sys_dir/ssh_host_rsa_key
```

- Add `:gixir_server` to application list

- Create your Auth module :
```
def
```
- Configure your ssh server:
```
config :gixir_server, GixirServer,
    system_dir: "sys_dir/",
    port: 2223,
    auth_user: MyApp.UserAuth
```
