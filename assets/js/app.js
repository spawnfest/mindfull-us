// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())


// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket

var users = {}

function addUserConnection(userEmail) {
    if (users[userEmail] === undefined) {
      users[userEmail] = {
        peerConnection: null
      }
    }
  
    return users
  }
  
  function removeUserConnection(userEmail) {
    delete users[userEmail]
  
    return users
  }


function initStream() {
    const stream = navigator.mediaDevices.getUserMedia({audio: true, video: true, width: "1280"})
        .then((stream) => {
              // Stores our stream in the global constant, localStream.
            window.localStream = stream
            // Sets our local video element to stream from the user's webcam (stream).
            document.getElementById("local-video").srcObject = stream
        })
        .catch(err => console.log(err))
}

let Hooks = {}
Hooks.JoinCall = {
  mounted() {
    initStream()
  }
}
Hooks.InitUser = {
  mounted () {
    addUserConnection(this.el.dataset.userEmail)
  },

  destroyed () {
    removeUserConnection(this.el.dataset.userEmail)
  }
}

Hooks.HandleOfferRequest = {
    mounted () {
      console.log("new offer request from", this.el.dataset.fromUserEmail)
      let fromUser = this.el.dataset.fromUserEmail
      createPeerConnection(this, fromUser)
    }
}

Hooks.HandleIceCandidateOffer = {
    mounted () {
      let data = this.el.dataset
      let fromUser = data.fromUserEmail
      let iceCandidate = JSON.parse(data.iceCandidate)
      let peerConnection = users[fromUser].peerConnection
  
      console.log("new ice candidate from", fromUser, iceCandidate)
  
      peerConnection.addIceCandidate(iceCandidate)
    }
  }
  
Hooks.HandleSdpOffer = {
    mounted () {
      let data = this.el.dataset
      let fromUser = data.fromUserEmail
      let sdp = data.sdp
  
      if (sdp != "") {
        console.log("new sdp OFFER from", data.fromUserEmail, data.sdp)
  
        createPeerConnection(this, fromUser, sdp)
      }
    }
  }
  
Hooks.HandleAnswer = {
    mounted () {
      let data = this.el.dataset
      let fromUser = data.fromUserEmail
      let sdp = data.sdp
      let peerConnection = users[fromUser].peerConnection
  
      if (sdp != "") {
        console.log("new sdp ANSWER from", fromUser, sdp)
        peerConnection.setRemoteDescription({type: "answer", sdp: sdp})
      }
    }
  }

// lv       - Our LiveView hook's `this` object.
// fromUser - The user to create the peer connection with.
// offer    - Stores an SDP offer if it was passed to the function.
function createPeerConnection(lv, fromUser, offer) {
    // Creates a variable for our peer connection to reference within
    // this function's scope.
    let newPeerConnection = new RTCPeerConnection({
      iceServers: [
        // We're going to get into STUN servers later, but for now, you
        // may use ours for this portion of development.
        { urls: "stun:littlechat.app:3478" }
      ]
    })
  
    // Add this new peer connection to our `users` object.
    users[fromUser].peerConnection = newPeerConnection;
  
    // Add each local track to the RTCPeerConnection.
    localStream.getTracks().forEach(track => newPeerConnection.addTrack(track, localStream))
  
    // If creating an answer, rather than an initial offer.
    if (offer !== undefined) {
      newPeerConnection.setRemoteDescription({type: "offer", sdp: offer})
      newPeerConnection.createAnswer()
        .then((answer) => {
          newPeerConnection.setLocalDescription(answer)
          console.log("Sending this ANSWER to the requester:", answer)
          lv.pushEvent("new_answer", {toUser: fromUser, description: answer})
        })
        .catch((err) => console.log(err))
    }
  
    newPeerConnection.onicecandidate = async ({candidate}) => {
      // fromUser is the new value for toUser because we're sending this data back
      // to the sender
      lv.pushEvent("new_ice_candidate", {toUser: fromUser, candidate})
    }
  
    // Don't add the `onnegotiationneeded` callback when creating an answer due to
    // a bug in Chrome's implementation of WebRTC.
    if (offer === undefined) {
      newPeerConnection.onnegotiationneeded = async () => {
        try {
          newPeerConnection.createOffer()
            .then((offer) => {
              newPeerConnection.setLocalDescription(offer)
              console.log("Sending this OFFER to the requester:", offer)
              lv.pushEvent("new_sdp_offer", {toUser: fromUser, description: offer})
            })
            .catch((err) => console.log(err))
        }
        catch (error) {
          console.log(error)
        }
      }
    }
  
    // When the data is ready to flow, add it to the correct video.
    newPeerConnection.ontrack = async (event) => {
      console.log("Track received:", event)
      document.getElementById(`video-remote-${fromUser}`).srcObject = event.streams[0]
    }
  
    return newPeerConnection;
}

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

liveSocket.connect()

window.addEventListener("phx:page-loading-start", info => NProgress.start())

window.liveSocket = liveSocket

