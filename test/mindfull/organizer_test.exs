defmodule Mindfull.OrganizerTest do
  use Mindfull.DataCase

  alias Mindfull.Organizer
  alias Mindfull.Organizer.Classroom
  alias Mindfull.Accounts.User

  describe "classrooms" do
    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    defp create_classroom(attrs) do
      user =
        %User{}
        |> User.registration_changeset(%{email: "test@test", password: "123456789123"})
        |> Repo.insert!()

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

  describe "filtering" do
    setup do
      user1 =
        %User{}
        |> User.registration_changeset(%{email: "test@test", password: "123456789123"})
        |> Repo.insert!()

      user2 =
        %User{}
        |> User.registration_changeset(%{email: "meditation@guru", password: "123456789123"})
        |> Repo.insert!()

      attrs1 = %{title: "First", user_id: user1.id}

      classroom1 =
        %Classroom{}
        |> Classroom.changeset(attrs1)
        |> Repo.insert!()

      attrs2 = %{title: "Second", user_id: user1.id}

      classroom2 =
        %Classroom{}
        |> Classroom.changeset(attrs2)
        |> Repo.insert!()

      attrs3 = %{title: "Second Other", user_id: user2.id}

      classroom3 =
        %Classroom{}
        |> Classroom.changeset(attrs3)
        |> Repo.insert!()

      {:ok, user1: user1, user2: user2, classrooms: [classroom1, classroom2, classroom3]}
    end

    test "filter by unique title", %{classrooms: [c1, _, _]} do
      classrooms = Organizer.list_classrooms()
      filtered_classrooms = Organizer.filter_classrooms(classrooms, "Firs")

      assert [classroom] = filtered_classrooms
      assert classroom.title == c1.title
      assert classroom.id == c1.id
      assert classroom.user_id == c1.user_id
    end

    test "filter by organizer email", %{classrooms: [c1, _, _]} do
      classrooms = Organizer.list_classrooms()
      filtered_classrooms = Organizer.filter_classrooms(classrooms, "test@te")

      assert [class1, class2] = filtered_classrooms
      assert class1.user_id == c1.user_id
      assert class2.user_id == c1.user_id
    end

    test "filter by not unique title", %{classrooms: [_, c2, c3]} do
      classrooms = Organizer.list_classrooms()
      filtered_classrooms = Organizer.filter_classrooms(classrooms, "Seco")

      assert [class2, class3] = filtered_classrooms
      assert class2.id == c2.id
      assert class2.title == c2.title
      assert class2.user_id == c2.user_id
      assert class3.id == c3.id
      assert class3.title == c3.title
      assert class3.user_id == c3.user_id
    end
  end
end
