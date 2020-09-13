defmodule Mindfull.OrganizerTest do
  use Mindfull.DataCase

  alias Mindfull.Organizer
  alias Mindfull.Accounts.User

  describe "classrooms" do
    alias Mindfull.Organizer.Classroom

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    defp create_classroom(attrs) do
      user = %User{} |> User.registration_changeset(%{email: "test@test", password: "123456789123"}) |> Repo.insert!
      attrs = Map.put(attrs, :user_id, user.id)
      Classroom.changeset(%Classroom{}, attrs)
    end

    def classroom_fixture(attrs \\ %{}) do
      {:ok, classroom} =
        attrs
        |> Enum.into(@valid_attrs)
        |> create_classroom()
        |> Organizer.create_classroom()

      classroom
    end

    test "list_classrooms/0 returns all classrooms" do
      classroom = classroom_fixture()
      id = classroom.id
      title = classroom.title
      user_id = classroom.user_id
      assert [%Classroom{id: ^id, title: ^title, user_id: ^user_id}] = Organizer.list_classrooms() 
    end

    test "get_classroom!/1 returns the classroom with given id" do
      classroom = classroom_fixture()
      assert Organizer.get_classroom!(classroom.id) == classroom
    end

    test "create_classroom/1 with valid data creates a classroom" do
      assert {:ok, %Classroom{} = classroom} =
               @valid_attrs
               |> create_classroom()
               |> Organizer.create_classroom()

      assert classroom.title == "some title"
    end

    test "create_classroom/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               @invalid_attrs
               |> create_classroom()
               |> Organizer.create_classroom()
    end

    test "update_classroom/2 with valid data updates the classroom" do
      classroom = classroom_fixture()

      assert {:ok, %Classroom{} = classroom} =
               Organizer.update_classroom(classroom, @update_attrs)

      assert classroom.title == "some updated title"
    end

    test "update_classroom/2 with invalid data returns error changeset" do
      classroom = classroom_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizer.update_classroom(classroom, @invalid_attrs)
      assert classroom == Organizer.get_classroom!(classroom.id)
    end

    test "delete_classroom/1 deletes the classroom" do
      classroom = classroom_fixture()
      assert {:ok, %Classroom{}} = Organizer.delete_classroom(classroom)
      assert_raise Ecto.NoResultsError, fn -> Organizer.get_classroom!(classroom.id) end
    end

    test "change_classroom/1 returns a classroom changeset" do
      classroom = classroom_fixture()
      assert %Ecto.Changeset{} = Organizer.change_classroom(classroom)
    end
  end
end
