# Factory Method Pattern

## Introduction

The Factory Method pattern is a creational design pattern that provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created.

### Key Characteristics

- **Encapsulation**: Encapsulates object creation logic
- **Flexibility**: Allows subclasses to decide which class to instantiate
- **Loose Coupling**: Client code works with interfaces rather than concrete implementations
- **Extensibility**: Easy to add new product types without modifying existing code

### Use Cases

- When a class cannot anticipate the class of objects it must create
- When you want to provide a library of products and only reveal their interfaces
- When you want to delegate object creation to subclasses
- When you need to provide a framework that allows extensions

## Implementation Examples

### C++ Implementation

#### C++ Basic Factory Method

```cpp
#include <iostream>
#include <memory>
#include <string>

// Product interface
class Document {
public:
    virtual ~Document() = default;
    virtual void open() = 0;
    virtual void save() = 0;
    virtual void close() = 0;
};

// Concrete Products
class WordDocument : public Document {
public:
    void open() override {
        std::cout << "Opening Word document" << std::endl;
    }
    
    void save() override {
        std::cout << "Saving Word document" << std::endl;
    }
    
    void close() override {
        std::cout << "Closing Word document" << std::endl;
    }
};

class PdfDocument : public Document {
public:
    void open() override {
        std::cout << "Opening PDF document" << std::endl;
    }
    
    void save() override {
        std::cout << "Saving PDF document" << std::endl;
    }
    
    void close() override {
        std::cout << "Closing PDF document" << std::endl;
    }
};

// Creator abstract class
class Application {
public:
    virtual ~Application() = default;
    
    // Factory Method
    virtual std::unique_ptr<Document> createDocument() = 0;
    
    void newDocument() {
        auto doc = createDocument();
        doc->open();
        // Work with document...
        doc->save();
        doc->close();
    }
};

// Concrete Creators
class WordApplication : public Application {
public:
    std::unique_ptr<Document> createDocument() override {
        return std::make_unique<WordDocument>();
    }
};

class PdfApplication : public Application {
public:
    std::unique_ptr<Document> createDocument() override {
        return std::make_unique<PdfDocument>();
    }
};

// Usage example
int main() {
    std::unique_ptr<Application> wordApp = std::make_unique<WordApplication>();
    wordApp->newDocument();
    
    std::unique_ptr<Application> pdfApp = std::make_unique<PdfApplication>();
    pdfApp->newDocument();
    
    return 0;
}
```

#### Parameterized Factory Method

```cpp
#include <iostream>
#include <memory>
#include <map>
#include <functional>

// Product interface
class Button {
public:
    virtual ~Button() = default;
    virtual void render() = 0;
    virtual void onClick() = 0;
};

// Concrete Products
class WindowsButton : public Button {
public:
    void render() override {
        std::cout << "Rendering Windows-style button" << std::endl;
    }
    
    void onClick() override {
        std::cout << "Windows button clicked!" << std::endl;
    }
};

class MacButton : public Button {
public:
    void render() override {
        std::cout << "Rendering macOS-style button" << std::endl;
    }
    
    void onClick() override {
        std::cout << "Mac button clicked!" << std::endl;
    }
};

class LinuxButton : public Button {
public:
    void render() override {
        std::cout << "Rendering Linux-style button" << std::endl;
    }
    
    void onClick() override {
        std::cout << "Linux button clicked!" << std::endl;
    }
};

// Dialog creator
class Dialog {
public:
    virtual ~Dialog() = default;
    
    // Factory Method
    virtual std::unique_ptr<Button> createButton() = 0;
    
    void render() {
        auto button = createButton();
        button->render();
        button->onClick();
    }
};

// Concrete Dialogs
class WindowsDialog : public Dialog {
public:
    std::unique_ptr<Button> createButton() override {
        return std::make_unique<WindowsButton>();
    }
};

class MacDialog : public Dialog {
public:
    std::unique_ptr<Button> createButton() override {
        return std::make_unique<MacButton>();
    }
};

class LinuxDialog : public Dialog {
public:
    std::unique_ptr<Button> createButton() override {
        return std::make_unique<LinuxButton>();
    }
};

// Usage with runtime selection
int main() {
    std::string config = "windows"; // This could come from config file
    
    std::unique_ptr<Dialog> dialog;
    
    if (config == "windows") {
        dialog = std::make_unique<WindowsDialog>();
    } else if (config == "mac") {
        dialog = std::make_unique<MacDialog>();
    } else if (config == "linux") {
        dialog = std::make_unique<LinuxDialog>();
    }
    
    if (dialog) {
        dialog->render();
    }
    
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>

// Product types
typedef enum {
    CAR_SEDAN,
    CAR_SUV,
    CAR_SPORTS
} CarType;

// Product structure
typedef struct {
    CarType type;
    void (*assemble)(void);
    void (*paint)(void);
    void (*testDrive)(void);
} Car;

// Concrete product functions
void sedanAssemble(void) {
    printf("Assembling Sedan car\n");
}

void sedanPaint(void) {
    printf("Painting Sedan car\n");
}

void sedanTestDrive(void) {
    printf("Test driving Sedan car\n");
}

void suvAssemble(void) {
    printf("Assembling SUV car\n");
}

void suvPaint(void) {
    printf("Painting SUV car\n");
}

void suvTestDrive(void) {
    printf("Test driving SUV car\n");
}

void sportsAssemble(void) {
    printf("Assembling Sports car\n");
}

void sportsPaint(void) {
    printf("Painting Sports car\n");
}

void sportsTestDrive(void) {
    printf("Test driving Sports car\n");
}

// Factory function
Car* createCar(CarType type) {
    Car* car = (Car*)malloc(sizeof(Car));
    car->type = type;
    
    switch (type) {
        case CAR_SEDAN:
            car->assemble = sedanAssemble;
            car->paint = sedanPaint;
            car->testDrive = sedanTestDrive;
            break;
        case CAR_SUV:
            car->assemble = suvAssemble;
            car->paint = suvPaint;
            car->testDrive = suvTestDrive;
            break;
        case CAR_SPORTS:
            car->assemble = sportsAssemble;
            car->paint = sportsPaint;
            car->testDrive = sportsTestDrive;
            break;
    }
    
    return car;
}

// Usage example
int main() {
    Car* sedan = createCar(CAR_SEDAN);
    sedan->assemble();
    sedan->paint();
    sedan->testDrive();
    
    Car* suv = createCar(CAR_SUV);
    suv->assemble();
    suv->paint();
    suv->testDrive();
    
    Car* sports = createCar(CAR_SPORTS);
    sports->assemble();
    sports->paint();
    sports->testDrive();
    
    free(sedan);
    free(suv);
    free(sports);
    
    return 0;
}
```

