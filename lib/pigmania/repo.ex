defmodule Pigmania.Repo do
  use Ecto.Repo,
    otp_app: :pigmania,
    adapter: Ecto.Adapters.Postgres
end
