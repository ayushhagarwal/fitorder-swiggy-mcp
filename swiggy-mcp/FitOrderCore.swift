import Foundation
import Observation

// MARK: - Demo intent and state

enum DemoPhase: String, Codable, Hashable, Sendable {
    case idle
    case understanding
    case planning
    case planReady
    case reviewing
    case refreshing
    case confirming
    case tracking
    case failed

    var isWorking: Bool {
        switch self {
        case .understanding, .planning, .refreshing, .confirming:
            return true
        case .idle, .planReady, .reviewing, .tracking, .failed:
            return false
        }
    }
}

struct FuelIntent: Codable, Hashable, Sendable {
    let originalText: String
    let event: String
    let eventTimelineDays: Int
    let diet: String
    let mealPurpose: String
    let requestedMealTime: String
    let refillDays: Int
    let budgetRupees: Int

    var timelineLabel: String {
        "\(eventTimelineDays) days"
    }

    var refillLabel: String {
        refillDays == 1 ? "One day" : "\(refillDays) days"
    }

    var budgetLabel: String {
        "Under ₹\(budgetRupees)"
    }

    var displayTokens: [String] {
        [diet, mealPurpose, requestedMealTime, refillLabel, budgetLabel]
    }
}

enum FuelPlannerError: LocalizedError, Hashable {
    case emptyPrompt
    case unsupportedPrompt(missing: [String])

    var errorDescription: String? {
        switch self {
        case .emptyPrompt:
            return "Enter a fuel-planning request first."
        case .unsupportedPrompt(let missing):
            return "FitOrder needs \(missing.joined(separator: ", ")) to prepare this demo plan."
        }
    }
}

struct DeterministicFuelPlanner: Sendable {
    static let goldenPrompt =
        "HYROX in 9 days. Plan tonight’s vegetarian recovery meal and a five-day breakfast refill under ₹900."

    func parse(_ prompt: String) throws -> FuelIntent {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw FuelPlannerError.emptyPrompt
        }

        let normalized = trimmed
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "’", with: "'")

        let event = normalized.contains("hyrox") ? "HYROX" : nil
        let eventTimeline = firstInteger(
            in: normalized,
            patterns: [
                #"(?:in|within)\s+(\d+)\s*days?"#,
                #"(\d+)\s*days?\s+(?:until|to)\s+(?:hyrox|the event)"#
            ]
        )
        let budget = firstInteger(
            in: normalized,
            patterns: [
                #"(?:under|below|within|budget(?:\s+of)?)\s*(?:rs\.?|inr|₹)?\s*(\d+)"#,
                #"(?:rs\.?|inr|₹)\s*(\d+)\s*(?:budget|maximum|max)?"#
            ]
        )

        let refillDays =
            firstInteger(
                in: normalized,
                patterns: [#"(\d+)[\s-]*day\s+(?:breakfast\s+)?refill"#]
            )
            ?? wordNumberBeforeDay(in: normalized)

        let diet = normalized.contains("vegetarian") || normalized.contains("veg ")
            ? "Vegetarian"
            : nil
        let purpose = normalized.contains("recovery") ? "Recovery" : nil
        let timing = normalized.contains("tonight") ? "Tonight" : nil

        var missing: [String] = []
        if event == nil { missing.append("an event") }
        if eventTimeline == nil { missing.append("an event timeline") }
        if diet == nil { missing.append("a diet") }
        if purpose == nil { missing.append("a meal purpose") }
        if timing == nil { missing.append("a meal time") }
        if refillDays == nil { missing.append("a refill duration") }
        if budget == nil { missing.append("a budget") }

        guard
            let event,
            let eventTimeline,
            let diet,
            let purpose,
            let timing,
            let refillDays,
            let budget
        else {
            throw FuelPlannerError.unsupportedPrompt(missing: missing)
        }

        return FuelIntent(
            originalText: trimmed,
            event: event,
            eventTimelineDays: eventTimeline,
            diet: diet,
            mealPurpose: purpose,
            requestedMealTime: timing,
            refillDays: refillDays,
            budgetRupees: budget
        )
    }

    private func firstInteger(in text: String, patterns: [String]) -> Int? {
        for pattern in patterns {
            guard
                let expression = try? NSRegularExpression(pattern: pattern),
                let match = expression.firstMatch(
                    in: text,
                    range: NSRange(text.startIndex..., in: text)
                ),
                match.numberOfRanges > 1,
                let range = Range(match.range(at: 1), in: text),
                let value = Int(text[range])
            else {
                continue
            }
            return value
        }
        return nil
    }

    private func wordNumberBeforeDay(in text: String) -> Int? {
        let values = [
            "one": 1,
            "two": 2,
            "three": 3,
            "four": 4,
            "five": 5,
            "six": 6,
            "seven": 7
        ]

        for (word, value) in values
        where text.range(of: #"\#(word)[\s-]*day\s+(?:breakfast\s+)?refill"#, options: .regularExpression) != nil {
            return value
        }
        return nil
    }
}

enum DemoScenario: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case goldenPath
    case serverUnavailable
    case cartChanged
    case ambiguousCheckout

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .goldenPath:
            return "Golden path"
        case .serverUnavailable:
            return "Server unavailable"
        case .cartChanged:
            return "Cart changes"
        case .ambiguousCheckout:
            return "Ambiguous checkout"
        }
    }
}

// MARK: - MCP tools

nonisolated enum DemoServer: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case food
    case instamart

    var id: String { rawValue }

    var endpointPath: String {
        switch self {
        case .food: return "food"
        case .instamart: return "im"
        }
    }

    var displayName: String {
        switch self {
        case .food: return "Swiggy Food"
        case .instamart: return "Instamart"
        }
    }
}

enum FoodMCPTool: String, Codable, CaseIterable, Hashable, Sendable {
    case getAddresses = "get_addresses"
    case searchMenu = "search_menu"
    case getRestaurantMenu = "get_restaurant_menu"
    case updateFoodCart = "update_food_cart"
    case fetchFoodCoupons = "fetch_food_coupons"
    case applyFoodCoupon = "apply_food_coupon"
    case getFoodCart = "get_food_cart"
    case placeFoodOrder = "place_food_order"
    case trackFoodOrder = "track_food_order"
    case getFoodOrderHistory = "get_food_order_history"
}

enum InstamartMCPTool: String, Codable, CaseIterable, Hashable, Sendable {
    case yourGoToItems = "your_go_to_items"
    case searchProducts = "search_products"
    case updateCart = "update_cart"
    case getCart = "get_cart"
    case checkout = "checkout"
    case trackOrder = "track_order"
    case getOrderHistory = "get_order_history"
}

enum ToolTraceLifecycle: String, Codable, Hashable, Sendable {
    case running
    case succeeded
    case failed
}

struct ToolTraceEvent: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let sequence: Int
    let server: DemoServer
    let toolName: String
    var lifecycle: ToolTraceLifecycle
    let startedAt: Date
    var finishedAt: Date?
    var latencyMilliseconds: Int?
    var summary: String
    var errorMessage: String?
    var maskedSessionIdentifier: String?

    var state: ToolTraceLifecycle { lifecycle }
    var friendlySummary: String { summary }

    init(
        id: String,
        sequence: Int,
        server: DemoServer,
        toolName: String,
        lifecycle: ToolTraceLifecycle = .running,
        startedAt: Date = Date(),
        finishedAt: Date? = nil,
        latencyMilliseconds: Int? = nil,
        summary: String,
        errorMessage: String? = nil,
        maskedSessionIdentifier: String? = nil
    ) {
        self.id = id
        self.sequence = sequence
        self.server = server
        self.toolName = toolName
        self.lifecycle = lifecycle
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.latencyMilliseconds = latencyMilliseconds
        self.summary = summary
        self.errorMessage = errorMessage
        self.maskedSessionIdentifier = maskedSessionIdentifier
    }
}

