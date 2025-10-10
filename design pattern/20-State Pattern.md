# State Pattern

## Introduction

The State Pattern is a behavioral design pattern that allows an object to alter its behavior when its internal state changes. The object will appear to change its class. It encapsulates state-specific behavior into separate state classes and delegates behavior to the current state.

### Key Characteristics

- **State Encapsulation**: Each state is encapsulated in its own class
- **Behavior Delegation**: Context delegates behavior to current state object
- **State Transitions**: State objects can trigger transitions to other states
- **Eliminates Conditionals**: Replaces large conditional statements with polymorphism

### Use Cases

- Finite state machines
- Game character behavior
- Workflow management
- Document approval processes
- Order processing systems
- UI component states

## Implementation Examples

### C++ Implementation

#### Vending Machine System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <unordered_map>
#include <stdexcept>

// Forward declarations
class VendingMachine;
class VendingState;

// State Interface
class VendingState {
public:
    virtual ~VendingState() = default;
    virtual void insertMoney(int amount) = 0;
    virtual void selectProduct(const std::string& productId) = 0;
    virtual void dispenseProduct() = 0;
    virtual void cancel() = 0;
    virtual std::string getStateName() const = 0;
};

// Concrete States
class ReadyState : public VendingState {
private:
    VendingMachine* machine;

public:
    ReadyState(VendingMachine* m) : machine(m) {}

    void insertMoney(int amount) override;
    void selectProduct(const std::string& productId) override;
    void dispenseProduct() override;
    void cancel() override;
    std::string getStateName() const override { return "Ready"; }
};

class HasMoneyState : public VendingState {
private:
    VendingMachine* machine;

public:
    HasMoneyState(VendingMachine* m) : machine(m) {}

    void insertMoney(int amount) override;
    void selectProduct(const std::string& productId) override;
    void dispenseProduct() override;
    void cancel() override;
    std::string getStateName() const override { return "HasMoney"; }
};

class ProductSelectedState : public VendingState {
private:
    VendingMachine* machine;

public:
    ProductSelectedState(VendingMachine* m) : machine(m) {}

    void insertMoney(int amount) override;
    void selectProduct(const std::string& productId) override;
    void dispenseProduct() override;
    void cancel() override;
    std::string getStateName() const override { return "ProductSelected"; }
};

class DispensingState : public VendingState {
private:
    VendingMachine* machine;

public:
    DispensingState(VendingMachine* m) : machine(m) {}

    void insertMoney(int amount) override;
    void selectProduct(const std::string& productId) override;
    void dispenseProduct() override;
    void cancel() override;
    std::string getStateName() const override { return "Dispensing"; }
};

class OutOfStockState : public VendingState {
private:
    VendingMachine* machine;

public:
    OutOfStockState(VendingMachine* m) : machine(m) {}

    void insertMoney(int amount) override;
    void selectProduct(const std::string& productId) override;
    void dispenseProduct() override;
    void cancel() override;
    std::string getStateName() const override { return "OutOfStock"; }
};

// Product Structure
struct Product {
    std::string name;
    int price;
    int quantity;

    Product(const std::string& n, int p, int q) : name(n), price(p), quantity(q) {}
};

// Context: Vending Machine
class VendingMachine {
private:
    std::unique_ptr<VendingState> currentState;
    int currentBalance;
    std::string selectedProductId;
    std::unordered_map<std::string, Product> products;

    // State objects
    std::unique_ptr<ReadyState> readyState;
    std::unique_ptr<HasMoneyState> hasMoneyState;
    std::unique_ptr<ProductSelectedState> productSelectedState;
    std::unique_ptr<DispensingState> dispensingState;
    std::unique_ptr<OutOfStockState> outOfStockState;

public:
    VendingMachine() : currentBalance(0) {
        // Initialize states
        readyState = std::make_unique<ReadyState>(this);
        hasMoneyState = std::make_unique<HasMoneyState>(this);
        productSelectedState = std::make_unique<ProductSelectedState>(this);
        dispensingState = std::make_unique<DispensingState>(this);
        outOfStockState = std::make_unique<OutOfStockState>(this);

        // Set initial state
        currentState = std::make_unique<ReadyState>(this);

        // Initialize products
        products["A1"] = Product("Coke", 150, 5);
        products["A2"] = Product("Pepsi", 150, 3);
        products["B1"] = Product("Chips", 100, 10);
        products["B2"] = Product("Chocolate", 120, 8);
        products["C1"] = Product("Water", 80, 0);  // Out of stock
    }

    // State transition methods
    void setState(std::unique_ptr<VendingState> newState) {
        std::cout << "State changed: " << currentState->getStateName() 
                  << " -> " << newState->getStateName() << std::endl;
        currentState = std::move(newState);
    }

    // Public interface - delegates to current state
    void insertMoney(int amount) {
        currentState->insertMoney(amount);
    }

    void selectProduct(const std::string& productId) {
        currentState->selectProduct(productId);
    }

    void dispenseProduct() {
        currentState->dispenseProduct();
    }

    void cancel() {
        currentState->cancel();
    }

    // Getters and setters for state access
    int getCurrentBalance() const { return currentBalance; }
    void setCurrentBalance(int balance) { currentBalance = balance; }

    std::string getSelectedProductId() const { return selectedProductId; }
    void setSelectedProductId(const std::string& id) { selectedProductId = id; }

    Product* getProduct(const std::string& productId) {
        auto it = products.find(productId);
        return it != products.end() ? &it->second : nullptr;
    }

    void updateProductQuantity(const std::string& productId, int newQuantity) {
        auto it = products.find(productId);
        if (it != products.end()) {
            it->second.quantity = newQuantity;
        }
    }

    // State getters
    std::unique_ptr<VendingState> getReadyState() { 
        return std::make_unique<ReadyState>(this); 
    }
    
    std::unique_ptr<VendingState> getHasMoneyState() { 
        return std::make_unique<HasMoneyState>(this); 
    }
    
    std::unique_ptr<VendingState> getProductSelectedState() { 
        return std::make_unique<ProductSelectedState>(this); 
    }
    
    std::unique_ptr<VendingState> getDispensingState() { 
        return std::make_unique<DispensingState>(this); 
    }
    
    std::unique_ptr<VendingState> getOutOfStockState() { 
        return std::make_unique<OutOfStockState>(this); 
    }

    void displayStatus() const {
        std::cout << "\n=== Vending Machine Status ===" << std::endl;
        std::cout << "Current State: " << currentState->getStateName() << std::endl;
        std::cout << "Current Balance: " << currentBalance << " cents" << std::endl;
        std::cout << "Selected Product: " << selectedProductId << std::endl;
        
        std::cout << "\nAvailable Products:" << std::endl;
        for (const auto& pair : products) {
            std::cout << "  " << pair.first << ": " << pair.second.name 
                      << " - " << pair.second.price << " cents" 
                      << " (" << pair.second.quantity << " left)" << std::endl;
        }
    }
};

// ReadyState Implementations
void ReadyState::insertMoney(int amount) {
    std::cout << "💰 Inserted " << amount << " cents" << std::endl;
    machine->setCurrentBalance(amount);
    machine->setState(machine->getHasMoneyState());
}

