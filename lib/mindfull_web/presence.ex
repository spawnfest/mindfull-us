defmodule MindfullWeb.Presence do
  use Phoenix.Presence,
    otp_app: :littlechat,
    pubsub_server: Mindfull.PubSub
end