// MARK: - Commerce models

struct DeliveryAddressSnapshot: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let label: String
    let line1: String
    let line2: String?
    let city: String
    let isSelected: Bool

    var displayLine: String {
        [line1, line2, city]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

struct NutritionEstimateSnapshot: Codable, Hashable, Sendable {
    let proteinGrams: Int
    let calories: Int?
    let carbohydrateGrams: Int?
    let sourceLabel: String
}

struct MealCandidateSnapshot: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let restaurantID: String
    let name: String
    let restaurantName: String
    let price: Int
    let deliveryMinutes: Int
    let rating: Double
    let isVegetarian: Bool
    let nutritionEstimate: NutritionEstimateSnapshot?
}

struct GroceryCandidateSnapshot: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let name: String
    let size: String
    let price: Int
    let isAvailable: Bool
}

struct SubstitutionProposal: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let original: GroceryCandidateSnapshot
    let replacement: GroceryCandidateSnapshot
    let reason: String

    var savings: Int {
        max(original.price - replacement.price, 0)
    }
}

struct GrocerySearchSnapshot: Codable, Hashable, Sendable {
    let products: [GroceryCandidateSnapshot]
    let substitution: SubstitutionProposal?
}

struct CouponSnapshot: Codable, Hashable, Identifiable, Sendable {
    var id: String { code }

    let code: String
    let discount: Int
    let description: String
}

struct CartLineSnapshot: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let name: String
    let detail: String?
    let quantity: Int
    let unitPrice: Int
    let totalPrice: Int
    let isAvailable: Bool
    let substitutedFor: String?
    let nutritionEstimate: NutritionEstimateSnapshot?
}

struct CartSnapshot: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let service: DemoServer
    let revision: Int
    let title: String
    let merchantName: String?
    let address: DeliveryAddressSnapshot
    let items: [CartLineSnapshot]
    let subtotal: Int
    let discount: Int
    let deliveryFee: Int
    let handlingFee: Int
    let taxes: Int
    let total: Int
    let deliveryMinutes: Int
    let couponCode: String?
    let currency: String

    var savings: Int {
        max(discount, 0)
    }
}

struct OrderReceiptSnapshot: Codable, Hashable, Identifiable, Sendable {
    var id: String { orderID }

    let orderID: String
    let service: DemoServer
    let status: String
    let cartRevision: Int
    let total: Int
    let idempotencyKey: String
}

enum TrackingMilestoneState: String, Codable, Hashable, Sendable {
    case completed
    case current
    case upcoming
}

struct TrackingMilestoneSnapshot: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String?
    let state: TrackingMilestoneState
}

struct TrackingSnapshot: Codable, Hashable, Identifiable, Sendable {
    var id: String { orderID }

    let orderID: String
    let service: DemoServer
    let status: String
    let headline: String
    let etaMinutes: Int
    let milestones: [TrackingMilestoneSnapshot]
}

struct CommerceAcknowledgement: Codable, Hashable, Sendable {
    let message: String
    let cartRevision: Int?

    init(message: String, cartRevision: Int? = nil) {
        self.message = message
        self.cartRevision = cartRevision
    }
}

struct CartChangeNotice: Codable, Hashable, Identifiable, Sendable {
    var id: String {
        "\(service.rawValue)-\(previousRevision)-\(currentRevision)"
    }

    let service: DemoServer
    let previousRevision: Int
    let currentRevision: Int
    let previousTotal: Int
    let currentTotal: Int

    var amountDelta: Int {
        currentTotal - previousTotal
    }
}

struct DemoFailureState: Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let message: String
    let recoverySuggestion: String
    let isRetryable: Bool
}

// MARK: - JSON support

nonisolated enum JSONValue: Codable, Hashable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .number(Double(value))
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported JSON value"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            if value.rounded() == value,
               value <= Double(Int.max),
               value >= Double(Int.min) {
                try container.encode(Int(value))
            } else {
                try container.encode(value)
            }
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    subscript(key: String) -> JSONValue? {
        guard case .object(let object) = self else { return nil }
        return object[key]
    }

    var stringValue: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }

    var arrayValue: [JSONValue]? {
        guard case .array(let value) = self else { return nil }
        return value
    }

    static func integer(_ value: Int) -> JSONValue {
        .number(Double(value))
    }
}

nonisolated private struct JSONRPCRequest: Encodable {
    let jsonrpc = "2.0"
    let id: Int
    let method: String
    let params: JSONValue
}

nonisolated private struct JSONRPCNotification: Encodable {
    let jsonrpc = "2.0"
    let method: String
    let params: JSONValue
}

nonisolated private struct JSONRPCResponse: Decodable {
    nonisolated struct RPCError: Decodable {
        let code: Int
        let message: String
        let data: JSONValue?
    }

    let jsonrpc: String?
    let id: JSONValue?
    let result: JSONValue?
    let error: RPCError?
}

// MARK: - MCP transport

enum MCPTransportError: LocalizedError, Hashable, Sendable {
    case invalidBaseURL(String)
    case invalidHTTPResponse
    case httpStatus(code: Int, message: String?)
    case rpc(code: Int, message: String)
    case tool(code: String, message: String)
    case ambiguousToolResult(code: String, message: String)
    case missingResult
    case malformedPayload(String)
    case decoding(String)
    case timeout
    case cancelled
    case connection(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL(let value):
            return "The MCP base URL is invalid: \(value)"
        case .invalidHTTPResponse:
            return "The MCP server returned an invalid response."
        case .httpStatus(let code, let message):
            return message.map { "MCP server error \(code): \($0)" }
                ?? "MCP server returned HTTP \(code)."
        case .rpc(let code, let message):
            return "MCP tool error \(code): \(message)"
        case .tool(_, let message):
            return message
        case .ambiguousToolResult(_, let message):
            return message
        case .missingResult:
            return "The MCP response did not contain a result."
        case .malformedPayload(let message):
            return "The MCP payload is malformed: \(message)"
        case .decoding(let message):
            return "The MCP result could not be decoded: \(message)"
        case .timeout:
            return "The local MCP server took too long to respond."
        case .cancelled:
            return "The MCP request was cancelled."
        case .connection(let message):
            return "Could not reach the local MCP server. \(message)"
        }
    }

    var mayHaveCompletedOnServer: Bool {
        switch self {
        case .timeout, .invalidHTTPResponse, .connection, .ambiguousToolResult:
            return true
        case .httpStatus(let code, _):
            return code >= 500
        case .invalidBaseURL, .rpc, .tool, .missingResult, .malformedPayload,
             .decoding, .cancelled:
            return false
        }
    }
}

