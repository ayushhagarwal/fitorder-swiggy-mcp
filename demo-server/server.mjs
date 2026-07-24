import http from "node:http";
import { fileURLToPath } from "node:url";
import path from "node:path";

const DEFAULT_HOST = "127.0.0.1";
const DEFAULT_PORT = 8787;
const JSON_LIMIT_BYTES = 1_000_000;
const VALID_SCENARIOS = new Set([
  "goldenPath",
  "serverUnavailable",
  "cartChanged",
  "ambiguousCheckout",
]);

const SEEDED_ADDRESS = Object.freeze({
  id: "address-home-demo",
  label: "Home",
  line1: "Seeded Home",
  line2: "Indiranagar",
  displayAddress: "Seeded Home · Indiranagar, Bengaluru",
  city: "Bengaluru",
  isDefault: true,
  isSelected: true,
  seeded: true,
});

const FOOD_RESTAURANT = Object.freeze({
  id: "restaurant-green-grain-demo",
  name: "Green Grain Kitchen",
  cuisine: "Healthy food · North Indian",
  rating: 4.6,
  deliveryMinutes: 28,
  seeded: true,
});

const FOOD_CATALOG = Object.freeze({
  "food-paneer-protein-bowl": Object.freeze({
    id: "food-paneer-protein-bowl",
    name: "Paneer Protein Bowl",
    unit: "1 bowl",
    price: 279,
    available: true,
    veg: true,
  }),
  "food-curd-side": Object.freeze({
    id: "food-curd-side",
    name: "Fresh Curd Side",
    unit: "150 g",
    price: 49,
    available: true,
    veg: true,
  }),
});

const INSTAMART_CATALOG = Object.freeze({
  "im-rolled-oats": Object.freeze({
    id: "im-rolled-oats",
    name: "Wholegrain Rolled Oats",
    unit: "1 kg",
    price: 169,
    available: true,
    seeded: true,
  }),
  "im-bananas": Object.freeze({
    id: "im-bananas",
    name: "Robusta Bananas",
    unit: "6 pieces",
    price: 54,
    available: true,
    seeded: true,
  }),
  "im-electrolytes": Object.freeze({
    id: "im-electrolytes",
    name: "Lemon Electrolyte Sachets",
    unit: "10 sachets",
    price: 129,
    available: true,
    seeded: true,
  }),
  "im-greek-yogurt": Object.freeze({
    id: "im-greek-yogurt",
    name: "Plain Greek Yogurt",
    unit: "400 g",
    price: 113,
    available: false,
    seeded: true,
  }),
  "im-high-protein-curd": Object.freeze({
    id: "im-high-protein-curd",
    name: "High-Protein Curd",
    unit: "400 g",
    price: 89,
    available: true,
    seeded: true,
  }),
});

const YOGURT_SUBSTITUTION = Object.freeze({
  id: "substitution-yogurt-to-curd",
  unavailableProduct: INSTAMART_CATALOG["im-greek-yogurt"],
  alternative: INSTAMART_CATALOG["im-high-protein-curd"],
  original: groceryWireItem(INSTAMART_CATALOG["im-greek-yogurt"]),
  replacement: groceryWireItem(INSTAMART_CATALOG["im-high-protein-curd"]),
  savings: 24,
  reason: "Closest high-protein vegetarian alternative in stock",
});

function groceryWireItem(item) {
  return {
    ...item,
    size: item.unit,
    isAvailable: item.available,
  };
}

function foodWireItem(item) {
  return {
    ...item,
    restaurantID: FOOD_RESTAURANT.id,
    restaurantName: FOOD_RESTAURANT.name,
    deliveryMinutes: FOOD_RESTAURANT.deliveryMinutes,
    rating: FOOD_RESTAURANT.rating,
    isVegetarian: item.veg,
    isAvailable: item.available,
    nutritionEstimate: item.id === "food-paneer-protein-bowl"
      ? {
          calories: 704,
          proteinGrams: 49,
          carbohydrateGrams: 74,
          sourceLabel: "FitOrder estimate",
        }
      : {
          calories: 92,
          proteinGrams: 8,
          carbohydrateGrams: 7,
          sourceLabel: "FitOrder estimate",
        },
  };
}

