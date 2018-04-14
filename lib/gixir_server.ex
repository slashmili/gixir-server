defmodule GixirServer do
  @moduledoc """
  SSh Server that handles users authoriztion and git commands on the server
  """
  defstruct ssh_pid: nil

  use GenServer
  require Logger

  alias __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    send(self(), :start_ssh)
    {:ok, %__MODULE__{}}
  end

  def handle_info(:start_ssh, state) do
    ssh_server_opts = Application.get_env(:gixir_server, __MODULE__)
    priv_dir = String.to_charlist(ssh_server_opts[:system_dir])
    port = ssh_server_opts[:port] || 0

    {:ok, ssh_pid} =
      :ssh.daemon(
        port,
        system_dir: priv_dir,
        user_dir: priv_dir,
        key_cb: GixirServer.SshKeyAuthentication,
        auth_methods: 'publickey',
        shell: &on_shell/2,
        ssh_cli: {GixirServer.GitCli, []}
      )

    {:noreply, %{state | ssh_pid: ssh_pid}}
  end

  def on_shell(username, peer_address) do
    Logger.debug(
      "new user connected with username #{username} and address #{inspect(peer_address)}"
    )

    spawn_link(fn ->
      IO.puts(
        "Hi #{username}! You've successfully authenticated, but GixirServer does not provide shell access."
      )
    end)
  end
end
