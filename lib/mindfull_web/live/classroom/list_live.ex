defmodule MindfullWeb.Classroom.ListLive do
  use MindfullWeb, :live_view

  alias Mindfull.Organizer

  @impl true
  def render(assigns) do
    ~L"""
    <form phx-change="search" class="search-form">
  <%= text_input :search_field, :query, placeholder: "Search for Classroom", autofocus: true, "phx-debounce": "300" %>
</form>

<div class="min-h-screen bg-gray-300">
    <div class="container mx-auto p-10 max-w-screen-lg">
        <div class="bg-white rounded shadow p-8">
            <div>
                <h3 class="text-xl mt-4 font-bold">Classroom List</h3>
                <!--     BOX     -->
    <%= for classroom <- @classrooms do %>
                <div class="border w-full rounded mt-5 flex p-4 justify-between items-center flex-wrap">
                    <div class="w-2/3">
                        <h3 class="text-lg font-large"><%= classroom.title %></h3>
                        <p class="text-gray-600 text-xs">Hosted by <b>Meditation Guru</b></p>
                    </div>
                    <div>
                        <button class="text-3xl font-medium" phx-click=<% classroom.id %> >Join Classroom</h4>
                   </div>
                </div>
      <% end %>
            </div>
        </div>
    </div>
</div>

 
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
