defmodule Mindfull.Repo do
  use Ecto.Repo,
    otp_app: :mindfull,
    adapter: Ecto.Adapters.Postgres
end
