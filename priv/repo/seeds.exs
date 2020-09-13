# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mindfull.Repo.insert!(%Mindfull.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Mindfull.Accounts.User
alias Mindfull.Organizer.Classroom
alias Mindfull.Repo

Repo.delete_all(Classroom)
Repo.delete_all(User)

user1 =
  %User{}
  |> User.registration_changeset(%{email: "meditation@guru", password: "MeditationIsFun"})
  |> Repo.insert!()

user2 =
  %User{}
  |> User.registration_changeset(%{email: "yoga@instructor", password: "YogaIsForEveryone"})
  |> Repo.insert!()

classroom1 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Meditation 101", user_id: user1.id})
  |> Repo.insert!()

classroom2 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Meditation For Programmers", user_id: user1.id})
  |> Repo.insert!()

classroom3 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Expert Meditation For Demanding", user_id: user1.id})
  |> Repo.insert!()

classroom4 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Yoga 101", user_id: user2.id})
  |> Repo.insert!()

classroom5 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Yoga For Programmers", user_id: user2.id})
  |> Repo.insert!()

classroom6 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Stretching 101", user_id: user2.id})
  |> Repo.insert!()

classroom7 =
  %Classroom{}
  |> Classroom.changeset(%{title: "Advanced Movements", user_id: user2.id})
  |> Repo.insert!()