const FOOD_TOOL_DEFINITIONS = Object.freeze([
  toolDefinition("get_addresses", "Return the seeded delivery addresses.", {}),
  toolDefinition("search_menu", "Search Food restaurants and menu items.", {
    query: stringProperty("Food search query"),
  }, ["query"]),
  toolDefinition("get_restaurant_menu", "Return a restaurant menu.", {
    restaurantId: stringProperty("Restaurant identifier"),
  }, ["restaurantId"]),
  toolDefinition("update_food_cart", "Replace or update the Food cart.", {
    restaurantId: stringProperty("Restaurant identifier"),
    addressId: stringProperty("Delivery address identifier"),
    items: arrayItemsProperty(),
  }, ["items"]),
  toolDefinition("fetch_food_coupons", "Return eligible Food coupons.", {}),
  toolDefinition("apply_food_coupon", "Apply an eligible coupon to the Food cart.", {
    couponCode: stringProperty("Coupon code"),
  }, ["couponCode"]),
  toolDefinition("get_food_cart", "Return the authoritative Food cart.", {}),
  toolDefinition("place_food_order", "Place the Food demo order after explicit confirmation.", {
    confirmed: booleanProperty("Whether the user explicitly confirmed"),
    cartRevision: integerProperty("Authoritative cart revision"),
    acceptedCartChanges: booleanProperty("Whether a changed cart was reconfirmed"),
  }, ["confirmed"]),
  toolDefinition("track_food_order", "Track the placed Food demo order.", {
    orderId: stringProperty("Food order identifier"),
  }),
  toolDefinition("get_food_order_history", "Recover an ambiguously placed Food order.", {}),
]);

const INSTAMART_TOOL_DEFINITIONS = Object.freeze([
  toolDefinition("your_go_to_items", "Return frequently purchased seeded grocery items.", {}),
  toolDefinition("search_products", "Search Instamart products and availability.", {
    query: stringProperty("Product search query"),
  }, ["query"]),
  toolDefinition("update_cart", "Replace or update the Instamart cart.", {
    addressId: stringProperty("Delivery address identifier"),
    items: arrayItemsProperty(),
  }, ["items"]),
  toolDefinition("get_cart", "Return the authoritative Instamart cart.", {}),
  toolDefinition("checkout", "Place the Instamart demo order after explicit confirmation.", {
    confirmed: booleanProperty("Whether the user explicitly confirmed"),
    cartRevision: integerProperty("Authoritative cart revision"),
    acceptedCartChanges: booleanProperty("Whether a changed cart was reconfirmed"),
  }, ["confirmed"]),
  toolDefinition("track_order", "Track the placed Instamart demo order.", {
    orderId: stringProperty("Instamart order identifier"),
  }),
  toolDefinition("get_order_history", "Recover an ambiguously placed Instamart order.", {}),
]);

function stringProperty(description) {
  return { type: "string", description };
}

function booleanProperty(description) {
  return { type: "boolean", description };
}

function integerProperty(description) {
  return { type: "integer", minimum: 1, description };
}

function arrayItemsProperty() {
  return {
    type: "array",
    minItems: 1,
    items: {
      type: "object",
      additionalProperties: false,
      properties: {
        id: stringProperty("Catalog item identifier"),
        itemId: stringProperty("Alias for the catalog item identifier"),
        quantity: { type: "integer", minimum: 0, maximum: 20 },
      },
      required: ["quantity"],
    },
  };
}

function toolDefinition(name, description, properties, required = []) {
  return {
    name,
    description,
    inputSchema: {
      type: "object",
      additionalProperties: true,
      properties,
      ...(required.length > 0 ? { required } : {}),
    },
  };
}

class ToolError extends Error {
  constructor(code, message, details = {}, retryable = false) {
    super(message);
    this.name = "ToolError";
    this.code = code;
    this.details = details;
    this.retryable = retryable;
  }
}

function createInitialState(scenario = "goldenPath") {
  return {
    scenario,
    food: {
      items: new Map(),
      restaurantId: FOOD_RESTAURANT.id,
      addressId: SEEDED_ADDRESS.id,
      couponCode: null,
      revision: 1,
      authoritativeRevision: null,
      reconfirmationRequired: false,
      cartChangeApplied: false,
      deliveryFeeOverride: null,
      order: null,
      trackingPolls: 0,
      ambiguousResponseReturned: false,
    },
    instamart: {
      items: new Map(),
      addressId: SEEDED_ADDRESS.id,
      revision: 1,
      authoritativeRevision: null,
      reconfirmationRequired: false,
      cartChangeApplied: false,
      deliveryFeeOverride: null,
      substitutionSeen: false,
      substitutionAccepted: false,
      order: null,
      trackingPolls: 0,
      ambiguousResponseReturned: false,
    },
  };
}

function sum(values) {
  return values.reduce((total, value) => total + value, 0);
}

