defmodule MindfullWeb.Presence do
  @moduledoc false
  use Phoenix.Presence,
    otp_app: :littlechat,
    pubsub_server: Mindfull.PubSub
end
