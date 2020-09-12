defmodule MindfullWeb.Classroom.ShowLive do
  use MindfullWeb, :live_view

  alias Mindfull.Organizer

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @classroom.title %></h1>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Organizer.get_classroom(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "That classroom does not exist.")
         |> push_redirect(to: Routes.new_path(socket, :new))}

      classroom ->
        {:ok,
         socket
         |> assign(:classroom, classroom)}
    end
  end
end