actor MCPTransport {
    static let fallbackBaseURL = URL(string: "http://127.0.0.1:8787")!

    static var defaultBaseURL: URL {
        guard
            let configured = ProcessInfo.processInfo.environment["MCP_BASE_URL"],
            let url = URL(string: configured),
            let scheme = url.scheme,
            ["http", "https"].contains(scheme),
            url.host != nil
        else {
            return fallbackBaseURL
        }
        return url
    }

    let baseURL: URL
    let timeout: TimeInterval

    private let session: URLSession
    private var nextRequestID = 1
    private let sharedSessionIdentifier: String
    private var sessionIdentifiers: [DemoServer: String] = [:]
    private var initializedServers: Set<DemoServer> = []

    init(
        baseURL: URL = MCPTransport.defaultBaseURL,
        timeout: TimeInterval = 12,
        session: URLSession? = nil
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.sharedSessionIdentifier =
            "fitorder-demo-\(UUID().uuidString.lowercased())"

        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = timeout
            configuration.timeoutIntervalForResource = timeout
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            self.session = URLSession(configuration: configuration)
        }
    }

    static func validatedBaseURL(_ value: String) throws -> URL {
        guard
            let url = URL(string: value),
            let scheme = url.scheme,
            ["http", "https"].contains(scheme),
            url.host != nil
        else {
            throw MCPTransportError.invalidBaseURL(value)
        }
        return url
    }

    func initialize(_ server: DemoServer) async throws {
        guard !initializedServers.contains(server) else { return }
        sessionIdentifiers[server] = sharedSessionIdentifier

        let result = try await performRPC(
            server: server,
            method: "initialize",
            params: .object([
                "protocolVersion": .string("2025-06-18"),
                "capabilities": .object([:]),
                "clientInfo": .object([
                    "name": .string("FitOrder"),
                    "version": .string("2.0")
                ])
            ]),
            includeSessionHeader: true
        )

        guard result["protocolVersion"]?.stringValue != nil else {
            throw MCPTransportError.malformedPayload(
                "initialize did not return protocolVersion"
            )
        }

        if sessionIdentifiers[server] == nil {
            sessionIdentifiers[server] = sharedSessionIdentifier
        }

        try await performNotification(
            server: server,
            method: "notifications/initialized",
            params: .object([:])
        )
        initializedServers.insert(server)
    }

    func listTools(on server: DemoServer) async throws -> JSONValue {
        try await initialize(server)
        return try await performRPC(
            server: server,
            method: "tools/list",
            params: .object([:])
        )
    }

    func call(
        tool name: String,
        on server: DemoServer,
        arguments: [String: JSONValue] = [:]
    ) async throws -> JSONValue {
        try await initialize(server)
        let result = try await performRPC(
            server: server,
            method: "tools/call",
            params: .object([
                "name": .string(name),
                "arguments": .object(arguments)
            ])
        )
        return try normalizeToolResult(result)
    }

    func resetDemo() async throws {
        try await performControlRequest(path: "demo/reset", scenario: nil)
        sessionIdentifiers.removeAll()
        initializedServers.removeAll()
        nextRequestID = 1
    }

    func setScenario(_ scenario: DemoScenario) async throws {
        try await performControlRequest(path: "demo/scenario", scenario: scenario)
    }

    func maskedSessionIdentifier(for server: DemoServer) -> String? {
        guard let identifier = sessionIdentifiers[server] else { return nil }
        guard identifier.count > 8 else { return "••••" }
        return "\(identifier.prefix(4))••••\(identifier.suffix(4))"
    }

    private func performRPC(
        server: DemoServer,
        method: String,
        params: JSONValue,
        includeSessionHeader: Bool = true
    ) async throws -> JSONValue {
        let requestID = nextRequestID
        nextRequestID += 1

        let payload = JSONRPCRequest(id: requestID, method: method, params: params)
        let data: Data
        do {
            data = try JSONEncoder().encode(payload)
        } catch {
            throw MCPTransportError.malformedPayload(error.localizedDescription)
        }

        var request = URLRequest(url: endpointURL(for: server))
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sharedSessionIdentifier, forHTTPHeaderField: "Mcp-Session-Id")
        request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
        if includeSessionHeader, let identifier = sessionIdentifiers[server] {
            request.setValue(identifier, forHTTPHeaderField: "Mcp-Session-Id")
        }

        let (responseData, response) = try await send(request)
        updateSessionIdentifier(from: response, server: server)

        let rpcResponse: JSONRPCResponse
        do {
            rpcResponse = try JSONDecoder().decode(JSONRPCResponse.self, from: responseData)
        } catch {
            throw MCPTransportError.decoding(error.localizedDescription)
        }

        if let error = rpcResponse.error {
            throw MCPTransportError.rpc(code: error.code, message: error.message)
        }
        guard let result = rpcResponse.result else {
            throw MCPTransportError.missingResult
        }
        return result
    }

    private func performNotification(
        server: DemoServer,
        method: String,
        params: JSONValue
    ) async throws {
        let payload = JSONRPCNotification(method: method, params: params)
        let data: Data
        do {
            data = try JSONEncoder().encode(payload)
        } catch {
            throw MCPTransportError.malformedPayload(error.localizedDescription)
        }

        var request = URLRequest(url: endpointURL(for: server))
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
        if let identifier = sessionIdentifiers[server] {
            request.setValue(identifier, forHTTPHeaderField: "Mcp-Session-Id")
        }

        let (_, response) = try await send(request, allowsEmptyBody: true)
        updateSessionIdentifier(from: response, server: server)
    }

    private func performControlRequest(
        path: String,
        scenario: DemoScenario?
    ) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sharedSessionIdentifier, forHTTPHeaderField: "Mcp-Session-Id")
        if let scenario {
            request.httpBody = try JSONEncoder().encode(["scenario": scenario.rawValue])
        } else {
            request.httpBody = Data("{}".utf8)
        }
        _ = try await send(request, allowsEmptyBody: true)
    }

    private func send(
        _ request: URLRequest,
        allowsEmptyBody: Bool = false
    ) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MCPTransportError.invalidHTTPResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw MCPTransportError.httpStatus(
                    code: httpResponse.statusCode,
                    message: Self.serverErrorMessage(from: data)
                )
            }

            if data.isEmpty && !allowsEmptyBody {
                throw MCPTransportError.missingResult
            }
            return (data, httpResponse)
        } catch is CancellationError {
            throw MCPTransportError.cancelled
        } catch let error as MCPTransportError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw MCPTransportError.timeout
            case .cancelled:
                throw MCPTransportError.cancelled
            default:
                throw MCPTransportError.connection(error.localizedDescription)
            }
        } catch {
            throw MCPTransportError.connection(error.localizedDescription)
        }
    }

    private static func serverErrorMessage(from data: Data) -> String? {
        guard
            !data.isEmpty,
            let payload = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            return nil
        }

        if let error = payload["error"] as? [String: Any],
           let message = error["message"] as? String {
            return message
        }
        if let message = payload["error"] as? String {
            return message
        }
        return payload["message"] as? String
    }

    private func endpointURL(for server: DemoServer) -> URL {
        baseURL.appendingPathComponent(server.endpointPath)
    }

    private func updateSessionIdentifier(
        from response: HTTPURLResponse,
        server: DemoServer
    ) {
        if let identifier = response.value(forHTTPHeaderField: "Mcp-Session-Id"),
           !identifier.isEmpty {
            sessionIdentifiers[server] = identifier
        }
    }

    private func normalizeToolResult(_ result: JSONValue) throws -> JSONValue {
        if let isError = result["isError"],
           case .bool(true) = isError {
            let structured = result["structuredContent"]
            let errorPayload = structured?["error"] ?? result["error"]
            let code = errorPayload?["code"]?.stringValue ?? "TOOL_ERROR"
            let message = errorPayload?["message"]?.stringValue
                ?? result["message"]?.stringValue
                ?? "The MCP tool reported an error."
            if case .bool(true) = errorPayload?["details"]?["mayHaveSucceeded"] {
                throw MCPTransportError.ambiguousToolResult(
                    code: code,
                    message: message
                )
            }
            throw MCPTransportError.tool(code: code, message: message)
        }

        if let structured = result["structuredContent"],
           structured != .null {
            return structured
        }

        if let text = textContent(in: result) {
            guard let data = text.data(using: .utf8) else {
                return .string(text)
            }
            if let decoded = try? JSONDecoder().decode(JSONValue.self, from: data) {
                return decoded
            }
            return .string(text)
        }

        return result
    }

    private func textContent(in result: JSONValue) -> String? {
        guard let contents = result["content"]?.arrayValue else { return nil }
        for content in contents {
            if content["type"]?.stringValue == "text",
               let text = content["text"]?.stringValue {
                return text
            }
        }
        return nil
    }
}