void ReadyState::selectProduct(const std::string& productId) {
    std::cout << "❌ Please insert money first" << std::endl;
}

void ReadyState::dispenseProduct() {
    std::cout << "❌ No product selected" << std::endl;
}

void ReadyState::cancel() {
    std::cout << "ℹ️  No transaction to cancel" << std::endl;
}

// HasMoneyState Implementations
void HasMoneyState::insertMoney(int amount) {
    std::cout << "💰 Added " << amount << " cents" << std::endl;
    machine->setCurrentBalance(machine->getCurrentBalance() + amount);
}

void HasMoneyState::selectProduct(const std::string& productId) {
    auto product = machine->getProduct(productId);
    if (!product) {
        std::cout << "❌ Invalid product ID: " << productId << std::endl;
        return;
    }

    if (product->quantity <= 0) {
        std::cout << "❌ Product " << product->name << " is out of stock" << std::endl;
        machine->setState(machine->getOutOfStockState());
        return;
    }

    if (machine->getCurrentBalance() < product->price) {
        std::cout << "❌ Insufficient funds. Need " << product->price 
                  << " cents, have " << machine->getCurrentBalance() << " cents" << std::endl;
        return;
    }

    std::cout << "✅ Selected " << product->name << std::endl;
    machine->setSelectedProductId(productId);
    machine->setState(machine->getProductSelectedState());
}

void HasMoneyState::dispenseProduct() {
    std::cout << "❌ Please select a product first" << std::endl;
}

void HasMoneyState::cancel() {
    std::cout << "🔄 Transaction cancelled. Returning " 
              << machine->getCurrentBalance() << " cents" << std::endl;
    machine->setCurrentBalance(0);
    machine->setSelectedProductId("");
    machine->setState(machine->getReadyState());
}

// ProductSelectedState Implementations
void ProductSelectedState::insertMoney(int amount) {
    std::cout << "💰 Added " << amount << " cents" << std::endl;
    machine->setCurrentBalance(machine->getCurrentBalance() + amount);
}

void ProductSelectedState::selectProduct(const std::string& productId) {
    std::cout << "🔄 Changing selection to " << productId << std::endl;
    machine->selectProduct(productId); // This will trigger state transition if valid
}

void ProductSelectedState::dispenseProduct() {
    auto productId = machine->getSelectedProductId();
    auto product = machine->getProduct(productId);
    
    if (!product || product->quantity <= 0) {
        std::cout << "❌ Product unavailable" << std::endl;
        machine->setState(machine->getOutOfStockState());
        return;
    }

    if (machine->getCurrentBalance() < product->price) {
        std::cout << "❌ Insufficient funds" << std::endl;
        return;
    }

    machine->setState(machine->getDispensingState());
    machine->dispenseProduct(); // Recursive call to trigger dispensing
}

void ProductSelectedState::cancel() {
    std::cout << "🔄 Selection cancelled" << std::endl;
    machine->setSelectedProductId("");
    machine->setState(machine->getHasMoneyState());
}

// DispensingState Implementations
void DispensingState::insertMoney(int amount) {
    std::cout << "❌ Currently dispensing, cannot accept money" << std::endl;
}

void DispensingState::selectProduct(const std::string& productId) {
    std::cout << "❌ Currently dispensing, cannot select new product" << std::endl;
}

void DispensingState::dispenseProduct() {
    auto productId = machine->getSelectedProductId();
    auto product = machine->getProduct(productId);
    
    if (product && product->quantity > 0) {
        // Calculate change
        int change = machine->getCurrentBalance() - product->price;
        
        // Dispense product
        std::cout << "🎉 Dispensing " << product->name << std::endl;
        machine->updateProductQuantity(productId, product->quantity - 1);
        
        // Return change if any
        if (change > 0) {
            std::cout << "💰 Returning change: " << change << " cents" << std::endl;
        }
        
        // Reset machine state
        machine->setCurrentBalance(0);
        machine->setSelectedProductId("");
        machine->setState(machine->getReadyState());
        
        std::cout << "✅ Thank you for your purchase!" << std::endl;
    } else {
        std::cout << "❌ Dispensing failed" << std::endl;
        machine->setState(machine->getOutOfStockState());
    }
}

void DispensingState::cancel() {
    std::cout << "❌ Cannot cancel during dispensing" << std::endl;
}

// OutOfStockState Implementations
void OutOfStockState::insertMoney(int amount) {
    std::cout << "❌ Product out of stock, cannot accept money" << std::endl;
}

void OutOfStockState::selectProduct(const std::string& productId) {
    auto product = machine->getProduct(productId);
    if (product && product->quantity > 0) {
        std::cout << "✅ Product " << product->name << " is available" << std::endl;
        machine->setState(machine->getHasMoneyState());
        machine->selectProduct(productId);
    } else {
        std::cout << "❌ Product " << productId << " is out of stock" << std::endl;
    }
}

void OutOfStockState::dispenseProduct() {
    std::cout << "❌ No product available to dispense" << std::endl;
}

void OutOfStockState::cancel() {
    std::cout << "🔄 Returning to ready state" << std::endl;
    machine->setCurrentBalance(0);
    machine->setSelectedProductId("");
    machine->setState(machine->getReadyState());
}

// Demo function
void vendingMachineDemo() {
    std::cout << "=== State Pattern - Vending Machine ===\n" << std::endl;
    
    VendingMachine machine;
    machine.displayStatus();

    std::cout << "\n--- Test Scenario 1: Successful Purchase ---" << std::endl;
    machine.insertMoney(200);
    machine.selectProduct("A1"); // Coke
    machine.dispenseProduct();

    std::cout << "\n--- Test Scenario 2: Insufficient Funds ---" << std::endl;
    machine.insertMoney(100);
    machine.selectProduct("B1"); // Chips - costs 100
    machine.selectProduct("A2"); // Pepsi - costs 150, insufficient funds

    std::cout << "\n--- Test Scenario 3: Out of Stock ---" << std::endl;
    machine.insertMoney(100);
    machine.selectProduct("C1"); // Water - out of stock

    std::cout << "\n--- Test Scenario 4: Cancellation ---" << std::endl;
    machine.cancel();

    std::cout << "\n--- Test Scenario 5: Complex Flow ---" << std::endl;
    machine.insertMoney(100);
    machine.insertMoney(50); // Add more money
    machine.selectProduct("B2"); // Chocolate - costs 120
    machine.dispenseProduct();

    machine.displayStatus();
}

int main() {
    vendingMachineDemo();
    return 0;
}
```

#### Traffic Light System

```cpp
#include <iostream>
#include <memory>
#include <thread>
#include <chrono>
#include <string>

// Forward declarations
class TrafficLight;
class TrafficLightState;

// State Interface
class TrafficLightState {
public:
    virtual ~TrafficLightState() = default;
    virtual void change(TrafficLight* light) = 0;
    virtual void display() const = 0;
    virtual int getDuration() const = 0;
    virtual std::string getName() const = 0;
};

