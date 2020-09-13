defmodule Mindfull.Repo.Migrations.ClassroomBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:classrooms) do
      add :user_id, references(:users)
    end
  end
end
