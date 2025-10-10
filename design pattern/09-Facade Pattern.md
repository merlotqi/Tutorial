# Facade Pattern

## Introduction

The Facade pattern is a structural design pattern that provides a simplified interface to a complex subsystem of classes, library, or framework. It hides the complexities of the underlying system and provides a unified, higher-level interface that makes the subsystem easier to use.

### Key Characteristics

- **Simplified Interface**: Provides a simple, unified interface to a complex subsystem
- **Decoupling**: Reduces dependencies between clients and subsystem components
- **Ease of Use**: Makes subsystem easier to use and understand
- **Single Entry Point**: Acts as a single point of entry to the subsystem

### Use Cases

- When you need to provide a simple interface to a complex subsystem
- When you want to decouple clients from subsystem components
- When you need to layer your subsystems and provide entry points to each layer
- When you want to wrap a poorly designed or complex API with a better one
- When you need to reduce dependencies between clients and implementation classes

## Implementation Examples

### C++ Implementation

#### Home Theater Facade Example

```cpp
#include <iostream>
#include <memory>
#include <string>

// Complex subsystem classes
class Amplifier {
private:
    int volume;
    bool isOn;

public:
    Amplifier() : volume(0), isOn(false) {}
    
    void on() {
        isOn = true;
        std::cout << "Amplifier is ON" << std::endl;
    }
    
    void off() {
        isOn = false;
        std::cout << "Amplifier is OFF" << std::endl;
    }
    
    void setVolume(int level) {
        volume = level;
        std::cout << "Amplifier volume set to " << level << std::endl;
    }
    
    void setSurroundSound() {
        std::cout << "Amplifier surround sound enabled" << std::endl;
    }
};

class DVDPlayer {
private:
    bool isOn;
    std::string movie;

public:
    DVDPlayer() : isOn(false) {}
    
    void on() {
        isOn = true;
        std::cout << "DVD Player is ON" << std::endl;
    }
    
    void off() {
        isOn = false;
        std::cout << "DVD Player is OFF" << std::endl;
    }
    
    void play(const std::string& movieTitle) {
        movie = movieTitle;
        std::cout << "DVD Player playing: " << movie << std::endl;
    }
    
    void stop() {
        std::cout << "DVD Player stopped: " << movie << std::endl;
        movie = "";
    }
    
    void eject() {
        std::cout << "DVD Player eject" << std::endl;
    }
};

class Projector {
private:
    bool isOn;

public:
    Projector() : isOn(false) {}
    
    void on() {
        isOn = true;
        std::cout << "Projector is ON" << std::endl;
    }
    
    void off() {
        isOn = false;
        std::cout << "Projector is OFF" << std::endl;
    }
    
    void wideScreenMode() {
        std::cout << "Projector in widescreen mode" << std::endl;
    }
};

class Screen {
public:
    void down() {
        std::cout << "Screen going down" << std::endl;
    }
    
    void up() {
        std::cout << "Screen going up" << std::endl;
    }
};

class TheaterLights {
public:
    void dim(int level) {
        std::cout << "Theater lights dimming to " << level << "%" << std::endl;
    }
    
    void on() {
        std::cout << "Theater lights ON" << std::endl;
    }
};

class PopcornPopper {
public:
    void on() {
        std::cout << "Popcorn popper ON" << std::endl;
    }
    
    void off() {
        std::cout << "Popcorn popper OFF" << std::endl;
    }
    
    void pop() {
        std::cout << "Popcorn popper popping popcorn!" << std::endl;
    }
};

// Facade class
class HomeTheaterFacade {
private:
    std::unique_ptr<Amplifier> amp;
    std::unique_ptr<DVDPlayer> dvd;
    std::unique_ptr<Projector> projector;
    std::unique_ptr<Screen> screen;
    std::unique_ptr<TheaterLights> lights;
    std::unique_ptr<PopcornPopper> popper;

public:
    HomeTheaterFacade() {
        amp = std::make_unique<Amplifier>();
        dvd = std::make_unique<DVDPlayer>();
        projector = std::make_unique<Projector>();
        screen = std::make_unique<Screen>();
        lights = std::make_unique<TheaterLights>();
        popper = std::make_unique<PopcornPopper>();
    }
    
    void watchMovie(const std::string& movie) {
        std::cout << "\n=== Getting ready to watch a movie ===" << std::endl;
        popper->on();
        popper->pop();
        lights->dim(10);
        screen->down();
        projector->on();
        projector->wideScreenMode();
        amp->on();
        amp->setSurroundSound();
        amp->setVolume(5);
        dvd->on();
        dvd->play(movie);
        std::cout << "=== Movie ready! ===" << std::endl;
    }
    
    void endMovie() {
        std::cout << "\n=== Shutting down home theater ===" << std::endl;
        popper->off();
        lights->on();
        screen->up();
        projector->off();
        amp->off();
        dvd->stop();
        dvd->eject();
        dvd->off();
        std::cout << "=== Home theater shutdown complete ===" << std::endl;
    }
    
    void listenToMusic() {
        std::cout << "\n=== Setting up for music ===" << std::endl;
        lights->on();
        amp->on();
        amp->setVolume(3);
        std::cout << "=== Music ready! ===" << std::endl;
    }
    
    void stopMusic() {
        std::cout << "\n=== Stopping music ===" << std::endl;
        amp->off();
        std::cout << "=== Music stopped ===" << std::endl;
    }
};

// Usage example
int main() {
    HomeTheaterFacade homeTheater;
    
    // Watch a movie using the simple facade interface
    homeTheater.watchMovie("The Matrix");
    std::cout << "\n... Enjoying the movie ...\n" << std::endl;
    homeTheater.endMovie();
    
    std::cout << "\n" << std::string(50, '=') << std::endl;
    
    // Listen to music
    homeTheater.listenToMusic();
    std::cout << "\n... Enjoying the music ...\n" << std::endl;
    homeTheater.stopMusic();
    
    return 0;
}
```

