# FitOrder localhost MCP demo

A dependency-free, stateful Node server for the FitOrder 2.0 recording. It uses
seeded commerce data, stores state only in memory, and cannot place real orders.

## Run

Requires Node.js 20 or newer.

```sh
cd demo-server
npm start
```

The default base URL is `http://127.0.0.1:8787`:

- Food MCP: `POST /food`
- Instamart MCP: `POST /im`
- Reset the current session: `POST /demo/reset`
- Select a scenario: `POST /demo/scenario`

Send the response `Mcp-Session-Id` header on subsequent calls. Control calls
with that header affect one session; omitting it resets or selects the default
scenario for all in-memory demo sessions, matching the app's recording reset.
Supported scenarios are `goldenPath`, `serverUnavailable`, `cartChanged`, and
`ambiguousCheckout`.

Tool results expose the same payload in `result.structuredContent` and as JSON
in `result.content[0].text`. Checkout requires `confirmed: true` and an
authoritative cart read immediately beforehand.

## Test

```sh
cd demo-server
npm test
```

The contract test starts an isolated zero-latency server. To test an already
running instance instead:

```sh
DEMO_SERVER_URL=http://127.0.0.1:8787 npm test
```

Normal server calls use stable 180–500 ms latency. Set
`DEMO_LATENCY_SCALE=0` only for local automated tests.