// MARK: - Domain client

enum SwiggyCommerceClientError: LocalizedError, Hashable, Sendable {
    case missingAddress
    case noMealMatch
    case noProducts
    case missingSubstitution
    case invalidPayload(String)
    case ambiguousPlacement(service: DemoServer, idempotencyKey: String)
    case orderNotRecovered(service: DemoServer)

    var errorDescription: String? {
        switch self {
        case .missingAddress:
            return "The seeded Home address was not returned by Swiggy MCP."
        case .noMealMatch:
            return "No matching vegetarian recovery meal was returned."
        case .noProducts:
            return "No matching breakfast products were returned."
        case .missingSubstitution:
            return "The expected in-stock substitution was not returned."
        case .invalidPayload(let detail):
            return "The Swiggy MCP result was incomplete. \(detail)"
        case .ambiguousPlacement(let service, _):
            return "\(service.displayName) may have received the order, but the response was interrupted."
        case .orderNotRecovered(let service):
            return "FitOrder could not verify the \(service.displayName) order after the interrupted response."
        }
    }
}

struct SwiggyCommerceClient: Sendable {
    let transport: MCPTransport

    init(transport: MCPTransport = MCPTransport()) {
        self.transport = transport
    }

    func resetDemo() async throws {
        try await transport.resetDemo()
    }

    func setScenario(_ scenario: DemoScenario) async throws {
        try await transport.setScenario(scenario)
    }

    func maskedSessionIdentifier(for server: DemoServer) async -> String? {
        await transport.maskedSessionIdentifier(for: server)
    }

    func resolveHomeAddress() async throws -> DeliveryAddressSnapshot {
        let payload = try await transport.call(
            tool: FoodMCPTool.getAddresses.rawValue,
            on: .food
        )
        let addresses: [DeliveryAddressSnapshot] = try decode(
            [DeliveryAddressSnapshot].self,
            from: payload,
            preferredKeys: ["addresses"]
        )
        guard let address = addresses.first(where: { $0.isSelected })
            ?? addresses.first(where: { $0.label.lowercased() == "home" })
            ?? addresses.first
        else {
            throw SwiggyCommerceClientError.missingAddress
        }
        return address
    }

    func searchRecoveryMeal(
        intent: FuelIntent,
        address: DeliveryAddressSnapshot
    ) async throws -> MealCandidateSnapshot {
        let payload = try await transport.call(
            tool: FoodMCPTool.searchMenu.rawValue,
            on: .food,
            arguments: [
                "query": .string("vegetarian paneer recovery bowl"),
                "address_id": .string(address.id),
                "diet": .string(intent.diet.lowercased()),
                "purpose": .string(intent.mealPurpose.lowercased()),
                "max_budget": .integer(intent.budgetRupees)
            ]
        )

        if let direct = try? decode(
            MealCandidateSnapshot.self,
            from: payload,
            preferredKeys: ["meal", "selected"]
        ) {
            return direct
        }

        let meals: [MealCandidateSnapshot] = try decode(
            [MealCandidateSnapshot].self,
            from: payload,
            preferredKeys: ["meals", "items", "results"]
        )
        guard let selected = meals.first(where: { $0.isVegetarian }) ?? meals.first else {
            throw SwiggyCommerceClientError.noMealMatch
        }
        return selected
    }

    func validateRestaurantMenu(
        for meal: MealCandidateSnapshot
    ) async throws -> MealCandidateSnapshot {
        let payload = try await transport.call(
            tool: FoodMCPTool.getRestaurantMenu.rawValue,
            on: .food,
            arguments: [
                "restaurant_id": .string(meal.restaurantID),
                "item_id": .string(meal.id)
            ]
        )
        if let direct = try? decode(
            MealCandidateSnapshot.self,
            from: payload,
            preferredKeys: ["meal", "item"]
        ) {
            return direct
        }
        let items: [MealCandidateSnapshot] = try decode(
            [MealCandidateSnapshot].self,
            from: payload,
            preferredKeys: ["items", "meals"]
        )
        guard let validated = items.first(where: { $0.id == meal.id }) else {
            throw SwiggyCommerceClientError.noMealMatch
        }
        return validated
    }

    func prepareFoodCart(
        meal: MealCandidateSnapshot,
        address: DeliveryAddressSnapshot
    ) async throws -> CommerceAcknowledgement {
        let payload = try await transport.call(
            tool: FoodMCPTool.updateFoodCart.rawValue,
            on: .food,
            arguments: [
                "address_id": .string(address.id),
                "restaurant_id": .string(meal.restaurantID),
                "items": .array([
                    .object([
                        "item_id": .string(meal.id),
                        "quantity": .integer(1)
                    ]),
                    .object([
                        "item_id": .string("food-curd-side"),
                        "quantity": .integer(1)
                    ])
                ])
            ]
        )
        return acknowledgement(from: payload, fallback: "Food cart prepared")
    }

    func fetchBestFoodCoupon() async throws -> CouponSnapshot {
        let payload = try await transport.call(
            tool: FoodMCPTool.fetchFoodCoupons.rawValue,
            on: .food
        )
        if let direct = try? decode(
            CouponSnapshot.self,
            from: payload,
            preferredKeys: ["coupon", "selected"]
        ) {
            return direct
        }
        let coupons: [CouponSnapshot] = try decode(
            [CouponSnapshot].self,
            from: payload,
            preferredKeys: ["coupons", "items"]
        )
        guard let best = coupons.max(by: { $0.discount < $1.discount }) else {
            throw SwiggyCommerceClientError.invalidPayload("No eligible coupon was included.")
        }
        return best
    }

    func applyFoodCoupon(_ coupon: CouponSnapshot) async throws -> CommerceAcknowledgement {
        let payload = try await transport.call(
            tool: FoodMCPTool.applyFoodCoupon.rawValue,
            on: .food,
            arguments: ["coupon_code": .string(coupon.code)]
        )
        return acknowledgement(from: payload, fallback: "\(coupon.code) applied")
    }

    func fetchFoodCart() async throws -> CartSnapshot {
        let payload = try await transport.call(
            tool: FoodMCPTool.getFoodCart.rawValue,
            on: .food
        )
        return try decode(
            CartSnapshot.self,
            from: payload,
            preferredKeys: ["cart"]
        )
    }

    func fetchFrequentlyOrdered(
        at address: DeliveryAddressSnapshot
    ) async throws -> [GroceryCandidateSnapshot] {
        let payload = try await transport.call(
            tool: InstamartMCPTool.yourGoToItems.rawValue,
            on: .instamart,
            arguments: ["address_id": .string(address.id)]
        )
        return try decode(
            [GroceryCandidateSnapshot].self,
            from: payload,
            preferredKeys: ["products", "items"]
        )
    }

    func searchBreakfastProducts(
        intent: FuelIntent,
        address: DeliveryAddressSnapshot
    ) async throws -> GrocerySearchSnapshot {
        let payload = try await transport.call(
            tool: InstamartMCPTool.searchProducts.rawValue,
            on: .instamart,
            arguments: [
                "query": .string("oats bananas electrolytes greek yogurt"),
                "address_id": .string(address.id),
                "refill_days": .integer(intent.refillDays),
                "diet": .string(intent.diet.lowercased())
            ]
        )
        let result = try decode(
            GrocerySearchSnapshot.self,
            from: payload,
            preferredKeys: ["search", "result"]
        )
        guard !result.products.isEmpty else {
            throw SwiggyCommerceClientError.noProducts
        }
        return result
    }