function lineItems(itemMap, catalog) {
  return [...itemMap.entries()]
    .filter(([, quantity]) => quantity > 0)
    .map(([id, quantity]) => {
      const item = catalog[id];
      return {
        id: item.id,
        name: item.name,
        detail: item.unit,
        quantity,
        unit: item.unit,
        unitPrice: item.price,
        totalPrice: item.price * quantity,
        available: item.available,
        isAvailable: item.available,
        ...(id === "im-high-protein-curd"
          ? { substitutedFor: "Plain Greek Yogurt" }
          : {}),
        ...(id === "food-paneer-protein-bowl"
          ? {
              nutritionEstimate: {
                calories: 612,
                proteinGrams: 41,
                carbohydrateGrams: 67,
                sourceLabel: "FitOrder estimate",
              },
            }
          : id === "food-curd-side"
            ? {
                nutritionEstimate: {
                  calories: 92,
                  proteinGrams: 8,
                  carbohydrateGrams: 7,
                  sourceLabel: "FitOrder estimate",
                },
              }
            : {}),
      };
    });
}

function foodCartSnapshot(food) {
  const items = lineItems(food.items, FOOD_CATALOG);
  const subtotal = sum(items.map((item) => item.totalPrice));
  const hasItems = items.length > 0;
  const discount = hasItems && food.couponCode === "FUEL30" ? 30 : 0;
  const deliveryFee = hasItems ? (food.deliveryFeeOverride ?? 25) : 0;
  const handlingFee = hasItems ? 6 : 0;
  const taxes = hasItems ? 14 : 0;
  return {
    id: "food-cart-demo",
    service: "food",
    title: "Tonight's recovery dinner",
    merchantName: FOOD_RESTAURANT.name,
    address: SEEDED_ADDRESS,
    addressText: SEEDED_ADDRESS.displayAddress,
    addressId: food.addressId,
    items,
    subtotal,
    discount,
    deliveryFee,
    handlingFee,
    taxes,
    total: subtotal - discount + deliveryFee + handlingFee + taxes,
    deliveryMinutes: 28,
    couponCode: food.couponCode,
    currency: "INR",
    revision: food.revision,
    authoritative: true,
  };
}

function instamartCartSnapshot(instamart) {
  const items = lineItems(instamart.items, INSTAMART_CATALOG);
  const subtotal = sum(items.map((item) => item.totalPrice));
  const hasItems = items.length > 0;
  const deliveryFee = hasItems ? (instamart.deliveryFeeOverride ?? 29) : 0;
  const handlingFee = hasItems ? 15 : 0;
  const taxes = 0;
  return {
    id: "instamart-cart-demo",
    service: "instamart",
    title: "5-day breakfast refill",
    merchantName: "Swiggy Instamart",
    address: SEEDED_ADDRESS,
    addressText: SEEDED_ADDRESS.displayAddress,
    addressId: instamart.addressId,
    items,
    subtotal,
    discount: 0,
    deliveryFee,
    handlingFee,
    taxes,
    total: subtotal + deliveryFee + handlingFee,
    deliveryMinutes: 18,
    couponCode: null,
    currency: "INR",
    revision: instamart.revision,
    authoritative: true,
  };
}

function normalizeUpdates(args) {
  if (Array.isArray(args.items)) {
    return args.items.map((item) => ({
      id: item.id ?? item.itemId ?? item.item_id ?? item.productId ?? item.product_id,
      quantity: item.quantity,
    }));
  }
  if (args.itemId || args.item_id || args.productId || args.product_id || args.id) {
    return [{
      id: args.itemId ?? args.item_id ?? args.productId ?? args.product_id ?? args.id,
      quantity: args.quantity ?? 1,
    }];
  }
  throw new ToolError("INVALID_ITEMS", "At least one cart item is required.");
}

function applyItemUpdates(target, catalog, args) {
  const updates = normalizeUpdates(args);
  const replace = args.operation != null
    ? args.operation === "replace"
    : args.replace !== false && Array.isArray(args.items);
  const next = replace ? new Map() : new Map(target);

  for (const update of updates) {
    const normalizedID = update.id === "high-protein-curd-side"
      ? "food-curd-side"
      : update.id;
    if (!normalizedID || !Object.hasOwn(catalog, normalizedID)) {
      throw new ToolError("UNKNOWN_ITEM", `Unknown seeded item: ${update.id ?? "missing"}.`);
    }
    if (!Number.isInteger(update.quantity) || update.quantity < 0 || update.quantity > 20) {
      throw new ToolError("INVALID_QUANTITY", `Invalid quantity for ${update.id}.`);
    }
    const item = catalog[normalizedID];
    if (!item.available && update.quantity > 0) {
      throw new ToolError(
        "ITEM_UNAVAILABLE",
        `${item.name} is currently unavailable.`,
        { substitution: YOGURT_SUBSTITUTION },
      );
    }
    if (update.quantity === 0) {
      next.delete(normalizedID);
    } else {
      next.set(normalizedID, update.quantity);
    }
  }
  return next;
}

