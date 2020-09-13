defmodule MindfullWeb.Classroom.ShowLive do
  @moduledoc false
  use MindfullWeb, :live_view

  alias Mindfull.Accounts
  alias Mindfull.Organizer

  alias MindfullWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <p class="pt-5">
    <div class="flex">
    <div class="w-3/4 text-center">
    <h1 class="text-teal-400 text-5xl font-bold text-center"><%= @classroom.title %></h1>
    </div>
    <div class="w-1/4 text-center">
    <button class="mt-5 bg-teal-500 hover:bg-teal-700 text-white font-bold py-2 px-4" phx-hook="JoinCall" phx-click="join_call">Join Call</button>
    </div>
    </div>
    </p>

    <div class="streams pt-5">
      <div class="flex mb-4"> 
    <div class="w-3/4">
    <div class="pr-1">
    <video id="local-video" class="border-solid border-4" playsinline autoplay muted width="100%"></video>
    </div>
    </div>
    <div class="w-1/4">
    <%= for email <- Enum.filter(@connected_users, fn connected_user -> connected_user != @user.email end) do %>
       <video id="video-remote-<%= email %>" class="border-solid border-4" data-user-email="<%= email %>" playsinline autoplay phx-hook="InitUser"></video>
     <% end %>
    </div>
      </div>
     </div>

    <div class="hidden">
    <div id="offer-requests">
      <%= for request <- @offer_requests do %>
      <span phx-hook="HandleOfferRequest" data-from-user-email="<%= request.from_user %>"></span>
      <% end %>
    </div>

    <div id="sdp-offers">
      <%= for sdp_offer <- @sdp_offers do %>
      <span phx-hook="HandleSdpOffer" data-from-user-email="<%= sdp_offer["from_user"] %>" data-sdp="<%= sdp_offer["description"]["sdp"] %>"></span>
      <% end %>
    </div>

    <div id="sdp-answers">
      <%= for answer <- @answers do %>
      <span phx-hook="HandleAnswer" data-from-user-email="<%= answer["from_user"] %>" data-sdp="<%= answer["description"]["sdp"] %>"></span>
      <% end %>
    </div>

    <div id="ice-candidates">
      <%= for ice_candidate_offer <- @ice_candidate_offers do %>
      <span phx-hook="HandleIceCandidateOffer" data-from-user-email="<%= ice_candidate_offer["from_user"] %>" data-ice-candidate="<%= Jason.encode!(ice_candidate_offer["candidate"]) %>"></span>
      <% end %>
    </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, session, socket) do
    user_token = session["user_token"]
    user = user_token && Accounts.get_user_by_session_token(user_token)
    Phoenix.PubSub.subscribe(Mindfull.PubSub, "classroom:" <> id)
    Phoenix.PubSub.subscribe(Mindfull.PubSub, "classroom:" <> id <> ":" <> user.email)

    {:ok, _} = Presence.track(self(), "classroom:" <> id, user.email, %{})

    case Organizer.get_classroom(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "That classroom does not exist.")
         |> push_redirect(to: Routes.new_path(socket, :new))}

      classroom ->
        {:ok,
         socket
         |> assign(:classroom, classroom)
         |> assign(:organizer, classroom.user)
         |> assign(:user, user)
         |> assign(:id, id)
         |> assign(:connected_users, [])
         |> assign(:offer_requests, [])
         |> assign(:ice_candidate_offers, [])
         |> assign(:sdp_offers, [])
         |> assign(:answers, [])}
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply,
     socket
     |> assign(:connected_users, list_present(socket))}
  end

  @impl true
  @doc """
  When an offer request has been received, add it to the `@offer_requests` list.
  """
  def handle_info(%Broadcast{event: "request_offers", payload: request}, socket) do
    {:noreply,
     socket
     |> assign(:offer_requests, socket.assigns.offer_requests ++ [request])}
  end

  @impl true
  def handle_info(%Broadcast{event: "new_ice_candidate", payload: payload}, socket) do
    {:noreply,
     socket
     |> assign(:ice_candidate_offers, socket.assigns.ice_candidate_offers ++ [payload])}
  end

  @impl true
  def handle_info(%Broadcast{event: "new_answer", payload: payload}, socket) do
    {:noreply,
     socket
     |> assign(:answers, socket.assigns.answers ++ [payload])}
  end

  @impl true
  def handle_info(%Broadcast{event: "new_sdp_offer", payload: payload}, socket) do
    {:noreply,
     socket
     |> assign(:sdp_offers, socket.assigns.ice_candidate_offers ++ [payload])}
  end

  @impl true
  def handle_event("join_call", _params, socket) do
    for user <- socket.assigns.connected_users do
      send_direct_message(
        socket.assigns.id,
        user,
        "request_offers",
        %{
          from_user: socket.assigns.user.email
        }
      )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("new_ice_candidate", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.email})

    send_direct_message(socket.assigns.id, payload["toUser"], "new_ice_candidate", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_sdp_offer", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.email})

    send_direct_message(socket.assigns.id, payload["toUser"], "new_sdp_offer", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_answer", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.email})

    send_direct_message(socket.assigns.id, payload["toUser"], "new_answer", payload)
    {:noreply, socket}
  end

  defp list_present(socket) do
    Presence.list("classroom:" <> socket.assigns.id)
    |> Enum.map(fn {k, _} -> k end)
  end

  defp send_direct_message(id, to_user, event, payload) do
    MindfullWeb.Endpoint.broadcast_from(
      self(),
      "classroom:" <> id <> ":" <> to_user,
      event,
      payload
    )
  end
end