// Concrete States
class RedState : public TrafficLightState {
public:
    void change(TrafficLight* light) override;
    void display() const override {
        std::cout << "🔴 RED - STOP" << std::endl;
    }
    int getDuration() const override { return 5; }
    std::string getName() const override { return "RED"; }
};

class YellowState : public TrafficLightState {
public:
    void change(TrafficLight* light) override;
    void display() const override {
        std::cout << "🟡 YELLOW - PREPARE" << std::endl;
    }
    int getDuration() const override { return 2; }
    std::string getName() const override { return "YELLOW"; }
};

class GreenState : public TrafficLightState {
public:
    void change(TrafficLight* light) override;
    void display() const override {
        std::cout << "🟢 GREEN - GO" << std::endl;
    }
    int getDuration() const override { return 5; }
    std::string getName() const override { return "GREEN"; }
};

class BlinkingYellowState : public TrafficLightState {
public:
    void change(TrafficLight* light) override;
    void display() const override {
        std::cout << "💛 BLINKING YELLOW - CAUTION" << std::endl;
    }
    int getDuration() const override { return 0; } // Manual change only
    std::string getName() const override { return "BLINKING_YELLOW"; }
};

class OffState : public TrafficLightState {
public:
    void change(TrafficLight* light) override {
        // Stay off until manually changed
    }
    void display() const override {
        std::cout << "⚫ OFF - LIGHT OUT" << std::endl;
    }
    int getDuration() const override { return 0; }
    std::string getName() const override { return "OFF"; }
};

// Context: Traffic Light
class TrafficLight {
private:
    std::unique_ptr<TrafficLightState> currentState;
    bool isEmergencyMode;
    int cycleCount;

public:
    TrafficLight() : isEmergencyMode(false), cycleCount(0) {
        // Start with red light
        currentState = std::make_unique<RedState>();
    }

    void setState(std::unique_ptr<TrafficLightState> newState) {
        std::cout << "🚦 Traffic light changing: " << currentState->getName() 
                  << " -> " << newState->getName() << std::endl;
        currentState = std::move(newState);
        currentState->display();
    }

    void change() {
        if (!isEmergencyMode) {
            currentState->change(this);
            cycleCount++;
        }
    }

    void display() const {
        currentState->display();
    }

    void setEmergencyMode(bool emergency) {
        isEmergencyMode = emergency;
        if (emergency) {
            std::cout << "🚨 EMERGENCY MODE ACTIVATED - Blinking Yellow" << std::endl;
            setState(std::make_unique<BlinkingYellowState>());
        } else {
            std::cout << "🚨 EMERGENCY MODE DEACTIVATED" << std::endl;
            setState(std::make_unique<RedState>());
        }
    }

    void turnOff() {
        std::cout << "💡 Turning traffic light off" << std::endl;
        setState(std::make_unique<OffState>());
    }

    void turnOn() {
        std::cout << "💡 Turning traffic light on" << std::endl;
        setState(std::make_unique<RedState>());
    }

    int getCycleCount() const { return cycleCount; }
    std::string getCurrentState() const { return currentState->getName(); }
};

// State transition implementations
void RedState::change(TrafficLight* light) {
    light->setState(std::make_unique<GreenState>());
}

void YellowState::change(TrafficLight* light) {
    light->setState(std::make_unique<RedState>());
}

void GreenState::change(TrafficLight* light) {
    light->setState(std::make_unique<YellowState>());
}

void BlinkingYellowState::change(TrafficLight* light) {
    // In blinking mode, we don't automatically change
    // This requires manual intervention
}

// Intersection with multiple traffic lights
class Intersection {
private:
    TrafficLight northSouthLight;
    TrafficLight eastWestLight;
    bool isRunning;

public:
    Intersection() : isRunning(false) {}

    void start() {
        isRunning = true;
        std::cout << "\n🚦 Starting intersection simulation..." << std::endl;
        
        // Initial sync - North/South gets green first
        northSouthLight.setState(std::make_unique<GreenState>());
        eastWestLight.setState(std::make_unique<RedState>());
    }

    void stop() {
        isRunning = false;
        std::cout << "\n🛑 Stopping intersection simulation..." << std::endl;
    }

    void runCycle(int cycles = 3) {
        for (int i = 0; i < cycles && isRunning; ++i) {
            std::cout << "\n--- Cycle " << (i + 1) << " ---" << std::endl;
            
            // North/South phase
            std::cout << "North/South: ";
            northSouthLight.display();
            std::cout << "East/West: ";
            eastWestLight.display();
            
            std::this_thread::sleep_for(std::chrono::seconds(
                northSouthLight.getCurrentState() == "GREEN" ? 5 : 2));
            
            // Change lights
            northSouthLight.change();
            eastWestLight.change();
            
            // East/West phase
            std::cout << "\nNorth/South: ";
            northSouthLight.display();
            std::cout << "East/West: ";
            eastWestLight.display();
            
            std::this_thread::sleep_for(std::chrono::seconds(
                eastWestLight.getCurrentState() == "GREEN" ? 5 : 2));
            
            // Change lights
            northSouthLight.change();
            eastWestLight.change();
        }
    }

    void emergencyMode() {
        std::cout << "\n🚨 ACTIVATING EMERGENCY MODE" << std::endl;
        northSouthLight.setEmergencyMode(true);
        eastWestLight.setEmergencyMode(true);
    }

    void normalMode() {
        std::cout << "\n🔧 RETURNING TO NORMAL MODE" << std::endl;
        northSouthLight.setEmergencyMode(false);
        eastWestLight.setEmergencyMode(false);
    }

    void displayStatus() const {
        std::cout << "\n=== Intersection Status ===" << std::endl;
        std::cout << "North/South: " << northSouthLight.getCurrentState() << std::endl;
        std::cout << "East/West: " << eastWestLight.getCurrentState() << std::endl;
        std::cout << "Total Cycles: " << northSouthLight.getCycleCount() << std::endl;
    }
};

// Demo function
void trafficLightDemo() {
    std::cout << "=== State Pattern - Traffic Light System ===\n" << std::endl;
    
    Intersection intersection;
    
    std::cout << "--- Single Traffic Light Test ---" << std::endl;
    TrafficLight light;
    
    // Test normal cycle
    for (int i = 0; i < 3; ++i) {
        light.display();
        std::this_thread::sleep_for(std::chrono::seconds(light.getCurrentState() == "YELLOW" ? 2 : 5));
        light.change();
    }
    
    std::cout << "\n--- Emergency Mode Test ---" << std::endl;
    light.setEmergencyMode(true);
    light.display();
    
    std::cout << "\n--- Back to Normal ---" << std::endl;
    light.setEmergencyMode(false);
    light.display();
    
    std::cout << "\n--- Intersection Simulation ---" << std::endl;
    intersection.start();
    intersection.runCycle(2);
    
    std::cout << "\n--- Emergency Mode in Intersection ---" << std::endl;
    intersection.emergencyMode();
    std::this_thread::sleep_for(std::chrono::seconds(3));
    
    std::cout << "\n--- Back to Normal Operation ---" << std::endl;
    intersection.normalMode();
    intersection.runCycle(1);
    
    intersection.displayStatus();
    intersection.stop();
}

