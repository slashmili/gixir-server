defmodule GixirServer.Ssh do
  alias GixirServer.SshCommand
  alias GixirServer.User

  @valid_commands ~w{git-upload-pack git-receive-pack git-upload-archive git-lfs-authenticate}
  @commands_to_action %{
    "git-upload-pack" => :clone,
    "git-receive-pack" => :push
  }

  def valid_command?(""), do: false

  def valid_command?(command) do
    exec =
      command
      |> String.trim()
      |> String.split(" ")
      |> Enum.at(0)

    Enum.any?(@valid_commands, fn cmd ->
      exec != "" and cmd =~ ~r{^#{exec}}
    end)
  end

  def parse_command(command) do
    with true <- valid_command?(command),
         %{"command" => cmd, "username" => username, "repository" => repo_name} <-
           match_command(command) do
      {:ok, %SshCommand{command: cmd, username: username, repository: repo_name}}
    else
      _ -> :error
    end
  end

  defp match_command(command) do
    Regex.named_captures(
      ~r{(?<command>[a-z\-]*) '/(?<username>.*)/(?<repository>.*).git'},
      command
    )
  end

  def get_git_command(command, current_user) do
    with {:ok, cmd} <- parse_command(command),
         true <- is_allowed?(cmd, current_user),
         {:ok, repo_full_path} <- find_repo_full_path(cmd.username, cmd.repository) do
      {:ok, "#{cmd.command} #{repo_full_path}"}
    else
      {:error, _} = err -> err
      reason -> {:error, reason}
    end
  end

  @doc """
  Checks if user by given key_id is allowed to access
  to request repo
  """
  def is_allowed?(%SshCommand{} = cmd, %User{} = current_user) do
    with action when not is_nil(action) <- Map.get(@commands_to_action, cmd.command),
         true <-
           User.user_auth_module().is_allowed?(
             current_user,
             action,
             {cmd.username, cmd.repository}
           ) do
      true
    else
      _ -> false
    end
  end

  defp find_repo_full_path(username, repository) do
    conf = Application.get_env(:gixir_server, GixirServer)
    repo_path = "#{conf[:git_home_dir]}/#{username}/#{repository}.git"

    if File.exists?(repo_path) do
      {:ok, "#{conf[:git_home_dir]}/#{username}/#{repository}.git"}
    else
      {:error, :repo_path_not_found}
    end
  end
end