    func prepareInstamartCart(
        products: [GroceryCandidateSnapshot],
        address: DeliveryAddressSnapshot
    ) async throws -> CommerceAcknowledgement {
        let items = products
            .filter(\.isAvailable)
            .map { product in
                JSONValue.object([
                    "product_id": .string(product.id),
                    "quantity": .integer(1)
                ])
            }

        let payload = try await transport.call(
            tool: InstamartMCPTool.updateCart.rawValue,
            on: .instamart,
            arguments: [
                "address_id": .string(address.id),
                "operation": .string("replace"),
                "items": .array(items)
            ]
        )
        return acknowledgement(from: payload, fallback: "Instamart cart prepared")
    }

    func acceptSubstitution(
        _ proposal: SubstitutionProposal,
        address: DeliveryAddressSnapshot
    ) async throws -> CommerceAcknowledgement {
        let payload = try await transport.call(
            tool: InstamartMCPTool.updateCart.rawValue,
            on: .instamart,
            arguments: [
                "address_id": .string(address.id),
                "operation": .string("add"),
                "replace": .bool(false),
                "substitution_for": .string(proposal.original.id),
                "items": .array([
                    .object([
                        "product_id": .string(proposal.replacement.id),
                        "quantity": .integer(1)
                    ])
                ])
            ]
        )
        return acknowledgement(from: payload, fallback: "Substitution accepted")
    }

    func fetchInstamartCart() async throws -> CartSnapshot {
        let payload = try await transport.call(
            tool: InstamartMCPTool.getCart.rawValue,
            on: .instamart
        )
        return try decode(
            CartSnapshot.self,
            from: payload,
            preferredKeys: ["cart"]
        )
    }

    func placeFoodOrder(
        cart: CartSnapshot,
        idempotencyKey: String,
        acceptedCartChanges: Bool
    ) async throws -> OrderReceiptSnapshot {
        do {
            let payload = try await transport.call(
                tool: FoodMCPTool.placeFoodOrder.rawValue,
                on: .food,
                arguments: [
                    "cart_id": .string(cart.id),
                    "cart_revision": .integer(cart.revision),
                    "confirmed": .bool(true),
                    "acceptedCartChanges": .bool(acceptedCartChanges),
                    "idempotency_key": .string(idempotencyKey)
                ]
            )
            return try decode(
                OrderReceiptSnapshot.self,
                from: payload,
                preferredKeys: ["order", "receipt"]
            )
        } catch let error as MCPTransportError where error.mayHaveCompletedOnServer {
            throw SwiggyCommerceClientError.ambiguousPlacement(
                service: .food,
                idempotencyKey: idempotencyKey
            )
        }
    }

    func checkoutInstamart(
        cart: CartSnapshot,
        idempotencyKey: String,
        acceptedCartChanges: Bool
    ) async throws -> OrderReceiptSnapshot {
        do {
            let payload = try await transport.call(
                tool: InstamartMCPTool.checkout.rawValue,
                on: .instamart,
                arguments: [
                    "cart_id": .string(cart.id),
                    "cart_revision": .integer(cart.revision),
                    "confirmed": .bool(true),
                    "acceptedCartChanges": .bool(acceptedCartChanges),
                    "idempotency_key": .string(idempotencyKey)
                ]
            )
            return try decode(
                OrderReceiptSnapshot.self,
                from: payload,
                preferredKeys: ["order", "receipt"]
            )
        } catch let error as MCPTransportError where error.mayHaveCompletedOnServer {
            throw SwiggyCommerceClientError.ambiguousPlacement(
                service: .instamart,
                idempotencyKey: idempotencyKey
            )
        }
    }

    func recoverFoodOrder(idempotencyKey: String) async throws -> OrderReceiptSnapshot {
        try await recoverOrder(
            service: .food,
            tool: FoodMCPTool.getFoodOrderHistory.rawValue,
            idempotencyKey: idempotencyKey
        )
    }

    func recoverInstamartOrder(idempotencyKey: String) async throws -> OrderReceiptSnapshot {
        try await recoverOrder(
            service: .instamart,
            tool: InstamartMCPTool.getOrderHistory.rawValue,
            idempotencyKey: idempotencyKey
        )
    }

    func trackFoodOrder(orderID: String) async throws -> TrackingSnapshot {
        let payload = try await transport.call(
            tool: FoodMCPTool.trackFoodOrder.rawValue,
            on: .food,
            arguments: ["order_id": .string(orderID)]
        )
        return try decode(
            TrackingSnapshot.self,
            from: payload,
            preferredKeys: ["tracking", "order"]
        )
    }

    func trackInstamartOrder(orderID: String) async throws -> TrackingSnapshot {
        let payload = try await transport.call(
            tool: InstamartMCPTool.trackOrder.rawValue,
            on: .instamart,
            arguments: ["order_id": .string(orderID)]
        )
        return try decode(
            TrackingSnapshot.self,
            from: payload,
            preferredKeys: ["tracking", "order"]
        )
    }

    private func recoverOrder(
        service: DemoServer,
        tool: String,
        idempotencyKey: String
    ) async throws -> OrderReceiptSnapshot {
        let payload = try await transport.call(
            tool: tool,
            on: service,
            arguments: ["idempotency_key": .string(idempotencyKey)]
        )

        if let direct = try? decode(
            OrderReceiptSnapshot.self,
            from: payload,
            preferredKeys: ["order", "receipt"]
        ) {
            return direct
        }

        let orders: [OrderReceiptSnapshot] = try decode(
            [OrderReceiptSnapshot].self,
            from: payload,
            preferredKeys: ["orders", "history"]
        )
        guard let order = orders.first(where: { $0.idempotencyKey == idempotencyKey }) else {
            throw SwiggyCommerceClientError.orderNotRecovered(service: service)
        }
        return order
    }

    private func acknowledgement(
        from payload: JSONValue,
        fallback: String
    ) -> CommerceAcknowledgement {
        if let decoded = try? decode(
            CommerceAcknowledgement.self,
            from: payload,
            preferredKeys: ["acknowledgement", "result"]
        ) {
            return decoded
        }

        let message = payload["message"]?.stringValue ?? fallback
        return CommerceAcknowledgement(message: message)
    }

    private func decode<T: Decodable>(
        _ type: T.Type,
        from payload: JSONValue,
        preferredKeys: [String]
    ) throws -> T {
        var candidates: [JSONValue] = []
        for key in preferredKeys {
            if let nested = payload[key] {
                candidates.append(nested)
            }
        }
        if let data = payload["data"] {
            candidates.append(data)
        }
        candidates.append(payload)

        var finalError: Error?
        for candidate in candidates {
            do {
                let data = try JSONEncoder().encode(candidate)
                return try JSONDecoder().decode(type, from: data)
            } catch {
                finalError = error
            }
        }

        throw MCPTransportError.decoding(
            finalError?.localizedDescription ?? "Unknown payload shape"
        )
    }
}

// MARK: - Demo session orchestration

@MainActor
@Observable
final class DemoSession {
    private enum RetryAction: Hashable {
        case reset
        case scenario(DemoScenario)
        case planning(String)
        case substitution
        case refresh
        case confirmation
        case tracking
    }

    private struct PlanBuildResult {
        let meal: MealCandidateSnapshot
        let groceries: GrocerySearchSnapshot
        let frequentlyOrdered: [GroceryCandidateSnapshot]
        let foodCart: CartSnapshot
        let instamartCart: CartSnapshot
        let coupon: CouponSnapshot
    }

