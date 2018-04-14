defmodule GixirServer.SshSessionTest do
  use ExUnit.Case
  alias GixirServer.SshSession
  doctest SshSession

  test "creates only one session for current PID with same data" do
    assert {:ok, %SshSession{public_key: "my_public", user: "user"}} ==
             SshSession.new(%{public_key: "my_public", user: "user"})

    assert {:error, {:already_registered, _}} =
             SshSession.new(%{public_key: "my_public", user: "user"})
  end

  test "should be able to create two sessions with same data for two PIDs" do
    test_pid = self()

    spawn_link(fn ->
      {:ok, _} = SshSession.new(%{public_key: "my_public", user: "user"})
      send(test_pid, :session_created)
    end)

    assert {:ok, _} = SshSession.new(%{public_key: "my_public", user: "user"})
    assert_receive :session_created
  end

  test "updates a session for current PID" do
    assert {:ok, session} = SshSession.new(%{public_key: nil, user: "user"})

    assert SshSession.update(%{session | public_key: "pp"}) ==
             {:ok, %GixirServer.SshSession{public_key: "pp", user: "user"}}
  end

  test "should fail when session is not initilized for this PID" do
    assert {:error, :session_not_found} = SshSession.update(%SshSession{public_key: "pp"})
  end

  test "gets a session" do
    assert {:ok, session} = SshSession.new(%{public_key: "public_key", user: "user"})

    assert {:ok, ^session} = SshSession.get()
  end

  test "should fail if there is no session set" do
    assert {:error, :session_not_found} = SshSession.get()
  end
end