function cartsEqual(left, right) {
  if (left.size !== right.size) return false;
  for (const [id, quantity] of left) {
    if (right.get(id) !== quantity) return false;
  }
  return true;
}

function bumpRevision(serviceState) {
  serviceState.revision += 1;
  serviceState.authoritativeRevision = null;
}

function maybeApplyCartChange(serviceState, service) {
  if (serviceState.cartChangeApplied) return null;
  const before = service === "food"
    ? foodCartSnapshot(serviceState)
    : instamartCartSnapshot(serviceState);
  if (before.items.length === 0) return null;

  serviceState.deliveryFeeOverride = before.deliveryFee + 10;
  serviceState.cartChangeApplied = true;
  serviceState.reconfirmationRequired = true;
  bumpRevision(serviceState);
  const after = service === "food"
    ? foodCartSnapshot(serviceState)
    : instamartCartSnapshot(serviceState);
  return {
    changed: true,
    reason: "Delivery fee changed while the authoritative cart was refreshed.",
    previousTotal: before.total,
    currentTotal: after.total,
    previousRevision: before.revision,
    currentRevision: after.revision,
  };
}

function validatePlacement(serviceState, cart, args) {
  if (args.confirmed !== true) {
    throw new ToolError(
      "CONFIRMATION_REQUIRED",
      "Explicit user confirmation is required before placing a demo order.",
    );
  }
  if (cart.items.length === 0) {
    throw new ToolError("EMPTY_CART", "The cart is empty.");
  }
  if (serviceState.authoritativeRevision !== serviceState.revision) {
    throw new ToolError(
      "AUTHORITATIVE_REFRESH_REQUIRED",
      "Refresh the authoritative cart immediately before checkout.",
      { expectedRevision: serviceState.revision },
      true,
    );
  }
  const suppliedRevision = args.cartRevision ?? args.cart_revision;
  if (suppliedRevision != null && suppliedRevision !== serviceState.revision) {
    throw new ToolError(
      "CART_REVISION_MISMATCH",
      "The supplied cart revision is stale.",
      { expectedRevision: serviceState.revision, suppliedRevision },
    );
  }
  const acceptedCartChanges = args.acceptedCartChanges ?? args.accepted_cart_changes;
  if (serviceState.reconfirmationRequired && acceptedCartChanges !== true) {
    throw new ToolError(
      "CART_CHANGE_CONFIRMATION_REQUIRED",
      "The changed cart must be reviewed and explicitly reconfirmed.",
      { cart },
    );
  }
}

function foodTracking(order, poll) {
  const index = Math.min(poll, 3);
  const phases = [
    { status: "confirmed", headline: "Order confirmed", etaMinutes: 28 },
    { status: "beingPrepared", headline: "The kitchen is preparing your meal", etaMinutes: 24 },
    { status: "outForDelivery", headline: "Your recovery dinner is on the way", etaMinutes: 12 },
    { status: "delivered", headline: "Recovery dinner delivered", etaMinutes: 0 },
  ];
  const current = phases[index];
  const titles = ["Order confirmed", "Being prepared", "Out for delivery", "Delivered"];
  return {
    orderId: order.orderId,
    orderID: order.orderId,
    service: "food",
    status: current.status,
    headline: current.headline,
    etaMinutes: current.etaMinutes,
    steps: titles.map((title, stepIndex) => ({
      id: `food-step-${stepIndex + 1}`,
      title,
      status: stepIndex < index ? "completed" : stepIndex === index ? "current" : "upcoming",
    })),
    milestones: titles.map((title, stepIndex) => ({
      id: `food-step-${stepIndex + 1}`,
      title,
      detail: stepIndex === index ? current.headline : null,
      state: stepIndex < index ? "completed" : stepIndex === index ? "current" : "upcoming",
    })),
    updatedAt: "2026-07-24T12:15:00.000Z",
  };
}

function instamartTracking(order, poll) {
  const index = Math.min(poll, 3);
  const phases = [
    { status: "confirmed", headline: "Order confirmed", etaMinutes: 18 },
    { status: "packing", headline: "Your breakfast refill is being packed", etaMinutes: 14 },
    { status: "outForDelivery", headline: "Your refill is on the way", etaMinutes: 7 },
    { status: "delivered", headline: "Breakfast refill delivered", etaMinutes: 0 },
  ];
  const current = phases[index];
  const titles = ["Order confirmed", "Packing items", "Out for delivery", "Delivered"];
  return {
    orderId: order.orderId,
    orderID: order.orderId,
    service: "instamart",
    status: current.status,
    headline: current.headline,
    etaMinutes: current.etaMinutes,
    steps: titles.map((title, stepIndex) => ({
      id: `instamart-step-${stepIndex + 1}`,
      title,
      status: stepIndex < index ? "completed" : stepIndex === index ? "current" : "upcoming",
    })),
    milestones: titles.map((title, stepIndex) => ({
      id: `instamart-step-${stepIndex + 1}`,
      title,
      detail: stepIndex === index ? current.headline : null,
      state: stepIndex < index ? "completed" : stepIndex === index ? "current" : "upcoming",
    })),
    updatedAt: "2026-07-24T12:15:02.000Z",
  };
}

