# 📄 Product Requirements Document

## **CalTab — On-Device Calorie Tracking App**

---

## 1. Product Overview

CalTab is a **privacy-first mobile calorie tracking application** built with Flutter.
The app allows users to track daily calorie intake through scanning, search, and manual entry, while all personal data is stored **locally on the device**.

The application calculates the user’s **daily calorie needs and macronutrient targets** during onboarding and provides a structured, minimalistic interface for tracking meals throughout the day.

Additionally, CalTab includes advanced features such as:

- AI-powered assistant (BYOK – Bring Your Own Key)
- Snap2Cal (image-based calorie estimation)

---

## 2. Objectives

- Deliver a **fast, minimal, and intuitive calorie tracking experience**
- Ensure **full offline-first functionality** for user data
- Demonstrate **strong mobile architecture and clean code practices**
- Fulfill all **technical and architectural requirements of the course**
- Extend functionality beyond requirements (AI features)

---

## 3. Target Users

- Students and young adults
- Users who want simple calorie tracking without complexity
- Privacy-conscious users (no account required)
- Beginner to intermediate fitness users

---

## 4. Key Features

---

## 4.1 Onboarding & Personalization

### User Inputs:

- Age
- Height (cm)
- Weight (kg)
- Gender
- Activity level (sedentary → active)
- Goal:
  - Cut
  - Maintenance
  - Bulk

---

### Calorie Calculation

BMR = 10W + 6.25H - 5A + s

Then:

- TDEE = BMR × activity multiplier
- Final goal:
  - Cut: −300–500 kcal
  - Maintain: TDEE
  - Bulk: +300–500 kcal

---

### Macro Calculation (Default)

- Protein: 1.6–2.2 g/kg
- Fat: 0.8–1 g/kg
- Carbs: remaining calories
- Fiber: estimated baseline

✔ All values are **editable by the user later**

---

## 4.2 Home Screen (Core Experience)

### Layout Components:

#### 1. Calorie Component

- Circular progress indicator
- Center text:

  ```
  X kcal left
  ```

- Dynamic color:
  - Green → under target
  - Orange → near target
  - Red → exceeded

---

#### 2. Macros Component

Grid layout showing:

- Protein
- Carbs
- Fat
- Fiber

Format:

```
X / Y g
```

Color-coded based on progress.

---

#### 3. Meals Component (Accordion)

Meal sections:

- Breakfast
- Snack
- Lunch
- Snack
- Dinner
- Second Dinner

Each section:

- Expandable list
- Displays logged food items
- Contains `+` button to add food

---

## 4.3 Food Logging

Users can log food from the central `+` action button, which opens the Add Food / Search screen.

Users can log food via:

### 1. Barcode Scanning

- Uses Open Food Facts API

### 2. Search

- Search food database
- Results loaded with pagination

### 3. Manual Entry

- Custom meals

### 4. Snap2Cal (AI)

- Take photo
- AI suggests:
  - Food name
  - Calories

- User edits and confirms

---

## 4.4 Smart Meal Assignment

When using quick add:

- Food is assigned automatically based on time:
  - Morning → Breakfast
  - Midday → Lunch
  - Evening → Dinner

User can override before saving.

---

## 4.5 Add Food / Search Screen

The Add Food screen is opened from the central `+` action button. It is the main entry point for logging food through search, barcode scanning, camera-based estimation, or manual entry.

### Search Bar

The top search bar includes:

- Search icon
- Text input placeholder: `Search food...`
- Barcode scanner icon
- Camera icon

The search input is:

- Debounced
- Validated (non-empty)

### Search Results

- Scrollable list view (required)
- Infinite scrolling (bonus)

Each item:

- Name
- Calories
- Image

### Quick Actions

- Barcode scan
- Snap2Cal camera photo
- Manual entry

---

## 4.6 Food Detail Screen

Displays:

- Nutritional values
- Product image
- Option to add to meal

---

## 4.7 Stats Screen

The Stats screen replaces the Search tab in the bottom navigation. Search is treated as part of the add-food flow, while Stats is a primary app destination.

Displays:

- Daily calorie history
- Weekly calorie trend
- Macro progress trends
- Logged meal consistency
- Optional weight/progress tracking later

---

## 4.8 AI Assistant (BYOK)

### Description:

Optional feature allowing users to connect their own API key.

### Capabilities:

- Chat-based interface
- Context-aware:
  - User profile
  - Daily intake

### Example prompts:

- “How many calories should I eat?”
- “What should I eat for dinner?”

---

## 4.9 Settings

- Edit user data (weight, goals)
- Adjust calorie target manually
- Adjust macros manually
- Theme switch (light/dark)
- Enter AI API key

Stored locally (SharedPreferences) ✔

---

## 5. Navigation

### Bottom Navigation Bar:

- Home
- Stats
- ➕ (central action button)
- AI
- Settings

### Central Button:

- Opens the Add Food / Search screen
- Provides access to:
  - Food search
  - Barcode scanning
  - Snap2Cal camera photo
  - Manual entry

### Recommended Tab Icons:

- Home: home icon
- Stats: bar chart or line chart icon
- Central action: plus icon
- AI: sparkles or bot icon
- Settings: settings icon

---

## 6. Technical Architecture

### Layered Structure (required)

```
lib/
  models/
  services/
  providers/
  screens/
  widgets/
```

---

### State Management

- Riverpod (preferred)

---

### Data Sources

- Open Food Facts API
- Optional local JSON fallback

---

### Storage

- Local database (Hive / SQLite)
- SharedPreferences (settings)

---

### Navigation

- Named routes or GoRouter

---

## 7. Data Models

### User

- id
- age
- height
- weight
- gender
- goal_type
- calorie_goal
- macro_targets

---

### FoodItem

- id
- name
- calories
- protein
- carbs
- fat
- fiber
- image_url

---

### MealEntry

- id
- date
- meal_type
- food_item
- quantity
- calories

---

## 8. UX & Design

- Minimalistic, Apple-like design
- Clean layout, strong hierarchy
- Fast interactions
- Clear feedback states

---

## 9. Required Technical Features Mapping

This app fulfills all required criteria:

- Menu / navigation ✔
- Scrollable list ✔
- API data ✔
- Detail screen ✔
- Input validation ✔
- Theme ✔
- State management ✔
- Layered architecture ✔
- Loading/error/empty states ✔
- Navigation system ✔
- Tests ✔
- Local storage ✔

---

## 10. Error & Loading States

All async operations must handle:

- Loading indicator
- Error message + retry
- Empty state

---

## 11. Testing

### Unit Tests:

- Model serialization (JSON)
- Validator functions
- Provider/service logic

### Widget Test:

- Render UI component

---

## 12. Non-Functional Requirements

- Runs on emulator (Android/iOS)
- Clean, readable code
- Proper folder structure
- Maintainable architecture
