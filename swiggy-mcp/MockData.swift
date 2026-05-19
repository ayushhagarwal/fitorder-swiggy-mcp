import Foundation

enum MockData {
    static let goals = ["Muscle Gain", "Fat Loss", "Pre-workout", "Post-workout"]
    static let diets = ["Vegetarian", "Eggetarian", "High-protein veg", "Balanced"]
    static let cuisines = ["North Indian", "South Indian", "Bowl/Salad", "Any"]
    static let budgets = ["Under ₹250", "Under ₹400", "Under ₹600"]
    static let proteinTargets = ["25g+", "35g+", "45g+"]
    static let calorieTargets = ["400-600 kcal", "600-800 kcal", "800+ kcal"]

    static let defaultPreferences = FitnessPreferences(
        goal: "Post-workout",
        diet: "High-protein veg",
        cuisine: "Bowl/Salad",
        budget: "Under ₹400",
        proteinTarget: "35g+",
        calories: "600-800 kcal"
    )

    static let meals: [MealRecommendation] = [
        MealRecommendation(
            id: "paneer-protein-bowl",
            name: "Paneer Protein Bowl",
            restaurant: "GreenFuel Kitchen",
            price: 289,
            deliveryMinutes: 28,
            rating: 4.5,
            protein: 38,
            calories: 620,
            carbs: 58,
            fat: 22,
            tags: ["High Protein", "Veg", "Post-workout"],
            why: "Closest match to your 35g+ protein target while staying under budget.",
            mcpFlow: ["search_menu", "update_food_cart", "apply_food_coupon"]
        ),
        MealRecommendation(
            id: "dal-roti-curd",
            name: "Dal Tadka + 2 Tandoori Roti + Curd",
            restaurant: "Homestyle North",
            price: 239,
            deliveryMinutes: 31,
            rating: 4.3,
            protein: 26,
            calories: 560,
            carbs: 72,
            fat: 14,
            tags: ["Balanced", "Budget", "Comfort"],
            why: "Budget-friendly balanced meal with good carbs and moderate protein.",
            mcpFlow: ["search_restaurants", "get_restaurant_menu", "update_food_cart"]
        ),
        MealRecommendation(
            id: "tofu-millet-bowl",
            name: "Tofu Millet Bowl",
            restaurant: "Urban Bowl Co.",
            price: 349,
            deliveryMinutes: 34,
            rating: 4.6,
            protein: 32,
            calories: 590,
            carbs: 52,
            fat: 19,
            tags: ["Clean", "Bowl", "Fitness"],
            why: "Clean bowl option with steady carbs and strong protein density.",
            mcpFlow: ["search_menu", "update_food_cart"]
        )
    ]

    static let curdAddon = CartAddon(
        name: "High-protein curd side",
        price: 59,
        protein: 11,
        calories: 90,
        carbs: 6,
        fat: 3
    )

    static let dishOptions = ["Paneer Bhurji", "Protein Dosa", "Oats Banana Smoothie", "Chickpea Salad Bowl"]
    static let groceryDiets = ["Vegetarian", "High protein", "Budget"]

    static func groceryPlan(dish: String, diet: String) -> GroceryPlan {
        GroceryPlan(
            id: "\(dish)-\(diet)",
            dish: dish,
            diet: diet,
            items: [
                GroceryItem(name: "High Protein Paneer 200g", price: 95),
                GroceryItem(name: "Onion 500g", price: 32),
                GroceryItem(name: "Tomato 500g", price: 38),
                GroceryItem(name: "Capsicum 250g", price: 45),
                GroceryItem(name: "Ginger Garlic Paste", price: 35),
                GroceryItem(name: "Turmeric Powder", price: 28),
                GroceryItem(name: "Jeera", price: 25),
                GroceryItem(name: "Curd 200g", price: 35)
            ],
            deliveryMinutes: 18,
            proteinEstimate: 45,
            serves: 2,
            mcpFlow: ["get_addresses", "search_products", "update_cart", "checkout"]
        )
    }

    static let events = ["10K Run", "Marathon", "HYROX", "Swimming Competition", "Long Ride"]
    static let eventDates = ["Tomorrow", "In 3 days", "This weekend"]
    static let eventGoals = ["Carb load", "Hydration", "Race morning fuel", "Recovery"]

    static let trainingGoalTypes = [
        "HYROX",
        "10K Run",
        "Marathon",
        "Swimming Competition",
        "Long Ride",
        "Strength Training Cut",
        "Muscle Gain Phase",
        "General Fat Loss"
    ]
    static let trainingTimelines = ["In 2 weeks", "In 1 month", "In 2 months", "In 3 months"]
    static let trainingFrequencies = ["3 days/week", "4 days/week", "5 days/week", "6 days/week"]
    static let goalDietPreferences = ["Vegetarian", "Eggetarian", "High-protein veg", "Balanced"]
    static let dailyBudgets = ["₹250/day", "₹400/day", "₹600/day", "Flexible"]
    static let targetDirections = ["Lean down", "Maintain + perform", "Gain muscle", "General fat loss"]

