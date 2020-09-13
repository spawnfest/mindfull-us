defmodule MindfullWeb.Stun do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  @doc """
  Inits STUN server at port 3678
  """
  def init(_) do
    :stun_listener.add_listener(3678, :udp, [])

    {:ok, []}
  end
end