    private(set) var phase: DemoPhase = .idle
    private(set) var prompt = DeterministicFuelPlanner.goldenPrompt
    private(set) var intent: FuelIntent?
    private(set) var address: DeliveryAddressSnapshot?
    private(set) var recommendedMeal: MealCandidateSnapshot?
    private(set) var groceryProducts: [GroceryCandidateSnapshot] = []
    private(set) var frequentlyOrderedProducts: [GroceryCandidateSnapshot] = []
    private(set) var appliedCoupon: CouponSnapshot?
    private(set) var substitutionProposal: SubstitutionProposal?
    private(set) var hasAcceptedSubstitution = false
    private(set) var foodCart: CartSnapshot?
    private(set) var instamartCart: CartSnapshot?
    private(set) var foodOrder: OrderReceiptSnapshot?
    private(set) var instamartOrder: OrderReceiptSnapshot?
    private(set) var foodTracking: TrackingSnapshot?
    private(set) var instamartTracking: TrackingSnapshot?
    private(set) var toolTrace: [ToolTraceEvent] = []
    private(set) var cartChanges: [CartChangeNotice] = []
    private(set) var cartsAreAuthoritative = false
    private(set) var requiresCartReconfirmation = false
    private(set) var hasAcceptedCartChanges = false
    private(set) var failure: DemoFailureState?
    private(set) var scenario: DemoScenario = .goldenPath

    @ObservationIgnored private let planner: DeterministicFuelPlanner
    @ObservationIgnored private let client: SwiggyCommerceClient
    @ObservationIgnored private var traceSequence = 0
    @ObservationIgnored private var retryAction: RetryAction?

    convenience init() {
        self.init(
            planner: DeterministicFuelPlanner(),
            client: SwiggyCommerceClient()
        )
    }

    init(
        planner: DeterministicFuelPlanner,
        client: SwiggyCommerceClient
    ) {
        self.planner = planner
        self.client = client
    }

    var combinedTotal: Int {
        (foodCart?.total ?? 0) + (instamartCart?.total ?? 0)
    }

    var remainingBudget: Int? {
        guard let intent else { return nil }
        return intent.budgetRupees - combinedTotal
    }

    var isWithinBudget: Bool {
        guard let intent else { return false }
        return combinedTotal <= intent.budgetRupees
    }

    var canReview: Bool {
        (phase == .planReady || phase == .reviewing)
            && foodCart != nil
            && instamartCart != nil
            && (substitutionProposal == nil || hasAcceptedSubstitution)
    }

    var canConfirm: Bool {
        phase == .reviewing
            && foodCart != nil
            && instamartCart != nil
            && cartsAreAuthoritative
            && !requiresCartReconfirmation
            && (substitutionProposal == nil || hasAcceptedSubstitution)
    }

    var completedToolCount: Int {
        toolTrace.filter { $0.lifecycle == .succeeded }.count
    }

    var hasBothTrackingSnapshots: Bool {
        foodTracking != nil && instamartTracking != nil
    }

    func updatePrompt(_ value: String) {
        guard !phase.isWorking else { return }
        prompt = value
    }

    func reset() async {
        clearLocalState(keepingScenario: true)
        do {
            try await client.resetDemo()
            if scenario != .goldenPath {
                try await client.setScenario(scenario)
            }
        } catch {
            fail(
                error,
                title: "Local demo server unavailable",
                suggestion: "Start the FitOrder MCP stub on port 8787, then retry.",
                retry: .reset
            )
        }
    }

    func setDebugScenario(_ newScenario: DemoScenario) async {
        scenario = newScenario
        clearLocalState(keepingScenario: true)
        do {
            try await client.resetDemo()
            try await client.setScenario(newScenario)
        } catch {
            fail(
                error,
                title: "Couldn’t configure the demo",
                suggestion: "Verify the local MCP stub is running, then retry.",
                retry: .scenario(newScenario)
            )
        }
    }

    func planFuel() async {
        await planFuel(prompt: prompt)
    }

    func planFuel(prompt newPrompt: String) async {
        guard !phase.isWorking else { return }
        clearPlanResult()
        prompt = newPrompt
        phase = .understanding

        do {
            let parsedIntent = try planner.parse(newPrompt)
            intent = parsedIntent

            try await client.resetDemo()
            if scenario != .goldenPath {
                try await client.setScenario(scenario)
            }

            phase = .planning
            let resolvedAddress: DeliveryAddressSnapshot = try await traced(
                server: .food,
                tool: FoodMCPTool.getAddresses.rawValue,
                runningSummary: "Resolving seeded Home address",
                successSummary: { "Selected \($0.label) · \($0.city)" },
                operation: { try await self.client.resolveHomeAddress() }
            )
            address = resolvedAddress

            async let foodResult = buildFoodPlan(
                intent: parsedIntent,
                address: resolvedAddress
            )
            async let groceryResult = buildInstamartPlan(
                intent: parsedIntent,
                address: resolvedAddress
            )

            let (food, grocery) = try await (foodResult, groceryResult)
            let result = PlanBuildResult(
                meal: food.meal,
                groceries: grocery.search,
                frequentlyOrdered: grocery.frequentlyOrdered,
                foodCart: food.cart,
                instamartCart: grocery.cart,
                coupon: food.coupon
            )

            recommendedMeal = result.meal
            groceryProducts = result.groceries.products
            frequentlyOrderedProducts = result.frequentlyOrdered
            substitutionProposal = result.groceries.substitution
            hasAcceptedSubstitution = result.groceries.substitution == nil
            foodCart = result.foodCart
            instamartCart = result.instamartCart
            appliedCoupon = result.coupon
            cartsAreAuthoritative = false
            phase = .planReady
            failure = nil
            retryAction = nil
        } catch {
            fail(
                error,
                title: "Couldn’t build your fuel plan",
                suggestion: "Check the local MCP server and try the seeded request again.",
                retry: .planning(newPrompt)
            )
        }
    }

    func acceptProposedSubstitution() async {
        guard
            phase == .planReady,
            !hasAcceptedSubstitution,
            let proposal = substitutionProposal,
            let address
        else {
            return
        }

        do {
            _ = try await traced(
                server: .instamart,
                tool: InstamartMCPTool.updateCart.rawValue,
                runningSummary: "Replacing unavailable Greek yogurt",
                successSummary: { $0.message },
                operation: {
                    try await self.client.acceptSubstitution(
                        proposal,
                        address: address
                    )
                }
            ) as CommerceAcknowledgement

            let refreshed: CartSnapshot = try await traced(
                server: .instamart,
                tool: InstamartMCPTool.getCart.rawValue,
                runningSummary: "Refreshing Instamart total",
                successSummary: { "\($0.items.count) items · ₹\($0.total)" },
                operation: { try await self.client.fetchInstamartCart() }
            )

            instamartCart = refreshed
            hasAcceptedSubstitution = true
            cartsAreAuthoritative = false
            failure = nil
            retryAction = nil
        } catch {
            fail(
                error,
                title: "Couldn’t apply the smart swap",
                suggestion: "Retry the substitution before reviewing the carts.",
                retry: .substitution,
                fallbackPhase: .planReady
            )
        }
    }

    func beginReview() async {
        guard canReview else { return }
        guard phase != .reviewing else { return }
        phase = .reviewing
        await refreshCartsForConfirmation()
    }