### Python Implementation

#### Python Basic Factory Method

```python
from abc import ABC, abstractmethod
from enum import Enum

class NotificationType(Enum):
    EMAIL = "email"
    SMS = "sms"
    PUSH = "push"

# Product interface
class Notification(ABC):
    @abstractmethod
    def send(self, message: str, recipient: str) -> None:
        pass

# Concrete Products
class EmailNotification(Notification):
    def send(self, message: str, recipient: str) -> None:
        print(f"Sending email to {recipient}: {message}")

class SMSNotification(Notification):
    def send(self, message: str, recipient: str) -> None:
        print(f"Sending SMS to {recipient}: {message}")

class PushNotification(Notification):
    def send(self, message: str, recipient: str) -> None:
        print(f"Sending push notification to {recipient}: {message}")

# Creator abstract class
class NotificationCreator(ABC):
    @abstractmethod
    def create_notification(self) -> Notification:
        pass
    
    def send_notification(self, message: str, recipient: str) -> None:
        notification = self.create_notification()
        notification.send(message, recipient)

# Concrete Creators
class EmailNotificationCreator(NotificationCreator):
    def create_notification(self) -> Notification:
        return EmailNotification()

class SMSNotificationCreator(NotificationCreator):
    def create_notification(self) -> Notification:
        return SMSNotification()

class PushNotificationCreator(NotificationCreator):
    def create_notification(self) -> Notification:
        return PushNotification()

# Usage example
if __name__ == "__main__":
    email_creator = EmailNotificationCreator()
    email_creator.send_notification("Hello via Email!", "user@example.com")
    
    sms_creator = SMSNotificationCreator()
    sms_creator.send_notification("Hello via SMS!", "+1234567890")
    
    push_creator = PushNotificationCreator()
    push_creator.send_notification("Hello via Push!", "user_device_123")
```

#### Parameterized Factory in Python