function handleFoodTool(state, name, args) {
  const food = state.food;
  switch (name) {
    case "get_addresses":
      return { addresses: [SEEDED_ADDRESS] };
    case "search_menu":
      return {
        query: args.query,
        restaurants: [{
          ...FOOD_RESTAURANT,
          matchedItems: Object.values(FOOD_CATALOG).map(foodWireItem),
        }],
        meals: Object.values(FOOD_CATALOG).map(foodWireItem),
      };
    case "get_restaurant_menu": {
      if ((args.restaurantId ?? args.restaurant_id) !== FOOD_RESTAURANT.id) {
        throw new ToolError("RESTAURANT_NOT_FOUND", "Seeded restaurant not found.");
      }
      const requestedItemID = args.itemId ?? args.item_id ?? "food-paneer-protein-bowl";
      const selected = FOOD_CATALOG[requestedItemID]
        ?? FOOD_CATALOG["food-paneer-protein-bowl"];
      const meal = foodWireItem(selected);
      return {
        restaurant: FOOD_RESTAURANT,
        meal,
        item: meal,
        items: Object.values(FOOD_CATALOG).map(foodWireItem),
      };
    }
    case "update_food_cart": {
      const next = applyItemUpdates(food.items, FOOD_CATALOG, args);
      if (!cartsEqual(next, food.items)) {
        food.items = next;
        bumpRevision(food);
      }
      if (args.addressId ?? args.address_id) {
        food.addressId = args.addressId ?? args.address_id;
      }
      return { cart: foodCartSnapshot(food) };
    }
    case "fetch_food_coupons":
      return {
        coupons: [{
          code: "FUEL30",
          title: "₹30 off recovery dinner",
          discount: 30,
          description: "Seeded recovery dinner saving",
          eligible: food.items.size > 0,
          seeded: true,
        }],
      };
    case "apply_food_coupon":
      if ((args.couponCode ?? args.coupon_code) !== "FUEL30") {
        throw new ToolError("COUPON_NOT_FOUND", "Coupon is not available in this demo.");
      }
      if (food.items.size === 0) {
        throw new ToolError("EMPTY_CART", "Add Food items before applying a coupon.");
      }
      if (food.couponCode !== "FUEL30") {
        food.couponCode = "FUEL30";
        bumpRevision(food);
      }
      return {
        cart: foodCartSnapshot(food),
        savings: 30,
      };
    case "get_food_cart": {
      const cartChanged = state.scenario === "cartChanged"
        && food.authoritativeRevision === food.revision
        ? maybeApplyCartChange(food, "food")
        : null;
      const cart = foodCartSnapshot(food);
      food.authoritativeRevision = food.revision;
      return {
        cart,
        ...(cartChanged
          ? { cartChanged, requiresReconfirmation: true }
          : {}),
      };
    }
    case "place_food_order": {
      const cart = foodCartSnapshot(food);
      validatePlacement(food, cart, args);
      if (!food.order) {
        food.order = {
          orderId: "FOOD-DEMO-2407",
          orderID: "FOOD-DEMO-2407",
          service: "food",
          status: "confirmed",
          cartRevision: food.revision,
          placedAt: "2026-07-24T12:15:00.000Z",
          total: cart.total,
          idempotencyKey: args.idempotencyKey
            ?? args.idempotency_key
            ?? "food-demo-idempotency",
        };
      }
      food.reconfirmationRequired = false;
      if (state.scenario === "ambiguousCheckout" && !food.ambiguousResponseReturned) {
        food.ambiguousResponseReturned = true;
        throw new ToolError(
          "ORDER_STATUS_UNKNOWN",
          "The placement response was interrupted; the order may have succeeded.",
          {
            mayHaveSucceeded: true,
            recoveryTool: "get_food_order_history",
          },
          true,
        );
      }
      return { ...food.order };
    }
    case "track_food_order":
      if (!food.order) {
        throw new ToolError("ORDER_NOT_FOUND", "No Food demo order has been placed.");
      }
      food.trackingPolls += 1;
      return { tracking: foodTracking(food.order, food.trackingPolls) };
    case "get_food_order_history":
      return { orders: food.order ? [{ ...food.order }] : [] };
    default:
      throw new ToolError("TOOL_NOT_FOUND", `Unknown Food tool: ${name}.`);
  }
}