    func refreshCartsForConfirmation() async {
        guard
            phase == .reviewing || phase == .failed,
            let previousFood = foodCart,
            let previousInstamart = instamartCart
        else {
            return
        }

        phase = .refreshing
        cartsAreAuthoritative = false
        requiresCartReconfirmation = false
        hasAcceptedCartChanges = false
        cartChanges = []

        do {
            async let latestFood: CartSnapshot = traced(
                server: .food,
                tool: FoodMCPTool.getFoodCart.rawValue,
                runningSummary: "Refreshing authoritative Food cart",
                successSummary: { "\($0.items.count) items · ₹\($0.total)" },
                operation: { try await self.client.fetchFoodCart() }
            )
            async let latestInstamart: CartSnapshot = traced(
                server: .instamart,
                tool: InstamartMCPTool.getCart.rawValue,
                runningSummary: "Refreshing authoritative Instamart cart",
                successSummary: { "\($0.items.count) items · ₹\($0.total)" },
                operation: { try await self.client.fetchInstamartCart() }
            )

            let (newFood, newInstamart) = try await (latestFood, latestInstamart)
            foodCart = newFood
            instamartCart = newInstamart

            cartChanges = [
                changeNotice(previous: previousFood, current: newFood),
                changeNotice(previous: previousInstamart, current: newInstamart)
            ].compactMap { $0 }

            phase = .reviewing
            if cartChanges.isEmpty {
                cartsAreAuthoritative = true
                hasAcceptedCartChanges = false
            } else {
                requiresCartReconfirmation = true
            }
            failure = nil
            retryAction = nil
        } catch {
            fail(
                error,
                title: "Cart refresh failed",
                suggestion: "Both carts must be refreshed before confirmation.",
                retry: .refresh,
                fallbackPhase: .reviewing
            )
        }
    }

    func acceptRefreshedCartChanges() {
        guard
            phase == .reviewing,
            requiresCartReconfirmation,
            !cartChanges.isEmpty
        else {
            return
        }
        requiresCartReconfirmation = false
        cartsAreAuthoritative = true
        hasAcceptedCartChanges = true
        cartChanges = []
    }

    func confirmOrders() async {
        guard canConfirm, let foodCart, let instamartCart else { return }
        phase = .confirming
        cartsAreAuthoritative = false

        let foodKey = idempotencyKey(for: .food, cart: foodCart)
        let instamartKey = idempotencyKey(for: .instamart, cart: instamartCart)

        do {
            if foodOrder == nil {
                foodOrder = try await placeFoodOrder(
                    cart: foodCart,
                    idempotencyKey: foodKey
                )
            }
            if instamartOrder == nil {
                instamartOrder = try await placeInstamartOrder(
                    cart: instamartCart,
                    idempotencyKey: instamartKey
                )
            }

            phase = .tracking
            failure = nil
            retryAction = nil
            await refreshTracking()
        } catch {
            fail(
                error,
                title: "We couldn’t verify both demo orders",
                suggestion: "Retry safely. FitOrder will not duplicate a verified order.",
                retry: .confirmation,
                fallbackPhase: .reviewing
            )
        }
    }

    func refreshTracking() async {
        guard let foodOrder, let instamartOrder else { return }
        phase = .tracking

        do {
            async let food: TrackingSnapshot = traced(
                server: .food,
                tool: FoodMCPTool.trackFoodOrder.rawValue,
                runningSummary: "Checking Food order",
                successSummary: { $0.headline },
                operation: {
                    try await self.client.trackFoodOrder(orderID: foodOrder.orderID)
                }
            )
            async let instamart: TrackingSnapshot = traced(
                server: .instamart,
                tool: InstamartMCPTool.trackOrder.rawValue,
                runningSummary: "Checking Instamart order",
                successSummary: { $0.headline },
                operation: {
                    try await self.client.trackInstamartOrder(
                        orderID: instamartOrder.orderID
                    )
                }
            )

            let (foodSnapshot, instamartSnapshot) = try await (food, instamart)
            foodTracking = foodSnapshot
            instamartTracking = instamartSnapshot
            failure = nil
            retryAction = nil
        } catch {
            fail(
                error,
                title: "Tracking is temporarily unavailable",
                suggestion: "The demo orders are safe. Retry tracking when the stub responds.",
                retry: .tracking,
                fallbackPhase: .tracking
            )
        }
    }

    func retryLastAction() async {
        guard let retryAction else { return }
        failure = nil

        switch retryAction {
        case .reset:
            await reset()
        case .scenario(let scenario):
            await setDebugScenario(scenario)
        case .planning(let prompt):
            phase = .idle
            await planFuel(prompt: prompt)
        case .substitution:
            phase = .planReady
            await acceptProposedSubstitution()
        case .refresh:
            phase = .reviewing
            await refreshCartsForConfirmation()
        case .confirmation:
            phase = .reviewing
            cartsAreAuthoritative = true
            requiresCartReconfirmation = false
            await confirmOrders()
        case .tracking:
            phase = .tracking
            await refreshTracking()
        }
    }

    private func buildFoodPlan(
        intent: FuelIntent,
        address: DeliveryAddressSnapshot
    ) async throws -> (
        meal: MealCandidateSnapshot,
        cart: CartSnapshot,
        coupon: CouponSnapshot
    ) {
        let searched: MealCandidateSnapshot = try await traced(
            server: .food,
            tool: FoodMCPTool.searchMenu.rawValue,
            runningSummary: "Matching a vegetarian recovery dinner",
            successSummary: { "\($0.name) · \($0.deliveryMinutes) min" },
            operation: {
                try await self.client.searchRecoveryMeal(
                    intent: intent,
                    address: address
                )
            }
        )

        let validated: MealCandidateSnapshot = try await traced(
            server: .food,
            tool: FoodMCPTool.getRestaurantMenu.rawValue,
            runningSummary: "Validating menu and availability",
            successSummary: { "\($0.name) is available" },
            operation: {
                try await self.client.validateRestaurantMenu(for: searched)
            }
        )

        _ = try await traced(
            server: .food,
            tool: FoodMCPTool.updateFoodCart.rawValue,
            runningSummary: "Building a separate Food cart",
            successSummary: { $0.message },
            operation: {
                try await self.client.prepareFoodCart(
                    meal: validated,
                    address: address
                )
            }
        ) as CommerceAcknowledgement

        let coupon: CouponSnapshot = try await traced(
            server: .food,
            tool: FoodMCPTool.fetchFoodCoupons.rawValue,
            runningSummary: "Checking eligible Food savings",
            successSummary: { "\($0.code) saves ₹\($0.discount)" },
            operation: { try await self.client.fetchBestFoodCoupon() }
        )

        _ = try await traced(
            server: .food,
            tool: FoodMCPTool.applyFoodCoupon.rawValue,
            runningSummary: "Applying the best coupon",
            successSummary: { $0.message },
            operation: { try await self.client.applyFoodCoupon(coupon) }
        ) as CommerceAcknowledgement

        let cart: CartSnapshot = try await traced(
            server: .food,
            tool: FoodMCPTool.getFoodCart.rawValue,
            runningSummary: "Reading authoritative Food cart",
            successSummary: { "\($0.items.count) items · ₹\($0.total)" },
            operation: { try await self.client.fetchFoodCart() }
        )

        return (validated, cart, coupon)
    }

