defmodule MindfullWeb.Classroom.ListLive do
  use MindfullWeb, :live_view

  alias Mindfull.Organizer

  @impl true
  def render(assigns) do
    ~L"""
    <form phx-change="search" class="search-form">
  <%= text_input :search_field, :query, placeholder: "Search for Classroom", autofocus: true, "phx-debounce": "300" %>
</form>
    <h1>List of classrooms</h1>
    <%= for classroom <- @classrooms do %>
      <h3><%= classroom.title %></h3>
      <button class="button" phx-click=<%= classroom.id %> >Join Classroom</button>
    <% end %>
"""
  end

  @impl true
  def mount(_params, _session, socket) do
    classrooms = Organizer.list_classrooms()

    {:ok, socket
    |> assign(:classrooms, classrooms)
    }
  end

  @impl true
  def handle_event("search", %{"search_field" => %{"query" => query}}, socket) do
    filtered_classrooms = Organizer.filter_classrooms(socket.assigns.classrooms, query)
    {:noreply, assign(socket, :classrooms, filtered_classrooms)}  
  end

  @impl true
  def handle_event(classroom_id, _params, socket) do
        {:noreply, push_redirect(socket, to: Routes.show_path(socket, :show, classroom_id))}
  end
end
