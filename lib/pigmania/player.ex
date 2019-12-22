defmodule Pigmania.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field(:name, :string)

    timestamps(type: :utc_datetime_usec)
  end

  def allowed_attrs,
    do: __MODULE__.__schema__(:fields) -- [:inserted_at, :updated_at, :id]

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, allowed_attrs())
    |> validate_required([:name])
  end
end
