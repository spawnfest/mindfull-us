defmodule Mindfull.Organizer.Classroom do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Mindfull.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "classrooms" do
    field :title, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(classroom, attrs) do
    classroom
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
