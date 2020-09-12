defmodule MindfullWeb.Classroom.ShowLive do
  use MindfullWeb, :live_view

  alias Mindfull.Organizer
  alias Mindfull.ConnectedUser

  alias MindfullWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @classroom.title %></h1>
    <h3>Connected Users:</h3>
    <ul>
      <%= for uuid <- @connected_users do %>
        <li><%= uuid %></li>
      <% end %>
    </ul>


    <div class="streams">
      <video id="local-video" playsinline autoplay muted width="600"></video>

     <%= for uuid <- @connected_users do %>
       <video id="video-remote-<%= uuid %>" data-user-uuid="<%= uuid %>" playsinline autoplay phx-hook="InitUser"></video>
     <% end %>
     </div>

    <button class="button" phx-hook="JoinCall" phx-click="join_call">Join Call</button>

    <div id="offer-requests">
      <%= for request <- @offer_requests do %>
      <span phx-hook="HandleOfferRequest" data-from-user-uuid="<%= request.from_user.uuid %>"></span>
      <% end %>
    </div>

    <div id="sdp-offers">
      <%= for sdp_offer <- @sdp_offers do %>
      <span phx-hook="HandleSdpOffer" data-from-user-uuid="<%= sdp_offer["from_user"] %>" data-sdp="<%= sdp_offer["description"]["sdp"] %>"></span>
      <% end %>
    </div>

    <div id="sdp-answers">
      <%= for answer <- @answers do %>
      <span phx-hook="HandleAnswer" data-from-user-uuid="<%= answer["from_user"] %>" data-sdp="<%= answer["description"]["sdp"] %>"></span>
      <% end %>
    </div>

    <div id="ice-candidates">
      <%= for ice_candidate_offer <- @ice_candidate_offers do %>
      <span phx-hook="HandleIceCandidateOffer" data-from-user-uuid="<%= ice_candidate_offer["from_user"] %>" data-ice-candidate="<%= Jason.encode!(ice_candidate_offer["candidate"]) %>"></span>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = create_connected_user()
    Phoenix.PubSub.subscribe(Mindfull.PubSub, "room:" <> id)
    Phoenix.PubSub.subscribe(Mindfull.PubSub, "room:" <> id <> ":" <> user.uuid)

    {:ok, _} = Presence.track(self(), "room:" <> id, user.uuid, %{})
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
         |> assign(:user, user)
         |> assign(:id, id)
         |> assign(:connected_users, [])
         |> assign(:offer_requests, [])
         |> assign(:ice_candidate_offers, [])
         |> assign(:sdp_offers, [])
         |> assign(:answers, [])
        }
    end
  end

  defp create_connected_user do
    %ConnectedUser{uuid: UUID.uuid4()}
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
      |> assign(:offer_requests, socket.assigns.offer_requests ++ [request])
    }
  end

  @impl true
  def handle_info(%Broadcast{event: "new_ice_candidate", payload: payload}, socket) do
    {:noreply,
      socket
      |> assign(:ice_candidate_offers, socket.assigns.ice_candidate_offers ++ [payload])
    }
  end

  @impl true
  def handle_info(%Broadcast{event: "new_answer", payload: payload}, socket) do
    {:noreply,
      socket
      |> assign(:answers, socket.assigns.answers ++ [payload])
    }
  end

  @impl true
  def handle_info(%Broadcast{event: "new_sdp_offer", payload: payload}, socket) do
    {:noreply,
      socket
      |> assign(:sdp_offers, socket.assigns.ice_candidate_offers ++ [payload])
    }
  end

  @impl true
  def handle_event("join_call", _params, socket) do
    for user <- socket.assigns.connected_users do
      send_direct_message(
        socket.assigns.id,
        user,
        "request_offers",
        %{
          from_user: socket.assigns.user
        }
      )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("new_ice_candidate", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.uuid})

    send_direct_message(socket.assigns.id, payload["toUser"], "new_ice_candidate", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_sdp_offer", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.uuid})

    send_direct_message(socket.assigns.id, payload["toUser"], "new_sdp_offer", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_answer", payload, socket) do
    payload = Map.merge(payload, %{"from_user" => socket.assigns.user.uuid})

    send_direct_message(socket.assigns.id, payload["toUser"], "new_answer", payload)
    {:noreply, socket}
  end


  defp list_present(socket) do
     Presence.list("room:" <> socket.assigns.id)
      |> Enum.map(fn {k, _} -> k end)
   end

   defp send_direct_message(id, to_user, event, payload) do
    MindfullWeb.Endpoint.broadcast_from(
      self(),
      "room:" <> id <> ":" <> to_user,
      event,
      payload
    )
  end
end
