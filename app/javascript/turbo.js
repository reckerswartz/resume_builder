import * as ActionCable from "@rails/actioncable"
import * as Turbo from "@hotwired/turbo"

const consumer = ActionCable.createConsumer()

class TurboCableStreamSourceElement extends HTMLElement {
  static observedAttributes = ["channel", "signed-stream-name"]

  connectedCallback() {
    Turbo.connectStreamSource(this)
    this.subscription = consumer.subscriptions.create(this.channel, {
      received: this.dispatchMessageEvent.bind(this),
      connected: this.subscriptionConnected.bind(this),
      disconnected: this.subscriptionDisconnected.bind(this)
    })
  }

  disconnectedCallback() {
    Turbo.disconnectStreamSource(this)

    if (this.subscription) this.subscription.unsubscribe()

    this.subscriptionDisconnected()
  }

  attributeChangedCallback() {
    if (this.subscription) {
      this.disconnectedCallback()
      this.connectedCallback()
    }
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data })
    return this.dispatchEvent(event)
  }

  subscriptionConnected() {
    this.setAttribute("connected", "")
  }

  subscriptionDisconnected() {
    this.removeAttribute("connected")
  }

  get channel() {
    const channel = this.getAttribute("channel")
    const signed_stream_name = this.getAttribute("signed-stream-name")

    return { channel, signed_stream_name, ...snakeize({ ...this.dataset }) }
  }
}

if (customElements.get("turbo-cable-stream-source") === undefined) {
  customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement)
}

addEventListener("turbo:before-fetch-request", encodeMethodIntoRequestBody)

function encodeMethodIntoRequestBody(event) {
  if (!(event.target instanceof HTMLFormElement)) return

  const {
    target: form,
    detail: { fetchOptions }
  } = event

  form.addEventListener("turbo:submit-start", ({ detail: { formSubmission: { submitter } } }) => {
    const body = isBodyInit(fetchOptions.body) ? fetchOptions.body : new URLSearchParams()
    const method = determineFetchMethod(submitter, body, form)

    if (!/get/i.test(method)) {
      if (/post/i.test(method)) {
        body.delete("_method")
      } else {
        body.set("_method", method)
      }

      fetchOptions.method = "post"
    }
  }, { once: true })
}

function determineFetchMethod(submitter, body, form) {
  const formMethod = determineFormMethod(submitter)
  const overrideMethod = body.get("_method")
  const method = form.getAttribute("method") || "get"

  if (typeof formMethod === "string") {
    return formMethod
  }

  if (typeof overrideMethod === "string") {
    return overrideMethod
  }

  return method
}

function determineFormMethod(submitter) {
  if (submitter instanceof HTMLButtonElement || submitter instanceof HTMLInputElement) {
    if (submitter.name === "_method") {
      return submitter.value
    }

    if (submitter.hasAttribute("formmethod")) {
      return submitter.formMethod
    }
  }

  return null
}

function isBodyInit(body) {
  return body instanceof FormData || body instanceof URLSearchParams
}

function snakeize(value) {
  if (!value || typeof value !== "object") return value
  if (value instanceof Date || value instanceof RegExp) return value
  if (Array.isArray(value)) return value.map(snakeize)

  return Object.keys(value).reduce((result, key) => {
    const snakeKey = key[0].toLowerCase() + key.slice(1).replace(/([A-Z]+)/g, (_match, letters) => `_${letters.toLowerCase()}`)

    result[snakeKey] = snakeize(value[key])
    return result
  }, {})
}
