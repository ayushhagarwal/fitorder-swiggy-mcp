import assert from "node:assert/strict";
import { createDemoServer, deterministicLatencyMs, loopbackCorsOrigin } from "./server.mjs";

let ownedServer = null;
let baseURL = process.env.DEMO_SERVER_URL?.replace(/\/$/, "");

if (!baseURL) {
  ownedServer = createDemoServer({ port: 0, latencyScale: 0, corsOrigin: null });
  const address = await ownedServer.start();
  assert.equal(address.address, "127.0.0.1");
  baseURL = `http://${address.address}:${address.port}`;
}

let sessionId = null;
let rpcId = 0;

async function post(route, body, expectedStatus = 200) {
  const response = await fetch(`${baseURL}${route}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(sessionId ? { "Mcp-Session-Id": sessionId } : {}),
    },
    body: JSON.stringify(body),
  });
  const returnedSessionId = response.headers.get("Mcp-Session-Id");
  if (returnedSessionId) sessionId = returnedSessionId;
  assert.notEqual(response.headers.get("access-control-allow-origin"), "*");
  assert.equal(response.headers.get("access-control-allow-origin"), null);
  const payload = await response.json();
  assert.equal(
    response.status,
    expectedStatus,
    `${route} returned ${response.status}: ${JSON.stringify(payload)}`,
  );
  return payload;
}

async function rpc(route, method, params = undefined, expectedStatus = 200) {
  const payload = await post(route, {
    jsonrpc: "2.0",
    id: ++rpcId,
    method,
    ...(params === undefined ? {} : { params }),
  }, expectedStatus);
  if (expectedStatus === 200) {
    assert.equal(payload.jsonrpc, "2.0");
    assert.equal(payload.id, rpcId);
  }
  return payload;
}

async function call(route, name, args = {}) {
  const payload = await rpc(route, "tools/call", { name, arguments: args });
  assert.ok(payload.result, `${name} did not return a JSON-RPC result`);
  assert.deepEqual(
    JSON.parse(payload.result.content[0].text),
    payload.result.structuredContent,
    `${name} text and structured content differ`,
  );
  return payload.result;
}

function successPayload(result, name) {
  assert.equal(result.isError, false, `${name} unexpectedly failed`);
  return result.structuredContent;
}

function errorPayload(result, code) {
  assert.equal(result.isError, true, `Expected tool error ${code}`);
  assert.equal(result.structuredContent.error.code, code);
  return result.structuredContent.error;
}

async function buildGoldenCarts() {
  successPayload(await call("/food", "get_addresses"), "get_addresses");
  successPayload(await call("/food", "search_menu", {
    query: "vegetarian high protein recovery dinner",
  }), "search_menu");
  successPayload(await call("/food", "get_restaurant_menu", {
    restaurant_id: "restaurant-green-grain-demo",
    item_id: "food-paneer-protein-bowl",
  }), "get_restaurant_menu");
  successPayload(await call("/food", "update_food_cart", {
    restaurant_id: "restaurant-green-grain-demo",
    address_id: "address-home-demo",
    items: [
      { item_id: "food-paneer-protein-bowl", quantity: 1 },
      { item_id: "high-protein-curd-side", quantity: 1 },
    ],
  }), "update_food_cart");
  const coupons = successPayload(
    await call("/food", "fetch_food_coupons"),
    "fetch_food_coupons",
  );
  assert.equal(coupons.coupons[0].code, "FUEL30");
  successPayload(await call("/food", "apply_food_coupon", {
    coupon_code: "FUEL30",
  }), "apply_food_coupon");
  const food = successPayload(
    await call("/food", "get_food_cart"),
    "get_food_cart",
  ).cart;

  successPayload(await call("/im", "your_go_to_items"), "your_go_to_items");
  const search = successPayload(await call("/im", "search_products", {
    query: "oats bananas electrolytes greek yogurt",
  }), "search_products");
  assert.equal(search.substitution.unavailableProduct.available, false);
  assert.equal(search.substitution.alternative.id, "im-high-protein-curd");
  assert.equal(search.substitution.savings, 24);

  const unavailable = errorPayload(await call("/im", "update_cart", {
    address_id: "address-home-demo",
    operation: "add",
    items: [{ product_id: "im-greek-yogurt", quantity: 1 }],
  }), "ITEM_UNAVAILABLE");
  assert.equal(unavailable.details.substitution.savings, 24);

  successPayload(await call("/im", "update_cart", {
    address_id: "address-home-demo",
    operation: "replace",
    items: [
      { product_id: "im-rolled-oats", quantity: 1 },
      { product_id: "im-bananas", quantity: 1 },
      { product_id: "im-electrolytes", quantity: 1 },
    ],
  }), "update_cart");
  const initialInstamart = successPayload(
    await call("/im", "get_cart"),
    "initial get_cart",
  ).cart;
  assert.equal(initialInstamart.total, 396);

  const update = successPayload(await call("/im", "update_cart", {
    address_id: "address-home-demo",
    operation: "add",
    substitution_for: "im-greek-yogurt",
    items: [
      { product_id: "im-high-protein-curd", quantity: 1 },
    ],
  }), "update_cart substitution");
  assert.equal(update.substitutionAccepted, true);
  const instamart = successPayload(
    await call("/im", "get_cart"),
    "get_cart",
  ).cart;
  return { food, instamart };
}

function rpcBody(id, name) {
  return {
    jsonrpc: "2.0",
    id,
    method: "tools/call",
    params: {
      name,
      arguments: name === "update_food_cart"
        ? { items: [{ item_id: "food-paneer-protein-bowl", quantity: 1 }] }
        : {},
    },
  };
}

async function rawPost(url, { session, body = {}, origin, expectedStatus = 200 } = {}) {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(session ? { "Mcp-Session-Id": session } : {}),
      ...(origin ? { Origin: origin } : {}),
    },
    body: JSON.stringify(body),
  });
  const text = await response.text();
  assert.equal(
    response.status,
    expectedStatus,
    `${url} returned ${response.status}: ${text}`,
  );
  return {
    response,
    payload: text.length > 0 ? JSON.parse(text) : null,
  };
}

async function foodItemCount(url, session) {
  const { payload } = await rawPost(url, {
    session,
    body: rpcBody(1, "get_food_cart"),
  });
  return payload.result.structuredContent.cart.items.length;
}

async function testSessionIsolation() {
  const demo = createDemoServer({ port: 0, latencyScale: 0, corsOrigin: null });
  const address = await demo.start();
  assert.equal(address.address, "127.0.0.1");
  const url = `http://${address.address}:${address.port}`;
  try {
    await rawPost(`${url}/food`, {
      session: "session-a",
      body: rpcBody(1, "update_food_cart"),
    });
    await rawPost(`${url}/food`, {
      session: "session-b",
      body: rpcBody(1, "update_food_cart"),
    });
    assert.equal(await foodItemCount(`${url}/food`, "session-a"), 1);
    assert.equal(await foodItemCount(`${url}/food`, "session-b"), 1);

    const missing = await rawPost(`${url}/demo/reset`, { expectedStatus: 401 });
    assert.equal(missing.payload.error, "Mcp-Session-Id is required.");
    assert.equal(missing.response.headers.get("access-control-allow-origin"), null);
    const missingScenario = await rawPost(`${url}/demo/scenario?all=1`, {
      expectedStatus: 401,
      body: { scenario: "serverUnavailable", reset: true },
    });
    assert.equal(missingScenario.payload.error, "Mcp-Session-Id is required.");
    assert.equal(await foodItemCount(`${url}/food`, "session-a"), 1);
    assert.equal(await foodItemCount(`${url}/food`, "session-b"), 1);

    const invalid = await rawPost(`${url}/demo/reset`, {
      session: "not a session",
      expectedStatus: 400,
    });
    assert.equal(invalid.payload.error, "Mcp-Session-Id is invalid.");
    assert.equal(await foodItemCount(`${url}/food`, "session-b"), 1);

    await rawPost(`${url}/demo/reset`, { session: "session-a", body: {} });
    assert.equal(await foodItemCount(`${url}/food`, "session-a"), 0);
    assert.equal(await foodItemCount(`${url}/food`, "session-b"), 1);

    await rawPost(`${url}/demo/scenario`, {
      session: "session-a",
      body: { scenario: "serverUnavailable", reset: false },
    });
    const unavailable = await rawPost(`${url}/food`, {
      session: "session-a",
      expectedStatus: 503,
      body: rpcBody(2, "get_addresses"),
    });
    assert.equal(unavailable.payload.error.data.code, "SERVER_UNAVAILABLE");
    assert.equal(await foodItemCount(`${url}/food`, "session-b"), 1);
  } finally {
    await demo.stop();
  }
}

function assertCors(response, expectedOrigin) {
  const allowOrigin = response.headers.get("access-control-allow-origin");
  assert.notEqual(allowOrigin, "*");
  assert.equal(allowOrigin, expectedOrigin);
}

async function testExplicitLoopbackCors() {
  const denied = [
    { corsOrigin: "*" },
    { corsOrigin: "https://evil.example" },
    { corsOrigin: "http://127.0.0.1:5173/path" },
  ];
  for (const options of denied) {
    const demo = createDemoServer({ port: 0, latencyScale: 0, ...options });
    const address = await demo.start();
    const url = `http://${address.address}:${address.port}`;
    try {
      const posted = await rawPost(`${url}/demo/reset`, {
        origin: "https://evil.example",
        expectedStatus: 401,
      });
      assertCors(posted.response, null);
      const preflight = await fetch(url, {
        method: "OPTIONS",
        headers: {
          Origin: "https://evil.example",
          "Access-Control-Request-Method": "POST",
        },
      });
      assertCors(preflight, null);
    } finally {
      await demo.stop();
    }
  }

  const previous = process.env.DEMO_CORS_ORIGIN;
  process.env.DEMO_CORS_ORIGIN = "http://127.0.0.1:5173";
  const demo = createDemoServer({ port: 0, latencyScale: 0 });
  try {
    const address = await demo.start();
    assert.equal(address.address, "127.0.0.1");
    const url = `http://${address.address}:${address.port}`;
    const allowed = await rawPost(`${url}/demo/reset`, {
      session: "browser-session",
      origin: "http://127.0.0.1:5173",
      body: {},
    });
    assertCors(allowed.response, "http://127.0.0.1:5173");
    assert.equal(
      allowed.response.headers.get("access-control-expose-headers"),
      "Mcp-Session-Id",
    );

    const otherLoopback = await rawPost(`${url}/demo/reset`, {
      session: "browser-session",
      origin: "http://localhost:5173",
      body: {},
    });
    assertCors(otherLoopback.response, null);

    const publicOrigin = await rawPost(`${url}/demo/reset`, {
      session: "browser-session",
      origin: "https://evil.example",
      body: {},
    });
    assertCors(publicOrigin.response, null);

    const preflight = await fetch(`${url}/demo/reset`, {
      method: "OPTIONS",
      headers: {
        Origin: "http://127.0.0.1:5173",
        "Access-Control-Request-Method": "POST",
        "Access-Control-Request-Headers": "content-type, mcp-session-id",
      },
    });
    assert.equal(preflight.status, 204);
    assertCors(preflight, "http://127.0.0.1:5173");
    assert.equal(
      preflight.headers.get("access-control-allow-methods"),
      "POST, OPTIONS",
    );
    assert.match(
      preflight.headers.get("access-control-allow-headers") ?? "",
      /Mcp-Session-Id/,
    );

    const blockedPreflight = await fetch(`${url}/demo/reset`, {
      method: "OPTIONS",
      headers: {
        Origin: "https://evil.example",
        "Access-Control-Request-Method": "POST",
      },
    });
    assertCors(blockedPreflight, null);
  } finally {
    if (previous === undefined) delete process.env.DEMO_CORS_ORIGIN;
    else process.env.DEMO_CORS_ORIGIN = previous;
    await demo.stop();
  }
}

try {
  assert.ok(deterministicLatencyMs("food:get_addresses") >= 180);
  assert.ok(deterministicLatencyMs("food:get_addresses") <= 500);
  assert.equal(
    deterministicLatencyMs("food:get_addresses"),
    deterministicLatencyMs("food:get_addresses"),
  );
  assert.ok(deterministicLatencyMs("im:get_cart") >= 180);
  assert.ok(deterministicLatencyMs("im:get_cart") <= 500);
  console.log("✓ deterministic latency is stable and bounded at 180–500 ms");

  const foodInitialize = await rpc("/food", "initialize", {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "fitorder-contract-test", version: "1.0.0" },
  });
  assert.equal(foodInitialize.result.serverInfo.name, "fitorder-food-demo");
  assert.ok(sessionId);
  const initialSession = sessionId;

  const imInitialize = await rpc("/im", "initialize", {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "fitorder-contract-test", version: "1.0.0" },
  });
  assert.equal(imInitialize.result.serverInfo.name, "fitorder-instamart-demo");
  assert.equal(sessionId, initialSession);

  const foodTools = (await rpc("/food", "tools/list")).result.tools.map(({ name }) => name);
  const instamartTools = (await rpc("/im", "tools/list")).result.tools.map(({ name }) => name);
  assert.deepEqual(foodTools.slice(0, 9), [
    "get_addresses",
    "search_menu",
    "get_restaurant_menu",
    "update_food_cart",
    "fetch_food_coupons",
    "apply_food_coupon",
    "get_food_cart",
    "place_food_order",
    "track_food_order",
  ]);
  assert.deepEqual(instamartTools.slice(0, 6), [
    "your_go_to_items",
    "search_products",
    "update_cart",
    "get_cart",
    "checkout",
    "track_order",
  ]);
  console.log("✓ initialize and tools/list expose the canonical Food + Instamart tools");

  const { food, instamart } = await buildGoldenCarts();
  assert.equal(food.total, 343);
  assert.equal(food.subtotal, 328);
  assert.equal(food.discount, 30);
  assert.equal(instamart.total, 485);
  assert.equal(instamart.subtotal, 441);
  assert.equal(food.total + instamart.total, 828);
  assert.equal(food.authoritative, true);
  assert.equal(instamart.authoritative, true);
  console.log("✓ substitution saves ₹24 and authoritative carts total ₹343 + ₹485 = ₹828");

  errorPayload(await call("/food", "place_food_order", {
    confirmed: false,
    cart_revision: food.revision,
  }), "CONFIRMATION_REQUIRED");

  const foodOrder = successPayload(await call("/food", "place_food_order", {
    confirmed: true,
    cart_revision: food.revision,
    idempotency_key: "contract-food-key",
  }), "place_food_order");
  const imOrder = successPayload(await call("/im", "checkout", {
    confirmed: true,
    cart_revision: instamart.revision,
    idempotency_key: "contract-im-key",
  }), "checkout");
  assert.equal(foodOrder.total, 343);
  assert.equal(imOrder.total, 485);

  const foodTracking = successPayload(await call("/food", "track_food_order", {
    order_id: foodOrder.orderID,
  }), "track_food_order").tracking;
  const imTracking = successPayload(await call("/im", "track_order", {
    order_id: imOrder.orderID,
  }), "track_order").tracking;
  assert.equal(foodTracking.status, "beingPrepared");
  assert.equal(imTracking.status, "packing");
  console.log("✓ explicit confirmation gates placement and both orders return tracking");

  await post("/demo/reset", {});
  const emptyFood = successPayload(
    await call("/food", "get_food_cart"),
    "get_food_cart after reset",
  ).cart;
  const emptyInstamart = successPayload(
    await call("/im", "get_cart"),
    "get_cart after reset",
  ).cart;
  assert.equal(emptyFood.items.length, 0);
  assert.equal(emptyInstamart.items.length, 0);
  assert.equal(emptyFood.total, 0);
  assert.equal(emptyInstamart.total, 0);
  console.log("✓ /demo/reset clears cart and order state for the current session");

  await post("/demo/scenario", { scenario: "serverUnavailable", reset: true });
  const unavailableRpc = await rpc("/food", "tools/call", {
    name: "get_addresses",
    arguments: {},
  }, 503);
  assert.equal(unavailableRpc.error.data.code, "SERVER_UNAVAILABLE");
  await post("/demo/reset", {});
  console.log("✓ serverUnavailable scenario emits a retryable JSON-RPC service error");

  await buildGoldenCarts();
  await post("/demo/scenario", { scenario: "cartChanged", reset: false });
  const changed = successPayload(
    await call("/food", "get_food_cart"),
    "cartChanged get_food_cart",
  );
  assert.equal(changed.requiresReconfirmation, true);
  assert.equal(changed.cartChanged.currentTotal, 353);
  errorPayload(await call("/food", "place_food_order", {
    confirmed: true,
    cart_revision: changed.cart.revision,
  }), "CART_CHANGE_CONFIRMATION_REQUIRED");
  console.log("✓ cartChanged scenario exposes the diff and requires reconfirmation");

  await post("/demo/scenario", { scenario: "ambiguousCheckout", reset: false });
  const ambiguous = await rpc("/food", "tools/call", {
    name: "place_food_order",
    arguments: {
      confirmed: true,
      accepted_cart_changes: true,
      cart_revision: changed.cart.revision,
      idempotency_key: "ambiguous-food-key",
    },
  }, 503);
  assert.equal(ambiguous.error.data.code, "ORDER_STATUS_UNKNOWN");
  assert.equal(ambiguous.error.data.recoveryTool, "get_food_order_history");
  const recovered = successPayload(
    await call("/food", "get_food_order_history"),
    "get_food_order_history",
  );
  assert.equal(recovered.orders[0].orderId, "FOOD-DEMO-2407");
  console.log("✓ ambiguousCheckout scenario recovers through order history");

  assert.equal(loopbackCorsOrigin("*"), null);
  assert.equal(loopbackCorsOrigin("https://evil.example"), null);
  assert.equal(loopbackCorsOrigin("http://127.0.0.1.evil.example"), null);
  assert.equal(loopbackCorsOrigin("http://127.0.0.1:5173/demo"), null);
  assert.equal(loopbackCorsOrigin("http://127.0.0.1:5173"), "http://127.0.0.1:5173");
  assert.equal(loopbackCorsOrigin("http://localhost:5173"), "http://localhost:5173");
  assert.equal(loopbackCorsOrigin("http://[::1]:5173"), "http://[::1]:5173");
  await testSessionIsolation();
  await testExplicitLoopbackCors();
  console.log("✓ control routes stay on one session and CORS is not a wildcard");

  console.log(`\nFitOrder demo-server contract passed against ${baseURL}`);
} finally {
  if (ownedServer) await ownedServer.stop();
}