function handleInstamartTool(state, name, args) {
  const instamart = state.instamart;
  switch (name) {
    case "your_go_to_items":
      return {
        items: [
          INSTAMART_CATALOG["im-rolled-oats"],
          INSTAMART_CATALOG["im-bananas"],
          INSTAMART_CATALOG["im-electrolytes"],
        ].map(groceryWireItem),
      };
    case "search_products": {
      instamart.substitutionSeen = true;
      return {
        query: args.query,
        products: Object.values(INSTAMART_CATALOG).map(groceryWireItem),
        substitution: YOGURT_SUBSTITUTION,
      };
    }
    case "update_cart": {
      let next;
      try {
        next = applyItemUpdates(instamart.items, INSTAMART_CATALOG, args);
      } catch (error) {
        if (error instanceof ToolError && error.code === "ITEM_UNAVAILABLE") {
          instamart.substitutionSeen = true;
        }
        throw error;
      }
      if (!cartsEqual(next, instamart.items)) {
        instamart.items = next;
        bumpRevision(instamart);
      }
      if (args.addressId ?? args.address_id) {
        instamart.addressId = args.addressId ?? args.address_id;
      }
      if (instamart.items.has("im-high-protein-curd") && instamart.substitutionSeen) {
        instamart.substitutionAccepted = true;
      }
      return {
        cart: instamartCartSnapshot(instamart),
        substitutionAccepted: instamart.substitutionAccepted,
        ...(instamart.substitutionAccepted
          ? { substitution: YOGURT_SUBSTITUTION }
          : {}),
      };
    }
    case "get_cart": {
      const cartChanged = state.scenario === "cartChanged"
        && instamart.authoritativeRevision === instamart.revision
        ? maybeApplyCartChange(instamart, "instamart")
        : null;
      const cart = instamartCartSnapshot(instamart);
      instamart.authoritativeRevision = instamart.revision;
      return {
        cart,
        substitutionAccepted: instamart.substitutionAccepted,
        ...(cartChanged
          ? { cartChanged, requiresReconfirmation: true }
          : {}),
      };
    }
    case "checkout": {
      const cart = instamartCartSnapshot(instamart);
      validatePlacement(instamart, cart, args);
      if (!instamart.order) {
        instamart.order = {
          orderId: "IM-DEMO-2407",
          orderID: "IM-DEMO-2407",
          service: "instamart",
          status: "confirmed",
          cartRevision: instamart.revision,
          placedAt: "2026-07-24T12:15:02.000Z",
          total: cart.total,
          idempotencyKey: args.idempotencyKey
            ?? args.idempotency_key
            ?? "instamart-demo-idempotency",
        };
      }
      instamart.reconfirmationRequired = false;
      if (state.scenario === "ambiguousCheckout" && !instamart.ambiguousResponseReturned) {
        instamart.ambiguousResponseReturned = true;
        throw new ToolError(
          "ORDER_STATUS_UNKNOWN",
          "The checkout response was interrupted; the order may have succeeded.",
          {
            mayHaveSucceeded: true,
            recoveryTool: "get_order_history",
          },
          true,
        );
      }
      return { ...instamart.order };
    }
    case "track_order":
      if (!instamart.order) {
        throw new ToolError("ORDER_NOT_FOUND", "No Instamart demo order has been placed.");
      }
      instamart.trackingPolls += 1;
      return { tracking: instamartTracking(instamart.order, instamart.trackingPolls) };
    case "get_order_history":
      return { orders: instamart.order ? [{ ...instamart.order }] : [] };
    default:
      throw new ToolError("TOOL_NOT_FOUND", `Unknown Instamart tool: ${name}.`);
  }
}

function hashString(value) {
  let hash = 2166136261;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

export function deterministicLatencyMs(key) {
  return 180 + (hashString(String(key)) % 321);
}

function wait(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function maskSessionId(sessionId) {
  if (sessionId.length <= 8) return "demo-••••";
  return `${sessionId.slice(0, 5)}••••${sessionId.slice(-3)}`;
}

function validateSessionId(candidate) {
  return typeof candidate === "string"
    && candidate.length >= 1
    && candidate.length <= 128
    && /^[A-Za-z0-9._-]+$/.test(candidate);
}

function sendJson(response, status, payload, sessionId = null) {
  const body = JSON.stringify(payload);
  response.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
    "Cache-Control": "no-store",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Mcp-Session-Id",
    "Access-Control-Expose-Headers": "Mcp-Session-Id",
    ...(sessionId ? { "Mcp-Session-Id": sessionId } : {}),
  });
  response.end(body);
}

