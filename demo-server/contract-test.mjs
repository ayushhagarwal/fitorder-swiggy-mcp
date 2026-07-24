import assert from "node:assert/strict";
import { createDemoServer, deterministicLatencyMs } from "./server.mjs";

let ownedServer = null;
let baseURL = process.env.DEMO_SERVER_URL?.replace(/\/$/, "");

if (!baseURL) {
  ownedServer = createDemoServer({ port: 0, latencyScale: 0 });
  const address = await ownedServer.start();
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

  console.log(`\nFitOrder demo-server contract passed against ${baseURL}`);
} finally {
  if (ownedServer) await ownedServer.stop();
}