    private func buildInstamartPlan(
        intent: FuelIntent,
        address: DeliveryAddressSnapshot
    ) async throws -> (
        search: GrocerySearchSnapshot,
        frequentlyOrdered: [GroceryCandidateSnapshot],
        cart: CartSnapshot
    ) {
        let frequentlyOrdered: [GroceryCandidateSnapshot] = try await traced(
            server: .instamart,
            tool: InstamartMCPTool.yourGoToItems.rawValue,
            runningSummary: "Checking frequently ordered staples",
            successSummary: { "\($0.count) familiar products found" },
            operation: {
                try await self.client.fetchFrequentlyOrdered(at: address)
            }
        )

        let search: GrocerySearchSnapshot = try await traced(
            server: .instamart,
            tool: InstamartMCPTool.searchProducts.rawValue,
            runningSummary: "Finding a five-day breakfast refill",
            successSummary: {
                let stockMessage = $0.substitution == nil
                    ? "all available"
                    : "1 smart swap proposed"
                return "\($0.products.count) products · \(stockMessage)"
            },
            operation: {
                try await self.client.searchBreakfastProducts(
                    intent: intent,
                    address: address
                )
            }
        )

        let replacementID = search.substitution?.replacement.id
        let originalID = search.substitution?.original.id
        let initialProducts = search.products.filter {
            $0.id != replacementID && $0.id != originalID && $0.isAvailable
        }

        _ = try await traced(
            server: .instamart,
            tool: InstamartMCPTool.updateCart.rawValue,
            runningSummary: "Building a separate Instamart cart",
            successSummary: { $0.message },
            operation: {
                try await self.client.prepareInstamartCart(
                    products: initialProducts,
                    address: address
                )
            }
        ) as CommerceAcknowledgement

        let cart: CartSnapshot = try await traced(
            server: .instamart,
            tool: InstamartMCPTool.getCart.rawValue,
            runningSummary: "Reading authoritative Instamart cart",
            successSummary: { "\($0.items.count) available items · ₹\($0.total)" },
            operation: { try await self.client.fetchInstamartCart() }
        )

        return (search, frequentlyOrdered, cart)
    }

    private func placeFoodOrder(
        cart: CartSnapshot,
        idempotencyKey: String
    ) async throws -> OrderReceiptSnapshot {
        do {
            return try await traced(
                server: .food,
                tool: FoodMCPTool.placeFoodOrder.rawValue,
                runningSummary: "Placing confirmed Food demo order",
                successSummary: { "Order \($0.orderID) confirmed" },
                operation: {
                    try await self.client.placeFoodOrder(
                        cart: cart,
                        idempotencyKey: idempotencyKey,
                        acceptedCartChanges: self.hasAcceptedCartChanges
                    )
                }
            )
        } catch SwiggyCommerceClientError.ambiguousPlacement {
            return try await traced(
                server: .food,
                tool: FoodMCPTool.getFoodOrderHistory.rawValue,
                runningSummary: "Verifying interrupted Food response",
                successSummary: { "Recovered order \($0.orderID)" },
                operation: {
                    try await self.client.recoverFoodOrder(
                        idempotencyKey: idempotencyKey
                    )
                }
            )
        }
    }

    private func placeInstamartOrder(
        cart: CartSnapshot,
        idempotencyKey: String
    ) async throws -> OrderReceiptSnapshot {
        do {
            return try await traced(
                server: .instamart,
                tool: InstamartMCPTool.checkout.rawValue,
                runningSummary: "Checking out confirmed Instamart demo order",
                successSummary: { "Order \($0.orderID) confirmed" },
                operation: {
                    try await self.client.checkoutInstamart(
                        cart: cart,
                        idempotencyKey: idempotencyKey,
                        acceptedCartChanges: self.hasAcceptedCartChanges
                    )
                }
            )
        } catch SwiggyCommerceClientError.ambiguousPlacement {
            return try await traced(
                server: .instamart,
                tool: InstamartMCPTool.getOrderHistory.rawValue,
                runningSummary: "Verifying interrupted Instamart response",
                successSummary: { "Recovered order \($0.orderID)" },
                operation: {
                    try await self.client.recoverInstamartOrder(
                        idempotencyKey: idempotencyKey
                    )
                }
            )
        }
    }

    private func traced<T>(
        server: DemoServer,
        tool: String,
        runningSummary: String,
        successSummary: (T) -> String,
        operation: () async throws -> T
    ) async throws -> T {
        traceSequence += 1
        let sequence = traceSequence
        let eventID = "\(String(format: "%02d", sequence))-\(server.rawValue)-\(tool)"
        let startedAt = Date()
        let maskedSession = await client.maskedSessionIdentifier(for: server)

        toolTrace.append(
            ToolTraceEvent(
                id: eventID,
                sequence: sequence,
                server: server,
                toolName: tool,
                startedAt: startedAt,
                summary: runningSummary,
                maskedSessionIdentifier: maskedSession
            )
        )

        do {
            let result = try await operation()
            let finishedAt = Date()
            updateTrace(
                id: eventID,
                lifecycle: .succeeded,
                finishedAt: finishedAt,
                summary: successSummary(result),
                errorMessage: nil,
                maskedSessionIdentifier: await client.maskedSessionIdentifier(for: server),
                startedAt: startedAt
            )
            return result
        } catch {
            let finishedAt = Date()
            updateTrace(
                id: eventID,
                lifecycle: .failed,
                finishedAt: finishedAt,
                summary: "Action needs attention",
                errorMessage: error.localizedDescription,
                maskedSessionIdentifier: await client.maskedSessionIdentifier(for: server),
                startedAt: startedAt
            )
            throw error
        }
    }

    private func updateTrace(
        id: String,
        lifecycle: ToolTraceLifecycle,
        finishedAt: Date,
        summary: String,
        errorMessage: String?,
        maskedSessionIdentifier: String?,
        startedAt: Date
    ) {
        guard let index = toolTrace.firstIndex(where: { $0.id == id }) else { return }
        toolTrace[index].lifecycle = lifecycle
        toolTrace[index].finishedAt = finishedAt
        toolTrace[index].latencyMilliseconds = max(
            Int(finishedAt.timeIntervalSince(startedAt) * 1_000),
            0
        )
        toolTrace[index].summary = summary
        toolTrace[index].errorMessage = errorMessage
        toolTrace[index].maskedSessionIdentifier = maskedSessionIdentifier
    }

    private func changeNotice(
        previous: CartSnapshot,
        current: CartSnapshot
    ) -> CartChangeNotice? {
        guard previous != current else { return nil }
        return CartChangeNotice(
            service: current.service,
            previousRevision: previous.revision,
            currentRevision: current.revision,
            previousTotal: previous.total,
            currentTotal: current.total
        )
    }

    private func idempotencyKey(
        for service: DemoServer,
        cart: CartSnapshot
    ) -> String {
        "fitorder-\(service.rawValue)-\(cart.id)-r\(cart.revision)"
    }

    private func fail(
        _ error: Error,
        title: String,
        suggestion: String,
        retry: RetryAction?,
        fallbackPhase: DemoPhase = .failed
    ) {
        phase = fallbackPhase == .failed ? .failed : fallbackPhase
        failure = DemoFailureState(
            id: "\(title)-\(toolTrace.count)",
            title: title,
            message: error.localizedDescription,
            recoverySuggestion: suggestion,
            isRetryable: retry != nil
        )
        retryAction = retry
    }

    private func clearPlanResult() {
        intent = nil
        address = nil
        recommendedMeal = nil
        groceryProducts = []
        frequentlyOrderedProducts = []
        appliedCoupon = nil
        substitutionProposal = nil
        hasAcceptedSubstitution = false
        foodCart = nil
        instamartCart = nil
        foodOrder = nil
        instamartOrder = nil
        foodTracking = nil
        instamartTracking = nil
        toolTrace = []
        cartChanges = []
        cartsAreAuthoritative = false
        requiresCartReconfirmation = false
        hasAcceptedCartChanges = false
        failure = nil
        traceSequence = 0
        retryAction = nil
    }

    private func clearLocalState(keepingScenario: Bool) {
        phase = .idle
        prompt = DeterministicFuelPlanner.goldenPrompt
        clearPlanResult()
        if !keepingScenario {
            scenario = .goldenPath
        }
    }
}