```python
from abc import ABC, abstractmethod
from typing import Dict, Type

class Transport(ABC):
    @abstractmethod
    def deliver(self) -> str:
        pass

class Truck(Transport):
    def deliver(self) -> str:
        return "Delivery by land in a truck"

class Ship(Transport):
    def deliver(self) -> str:
        return "Delivery by sea in a ship"

class Airplane(Transport):
    def deliver(self) -> str:
        return "Delivery by air in an airplane"

class Logistics(ABC):
    @abstractmethod
    def create_transport(self) -> Transport:
        pass
    
    def plan_delivery(self) -> str:
        transport = self.create_transport()
        return transport.deliver()

class RoadLogistics(Logistics):
    def create_transport(self) -> Transport:
        return Truck()

class SeaLogistics(Logistics):
    def create_transport(self) -> Transport:
        return Ship()

class AirLogistics(Logistics):
    def create_transport(self) -> Transport:
        return Airplane()

# Factory that creates logistics based on type
class LogisticsFactory:
    _logistics_types: Dict[str, Type[Logistics]] = {
        "road": RoadLogistics,
        "sea": SeaLogistics,
        "air": AirLogistics
    }
    
    @classmethod
    def create_logistics(cls, logistics_type: str) -> Logistics:
        if logistics_type not in cls._logistics_types:
            raise ValueError(f"Unknown logistics type: {logistics_type}")
        return cls._logistics_types[logistics_type]()
    
    @classmethod
    def register_logistics(cls, name: str, logistics_class: Type[Logistics]) -> None:
        cls._logistics_types[name] = logistics_class

# Usage example
if __name__ == "__main__":
    # Standard usage
    road_logistics = LogisticsFactory.create_logistics("road")
    print(road_logistics.plan_delivery())
    
    sea_logistics = LogisticsFactory.create_logistics("sea")
    print(sea_logistics.plan_delivery())
    
    air_logistics = LogisticsFactory.create_logistics("air")
    print(air_logistics.plan_delivery())
    
    # Dynamic registration
    class Train(Transport):
        def deliver(self) -> str:
            return "Delivery by rail in a train"
    
    class RailLogistics(Logistics):
        def create_transport(self) -> Transport:
            return Train()
    
    # Register new logistics type at runtime
    LogisticsFactory.register_logistics("rail", RailLogistics)
    
    rail_logistics = LogisticsFactory.create_logistics("rail")
    print(rail_logistics.plan_delivery())
```

#### Python with Class-based Factory Method

```python
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    @abstractmethod
    def process_payment(self, amount: float) -> bool:
        pass
    
    @abstractmethod
    def refund(self, amount: float) -> bool:
        pass

class CreditCardPayment(PaymentMethod):
    def process_payment(self, amount: float) -> bool:
        print(f"Processing credit card payment of ${amount:.2f}")
        return True
    
    def refund(self, amount: float) -> bool:
        print(f"Refunding ${amount:.2f} to credit card")
        return True

class PayPalPayment(PaymentMethod):
    def process_payment(self, amount: float) -> bool:
        print(f"Processing PayPal payment of ${amount:.2f}")
        return True
    
    def refund(self, amount: float) -> bool:
        print(f"Refunding ${amount:.2f} to PayPal account")
        return True

class CryptoPayment(PaymentMethod):
    def process_payment(self, amount: float) -> bool:
        print(f"Processing cryptocurrency payment of ${amount:.2f}")
        return True
    
    def refund(self, amount: float) -> bool:
        print(f"Refunding ${amount:.2f} in cryptocurrency")
        return True

# Payment processor using Factory Method
class PaymentProcessor:
    def __init__(self):
        self._payment_methods = {}
    
    def register_payment_method(self, name: str, payment_class: type):
        self._payment_methods[name] = payment_class
    
    def create_payment_method(self, name: str) -> PaymentMethod:
        if name not in self._payment_methods:
            raise ValueError(f"Unknown payment method: {name}")
        return self._payment_methods[name]()
    
    def process_order(self, payment_method: str, amount: float) -> None:
        try:
            method = self.create_payment_method(payment_method)
            if method.process_payment(amount):
                print("Payment successful!")
        except Exception as e:
            print(f"Payment failed: {e}")

# Usage
if __name__ == "__main__":
    processor = PaymentProcessor()
    
    # Register payment methods
    processor.register_payment_method("credit_card", CreditCardPayment)
    processor.register_payment_method("paypal", PayPalPayment)
    processor.register_payment_method("crypto", CryptoPayment)
    
    # Process payments using different methods
    processor.process_order("credit_card", 100.0)
    processor.process_order("paypal", 50.0)
    processor.process_order("crypto", 75.0)
```

## Advantages and Disadvantages

### Advantages

- **Flexibility**: Easy to add new product types without modifying existing code
- **Loose Coupling**: Client code depends on interfaces rather than concrete classes
- **Single Responsibility**: Object creation code is centralized
- **Open/Closed Principle**: Easy to extend with new product types

### Disadvantages

- **Complexity**: Can introduce many small classes
- **Overhead**: May be overkill for simple object creation
- **Client dependency**: Client might need to know which creator to use

## Best Practices

1. **Use when object creation logic is complex**: When creation involves multiple steps or conditions
2. **Follow naming conventions**: Use descriptive names like `createX()` for factory methods
3. **Consider parameterized factories**: When you need to create different variants of products
4. **Use dependency injection**: For better testability and flexibility
5. **Document the factory interface**: Clearly specify what products can be created

The Factory Method pattern is particularly useful when you need to provide a framework that other developers can extend with their own implementations while maintaining consistency in how objects are created and used.
