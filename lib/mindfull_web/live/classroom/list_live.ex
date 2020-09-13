defmodule MindfullWeb.Classroom.ListLive do
  @moduledoc false
  use MindfullWeb, :live_view

  alias Mindfull.Organizer

  @impl true
  def render(assigns) do
    ~L"""
      <div class="min-h-screen bg-gray-300">
          <div class="container max-w-screen-lg p-10 mx-auto">
          <div class="relative flex items-center justify-between w-full h-10 pl-3 pr-2 mb-5 bg-white border rounded">
            <form phx-change="search" class="w-full" onsubmit="return false">
              <%= text_input :search_field, :query, placeholder: "Search for Classroom", autofocus: true, "phx-debounce": "300", class: "w-full outline-none appearance-none focus:outline-none active:outline-none" %>
            </form>
            <span class="ml-1 outline-none focus:outline-none active:outline-none">
                <svg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    viewBox="0 0 24 24" class="w-6 h-6">
                  <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
            </span>
            </div>
              <div class="p-8 bg-white rounded shadow">
                  <div>
                      <h3 class="mt-4 text-xl font-bold">Classroom List</h3>
                      <!--     BOX     -->
                      <%= for classroom <- @classrooms do %>
                      <div class="flex flex-wrap items-center justify-between w-full p-4 mt-5 border rounded">
                          <div class="w-2/3">
                              <h3 class="text-lg font-large"><%= classroom.title %></h3>
                              <p class="text-xs text-gray-600">Hosted by <b><%= classroom.user.email %></b></p>
                          </div>
                          <div>
                              <button class="text-teal-600 text-md font-small" phx-click=<%= classroom.id %> >Join Classroom</button>
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

    {:ok,
     socket
     |> assign(:classrooms, classrooms)
     |> assign(:cached_classrooms, classrooms)}
  end

  @impl true
  def handle_event("search", %{"search_field" => %{"query" => query}}, socket) do
    filtered_classrooms = Organizer.filter_classrooms(socket.assigns.cached_classrooms, query)
    {:noreply, assign(socket, :classrooms, filtered_classrooms)}
  end

  @impl true
  def handle_event("clear-search", _params, socket) do
    classrooms = Organizer.list_classrooms()

    {:noreply,
     socket
     |> assign(:classrooms, classrooms)
     |> assign(:cached_classrooms, classrooms)}
  end

  @impl true
  def handle_event(classroom_id, _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.show_path(socket, :show, classroom_id))}
  end
end