#### Computer System Facade Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>

// Complex subsystem classes
class CPU {
public:
    void freeze() {
        std::cout << "CPU: Freezing processor..." << std::endl;
    }
    
    void jump(long position) {
        std::cout << "CPU: Jumping to position " << position << std::endl;
    }
    
    void execute() {
        std::cout << "CPU: Executing instructions..." << std::endl;
    }
};

class Memory {
private:
    std::vector<char> data;

public:
    Memory() {
        // Simulate memory initialization
        data.resize(1024, 0);
        std::cout << "Memory: Initialized with 1KB" << std::endl;
    }
    
    void load(long position, const std::vector<char>& dataToLoad) {
        std::cout << "Memory: Loading data at position " << position << std::endl;
        // Simulate memory loading
    }
    
    char read(long position) {
        std::cout << "Memory: Reading from position " << position << std::endl;
        return data[position];
    }
};

class HardDrive {
public:
    std::vector<char> read(long lba, int size) {
        std::cout << "HardDrive: Reading " << size << " bytes from LBA " << lba << std::endl;
        return std::vector<char>(size, 0); // Simulate data
    }
};

class Display {
public:
    void show(const std::string& message) {
        std::cout << "Display: " << message << std::endl;
    }
    
    void clear() {
        std::cout << "Display: Screen cleared" << std::endl;
    }
};

class Keyboard {
public:
    bool hasKeyPress() {
        // Simulate keyboard input check
        return true;
    }
    
    char getKey() {
        // Simulate getting a key press
        return 'A';
    }
};

class NetworkInterface {
public:
    bool connect(const std::string& address) {
        std::cout << "Network: Connecting to " << address << std::endl;
        return true;
    }
    
    void disconnect() {
        std::cout << "Network: Disconnected" << std::endl;
    }
    
    std::vector<char> receiveData() {
        std::cout << "Network: Receiving data..." << std::endl;
        return std::vector<char>(1024, 0); // Simulate received data
    }
};

// Computer Facade
class ComputerFacade {
private:
    std::unique_ptr<CPU> cpu;
    std::unique_ptr<Memory> memory;
    std::unique_ptr<HardDrive> hardDrive;
    std::unique_ptr<Display> display;
    std::unique_ptr<Keyboard> keyboard;
    std::unique_ptr<NetworkInterface> network;

public:
    ComputerFacade() {
        cpu = std::make_unique<CPU>();
        memory = std::make_unique<Memory>();
        hardDrive = std::make_unique<HardDrive>();
        display = std::make_unique<Display>();
        keyboard = std::make_unique<Keyboard>();
        network = std::make_unique<NetworkInterface>();
    }
    
    void start() {
        std::cout << "=== Computer Starting Up ===" << std::endl;
        cpu->freeze();
        
        // Load BIOS from hard drive
        auto biosData = hardDrive->read(0, 512);
        memory->load(0, biosData);
        
        cpu->jump(0);
        cpu->execute();
        
        display->show("Welcome to Computer System");
        std::cout << "=== Computer Ready ===" << std::endl;
    }
    
    void shutdown() {
        std::cout << "=== Computer Shutting Down ===" << std::endl;
        display->show("System shutting down...");
        display->clear();
        std::cout << "=== Computer Off ===" << std::endl;
    }
    
    void browseWeb(const std::string& url) {
        std::cout << "=== Starting Web Browser ===" << std::endl;
        
        if (network->connect(url)) {
            display->show("Connected to: " + url);
            auto webData = network->receiveData();
            memory->load(0x1000, webData);
            display->show("Web page loaded");
        }
        
        network->disconnect();
        std::cout << "=== Web Browsing Complete ===" << std::endl;
    }
    