function readJson(request) {
  return new Promise((resolve, reject) => {
    let size = 0;
    const chunks = [];
    request.on("data", (chunk) => {
      size += chunk.length;
      if (size > JSON_LIMIT_BYTES) {
        reject(new Error("Request body is too large."));
        request.destroy();
        return;
      }
      chunks.push(chunk);
    });
    request.on("end", () => {
      try {
        const text = Buffer.concat(chunks).toString("utf8");
        resolve(text.length > 0 ? JSON.parse(text) : {});
      } catch {
        reject(new Error("Request body must be valid JSON."));
      }
    });
    request.on("error", reject);
  });
}

function rpcSuccess(id, result) {
  return { jsonrpc: "2.0", id: id ?? null, result };
}

function rpcError(id, code, message, data = undefined) {
  return {
    jsonrpc: "2.0",
    id: id ?? null,
    error: {
      code,
      message,
      ...(data === undefined ? {} : { data }),
    },
  };
}

function toolResult(payload) {
  return {
    content: [{ type: "text", text: JSON.stringify(payload) }],
    structuredContent: payload,
    isError: false,
  };
}

function toolErrorResult(error) {
  const payload = {
    error: {
      code: error.code ?? "TOOL_ERROR",
      message: error.message,
      retryable: error.retryable ?? false,
      ...(error.details && Object.keys(error.details).length > 0
        ? { details: error.details }
        : {}),
    },
  };
  return {
    content: [{ type: "text", text: JSON.stringify(payload) }],
    structuredContent: payload,
    isError: true,
    message: error.message,
  };
}

function validateRpcRequest(body) {
  if (!body || body.jsonrpc !== "2.0" || typeof body.method !== "string") {
    throw new ToolError("INVALID_REQUEST", "Expected a JSON-RPC 2.0 request.");
  }
}