    static let activeTrainingGoal = TrainingGoal(
        id: "active-hyrox",
        goalType: "HYROX",
        timeline: "In 2 months",
        currentWeight: 74,
        targetDirection: "Lean down",
        trainingFrequency: "5 days/week",
        dietPreference: "High-protein veg",
        budget: "₹400/day",
        startDay: 3
    )

    static func eventPlan(event: String, date: String, goal: String) -> EventPrepPlan {
        EventPrepPlan(
            id: "\(event)-\(date)-\(goal)",
            event: event,
            date: date,
            goal: goal,
            timeline: [
                EventTimelineItem(
                    time: "Tonight",
                    title: "Light carb dinner",
                    detail: "Veg Khichdi + Curd",
                    commerceLabel: "Suggested Swiggy Food",
                    price: 219,
                    macros: "520 kcal · easy digestion"
                ),
                EventTimelineItem(
                    time: "Race Morning",
                    title: "Instamart essentials",
                    detail: "Banana x 6, electrolyte sachets, peanut butter, bread, water bottle",
                    commerceLabel: "Groceries via Instamart",
                    price: 286,
                    macros: "Fast carbs · hydration"
                ),
                EventTimelineItem(
                    time: "Post Race",
                    title: "Recovery meal",
                    detail: "Paneer Rice Bowl",
                    commerceLabel: "Suggested Swiggy Food",
                    price: 289,
                    macros: "38g protein"
                )
            ],
            prepCarts: [
                PrepCart(name: "Food cart", price: 219, icon: "fork.knife"),
                PrepCart(name: "Instamart cart", price: 286, icon: "cart.fill"),
                PrepCart(name: "Recovery meal", price: 289, icon: "bolt.fill")
            ],
            foodFlow: ["search_menu", "update_food_cart"],
            instamartFlow: ["search_products", "update_cart"],
            trackingFlow: ["track_food_order", "track_order"]
        )
    }

    static func trainingGoal(
        goalType: String,
        timeline: String,
        currentWeight: Int,
        targetDirection: String,
        trainingFrequency: String,
        dietPreference: String,
        budget: String
    ) -> TrainingGoal {
        TrainingGoal(
            id: "\(goalType)-\(timeline)-\(currentWeight)-\(targetDirection)-\(trainingFrequency)-\(dietPreference)-\(budget)",
            goalType: goalType,
            timeline: timeline,
            currentWeight: currentWeight,
            targetDirection: targetDirection,
            trainingFrequency: trainingFrequency,
            dietPreference: dietPreference,
            budget: budget,
            startDay: 3
        )
    }

    static func phases(for goal: TrainingGoal) -> [TrainingPhase] {
        let performanceFocus = goal.goalType == "Muscle Gain Phase" ? "Progressive overload + recovery" : "Strength + conditioning"
        let baseCalories = calorieTarget(for: goal)
        let protein = proteinTarget(for: goal)

        return [
            TrainingPhase(
                id: "phase-1-\(goal.id)",
                label: goal.totalDays <= 14 ? "Days 1-7" : "Weeks 1-4",
                title: goal.goalType == "Muscle Gain Phase" ? "Foundation + Protein Rhythm" : "Base + Lean Protein",
                description: "Slight calorie control, high protein, stable carbs around training.",
                target: MacroTarget(
                    protein: protein,
                    calories: baseCalories,
                    carbs: "Moderate",
                    focus: performanceFocus
                ),
                carbNote: "Moderate",
                focus: performanceFocus,
                swiggyExecution: [
                    "Lunch: High-protein veg meal",
                    "Dinner: Balanced bowl",
                    "Instamart: Weekly protein staples"
                ]
            ),
            TrainingPhase(
                id: "phase-2-\(goal.id)",
                label: goal.totalDays <= 14 ? "Days 8-12" : "Weeks 5-7",
                title: "Performance Build",
                description: "Increase carbs around hard training days while maintaining protein.",
                target: MacroTarget(
                    protein: protein + 5,
                    calories: baseCalories + 150,
                    carbs: "Higher on training days",
                    focus: "Hard session support"
                ),
                carbNote: "Higher on training days",
                focus: "Hard session support",
                swiggyExecution: [
                    "Lunch: Carb + protein bowl",
                    "Dinner: Dal, rice, curd or paneer meal",
                    "Instamart: Bananas, curd, oats, electrolytes"
                ]
            ),
            TrainingPhase(
                id: "phase-3-\(goal.id)",
                label: goal.totalDays <= 14 ? "Final 2 days" : "Final Week",
                title: "Event Week Fuel",
                description: "Prioritize easy digestion, hydration, and carb timing.",
                target: MacroTarget(
                    protein: max(protein - 10, 95),
                    calories: baseCalories + 200,
                    carbs: "Carb load + hydration",
                    focus: "Carb load + hydration"
                ),
                carbNote: "Carb load + hydration",
                focus: "Carb load + hydration",
                swiggyExecution: [
                    "Lunch: Simple rice bowl",
                    "Dinner: Easy-digestion comfort meal",
                    "Instamart: Electrolytes, bananas, bread, curd"
                ]
            )
        ]
    }

