defmodule MindfullWeb.Classroom.NewLive do
  use MindfullWeb, :live_view

  alias Mindfull.Organizer
  alias Mindfull.Organizer.Classroom

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Create a New Classroom</h1>
    <div>
      <%= form_for @changeset, "#", [phx_change: "validate", phx_submit: "save"], fn f -> %>
        <%= text_input f, :title, placeholder: "Title" %>
        <%= error_tag f, :title %>
        <%= submit "Save" %>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, put_changeset(socket)}
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

  defp put_changeset(socket, params \\ %{}) do
    assign(socket, :changeset, Classroom.changeset(%Classroom{}, params))
  end
end
