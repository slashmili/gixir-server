defmodule GixirServer.User do
  defstruct username: nil, key_id: nil
  @type username :: binary
  @type key_id :: binary | integer
  @type t :: %__MODULE__{username: username, key_id: key_id}
  @type action :: :clone | :push
  @type repository_owner_name :: binary
  @type repository_name :: binary
  @type repository_tuple :: {repository_owner_name, repository_name}
  @callback get_user_by_key(binary) :: nil | t
  @callback is_allowed?(t, action, repository_tuple) :: boolean

  require Logger

  @spec get_user_by_key(binary) :: boolean
  def get_user_by_key(_) do
    Logger.error(
      "You haven't configure :auth_user setttings, please check the docs. Until then all of ssh authentications will fail!"
    )

    nil
  end

  def is_allowed?(_, _, _) do
    Logger.error(
      "You haven't configure :auth_user setttings, please check the docs. Until then all of ssh authentications will fail!"
    )

    false
  end

  def user_auth_module do
    Application.get_env(:gixir_server, GixirServer)[:auth_user] || __MODULE__
  end
end