    void runApplication(const std::string& appName) {
        std::cout << "=== Running " << appName << " ===" << std::endl;
        display->show("Launching: " + appName);
        
        // Simulate application loading and execution
        auto appData = hardDrive->read(1024, 2048);
        memory->load(0x2000, appData);
        cpu->jump(0x2000);
        cpu->execute();
        
        display->show(appName + " is running");
        std::cout << "=== " << appName << " Finished ===" << std::endl;
    }
};

// Usage example
int main() {
    ComputerFacade computer;
    
    // Simple interface to complex computer operations
    computer.start();
    std::cout << std::endl;
    
    computer.runApplication("Text Editor");
    std::cout << std::endl;
    
    computer.browseWeb("http://example.com");
    std::cout << std::endl;
    
    computer.shutdown();
    
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Subsystem: Audio System
typedef struct {
    void (*power_on)(void);
    void (*power_off)(void);
    void (*set_volume)(int level);
    void (*set_source)(const char* source);
} AudioSystem;

void audio_power_on(void) {
    printf("Audio System: Power ON\n");
}

void audio_power_off(void) {
    printf("Audio System: Power OFF\n");
}

void audio_set_volume(int level) {
    printf("Audio System: Volume set to %d\n", level);
}

void audio_set_source(const char* source) {
    printf("Audio System: Source set to %s\n", source);
}

AudioSystem create_audio_system(void) {
    AudioSystem audio;
    audio.power_on = audio_power_on;
    audio.power_off = audio_power_off;
    audio.set_volume = audio_set_volume;
    audio.set_source = audio_set_source;
    return audio;
}

// Subsystem: Video System
typedef struct {
    void (*power_on)(void);
    void (*power_off)(void);
    void (*set_resolution)(const char* resolution);
    void (*set_input)(const char* input);
} VideoSystem;

void video_power_on(void) {
    printf("Video System: Power ON\n");
}

void video_power_off(void) {
    printf("Video System: Power OFF\n");
}

void video_set_resolution(const char* resolution) {
    printf("Video System: Resolution set to %s\n", resolution);
}

void video_set_input(const char* input) {
    printf("Video System: Input set to %s\n", input);
}

VideoSystem create_video_system(void) {
    VideoSystem video;
    video.power_on = video_power_on;
    video.power_off = video_power_off;
    video.set_resolution = video_set_resolution;
    video.set_input = video_set_input;
    return video;
}

// Subsystem: Lighting System
typedef struct {
    void (*dim_lights)(int level);
    void (*normal_lights)(void);
    void (*set_color)(const char* color);
} LightingSystem;

void lighting_dim_lights(int level) {
    printf("Lighting System: Lights dimmed to %d%%\n", level);
}

void lighting_normal_lights(void) {
    printf("Lighting System: Lights set to normal\n");
}

void lighting_set_color(const char* color) {
    printf("Lighting System: Color set to %s\n", color);
}

LightingSystem create_lighting_system(void) {
    LightingSystem lighting;
    lighting.dim_lights = lighting_dim_lights;
    lighting.normal_lights = lighting_normal_lights;
    lighting.set_color = lighting_set_color;
    return lighting;
}

// Subsystem: Climate Control
typedef struct {
    void (*set_temperature)(float temp);
    void (*set_fan_speed)(int speed);
    void (*set_mode)(const char* mode);
} ClimateControl;

void climate_set_temperature(float temp) {
    printf("Climate Control: Temperature set to %.1f°C\n", temp);
}

void climate_set_fan_speed(int speed) {
    printf("Climate Control: Fan speed set to %d\n", speed);
}

void climate_set_mode(const char* mode) {
    printf("Climate Control: Mode set to %s\n", mode);
}

ClimateControl create_climate_control(void) {
    ClimateControl climate;
    climate.set_temperature = climate_set_temperature;
    climate.set_fan_speed = climate_set_fan_speed;
    climate.set_mode = climate_set_mode;
    return climate;
}

// Home Automation Facade
typedef struct {
    AudioSystem audio;
    VideoSystem video;
    LightingSystem lighting;
    ClimateControl climate;
} HomeAutomationFacade;

void home_cinema_mode(HomeAutomationFacade* home) {
    printf("\n=== Home Cinema Mode ===\n");
    home->lighting.dim_lights(20);
    home->climate.set_temperature(22.0);
    home->climate.set_fan_speed(1);
    home->audio.power_on();
    home->audio.set_volume(60);
    home->audio.set_source("Blu-ray Player");
    home->video.power_on();
    home->video.set_resolution("4K");
    home->video.set_input("HDMI 1");
    printf("=== Cinema Mode Ready ===\n");
}

void home_party_mode(HomeAutomationFacade* home) {
    printf("\n=== Home Party Mode ===\n");
    home->lighting.normal_lights();
    home->lighting.set_color("Colorful");
    home->climate.set_temperature(20.0);
    home->climate.set_fan_speed(3);
    home->audio.power_on();
    home->audio.set_volume(80);
    home->audio.set_source("Streaming Service");
    home->video.power_on();
    home->video.set_resolution("1080p");
    home->video.set_input("Chromecast");
    printf("=== Party Mode Ready ===\n");
}

void home_reading_mode(HomeAutomationFacade* home) {
    printf("\n=== Home Reading Mode ===\n");
    home->lighting.normal_lights();
    home->climate.set_temperature(23.0);
    home->climate.set_fan_speed(1);
    home->climate.set_mode("Quiet");
    home->audio.power_off();
    home->video.power_off();
    printf("=== Reading Mode Ready ===\n");
}

void home_shutdown_all(HomeAutomationFacade* home) {
    printf("\n=== Shutting Down All Systems ===\n");
    home->audio.power_off();
    home->video.power_off();
    home->lighting.normal_lights();
    home->climate.set_temperature(21.0);
    home->climate.set_fan_speed(0);
    printf("=== All Systems Off ===\n");
}

// Usage example
int main() {
    printf("=== Home Automation System ===\n");
    
    // Create subsystem components
    AudioSystem audio = create_audio_system();
    VideoSystem video = create_video_system();
    LightingSystem lighting = create_lighting_system();
    ClimateControl climate = create_climate_control();
    
    // Create facade
    HomeAutomationFacade home = {
        .audio = audio,
        .video = video,
        .lighting = lighting,
        .climate = climate
    };
    
    // Use simple facade interface
    home_cinema_mode(&home);
    printf("\n... Enjoying the movie ...\n");
    
    home_party_mode(&home);
    printf("\n... Party time! ...\n");
    
    home_reading_mode(&home);
    printf("\n... Reading time ...\n");
    
    home_shutdown_all(&home);
    
    return 0;
}
```

### Python Implementation

#### E-commerce Order Processing Facade

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Optional
from datetime import datetime
import random

# Complex subsystem classes
class InventoryService:
    def __init__(self):
        self._products = {
            "001": {"name": "Laptop", "price": 999.99, "stock": 10},
            "002": {"name": "Mouse", "price": 29.99, "stock": 50},
            "003": {"name": "Keyboard", "price": 79.99, "stock": 30},
            "004": {"name": "Monitor", "price": 299.99, "stock": 15},
        }
    
    def check_stock(self, product_id: str, quantity: int) -> bool:
        product = self._products.get(product_id)
        if not product:
            return False
        return product["stock"] >= quantity
    
    def reserve_items(self, product_id: str, quantity: int) -> bool:
        if self.check_stock(product_id, quantity):
            self._products[product_id]["stock"] -= quantity
            print(f"Inventory: Reserved {quantity} of {self._products[product_id]['name']}")
            return True
        return False
    
    def get_product_info(self, product_id: str) -> Optional[Dict]:
        return self._products.get(product_id)

class PaymentService:
    def process_payment(self, amount: float, card_number: str, cvv: str) -> bool:
        print(f"Payment: Processing ${amount:.2f} payment")
        # Simulate payment processing
        if len(card_number) == 16 and len(cvv) == 3:
            print("Payment: Payment successful")
            return True
        print("Payment: Payment failed")
        return False
    
    def refund_payment(self, transaction_id: str, amount: float) -> bool:
        print(f"Payment: Refunding ${amount:.2f} for transaction {transaction_id}")
        return True

class ShippingService:
    def __init__(self):
        self._shipping_methods = {
            "standard": {"cost": 5.99, "days": 5},
            "express": {"cost": 12.99, "days": 2},
            "overnight": {"cost": 24.99, "days": 1},
        }
    
    def calculate_shipping(self, items: List[Dict], method: str) -> float:
        base_cost = self._shipping_methods[method]["cost"]
        # Add $1 per item for simplicity
        total_cost = base_cost + (len(items) * 1.0)
        print(f"Shipping: {method} shipping cost: ${total_cost:.2f}")
        return total_cost
    
    def schedule_delivery(self, order_id: str, address: Dict, method: str) -> str:
        delivery_days = self._shipping_methods[method]["days"]
        delivery_date = datetime.now().replace(day=datetime.now().day + delivery_days)
        tracking_number = f"TRK{random.randint(100000, 999999)}"
        
        print(f"Shipping: Scheduled {method} delivery for order {order_id}")
        print(f"Shipping: Estimated delivery: {delivery_date.strftime('%Y-%m-%d')}")
        print(f"Shipping: Tracking number: {tracking_number}")
        
        return tracking_number

class NotificationService:
    def send_order_confirmation(self, email: str, order_details: Dict) -> bool:
        print(f"Notification: Sent order confirmation to {email}")
        print(f"  Order ID: {order_details['order_id']}")
        print(f"  Total: ${order_details['total']:.2f}")
        return True
    
    def send_shipping_notification(self, email: str, tracking_number: str) -> bool:
        print(f"Notification: Sent shipping notification to {email}")
        print(f"  Tracking: {tracking_number}")
        return True
    
    def send_payment_receipt(self, email: str, amount: float) -> bool:
        print(f"Notification: Sent payment receipt to {email}")
        print(f"  Amount: ${amount:.2f}")
        return True

class OrderService:
    def __init__(self):
        self._orders = {}
        self._next_order_id = 1000
    
    def create_order(self, items: List[Dict], customer_info: Dict) -> str:
        order_id = f"ORD{self._next_order_id}"
        self._next_order_id += 1
        
        order = {
            "order_id": order_id,
            "items": items,
            "customer_info": customer_info,
            "status": "created",
            "created_at": datetime.now()
        }
        
        self._orders[order_id] = order
        print(f"Order: Created order {order_id}")
        return order_id
    
    def update_order_status(self, order_id: str, status: str) -> bool:
        if order_id in self._orders:
            self._orders[order_id]["status"] = status
            print(f"Order: Updated {order_id} status to {status}")
            return True
        return False
    
    def get_order(self, order_id: str) -> Optional[Dict]:
        return self._orders.get(order_id)

# E-commerce Facade
class ECommerceFacade:
    def __init__(self):
        self.inventory = InventoryService()
        self.payment = PaymentService()
        self.shipping = ShippingService()
        self.notification = NotificationService()
        self.order = OrderService()
    
    def place_order(self, 
                   items: List[Dict], 
                   customer_info: Dict, 
                   payment_info: Dict,
                   shipping_method: str = "standard") -> Dict[str, str]:
        """
        Simplified interface for placing an order
        """
        print("=== Processing New Order ===")
        
        # Step 1: Validate inventory
        for item in items:
            if not self.inventory.check_stock(item["product_id"], item["quantity"]):
                raise Exception(f"Product {item['product_id']} out of stock")
        
        # Step 2: Create order
        order_id = self.order.create_order(items, customer_info)
        
        # Step 3: Reserve items
        for item in items:
            self.inventory.reserve_items(item["product_id"], item["quantity"])
        
        # Step 4: Calculate total
        subtotal = sum(
            self.inventory.get_product_info(item["product_id"])["price"] * item["quantity"]
            for item in items
        )
        shipping_cost = self.shipping.calculate_shipping(items, shipping_method)
        total = subtotal + shipping_cost
        
        # Step 5: Process payment
        if not self.payment.process_payment(total, payment_info["card_number"], payment_info["cvv"]):
            self.order.update_order_status(order_id, "payment_failed")
            raise Exception("Payment processing failed")
        
        # Step 6: Schedule shipping
        tracking_number = self.shipping.schedule_delivery(
            order_id, customer_info["address"], shipping_method
        )
        
        # Step 7: Update order status
        self.order.update_order_status(order_id, "confirmed")
        
        # Step 8: Send notifications
        order_details = {
            "order_id": order_id,
            "items": items,
            "subtotal": subtotal,
            "shipping": shipping_cost,
            "total": total
        }
        
        self.notification.send_order_confirmation(customer_info["email"], order_details)
        self.notification.send_shipping_notification(customer_info["email"], tracking_number)
        self.notification.send_payment_receipt(customer_info["email"], total)
        
        print("=== Order Processing Complete ===\n")
        
        return {
            "order_id": order_id,
            "tracking_number": tracking_number,
            "total": total,
            "status": "confirmed"
        }
    
    def cancel_order(self, order_id: str) -> bool:
        """
        Simplified interface for canceling an order
        """
        print(f"=== Canceling Order {order_id} ===")
        
        order = self.order.get_order(order_id)
        if not order:
            print("Order not found")
            return False
        
        # Refund payment
        total = sum(
            self.inventory.get_product_info(item["product_id"])["price"] * item["quantity"]
            for item in order["items"]
        )
        shipping_cost = self.shipping.calculate_shipping(order["items"], "standard")
        total += shipping_cost
        
        self.payment.refund_payment(order_id, total)
        
        # Restore inventory
        for item in order["items"]:
            self.inventory._products[item["product_id"]]["stock"] += item["quantity"]
        
        # Update order status
        self.order.update_order_status(order_id, "cancelled")
        
        # Send notification
        self.notification.send_order_confirmation(
            order["customer_info"]["email"],
            {"order_id": order_id, "total": -total, "status": "refunded"}
        )
        
        print("=== Order Cancellation Complete ===\n")
        return True
    
    def get_order_status(self, order_id: str) -> Optional[Dict]:
        """
        Get order status and details
        """
        return self.order.get_order(order_id)

# Usage example
def ecommerce_demo():
    print("=== E-Commerce System Demo ===\n")
    
    facade = ECommerceFacade()
    
    # Sample order data
    items = [
        {"product_id": "001", "quantity": 1},  # Laptop
        {"product_id": "002", "quantity": 2},  # Mouse
    ]
    
    customer_info = {
        "name": "John Doe",
        "email": "john.doe@example.com",
        "address": {
            "street": "123 Main St",
            "city": "Anytown",
            "state": "CA",
            "zip": "12345"
        }
    }
    
    payment_info = {
        "card_number": "4111111111111111",
        "cvv": "123"
    }
    
    try:
        # Place an order using the simple facade interface
        result = facade.place_order(
            items=items,
            customer_info=customer_info,
            payment_info=payment_info,
            shipping_method="express"
        )
        
        print(f"Order Result: {result}\n")
        
        # Check order status
        order_status = facade.get_order_status(result["order_id"])
        print(f"Order Status: {order_status['status']}\n")
        
        # Cancel order
        facade.cancel_order(result["order_id"])
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    ecommerce_demo()
```

#### Banking System Facade

```python
from abc import ABC, abstractmethod
from typing import Dict, List, Optional
from datetime import datetime
import hashlib
import random

# Complex banking subsystem
class AccountService:
    def __init__(self):
        self._accounts = {}
    
    def create_account(self, customer_id: str, account_type: str, initial_balance: float = 0.0) -> str:
        account_number = f"ACC{random.randint(100000, 999999)}"
        self._accounts[account_number] = {
            "customer_id": customer_id,
            "type": account_type,
            "balance": initial_balance,
            "created_date": datetime.now(),
            "status": "active"
        }
        print(f"AccountService: Created {account_type} account {account_number}")
        return account_number
    
    def get_account(self, account_number: str) -> Optional[Dict]:
        return self._accounts.get(account_number)
    
    def update_balance(self, account_number: str, amount: float) -> bool:
        if account_number in self._accounts:
            self._accounts[account_number]["balance"] += amount
            return True
        return False
    
    def close_account(self, account_number: str) -> bool:
        if account_number in self._accounts:
            self._accounts[account_number]["status"] = "closed"
            print(f"AccountService: Closed account {account_number}")
            return True
        return False

class TransactionService:
    def __init__(self):
        self._transactions = []
    
    def record_transaction(self, 
                         from_account: str, 
                         to_account: str, 
                         amount: float, 
                         transaction_type: str) -> str:
        transaction_id = f"TXN{random.randint(100000, 999999)}"
        transaction = {
            "id": transaction_id,
            "from_account": from_account,
            "to_account": to_account,
            "amount": amount,
            "type": transaction_type,
            "timestamp": datetime.now(),
            "status": "completed"
        }
        self._transactions.append(transaction)
        print(f"TransactionService: Recorded {transaction_type} - ${amount:.2f}")
        return transaction_id
    
    def get_transaction_history(self, account_number: str) -> List[Dict]:
        return [
            txn for txn in self._transactions
            if txn["from_account"] == account_number or txn["to_account"] == account_number
        ]

class SecurityService:
    def __init__(self):
        self._failed_attempts = {}
    
    def authenticate_user(self, username: str, password: str) -> bool:
        # Simple authentication (in real system, use proper hashing)
        expected_hash = hashlib.md5(f"{username}:{password}".encode()).hexdigest()
        stored_hash = "5f4dcc3b5aa765d61d8327deb882cf99"  # "password" hash
        
        if expected_hash == stored_hash:
            self._failed_attempts[username] = 0
            print(f"SecurityService: User {username} authenticated")
            return True
        else:
            self._failed_attempts[username] = self._failed_attempts.get(username, 0) + 1
            print(f"SecurityService: Authentication failed for {username}")
            return False
    
    def check_fraud(self, transaction: Dict) -> bool:
        # Simple fraud detection
        if transaction["amount"] > 10000:
            print(f"SecurityService: Flagged large transaction for review")
            return True
        return False
    
    def log_security_event(self, event: str, user: str) -> None:
        print(f"SecurityService: {event} - User: {user}")

class NotificationService:
    def send_sms(self, phone_number: str, message: str) -> bool:
        print(f"NotificationService: SMS to {phone_number}: {message}")
        return True
    
    def send_email(self, email: str, subject: str, message: str) -> bool:
        print(f"NotificationService: Email to {email}: {subject} - {message}")
        return True
    
    def send_push_notification(self, device_id: str, message: str) -> bool:
        print(f"NotificationService: Push to {device_id}: {message}")
        return True

class LoanService:
    def __init__(self):
        self._loans = {}
    
    def apply_for_loan(self, customer_id: str, amount: float, loan_type: str) -> str:
        loan_id = f"LOAN{random.randint(100000, 999999)}"
        self._loans[loan_id] = {
            "customer_id": customer_id,
            "amount": amount,
            "type": loan_type,
            "status": "pending",
            "applied_date": datetime.now()
        }
        print(f"LoanService: Applied for {loan_type} loan - ${amount:.2f}")
        return loan_id
    
    def approve_loan(self, loan_id: str) -> bool:
        if loan_id in self._loans:
            self._loans[loan_id]["status"] = "approved"
            self._loans[loan_id]["approved_date"] = datetime.now()
            print(f"LoanService: Approved loan {loan_id}")
            return True
        return False
    
    def get_loan_status(self, loan_id: str) -> Optional[Dict]:
        return self._loans.get(loan_id)

# Banking System Facade
class BankingFacade:
    def __init__(self):
        self.accounts = AccountService()
        self.transactions = TransactionService()
        self.security = SecurityService()
        self.notifications = NotificationService()
        self.loans = LoanService()
    
    def open_bank_account(self, 
                         customer_info: Dict, 
                         account_type: str, 
                         initial_deposit: float = 0.0) -> Dict[str, str]:
        """
        Simplified interface for opening a bank account
        """
        print("=== Opening New Bank Account ===")
        
        # Authenticate user
        if not self.security.authenticate_user(customer_info["username"], customer_info["password"]):
            raise Exception("Authentication failed")
        
        # Create account
        account_number = self.accounts.create_account(
            customer_info["customer_id"], account_type, initial_deposit
        )
        
        # Record initial deposit if any
        if initial_deposit > 0:
            self.transactions.record_transaction(
                "BANK", account_number, initial_deposit, "initial_deposit"
            )
        
        # Send notification
        self.notifications.send_email(
            customer_info["email"],
            "Account Opened",
            f"Your {account_type} account {account_number} has been opened with initial deposit ${initial_deposit:.2f}"
        )
        
        print("=== Account Opening Complete ===\n")
        
        return {
            "account_number": account_number,
            "type": account_type,
            "initial_balance": initial_deposit
        }
    
    def transfer_money(self, 
                      from_account: str, 
                      to_account: str, 
                      amount: float, 
                      credentials: Dict) -> Dict[str, str]:
        """
        Simplified interface for money transfer
        """
        print("=== Processing Money Transfer ===")
        
        # Authenticate
        if not self.security.authenticate_user(credentials["username"], credentials["password"]):
            raise Exception("Authentication failed")
        
        # Check accounts
        from_acc = self.accounts.get_account(from_account)
        to_acc = self.accounts.get_account(to_account)
        
        if not from_acc or not to_acc:
            raise Exception("Invalid account number")
        
        if from_acc["balance"] < amount:
            raise Exception("Insufficient funds")
        
        # Check for fraud
        transaction_data = {
            "from_account": from_account,
            "to_account": to_account,
            "amount": amount,
            "type": "transfer"
        }
        
        if self.security.check_fraud(transaction_data):
            self.security.log_security_event("Suspicious transfer attempted", credentials["username"])
            raise Exception("Transfer flagged for review")
        
        # Process transfer
        self.accounts.update_balance(from_account, -amount)
        self.accounts.update_balance(to_account, amount)
        
        # Record transaction
        transaction_id = self.transactions.record_transaction(
            from_account, to_account, amount, "transfer"
        )
        
        # Send notifications
        from_customer = "Customer"  # In real system, get from customer service
        to_customer = "Recipient"   # In real system, get from customer service
        
        self.notifications.send_email(
            "from@example.com",  # In real system, use actual email
            "Transfer Sent",
            f"You transferred ${amount:.2f} to {to_account}"
        )
        
        print("=== Transfer Complete ===\n")
        
        return {
            "transaction_id": transaction_id,
            "from_account": from_account,
            "to_account": to_account,
            "amount": amount,
            "status": "completed"
        }
    
    def apply_for_loan(self, customer_info: Dict, loan_details: Dict) -> Dict[str, str]:
        """
        Simplified interface for loan application
        """
        print("=== Processing Loan Application ===")
        
        # Authenticate
        if not self.security.authenticate_user(customer_info["username"], customer_info["password"]):
            raise Exception("Authentication failed")
        
        # Apply for loan
        loan_id = self.loans.apply_for_loan(
            customer_info["customer_id"],
            loan_details["amount"],
            loan_details["type"]
        )
        
        # Auto-approve small personal loans (simplified)
        if loan_details["type"] == "personal" and loan_details["amount"] <= 5000:
            self.loans.approve_loan(loan_id)
            status = "approved"
            
            # If approved, disburse funds to account
            if loan_details.get("disburse_to_account"):
                self.accounts.update_balance(loan_details["disburse_to_account"], loan_details["amount"])
                self.transactions.record_transaction(
                    "BANK", loan_details["disburse_to_account"], loan_details["amount"], "loan_disbursement"
                )
        else:
            status = "pending_review"
        
        # Send notification
        self.notifications.send_email(
            customer_info["email"],
            "Loan Application",
            f"Your {loan_details['type']} loan application is {status}"
        )
        
        print("=== Loan Application Complete ===\n")
        
        return {
            "loan_id": loan_id,
            "amount": loan_details["amount"],
            "type": loan_details["type"],
            "status": status
        }
    
    def get_account_summary(self, account_number: str, credentials: Dict) -> Dict:
        """
        Get account summary with transaction history
        """
        if not self.security.authenticate_user(credentials["username"], credentials["password"]):
            raise Exception("Authentication failed")
        
        account = self.accounts.get_account(account_number)
        if not account:
            raise Exception("Account not found")
        
        transactions = self.transactions.get_transaction_history(account_number)
        
        return {
            "account_number": account_number,
            "type": account["type"],
            "balance": account["balance"],
            "status": account["status"],
            "recent_transactions": transactions[-5:]  # Last 5 transactions
        }

# Usage example
def banking_system_demo():
    print("=== Banking System Demo ===\n")
    
    facade = BankingFacade()
    
    customer_info = {
        "customer_id": "CUST123",
        "username": "johndoe",
        "password": "password",  # In real system, never store plain text passwords
        "email": "john.doe@example.com"
    }
    
    try:
        # Open a new account
        print("1. Opening new checking account...")
        account_result = facade.open_bank_account(
            customer_info=customer_info,
            account_type="checking",
            initial_deposit=1000.0
        )
        print(f"Account opened: {account_result}\n")
        
        # Transfer money
        print("2. Transferring money...")
        transfer_result = facade.transfer_money(
            from_account=account_result["account_number"],
            to_account="ACC999999",  # Some other account
            amount=200.0,
            credentials={"username": "johndoe", "password": "password"}
        )
        print(f"Transfer completed: {transfer_result}\n")
        
        # Apply for loan
        print("3. Applying for personal loan...")
        loan_result = facade.apply_for_loan(
            customer_info=customer_info,
            loan_details={
                "amount": 3000.0,
                "type": "personal",
                "disburse_to_account": account_result["account_number"]
            }
        )
        print(f"Loan application: {loan_result}\n")
        
        # Get account summary
        print("4. Getting account summary...")
        summary = facade.get_account_summary(
            account_number=account_result["account_number"],
            credentials={"username": "johndoe", "password": "password"}
        )
        print(f"Account Summary:")
        print(f"  Balance: ${summary['balance']:.2f}")
        print(f"  Recent Transactions: {len(summary['recent_transactions'])}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    banking_system_demo()
```

## Advantages and Disadvantages

### Advantages

- **Simplified Interface**: Provides a simple interface to a complex subsystem
- **Decoupling**: Reduces coupling between clients and subsystem components
- **Easier to Use**: Makes subsystem easier to use and understand
- **Single Responsibility**: Facade class has a single responsibility to simplify the subsystem
- **Improved Maintainability**: Changes to subsystem don't affect clients as long as facade interface remains the same

### Disadvantages

- **God Object Risk**: Facade can become a "god object" coupled to all subsystem classes
- **Limited Flexibility**: May not expose all functionality of the subsystem
- **Additional Layer**: Adds another layer of abstraction which can impact performance
- **Complex Facade**: Facade itself can become complex if subsystem is very large

## Best Practices

1. **Keep Facade Simple**: The facade should provide a truly simplified interface
2. **Use for Complex Subsystems**: Ideal for wrapping complex legacy systems or frameworks
3. **Don't Expose Internals**: Clients should not need to access subsystem classes directly
4. **Use Multiple Facades**: For very large systems, create multiple facades for different use cases
5. **Document the Interface**: Clearly document what the facade does and doesn't provide

## Facade vs Other Patterns

- **vs Adapter**: Facade simplifies an interface, Adapter converts one interface to another
- **vs Mediator**: Facade unidirectional (client to subsystem), Mediator bidirectional between colleagues
- **vs Proxy**: Facade provides simplified access, Proxy provides controlled access
- **vs Abstract Factory**: Facade simplifies usage, Abstract Factory creates related objects

The Facade pattern is particularly useful when you need to provide a simple interface to a complex subsystem, when you want to decouple clients from subsystem components, or when you need to layer your subsystems and provide entry points to each layer.
