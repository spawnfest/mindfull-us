defmodule MindfullWeb.Classroom.NewLive do
  @moduledoc false
  use MindfullWeb, :live_view

  alias Mindfull.Accounts
  alias Mindfull.Organizer
  alias Mindfull.Organizer.Classroom

  @impl true
  def render(assigns) do
    ~L"""
    <div class="min-h-screen bg-gray-300">
        <%= form_for @changeset, "#", [phx_change: "validate", phx_submit: "save", class: "container mx-auto p-10 max-w-screen-lg"], fn f -> %>
          <%= hidden_input f, :user_id %>
          <%= text_input f, :title, class: "h-16 border-solid border w-full rounded px-3 py-2", placeholder: "Name of your class" %>
          <%= submit "Save", class: "w-full mt-5 bg-teal-500 text-white px-6 md:px-8 py-3 md:py-4 text-md md:text-md text-secondary font-bold uppercase rounded hover:bg-primary-400" %>
          <%= error_tag f, :title %>
        <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    user_token = session["user_token"]
    user = user_token && Accounts.get_user_by_session_token(user_token)
    {:ok, put_changeset(socket, %{user_id: user.id})}
  end

  @impl true
  def handle_event("validate", %{"classroom" => room_params}, socket) do
    {:noreply, put_changeset(socket, room_params)}
  end

  def handle_event("save", _, %{assigns: %{changeset: changeset}} = socket) do
    case Organizer.create_classroom(changeset) do
      {:ok, classroom} ->
        {:noreply, push_redirect(socket, to: Routes.show_path(socket, :show, classroom.id))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Could not save the room.")}
    end
  end

  defp put_changeset(socket, params) do
    assign(socket, :changeset, Classroom.changeset(%Classroom{}, params))
  end
end
