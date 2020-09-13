defmodule Mindfull.Organizer.Classroom do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mindfull.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "classrooms" do
    field :title, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(classroom, attrs) do
    classroom
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
