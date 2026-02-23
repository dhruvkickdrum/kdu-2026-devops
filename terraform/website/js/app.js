var API_ENDPOINT = "https://e8qcjwksga.execute-api.us-west-2.amazonaws.com/prod/messages";

function timeAgo(isoString) {
  const diff = (Date.now() - new Date(isoString).getTime()) / 1000;
  if (diff < 60)  return "Just now";
  if (diff < 3600) return Math.floor(diff / 60) + " min ago";
  if (diff < 86400) return Math.floor(diff / 3600) + " hr ago";
  return new Date(isoString).toLocaleDateString();
}

function setStatus(msg, type) {
  const el = document.getElementById("submit-status");
  el.textContent = msg;
  el.className = "status-msg " + type;
}

async function loadMessages() {
  const list = document.getElementById("messages-list");
  list.innerHTML = '<p class="loading">Loading...</p>';
  try {
    const res  = await fetch(API_ENDPOINT, { method: "GET" });
    const data = await res.json();

    if (!data.success || data.messages.length === 0) {
      list.innerHTML = '<p class="empty">No messages yet. Be the first!</p>';
      return;
    }

    list.innerHTML = data.messages.map(function(m) {
      return '<div class="message-item">' +
        '<p class="message-text">' + escapeHtml(m.message) + '</p>' +
        '<p class="message-meta">' +
          '<span class="message-author">' + escapeHtml(m.author || "Anonymous") + '</span>' +
          ' &nbsp;·&nbsp; ' + timeAgo(m.timestamp) +
        '</p>' +
        '</div>';
    }).join("");

  } catch (err) {
    list.innerHTML = '<p class="empty">Failed to load messages. Try refreshing.</p>';
    console.error(err);
  }
}

async function submitMessage() {
  var messageInput = document.getElementById("message-input");
  var authorInput  = document.getElementById("author-input");
  var btn          = document.getElementById("submit-btn");

  var message = messageInput.value.trim();
  var author  = authorInput.value.trim() || "Anonymous";

  if (!message) { setStatus("Please enter a message.", "error"); return; }

  btn.disabled = true;
  setStatus("Sending...", "");

  try {
    var res = await fetch(API_ENDPOINT, {
      method : "POST",
      headers: { "Content-Type": "application/json" },
      body   : JSON.stringify({ message: message, author: author }),
    });
    var data = await res.json();

    if (data.success) {
      messageInput.value = "";
      authorInput.value  = "";
      document.getElementById("char-count").textContent = "0 / 500";
      setStatus("Message posted!", "success");
      await loadMessages();
    } else {
      setStatus("Error: " + data.error, "error");
    }
  } catch (err) {
    setStatus("Network error. Try again.", "error");
    console.error(err);
  } finally {
    btn.disabled = false;
  }
}

function escapeHtml(text) {
  var div = document.createElement("div");
  div.appendChild(document.createTextNode(text));
  return div.innerHTML;
}

document.getElementById("message-input").addEventListener("input", function () {
  document.getElementById("char-count").textContent = this.value.length + " / 500";
});

loadMessages();