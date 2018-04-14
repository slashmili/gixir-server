defmodule GixirServer.GitCli do
  @moduledoc """
  Implements SSH Channel and provides Git cli to remote connection
  """
  @behaviour :ssh_channel

  alias GixirServer.SshSession
  require Logger

  @doc false
  def init(_) do
    {:ok, %{port: nil, channel_id: nil, want_reply: nil, cm: nil}}
  end

  @doc false
  def handle_msg({p, {:data, data}}, state) when is_port(p) do
    :ssh_connection.send(state.cm, state.channel_id, 0, data)
    {:ok, state}
  end

  def handle_msg({:EXIT, _, _}, state) do
    close_ssh_connection(state, :ok)
    {:ok, state}
  end

  def handle_msg({:ssh_channel_up, channel_id, cm}, state) do
    {:ok, %{state | cm: cm, channel_id: channel_id}}
  end

  def handle_msg(args, state) do
    Logger.debug("GixirServer.GitCli.handle_msg: unmatched: #{inspect(args)}")
    {:ok, state}
  end

  @doc false
  def handle_ssh_msg({:ssh_cm, cm, {:exec, channel_id, want_reply, cmd}}, state) do
    port =
      with {:ok, session} <- SshSession.get(cm),
           {:ok, command} <- GixirServer.Ssh.get_git_command(to_string(cmd), session.user) do
        conf = Application.get_env(:gixir_server, GixirServer)
        git_dir = conf[:git_bin_dir] || "/usr/local/bin/"
        [command, arg01] = String.split(command)
        opts = [:binary, :exit_status, {:args, [arg01]}]
        git_cmd = "#{git_dir}#{command}"
        Port.open({:spawn_executable, git_cmd}, opts)
      else
        oth ->
          :ssh_connection.send(cm, channel_id, 0, "Invalid command: '#{cmd}'\n")
          Logger.debug("Failed to exec #{inspect(cmd)} on git server, error: #{inspect(oth)}")
          close_ssh_connection(state, :invalid_command)
      end

    {:ok, %{state | want_reply: want_reply, port: port}}
  end

  def handle_ssh_msg({:ssh_cm, _cm, {:data, _channel_id, _data_type, data}}, state) do
    send(state.port, {self(), {:command, data}})
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, _cm, {:eof, _channel_id}}, state) do
    if Port.info(state.port) == nil do
      close_ssh_connection(state, :ok)
    end

    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, _cm, {:shell, _channel_id, _}}, state) do
    close_ssh_connection(state, :no_shell)
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, cm, {:pty, channel_id, _, _}}, state) do
    username =
      case SshSession.get(cm) do
        {:ok, session} -> session.user.username
        _ -> ""
      end

    message =
      "Hi #{username}! You've successfully authenticated, but GitWerk does not provide shell access.\r\n"

    :ssh_connection.send(cm, channel_id, 1, message)
    {:ok, state}
  end

  def handle_ssh_msg(args, state) do
    Logger.debug("GixirServer.GitCli.handle_msg.handle_ssh_msg: unmatched: #{inspect(args)}")
    {:ok, state}
  end

  defp close_ssh_connection(state, status) do
    if status == :ok do
      :ssh_connection.exit_status(state.cm, state.channel_id, 0)
    else
      :ssh_connection.exit_status(state.cm, state.channel_id, 1)
    end

    :ssh_connection.close(state.cm, state.channel_id)
  end

  def terminate(_reason, _state) do
    :ok
  end

  @doc false
  def handle_cast(args, state) do
    Logger.debug("GixirServer.GitCli.handle_cast: unmatched: #{inspect(args)}")
    {:noreply, state}
  end

  @doc false
  def handle_call(args, _, state) do
    Logger.debug("GixirServer.GitCli.handle_call: unmatched: #{inspect(args)}")
    {:reply, :ok, state}
  end

  @doc false
  def code_change(args, _, state) do
    Logger.debug("GixirServer.GitCli.code_change: unmatched: #{inspect(args)}")
    {:reply, :ok, state}
  end
end