    static func todayFuelPlan(for goal: TrainingGoal) -> DailyFuelPlan {
        let phase = phases(for: goal)[0]
        let meals = [
            FuelMeal(
                id: "breakfast-dosa-\(goal.id)",
                slot: "Breakfast",
                source: .instamart,
                title: "Protein dosa kit",
                restaurant: nil,
                items: ["Dosa batter", "Paneer", "Curd", "Banana", "Coffee / milk optional"],
                price: 286,
                protein: 35,
                calories: 520,
                deliveryMinutes: 18,
                mcpMapping: ["get_addresses", "search_products", "update_cart"]
            ),
            FuelMeal(
                id: "lunch-bowl-\(goal.id)",
                slot: "Lunch",
                source: .food,
                title: "Paneer Protein Bowl",
                restaurant: "GreenFuel Kitchen",
                items: ["Paneer Protein Bowl"],
                price: 289,
                protein: 38,
                calories: 620,
                deliveryMinutes: 28,
                mcpMapping: ["search_menu", "get_restaurant_menu", "update_food_cart", "fetch_food_coupons", "apply_food_coupon"]
            ),
            FuelMeal(
                id: "dinner-dal-\(goal.id)",
                slot: "Dinner",
                source: .food,
                title: "Dal Tadka + Roti + Curd",
                restaurant: "Homestyle North",
                items: ["Dal Tadka", "2 Tandoori Roti", "Curd"],
                price: 239,
                protein: 26,
                calories: 560,
                deliveryMinutes: 31,
                mcpMapping: ["search_menu", "get_restaurant_menu", "update_food_cart", "fetch_food_coupons", "apply_food_coupon"]
            )
        ]

        return DailyFuelPlan(
            id: "today-\(goal.id)",
            goal: goal,
            phase: phase,
            meals: meals,
            progressProtein: meals.reduce(0) { $0 + $1.protein },
            estimatedDailyCost: meals.reduce(0) { $0 + $1.price }
        )
    }

    static func weeklyRefillItems(for goal: TrainingGoal) -> [GroceryCartItem] {
        var items = [
            GroceryCartItem(id: "paneer", name: "Paneer 200g", quantity: "x 4", price: 320),
            GroceryCartItem(id: "curd", name: "Greek yogurt / curd", quantity: "1 kg", price: 180),
            GroceryCartItem(id: "bananas", name: "Bananas", quantity: "12 pcs", price: 60),
            GroceryCartItem(id: "oats", name: "Oats", quantity: "1 pack", price: 145),
            GroceryCartItem(id: "peanut-butter", name: "Peanut butter", quantity: "1 jar", price: 190),
            GroceryCartItem(id: "milk", name: "Milk", quantity: "2 L", price: 120),
            GroceryCartItem(id: "carbs", name: "Rice / poha / dosa batter", quantity: "weekly pack", price: 135),
            GroceryCartItem(id: "electrolytes", name: "Electrolytes", quantity: "5 sachets", price: 100)
        ]

        if goal.dietPreference == "Eggetarian" {
            items.insert(GroceryCartItem(id: "eggs", name: "Eggs", quantity: "12 pcs", price: 96), at: 2)
        }

        return items
    }

    static func breakfastItems(for meal: FuelMeal) -> [GroceryCartItem] {
        [
            GroceryCartItem(id: "\(meal.id)-dosa", name: "Dosa batter", quantity: "1 pack", price: 75),
            GroceryCartItem(id: "\(meal.id)-paneer", name: "Paneer", quantity: "200g", price: 95),
            GroceryCartItem(id: "\(meal.id)-curd", name: "Curd", quantity: "400g", price: 58),
            GroceryCartItem(id: "\(meal.id)-banana", name: "Banana", quantity: "6 pcs", price: 42),
            GroceryCartItem(id: "\(meal.id)-milk", name: "Coffee / milk optional", quantity: "1 pack", price: 16)
        ]
    }

    static func proteinTarget(for goal: TrainingGoal) -> Int {
        switch goal.dietPreference {
        case "Balanced":
            return 125
        case "Vegetarian":
            return 120
        default:
            return 130
        }
    }

    static func calorieTarget(for goal: TrainingGoal) -> Int {
        switch goal.targetDirection {
        case "Gain muscle":
            return 2450
        case "General fat loss":
            return 1950
        default:
            return 2100
        }
    }
}