int main() {
    trafficLightDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// State function pointers
typedef struct PlayerState PlayerState;
typedef void (*UpdateFunction)(PlayerState*);
typedef void (*HandleInputFunction)(PlayerState*, const char*);
typedef const char* (*GetStateNameFunction)(const PlayerState*);

// Player Context
typedef struct PlayerState {
    int health;
    int stamina;
    int position_x;
    int position_y;
    UpdateFunction update;
    HandleInputFunction handle_input;
    GetStateNameFunction get_state_name;
} PlayerState;

// State function declarations
void idle_update(PlayerState* state);
void idle_handle_input(PlayerState* state, const char* input);
const char* idle_get_name(const PlayerState* state);

void walking_update(PlayerState* state);
void walking_handle_input(PlayerState* state, const char* input);
const char* walking_get_name(const PlayerState* state);

void running_update(PlayerState* state);
void running_handle_input(PlayerState* state, const char* input);
const char* running_get_name(const PlayerState* state);

void attacking_update(PlayerState* state);
void attacking_handle_input(PlayerState* state, const char* input);
const char* attacking_get_name(const PlayerState* state);

void dead_update(PlayerState* state);
void dead_handle_input(PlayerState* state, const char* input);
const char* dead_get_name(const PlayerState* state);

// State transition function
void change_state(PlayerState* state, 
                  UpdateFunction update_func,
                  HandleInputFunction handle_func,
                  GetStateNameFunction name_func) {
    printf("State changed: %s -> ", state->get_state_name(state));
    state->update = update_func;
    state->handle_input = handle_func;
    state->get_state_name = name_func;
    printf("%s\n", state->get_state_name(state));
}

// Idle State implementation
void idle_update(PlayerState* state) {
    // Regenerate stamina while idle
    if (state->stamina < 100) {
        state->stamina += 5;
        if (state->stamina > 100) state->stamina = 100;
    }
    
    // Regenerate health slowly
    if (state->health < 100 && rand() % 10 == 0) {
        state->health += 1;
    }
}

void idle_handle_input(PlayerState* state, const char* input) {
    if (strcmp(input, "move") == 0) {
        change_state(state, walking_update, walking_handle_input, walking_get_name);
    } else if (strcmp(input, "attack") == 0) {
        change_state(state, attacking_update, attacking_handle_input, attacking_get_name);
    } else if (strcmp(input, "run") == 0 && state->stamina >= 20) {
        change_state(state, running_update, running_handle_input, running_get_name);
    } else {
        printf("Idle: Unknown input '%s'\n", input);
    }
}

const char* idle_get_name(const PlayerState* state) {
    return "IDLE";
}

// Walking State implementation
void walking_update(PlayerState* state) {
    state->position_x += 1;
    
    // Consume minimal stamina
    if (state->stamina > 0) {
        state->stamina -= 1;
    }
    
    // Auto-transition to idle if no stamina
    if (state->stamina <= 0) {
        change_state(state, idle_update, idle_handle_input, idle_get_name);
    }
}

void walking_handle_input(PlayerState* state, const char* input) {
    if (strcmp(input, "stop") == 0) {
        change_state(state, idle_update, idle_handle_input, idle_get_name);
    } else if (strcmp(input, "run") == 0 && state->stamina >= 20) {
        change_state(state, running_update, running_handle_input, running_get_name);
    } else if (strcmp(input, "attack") == 0) {
        change_state(state, attacking_update, attacking_handle_input, attacking_get_name);
    } else {
        printf("Walking: Unknown input '%s'\n", input);
    }
}

const char* walking_get_name(const PlayerState* state) {
    return "WALKING";
}

// Running State implementation
void running_update(PlayerState* state) {
    state->position_x += 3;
    
    // Consume stamina quickly
    state->stamina -= 5;
    
    // Auto-transition based on stamina
    if (state->stamina <= 0) {
        change_state(state, idle_update, idle_handle_input, idle_get_name);
    } else if (state->stamina < 20) {
        change_state(state, walking_update, walking_handle_input, walking_get_name);
    }
}

void running_handle_input(PlayerState* state, const char* input) {
    if (strcmp(input, "stop") == 0) {
        change_state(state, idle_update, idle_handle_input, idle_get_name);
    } else if (strcmp(input, "walk") == 0) {
        change_state(state, walking_update, walking_handle_input, walking_get_name);
    } else if (strcmp(input, "attack") == 0) {
        change_state(state, attacking_update, attacking_handle_input, attacking_get_name);
    } else {
        printf("Running: Unknown input '%s'\n", input);
    }
}

const char* running_get_name(const PlayerState* state) {
    return "RUNNING";
}

// Attacking State implementation
void attacking_update(PlayerState* state) {
    // Attack consumes stamina
    state->stamina -= 10;
    
    // Auto-transition back to idle after attack
    change_state(state, idle_update, idle_handle_input, idle_get_name);
    
    printf("Player attacks! Stamina decreased.\n");
}

void attacking_handle_input(PlayerState* state, const char* input) {
    printf("Attacking: Cannot handle input '%s' during attack animation\n", input);
}

const char* attacking_get_name(const PlayerState* state) {
    return "ATTACKING";
}

// Dead State implementation
void dead_update(PlayerState* state) {
    // No updates when dead
}

void dead_handle_input(PlayerState* state, const char* input) {
    if (strcmp(input, "respawn") == 0) {
        state->health = 100;
        state->stamina = 100;
        change_state(state, idle_update, idle_handle_input, idle_get_name);
        printf("Player respawned!\n");
    } else {
        printf("Dead: Can only 'respawn'\n");
    }
}

const char* dead_get_name(const PlayerState* state) {
    return "DEAD";
}

// Player initialization
void init_player(PlayerState* player) {
    player->health = 100;
    player->stamina = 100;
    player->position_x = 0;
    player->position_y = 0;
    player->update = idle_update;
    player->handle_input = idle_handle_input;
    player->get_state_name = idle_get_name;
}

// Take damage function
void take_damage(PlayerState* player, int damage) {
    player->health -= damage;
    if (player->health <= 0) {
        player->health = 0;
        change_state(player, dead_update, dead_handle_input, dead_get_name);
        printf("Player died!\n");
    } else {
        printf("Player took %d damage. Health: %d\n", damage, player->health);
    }
}

// Display player status
void display_status(const PlayerState* player) {
    printf("\n=== Player Status ===\n");
    printf("State: %s\n", player->get_state_name(player));
    printf("Health: %d\n", player->health);
    printf("Stamina: %d\n", player->stamina);
    printf("Position: (%d, %d)\n", player->position_x, player->position_y);
}

// Demo function
void gameCharacterDemo() {
    printf("=== State Pattern - Game Character ===\n\n");
    
    PlayerState player;
    init_player(&player);
    
    printf("--- Initial State ---\n");
    display_status(&player);
    
    printf("\n--- Testing State Transitions ---\n");
    player.handle_input(&player, "move");
    player.update(&player);
    display_status(&player);
    
    player.handle_input(&player, "run");
    player.update(&player);
    display_status(&player);
    
    player.handle_input(&player, "attack");
    player.update(&player);
    display_status(&player);
    
    printf("\n--- Testing Stamina Depletion ---\n");
    // Run until stamina is depleted
    player.handle_input(&player, "run");
    for (int i = 0; i < 5 && strcmp(player.get_state_name(&player), "DEAD") != 0; i++) {
        player.update(&player);
        display_status(&player);
    }
    
    printf("\n--- Testing Damage and Death ---\n");
    init_player(&player); // Reset player
    take_damage(&player, 80);
    display_status(&player);
    
    take_damage(&player, 30); // This should kill the player
    display_status(&player);
    
    printf("\n--- Testing Respawn ---\n");
    player.handle_input(&player, "respawn");
    display_status(&player);
    
    printf("\n--- Complex Scenario ---\n");
    player.handle_input(&player, "move");
    player.update(&player);
    player.handle_input(&player, "run");
    player.update(&player);
    take_damage(&player, 25);
    player.handle_input(&player, "attack");
    player.update(&player);
    display_status(&player);
}

int main() {
    srand(42); // Seed for reproducible results
    gameCharacterDemo();
    return 0;
}
```

### Python Implementation

#### Document Workflow System

```python
from abc import ABC, abstractmethod
from typing import Optional, List
from datetime import datetime
from enum import Enum
import uuid

class DocumentType(Enum):
    DRAFT = "draft"
    REVIEW = "review"
    APPROVED = "approved"
    PUBLISHED = "published"
    ARCHIVED = "archived"
    REJECTED = "rejected"

class Document:
    def __init__(self, title: str, content: str, author: str):
        self.id = str(uuid.uuid4())
        self.title = title
        self.content = content
        self.author = author
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
        self.version = 1
        self.comments: List[str] = []
        self.approvers: List[str] = []
        self.reject_reason: Optional[str] = None
    
    def add_comment(self, comment: str):
        self.comments.append(f"{datetime.now()}: {comment}")
    
    def add_approver(self, approver: str):
        self.approvers.append(approver)
    
    def update_content(self, new_content: str):
        self.content = new_content
        self.version += 1
        self.updated_at = datetime.now()
    
    def __str__(self):
        return f"Document('{self.title}', v{self.version}, {self.get_status()})"
    
    def get_status(self) -> str:
        return "Unknown"

# State Interface
class DocumentState(ABC):
    @abstractmethod
    def edit(self, document: Document, user: str, new_content: str) -> bool: ...
    
    @abstractmethod
    def review(self, document: Document, user: str) -> bool: ...
    
    @abstractmethod
    def approve(self, document: Document, user: str) -> bool: ...
    
    @abstractmethod
    def reject(self, document: Document, user: str, reason: str) -> bool: ...
    
    @abstractmethod
    def publish(self, document: Document, user: str) -> bool: ...
    
    @abstractmethod
    def archive(self, document: Document, user: str) -> bool: ...
    
    @abstractmethod
    def get_state_name(self) -> str: ...

# Concrete States
class DraftState(DocumentState):
    def edit(self, document: Document, user: str, new_content: str) -> bool:
        print(f"✏️  {user} edited the draft")
        document.update_content(new_content)
        document.add_comment(f"{user} made edits to the draft")
        return True
    
    def review(self, document: Document, user: str) -> bool:
        print(f"👀 {user} sent document for review")
        document.add_comment(f"{user} submitted for review")
        return True
    
    def approve(self, document: Document, user: str) -> bool:
        print("❌ Cannot approve a draft document")
        return False
    
    def reject(self, document: Document, user: str, reason: str) -> bool:
        print("❌ Cannot reject a draft document")
        return False
    
    def publish(self, document: Document, user: str) -> bool:
        print("❌ Cannot publish a draft document")
        return False
    
    def archive(self, document: Document, user: str) -> bool:
        print(f"📦 {user} archived the draft")
        document.add_comment(f"{user} archived the draft")
        return True
    
    def get_state_name(self) -> str:
        return "DRAFT"

class ReviewState(DocumentState):
    def edit(self, document: Document, user: str, new_content: str) -> bool:
        print("❌ Cannot edit document while under review")
        return False
    
    def review(self, document: Document, user: str) -> bool:
        print(f"🔍 {user} is reviewing the document")
        document.add_comment(f"{user} conducted a review")
        return True
    
    def approve(self, document: Document, user: str) -> bool:
        print(f"✅ {user} approved the document")
        document.add_approver(user)
        document.add_comment(f"{user} approved the document")
        
        # Check if we have enough approvals
        if len(document.approvers) >= 2:
            print("🎉 Document received sufficient approvals!")
            return True
        else:
            print(f"📋 Need {2 - len(document.approvers)} more approval(s)")
            return True
    
    def reject(self, document: Document, user: str, reason: str) -> bool:
        print(f"❌ {user} rejected the document: {reason}")
        document.reject_reason = reason
        document.add_comment(f"{user} rejected the document: {reason}")
        return True
    
    def publish(self, document: Document, user: str) -> bool:
        print("❌ Cannot publish document under review")
        return False
    
    def archive(self, document: Document, user: str) -> bool:
        print("❌ Cannot archive document under review")
        return False
    
    def get_state_name(self) -> str:
        return "UNDER_REVIEW"

class ApprovedState(DocumentState):
    def edit(self, document: Document, user: str, new_content: str) -> bool:
        print("❌ Cannot edit an approved document")
        return False
    
    def review(self, document: Document, user: str) -> bool:
        print("❌ Approved document doesn't need review")
        return False
    
    def approve(self, document: Document, user: str) -> bool:
        print("✅ Document already approved")
        return True
    
    def reject(self, document: Document, user: str, reason: str) -> bool:
        print("❌ Cannot reject an approved document")
        return False
    
    def publish(self, document: Document, user: str) -> bool:
        print(f"🚀 {user} published the document")
        document.add_comment(f"{user} published the document")
        return True
    
    def archive(self, document: Document, user: str) -> bool:
        print(f"📦 {user} archived the approved document")
        document.add_comment(f"{user} archived the approved document")
        return True
    
    def get_state_name(self) -> str:
        return "APPROVED"

class PublishedState(DocumentState):
    def edit(self, document: Document, user: str, new_content: str) -> bool:
        print("❌ Cannot edit a published document. Create new version instead.")
        return False
    
    def review(self, document: Document, user: str) -> bool:
        print("❌ Published document doesn't need review")
        return False
    
    def approve(self, document: Document, user: str) -> bool:
        print("✅ Document already published")
        return True
    
    def reject(self, document: Document, user: str, reason: str) -> bool:
        print("❌ Cannot reject a published document")
        return False
    
    def publish(self, document: Document, user: str) -> bool:
        print("✅ Document already published")
        return True
    
    def archive(self, document: Document, user: str) -> bool:
        print(f"📦 {user} archived the published document")
        document.add_comment(f"{user} archived the published document")
        return True
    
    def get_state_name(self) -> str:
        return "PUBLISHED"

class ArchivedState(DocumentState):
    def edit(self, document: Document, user: str, new_content: str) -> bool:
        print("❌ Cannot edit an archived document")
        return False
    
    def review(self, document: Document, user: str) -> bool:
        print("❌ Cannot review an archived document")
        return False
    
    def approve(self, document: Document, user: str) -> bool:
        print("❌ Cannot approve an archived document")
        return False
    
    def reject(self, document: Document, user: str, reason: str) -> bool:
        print("❌ Cannot reject an archived document")
        return False
    
    def publish(self, document: Document, user: str) -> bool:
        print("❌ Cannot publish an archived document")
        return False
    
    def archive(self, document: Document, user: str) -> bool:
        print("✅ Document already archived")
        return True
    
    def get_state_name(self) -> str:
        return "ARCHIVED"

class RejectedState(DocumentState):
    def edit(self, document: Document, user: str, new_content: str) -> bool:
        print(f"✏️  {user} is editing the rejected document")
        document.update_content(new_content)
        document.add_comment(f"{user} made edits after rejection")
        return True
    
    def review(self, document: Document, user: str) -> bool:
        print(f"👀 {user} resubmitted document for review")
        document.add_comment(f"{user} resubmitted for review after rejection")
        return True
    
    def approve(self, document: Document, user: str) -> bool:
        print("❌ Cannot approve a rejected document")
        return False
    
    def reject(self, document: Document, user: str, reason: str) -> bool:
        print(f"❌ Document already rejected: {document.reject_reason}")
        return False
    
    def publish(self, document: Document, user: str) -> bool:
        print("❌ Cannot publish a rejected document")
        return False
    
    def archive(self, document: Document, user: str) -> bool:
        print(f"📦 {user} archived the rejected document")
        document.add_comment(f"{user} archived the rejected document")
        return True
    
    def get_state_name(self) -> str:
        return "REJECTED"

# Document Context with State Management
class StatefulDocument(Document):
    def __init__(self, title: str, content: str, author: str):
        super().__init__(title, content, author)
        self._state: DocumentState = DraftState()
    
    def set_state(self, new_state: DocumentState):
        old_state = self._state.get_state_name()
        self._state = new_state
        print(f"📄 Document state changed: {old_state} → {new_state.get_state_name()}")
    
    def get_status(self) -> str:
        return self._state.get_state_name()
    
    # State operations
    def edit(self, user: str, new_content: str) -> bool:
        return self._state.edit(self, user, new_content)
    
    def submit_for_review(self, user: str) -> bool:
        if self._state.review(self, user):
            self.set_state(ReviewState())
            return True
        return False
    
    def approve(self, user: str) -> bool:
        if self._state.approve(self, user):
            # Check if we should transition to approved state
            if isinstance(self._state, ReviewState) and len(self.approvers) >= 2:
                self.set_state(ApprovedState())
            return True
        return False
    
    def reject(self, user: str, reason: str) -> bool:
        if self._state.reject(self, user, reason):
            self.set_state(RejectedState())
            return True
        return False
    
    def publish(self, user: str) -> bool:
        if self._state.publish(self, user):
            self.set_state(PublishedState())
            return True
        return False
    
    def archive(self, user: str) -> bool:
        if self._state.archive(self, user):
            self.set_state(ArchivedState())
            return True
        return False
    
    def display_info(self):
        print(f"\n=== Document: {self.title} ===")
        print(f"ID: {self.id}")
        print(f"Status: {self.get_status()}")
        print(f"Author: {self.author}")
        print(f"Version: {self.version}")
        print(f"Created: {self.created_at}")
        print(f"Updated: {self.updated_at}")
        print(f"Approvers: {', '.join(self.approvers) if self.approvers else 'None'}")
        if self.reject_reason:
            print(f"Rejection Reason: {self.reject_reason}")
        print(f"Comments: {len(self.comments)}")
        for comment in self.comments[-3:]:  # Show last 3 comments
            print(f"  - {comment}")

# Workflow Manager
class DocumentWorkflow:
    def __init__(self):
        self.documents: List[StatefulDocument] = []
    
    def create_document(self, title: str, content: str, author: str) -> StatefulDocument:
        doc = StatefulDocument(title, content, author)
        self.documents.append(doc)
        print(f"📝 Created new document: {title}")
        return doc
    
    def simulate_workflow(self, doc: StatefulDocument):
        print(f"\n🎬 Simulating workflow for: {doc.title}")
        
        # Author edits and submits
        doc.edit("Alice", "Initial content for the document")
        doc.edit("Alice", "Revised content with more details")
        doc.submit_for_review("Alice")
        
        # Reviewers review
        doc.approve("Bob")
        doc.review("Charlie", "Looks good, but needs minor fixes")
        doc.approve("Charlie")  # Second approval
        
        # Publish
        doc.publish("Alice")
        
        # Archive
        doc.archive("Alice")

# Demo function
def documentWorkflowDemo():
    print("=== State Pattern - Document Workflow System ===\n")
    
    workflow = DocumentWorkflow()
    
    # Create a document
    doc = workflow.create_document(
        "Project Proposal", 
        "This is the content of our project proposal...", 
        "Alice"
    )
    
    doc.display_info()
    
    print("\n--- Testing Valid Transitions ---")
    doc.edit("Alice", "Updated project proposal content")
    doc.submit_for_review("Alice")
    doc.display_info()
    
    doc.approve("Bob")
    doc.approve("Charlie")  # Second approval should trigger state change
    doc.display_info()
    
    doc.publish("Alice")
    doc.display_info()
    
    print("\n--- Testing Invalid Operations ---")
    # Try to edit a published document
    doc.edit("Alice", "Trying to edit published doc")  # Should fail
    
    # Archive the document
    doc.archive("Alice")
    doc.display_info()
    
    print("\n--- Testing Rejection Flow ---")
    doc2 = workflow.create_document("Technical Spec", "Technical specifications...", "Bob")
    doc2.submit_for_review("Bob")
    doc2.reject("Charlie", "Incomplete requirements section")
    doc2.display_info()
    
    # After rejection, author can edit and resubmit
    doc2.edit("Bob", "Added complete requirements section")
    doc2.submit_for_review("Bob")
    doc2.approve("Alice")
    doc2.approve("Charlie")
    doc2.publish("Bob")
    doc2.display_info()
    
    print("\n--- Complete Workflow Simulation ---")
    doc3 = workflow.create_document("Meeting Notes", "Notes from today's meeting...", "Charlie")
    workflow.simulate_workflow(doc3)

if __name__ == "__main__":
    documentWorkflowDemo()
```

#### Order Processing System

```python
from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
import uuid

class PaymentStatus(Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"

class ShippingStatus(Enum):
    PENDING = "pending"
    PACKAGING = "packaging"
    SHIPPED = "shipped"
    IN_TRANSIT = "in_transit"
    DELIVERED = "delivered"
    RETURNED = "returned"

# Order Item
class OrderItem:
    def __init__(self, product_id: str, product_name: str, quantity: int, price: float):
        self.product_id = product_id
        self.product_name = product_name
        self.quantity = quantity
        self.price = price
    
    @property
    def total_price(self) -> float:
        return self.quantity * self.price
    
    def __str__(self):
        return f"{self.product_name} x{self.quantity} - ${self.total_price:.2f}"

# Order State Interface
class OrderState(ABC):
    @abstractmethod
    def add_item(self, order: 'Order', item: OrderItem) -> bool: ...
    
    @abstractmethod
    def remove_item(self, order: 'Order', product_id: str) -> bool: ...
    
    @abstractmethod
    def cancel(self, order: 'Order') -> bool: ...
    
    @abstractmethod
    def process_payment(self, order: 'Order') -> bool: ...
    
    @abstractmethod
    def ship(self, order: 'Order') -> bool: ...
    
    @abstractmethod
    def deliver(self, order: 'Order') -> bool: ...
    
    @abstractmethod
    def return_order(self, order: 'Order') -> bool: ...
    
    @abstractmethod
    def get_state_name(self) -> str: ...

# Concrete States
class NewOrderState(OrderState):
    def add_item(self, order: 'Order', item: OrderItem) -> bool:
        order.items.append(item)
        order.calculate_total()
        print(f"📦 Added {item.product_name} to order")
        return True
    
    def remove_item(self, order: 'Order', product_id: str) -> bool:
        order.items = [item for item in order.items if item.product_id != product_id]
        order.calculate_total()
        print(f"🗑️ Removed item {product_id} from order")
        return True
    
    def cancel(self, order: 'Order') -> bool:
        print("🛑 Order cancelled")
        return True
    
    def process_payment(self, order: 'Order') -> bool:
        print("💳 Processing payment for new order")
        return True
    
    def ship(self, order: 'Order') -> bool:
        print("❌ Cannot ship unpaid order")
        return False
    
    def deliver(self, order: 'Order') -> bool:
        print("❌ Cannot deliver unpaid order")
        return False
    
    def return_order(self, order: 'Order') -> bool:
        print("❌ Cannot return unpaid order")
        return False
    
    def get_state_name(self) -> str:
        return "NEW"

class PaidOrderState(OrderState):
    def add_item(self, order: 'Order', item: OrderItem) -> bool:
        print("❌ Cannot modify paid order")
        return False
    
    def remove_item(self, order: 'Order', product_id: str) -> bool:
        print("❌ Cannot modify paid order")
        return False
    
    def cancel(self, order: 'Order') -> bool:
        print("🔄 Cancelling paid order - refund will be processed")
        return True
    
    def process_payment(self, order: 'Order') -> bool:
        print("✅ Payment already processed")
        return True
    
    def ship(self, order: 'Order') -> bool:
        print("🚚 Preparing order for shipment")
        return True
    
    def deliver(self, order: 'Order') -> bool:
        print("❌ Cannot deliver order that hasn't been shipped")
        return False
    
    def return_order(self, order: 'Order') -> bool:
        print("❌ Cannot return order that hasn't been delivered")
        return False
    
    def get_state_name(self) -> str:
        return "PAID"

class ShippedOrderState(OrderState):
    def add_item(self, order: 'Order', item: OrderItem) -> bool:
        print("❌ Cannot modify shipped order")
        return False
    
    def remove_item(self, order: 'Order', product_id: str) -> bool:
        print("❌ Cannot modify shipped order")
        return False
    
    def cancel(self, order: 'Order') -> bool:
        print("❌ Cannot cancel shipped order")
        return False
    
    def process_payment(self, order: 'Order') -> bool:
        print("✅ Payment already processed")
        return True
    
    def ship(self, order: 'Order') -> bool:
        print("✅ Order already shipped")
        return True
    
    def deliver(self, order: 'Order') -> bool:
        print("📦 Order delivered to customer")
        return True
    
    def return_order(self, order: 'Order') -> bool:
        print("❌ Cannot return order in transit")
        return False
    
    def get_state_name(self) -> str:
        return "SHIPPED"

class DeliveredOrderState(OrderState):
    def add_item(self, order: 'Order', item: OrderItem) -> bool:
        print("❌ Cannot modify delivered order")
        return False
    
    def remove_item(self, order: 'Order', product_id: str) -> bool:
        print("❌ Cannot modify delivered order")
        return False
    
    def cancel(self, order: 'Order') -> bool:
        print("❌ Cannot cancel delivered order")
        return False
    
    def process_payment(self, order: 'Order') -> bool:
        print("✅ Payment already processed")
        return True
    
    def ship(self, order: 'Order') -> bool:
        print("✅ Order already delivered")
        return True
    
    def deliver(self, order: 'Order') -> bool:
        print("✅ Order already delivered")
        return True
    
    def return_order(self, order: 'Order') -> bool:
        print("🔄 Processing return for delivered order")
        return True
    
    def get_state_name(self) -> str:
        return "DELIVERED"

class CancelledOrderState(OrderState):
    def add_item(self, order: 'Order', item: OrderItem) -> bool:
        print("❌ Cannot modify cancelled order")
        return False
    
    def remove_item(self, order: 'Order', product_id: str) -> bool:
        print("❌ Cannot modify cancelled order")
        return False
    
    def cancel(self, order: 'Order') -> bool:
        print("✅ Order already cancelled")
        return True
    
    def process_payment(self, order: 'Order') -> bool:
        print("❌ Cannot process payment for cancelled order")
        return False
    
    def ship(self, order: 'Order') -> bool:
        print("❌ Cannot ship cancelled order")
        return False
    
    def deliver(self, order: 'Order') -> bool:
        print("❌ Cannot deliver cancelled order")
        return False
    
    def return_order(self, order: 'Order') -> bool:
        print("❌ Cannot return cancelled order")
        return False
    
    def get_state_name(self) -> str:
        return "CANCELLED"

class ReturnedOrderState(OrderState):
    def add_item(self, order: 'Order', item: OrderItem) -> bool:
        print("❌ Cannot modify returned order")
        return False
    
    def remove_item(self, order: 'Order', product_id: str) -> bool:
        print("❌ Cannot modify returned order")
        return False
    
    def cancel(self, order: 'Order') -> bool:
        print("❌ Cannot cancel returned order")
        return False
    
    def process_payment(self, order: 'Order') -> bool:
        print("❌ Cannot process payment for returned order")
        return False
    
    def ship(self, order: 'Order') -> bool:
        print("❌ Cannot ship returned order")
        return False
    
    def deliver(self, order: 'Order') -> bool:
        print("❌ Cannot deliver returned order")
        return False
    
    def return_order(self, order: 'Order') -> bool:
        print("✅ Order already returned")
        return True
    
    def get_state_name(self) -> str:
        return "RETURNED"

# Order Context
class Order:
    def __init__(self, customer_id: str, customer_name: str):
        self.order_id = str(uuid.uuid4())[:8]
        self.customer_id = customer_id
        self.customer_name = customer_name
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
        self.items: List[OrderItem] = []
        self.total_amount = 0.0
        self.payment_status = PaymentStatus.PENDING
        self.shipping_status = ShippingStatus.PENDING
        self._state: OrderState = NewOrderState()
        self.history: List[Dict[str, Any]] = []
        
        self._add_history("Order created")
    
    def set_state(self, new_state: OrderState):
        old_state = self._state.get_state_name()
        self._state = new_state
        self.updated_at = datetime.now()
        self._add_history(f"State changed: {old_state} → {new_state.get_state_name()}")
        print(f"🔄 Order state changed: {old_state} → {new_state.get_state_name()}")
    
    def calculate_total(self):
        self.total_amount = sum(item.total_price for item in self.items)
    
    def _add_history(self, event: str):
        self.history.append({
            'timestamp': datetime.now(),
            'event': event,
            'state': self._state.get_state_name()
        })
    
    # State operations
    def add_item(self, item: OrderItem) -> bool:
        if self._state.add_item(self, item):
            self._add_history(f"Added item: {item.product_name}")
            return True
        return False
    
    def remove_item(self, product_id: str) -> bool:
        if self._state.remove_item(self, product_id):
            self._add_history(f"Removed item: {product_id}")
            return True
        return False
    
    def cancel(self) -> bool:
        if self._state.cancel(self):
            self.set_state(CancelledOrderState())
            self._add_history("Order cancelled")
            return True
        return False
    
    def process_payment(self) -> bool:
        if self._state.process_payment(self):
            self.payment_status = PaymentStatus.COMPLETED
            self.set_state(PaidOrderState())
            self._add_history("Payment processed")
            return True
        return False
    
    def ship(self) -> bool:
        if self._state.ship(self):
            self.shipping_status = ShippingStatus.SHIPPED
            self.set_state(ShippedOrderState())
            self._add_history("Order shipped")
            return True
        return False
    
    def deliver(self) -> bool:
        if self._state.deliver(self):
            self.shipping_status = ShippingStatus.DELIVERED
            self.set_state(DeliveredOrderState())
            self._add_history("Order delivered")
            return True
        return False
    
    def return_order(self) -> bool:
        if self._state.return_order(self):
            self.shipping_status = ShippingStatus.RETURNED
            self.set_state(ReturnedOrderState())
            self._add_history("Order returned")
            return True
        return False
    
    def get_status(self) -> str:
        return self._state.get_state_name()
    
    def display_info(self):
        print(f"\n=== Order #{self.order_id} ===")
        print(f"Customer: {self.customer_name}")
        print(f"Status: {self.get_status()}")
        print(f"Payment: {self.payment_status.value}")
        print(f"Shipping: {self.shipping_status.value}")
        print(f"Total: ${self.total_amount:.2f}")
        print(f"Created: {self.created_at}")
        print(f"Updated: {self.updated_at}")
        
        print(f"\nItems ({len(self.items)}):")
        for item in self.items:
            print(f"  - {item}")
        
        print(f"\nRecent History:")
        for event in self.history[-5:]:
            print(f"  {event['timestamp'].strftime('%H:%M:%S')} - {event['event']}")

# Order Management System
class OrderManager:
    def __init__(self):
        self.orders: Dict[str, Order] = {}
    
    def create_order(self, customer_id: str, customer_name: str) -> Order:
        order = Order(customer_id, customer_name)
        self.orders[order.order_id] = order
        print(f"📝 Created new order #{order.order_id} for {customer_name}")
        return order
    
    def process_complete_workflow(self, order: Order):
        print(f"\n🎬 Processing complete workflow for order #{order.order_id}")
        
        # Add items
        order.add_item(OrderItem("P001", "Laptop", 1, 999.99))
        order.add_item(OrderItem("P002", "Mouse", 2, 29.99))
        
        # Process payment
        order.process_payment()
        
        # Ship order
        order.ship()
        
        # Deliver order
        order.deliver()
        
        order.display_info()
    
    def process_return_workflow(self, order: Order):
        print(f"\n🔄 Processing return workflow for order #{order.order_id}")
        
        # Return order
        order.return_order()
        
        order.display_info()

# Demo function
def orderProcessingDemo():
    print("=== State Pattern - Order Processing System ===\n")
    
    manager = OrderManager()
    
    # Test normal workflow
    print("--- Normal Order Workflow ---")
    order1 = manager.create_order("C001", "Alice Johnson")
    order1.add_item(OrderItem("P001", "Smartphone", 1, 699.99))
    order1.add_item(OrderItem("P003", "Phone Case", 1, 19.99))
    order1.display_info()
    
    order1.process_payment()
    order1.ship()
    order1.deliver()
    order1.display_info()
    
    # Test cancellation workflow
    print("\n--- Cancellation Workflow ---")
    order2 = manager.create_order("C002", "Bob Smith")
    order2.add_item(OrderItem("P004", "Headphones", 1, 149.99))
    order2.display_info()
    
    order2.cancel()
    order2.display_info()
    
    # Test return workflow
    print("\n--- Return Workflow ---")
    order3 = manager.create_order("C003", "Charlie Brown")
    order3.add_item(OrderItem("P005", "Tablet", 1, 399.99))
    order3.process_payment()
    order3.ship()
    order3.deliver()
    order3.return_order()
    order3.display_info()
    
    # Test invalid operations
    print("\n--- Testing Invalid Operations ---")
    order4 = manager.create_order("C004", "Diana Prince")
    order4.add_item(OrderItem("P006", "Camera", 1, 499.99))
    order4.process_payment()
    
    # Try to add item after payment
    order4.add_item(OrderItem("P007", "Lens", 1, 199.99))  # Should fail
    
    # Try to ship before payment
    order5 = manager.create_order("C005", "Bruce Wayne")
    order5.add_item(OrderItem("P008", "Drone", 1, 299.99))
    order5.ship()  # Should fail
    
    print("\n--- Complete Workflow Simulation ---")
    order6 = manager.create_order("C006", "Clark Kent")
    manager.process_complete_workflow(order6)

if __name__ == "__main__":
    orderProcessingDemo()
```

## Advantages and Disadvantages

### Advantages

- **Eliminates Conditionals**: Replaces complex conditional logic with polymorphism
- **Single Responsibility**: Each state class has its own responsibility
- **Open/Closed Principle**: Easy to add new states without changing existing code
- **Simplifies Context**: Context code becomes simpler and more maintainable
- **Explicit State Transitions**: State transitions become explicit and clear

### Disadvantages

- **Overkill for Simple State Machines**: Can be overkill for state machines with few states
- **Increased Number of Classes**: Each state becomes a separate class
- **State Knowledge**: States may need to know about other states for transitions
- **Complexity**: Can add complexity for simple state changes

## Best Practices

1. **Use for Complex State Machines**: When you have complex state-dependent behavior
2. **Keep State Classes Stateless**: State objects should be stateless and reusable
3. **Define Clear State Transitions**: Document allowed transitions between states
4. **Use State Pattern with Strategy**: Combine with Strategy pattern for more flexibility
5. **Consider State Entry/Exit Actions**: Implement entry and exit actions for states

## State vs Other Patterns

- **vs Strategy**: State pattern changes behavior based on state, Strategy changes algorithm
- **vs Command**: State encapsulates state-dependent behavior, Command encapsulates requests
- **vs Memento**: State manages current behavior, Memento captures and restores state
- **vs Observer**: State manages internal state changes, Observer notifies external objects

The State pattern is particularly useful in scenarios where an object's behavior depends on its state, and it must change its behavior at runtime depending on that state. It's widely used in game development, workflow systems, UI components, and any system with complex state-dependent behavior.
