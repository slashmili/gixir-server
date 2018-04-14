defmodule GixirServer.SshSession do
  defstruct public_key: nil, user: nil

  alias __MODULE__

  @type t :: %SshSession{public_key: binary, user: binary}

  @doc """
  Registers the current process with provided attrs
  """
  @spec new(map) :: {:ok, SshSession.t()} | {:error, {:already_registered, pid}}
  def new(attrs \\ %{}) do
    session = struct(SshSession, attrs)

    with {:ok, _} <- Registry.register(SshSession, self(), session) do
      {:ok, session}
    end
  end

  @doc """
  Updates stored data related to current process
  """
  @spec update(t) :: {:ok, SshSession.t()} | {:error, :session_not_found}
  def update(%SshSession{} = attrs) do
    with {new_value, _old_value} <- Registry.update_value(SshSession, self(), fn _ -> attrs end) do
      {:ok, new_value}
    else
      _ -> {:error, :session_not_found}
    end
  end

  @doc """
  Gets session for this pid
  """
  @spec get(pid | nil) :: {:ok, t} | {:error, :session_not_found}
  def get(pid \\ nil) do
    pid = pid || self()

    with [{_, value}] <- Registry.lookup(SshSession, pid) do
      {:ok, value}
    else
      _ -> {:error, :session_not_found}
    end
  end
end