export function createDemoServer(options = {}) {
  const host = options.host ?? DEFAULT_HOST;
  const port = options.port ?? Number(process.env.PORT ?? DEFAULT_PORT);
  const latencyScale = options.latencyScale
    ?? Number(process.env.DEMO_LATENCY_SCALE ?? 1);
  const sessions = new Map();
  let sessionCounter = 0;
  let defaultScenario = "goldenPath";

  function resolveSession(request) {
    const supplied = request.headers["mcp-session-id"];
    if (supplied != null && !validateSessionId(supplied)) {
      throw new ToolError("INVALID_SESSION", "Mcp-Session-Id is invalid.");
    }
    const sessionId = supplied ?? `demo-session-${String(++sessionCounter).padStart(4, "0")}`;
    if (!sessions.has(sessionId)) {
      sessions.set(sessionId, createInitialState(defaultScenario));
    }
    return { sessionId, state: sessions.get(sessionId) };
  }

  const server = http.createServer(async (request, response) => {
    if (request.method === "OPTIONS") {
      response.writeHead(204, {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Mcp-Session-Id",
      });
      response.end();
      return;
    }

    if (request.method !== "POST") {
      sendJson(response, 405, { error: "Only POST is supported." });
      return;
    }

    let sessionId = null;
    try {
      const session = resolveSession(request);
      sessionId = session.sessionId;
      const body = await readJson(request);
      const hasExplicitSession = request.headers["mcp-session-id"] != null;

      if (request.url === "/demo/reset") {
        const scenario = body.scenario ?? "goldenPath";
        if (!VALID_SCENARIOS.has(scenario)) {
          sendJson(response, 400, {
            error: "Unknown scenario.",
            validScenarios: [...VALID_SCENARIOS],
          }, sessionId);
          return;
        }
        if (hasExplicitSession) {
          sessions.set(sessionId, createInitialState(scenario));
        } else {
          defaultScenario = scenario;
          sessions.clear();
        }
        sendJson(response, 200, {
          ok: true,
          scenario,
          session: maskSessionId(sessionId),
        }, sessionId);
        return;
      }

      if (request.url === "/demo/scenario") {
        const scenario = body.scenario;
        if (!VALID_SCENARIOS.has(scenario)) {
          sendJson(response, 400, {
            error: "Unknown scenario.",
            validScenarios: [...VALID_SCENARIOS],
          }, sessionId);
          return;
        }
        if (!hasExplicitSession) {
          defaultScenario = scenario;
          if (body.reset === true) {
            sessions.clear();
          } else {
            for (const state of sessions.values()) {
              state.scenario = scenario;
              state.food.cartChangeApplied = false;
              state.instamart.cartChangeApplied = false;
              state.food.ambiguousResponseReturned = false;
              state.instamart.ambiguousResponseReturned = false;
            }
          }
        } else if (body.reset === true) {
          sessions.set(sessionId, createInitialState(scenario));
        } else {
          session.state.scenario = scenario;
          session.state.food.cartChangeApplied = false;
          session.state.instamart.cartChangeApplied = false;
          session.state.food.ambiguousResponseReturned = false;
          session.state.instamart.ambiguousResponseReturned = false;
        }
        sendJson(response, 200, {
          ok: true,
          scenario,
          reset: body.reset === true,
          session: maskSessionId(sessionId),
        }, sessionId);
        return;
      }

      const service = request.url === "/food"
        ? "food"
        : request.url === "/im"
          ? "instamart"
          : null;
      if (!service) {
        sendJson(response, 404, { error: "Route not found." }, sessionId);
        return;
      }

      try {
        validateRpcRequest(body);
      } catch (error) {
        sendJson(response, 400, rpcError(body?.id, -32600, error.message), sessionId);
        return;
      }

      const toolName = body.method === "tools/call" ? body.params?.name : body.method;
      const delay = deterministicLatencyMs(`${service}:${toolName}`) * latencyScale;
      if (delay > 0) await wait(delay);

      const currentState = sessions.get(sessionId);
      if (currentState.scenario === "serverUnavailable" && body.method === "tools/call") {
        sendJson(response, 503, rpcError(
          body.id,
          -32001,
          `${service === "food" ? "Food" : "Instamart"} demo service is unavailable.`,
          { code: "SERVER_UNAVAILABLE", retryable: true },
        ), sessionId);
        return;
      }

      if (body.method === "initialize") {
        sendJson(response, 200, rpcSuccess(body.id, {
          protocolVersion: body.params?.protocolVersion ?? "2025-06-18",
          capabilities: { tools: { listChanged: false } },
          serverInfo: {
            name: `fitorder-${service}-demo`,
            version: "2.0.0",
          },
          instructions: "Seeded localhost commerce data. No real orders or personal data.",
        }), sessionId);
        return;
      }

      if (body.method === "notifications/initialized") {
        response.writeHead(202, {
          "Mcp-Session-Id": sessionId,
          "Access-Control-Allow-Origin": "*",
        });
        response.end();
        return;
      }

      if (body.method === "tools/list") {
        sendJson(response, 200, rpcSuccess(body.id, {
          tools: service === "food"
            ? FOOD_TOOL_DEFINITIONS
            : INSTAMART_TOOL_DEFINITIONS,
        }), sessionId);
        return;
      }

      if (body.method !== "tools/call") {
        sendJson(response, 404, rpcError(
          body.id,
          -32601,
          `Method not found: ${body.method}.`,
        ), sessionId);
        return;
      }

      const name = body.params?.name;
      const args = body.params?.arguments ?? {};
      if (typeof name !== "string") {
        sendJson(response, 400, rpcError(
          body.id,
          -32602,
          "tools/call requires params.name.",
        ), sessionId);
        return;
      }

      try {
        const payload = service === "food"
          ? handleFoodTool(currentState, name, args)
          : handleInstamartTool(currentState, name, args);
        sendJson(response, 200, rpcSuccess(body.id, toolResult(payload)), sessionId);
      } catch (error) {
        const normalized = error instanceof ToolError
          ? error
          : new ToolError("INTERNAL_TOOL_ERROR", "The demo tool failed.", {}, true);
        if (normalized.code === "ORDER_STATUS_UNKNOWN") {
          sendJson(response, 503, rpcError(
            body.id,
            -32002,
            normalized.message,
            {
              code: normalized.code,
              retryable: normalized.retryable,
              ...normalized.details,
            },
          ), sessionId);
          return;
        }
        sendJson(response, 200, rpcSuccess(body.id, toolErrorResult(normalized)), sessionId);
      }
    } catch (error) {
      sendJson(response, 400, {
        error: error.message ?? "Invalid request.",
      }, sessionId);
    }
  });

  return {
    server,
    sessions,
    async start() {
      if (server.listening) return server.address();
      await new Promise((resolve, reject) => {
        server.once("error", reject);
        server.listen(port, host, () => {
          server.off("error", reject);
          resolve();
        });
      });
      return server.address();
    },
    async stop() {
      if (!server.listening) return;
      await new Promise((resolve, reject) => {
        server.close((error) => error ? reject(error) : resolve());
      });
    },
  };
}

async function runFromCommandLine() {
  const demoServer = createDemoServer();
  const address = await demoServer.start();
  console.log(`FitOrder demo MCP server listening on http://${address.address}:${address.port}`);
  console.log("Food: /food · Instamart: /im · Reset: /demo/reset");

  const shutdown = async () => {
    await demoServer.stop();
    process.exit(0);
  };
  process.once("SIGINT", shutdown);
  process.once("SIGTERM", shutdown);
}

const isMain = process.argv[1]
  && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url));
if (isMain) {
  runFromCommandLine().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
