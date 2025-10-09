# Adapter Pattern

## Introduction

The Adapter pattern is a structural design pattern that allows objects with incompatible interfaces to collaborate. It acts as a bridge between two incompatible interfaces by converting the interface of one class into an interface expected by the clients.

### Key Characteristics
- **Interface Translation**: Converts one interface to another
- **Client Transparency**: Clients work with the target interface without knowing about the adaptee
- **Reusability**: Allows existing classes to be reused with incompatible interfaces
- **Two-Way Communication**: Can adapt both requests and responses

### Use Cases
- When you want to use an existing class, but its interface doesn't match what you need
- When you want to create a reusable class that cooperates with unrelated or unforeseen classes
- When you need to use several existing subclasses, but it's impractical to adapt their interface by subclassing each one

## Implementation Examples

### C++ Implementation

#### Class Adapter (Multiple Inheritance)
```cpp
#include <iostream>
#include <string>
#include <cmath>

// Target interface (what clients expect)
class RoundPeg {
public:
    virtual ~RoundPeg() = default;
    virtual double getRadius() const = 0;
};

// Adaptee (incompatible interface)
class SquarePeg {
private:
    double width;

public:
    SquarePeg(double width) : width(width) {}
    
    double getWidth() const {
        return width;
    }
};

// Adapter (class adapter using multiple inheritance)
class SquarePegAdapter : public RoundPeg, private SquarePeg {
public:
    SquarePegAdapter(double width) : SquarePeg(width) {}
    
    double getRadius() const override {
        // Calculate the minimum circle radius that can fit the square peg
        return getWidth() * std::sqrt(2) / 2;
    }
};

// Client that works with RoundPeg interface
class RoundHole {
private:
    double radius;

public:
    RoundHole(double radius) : radius(radius) {}
    
    double getRadius() const {
        return radius;
    }
    
    bool fits(const RoundPeg* peg) const {
        return getRadius() >= peg->getRadius();
    }
};

// Usage example
int main() {
    RoundHole hole(5.0);
    
    // Using compatible round peg
    class CompatibleRoundPeg : public RoundPeg {
    private:
        double radius;
    public:
        CompatibleRoundPeg(double radius) : radius(radius) {}
        double getRadius() const override { return radius; }
    };
    
    CompatibleRoundPeg roundPeg(5.0);
    std::cout << "Round peg fits: " << (hole.fits(&roundPeg) ? "Yes" : "No") << std::endl;
    
    // Using square peg via adapter
    SquarePeg squarePeg(7.0); // Too big for hole radius 5.0
    SquarePegAdapter adapter(7.0);
    std::cout << "Square peg fits via adapter: " << (hole.fits(&adapter) ? "Yes" : "No") << std::endl;
    
    // Using smaller square peg
    SquarePeg smallSquarePeg(5.0);
    SquarePegAdapter smallAdapter(5.0);
    std::cout << "Small square peg fits via adapter: " << (hole.fits(&smallAdapter) ? "Yes" : "No") << std::endl;
    
    return 0;
}
```

#### Object Adapter (Composition)
```cpp
#include <iostream>
#include <string>
#include <vector>
#include <memory>

// Legacy system (Adaptee)
class LegacyRectangle {
private:
    double x1, y1, x2, y2;

public:
    LegacyRectangle(double x1, double y1, double x2, double y2) 
        : x1(x1), y1(y1), x2(x2), y2(y2) {}
    
    void legacyDraw() const {
        std::cout << "LegacyRectangle: draw() at [(" << x1 << "," << y1 
                  << "), (" << x2 << "," << y2 << ")]" << std::endl;
    }
    
    double getX1() const { return x1; }
    double getY1() const { return y1; }
    double getX2() const { return x2; }
    double getY2() const { return y2; }
};

// Modern interface (Target)
class Shape {
public:
    virtual ~Shape() = default;
    virtual void draw() const = 0;
    virtual void resize(double factor) = 0;
};

// Adapter using composition
class RectangleAdapter : public Shape {
private:
    std::unique_ptr<LegacyRectangle> legacyRect;

public:
    RectangleAdapter(double x, double y, double w, double h) {
        legacyRect = std::make_unique<LegacyRectangle>(x, y, x + w, y + h);
    }
    
    void draw() const override {
        legacyRect->legacyDraw();
    }
    
    void resize(double factor) override {
        double x1 = legacyRect->getX1();
        double y1 = legacyRect->getY1();
        double x2 = legacyRect->getX2();
        double y2 = legacyRect->getY2();
        
        double width = (x2 - x1) * factor;
        double height = (y2 - y1) * factor;
        
        legacyRect = std::make_unique<LegacyRectangle>(x1, y1, x1 + width, y1 + height);
        std::cout << "Resized by factor " << factor << std::endl;
    }
};

// Another example: Media Player Adapter
class AdvancedMediaPlayer {
public:
    virtual ~AdvancedMediaPlayer() = default;
    virtual void playVlc(const std::string& fileName) = 0;
    virtual void playMp4(const std::string& fileName) = 0;
};

class VlcPlayer : public AdvancedMediaPlayer {
public:
    void playVlc(const std::string& fileName) override {
        std::cout << "Playing vlc file: " << fileName << std::endl;
    }
    
    void playMp4(const std::string& fileName) override {
        // Do nothing - VLC player doesn't support MP4
    }
};

class Mp4Player : public AdvancedMediaPlayer {
public:
    void playVlc(const std::string& fileName) override {
        // Do nothing - MP4 player doesn't support VLC
    }
    
    void playMp4(const std::string& fileName) override {
        std::cout << "Playing mp4 file: " << fileName << std::endl;
    }
};

// Target interface
class MediaPlayer {
public:
    virtual ~MediaPlayer() = default;
    virtual void play(const std::string& audioType, const std::string& fileName) = 0;
};

// Adapter
class MediaAdapter : public MediaPlayer {
private:
    std::unique_ptr<AdvancedMediaPlayer> advancedMusicPlayer;

public:
    MediaAdapter(const std::string& audioType) {
        if (audioType == "vlc") {
            advancedMusicPlayer = std::make_unique<VlcPlayer>();
        } else if (audioType == "mp4") {
            advancedMusicPlayer = std::make_unique<Mp4Player>();
        }
    }
    
    void play(const std::string& audioType, const std::string& fileName) override {
        if (audioType == "vlc") {
            advancedMusicPlayer->playVlc(fileName);
        } else if (audioType == "mp4") {
            advancedMusicPlayer->playMp4(fileName);
        }
    }
};

// Concrete MediaPlayer implementation
class AudioPlayer : public MediaPlayer {
private:
    MediaAdapter* mediaAdapter;

public:
    ~AudioPlayer() {
        delete mediaAdapter;
    }
    
    void play(const std::string& audioType, const std::string& fileName) override {
        // Built-in support for mp3
        if (audioType == "mp3") {
            std::cout << "Playing mp3 file: " << fileName << std::endl;
        }
        // MediaAdapter provides support for other formats
        else if (audioType == "vlc" || audioType == "mp4") {
            mediaAdapter = new MediaAdapter(audioType);
            mediaAdapter->play(audioType, fileName);
        } else {
            std::cout << "Invalid media type: " << audioType << std::endl;
        }
    }
};

// Usage example
int main() {
    std::cout << "=== Rectangle Adapter Example ===" << std::endl;
    RectangleAdapter rect(10, 20, 30, 40);
    rect.draw();
    rect.resize(1.5);
    rect.draw();
    
    std::cout << "\n=== Media Player Adapter Example ===" << std::endl;
    AudioPlayer audioPlayer;
    audioPlayer.play("mp3", "song.mp3");
    audioPlayer.play("mp4", "movie.mp4");
    audioPlayer.play("vlc", "video.vlc");
    audioPlayer.play("avi", "movie.avi");
    
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Adaptee: Legacy temperature sensor in Fahrenheit
typedef struct {
    double (*get_temperature_f)(void);
} FahrenheitSensor;

double get_fahrenheit_temperature(void) {
    return 98.6; // Normal body temperature in Fahrenheit
}

// Target interface: Celsius temperature
typedef struct {
    double (*get_temperature_c)(void);
} CelsiusSensor;

// Adapter structure
typedef struct {
    CelsiusSensor base;
    FahrenheitSensor* fahrenheit_sensor;
} TemperatureAdapter;

double adapter_get_temperature_c(void) {
    TemperatureAdapter* adapter = (TemperatureAdapter*)this;
    double fahrenheit = adapter->fahrenheit_sensor->get_temperature_f();
    return (fahrenheit - 32) * 5.0 / 9.0;
}

TemperatureAdapter* create_temperature_adapter(FahrenheitSensor* sensor) {
    TemperatureAdapter* adapter = malloc(sizeof(TemperatureAdapter));
    adapter->base.get_temperature_c = adapter_get_temperature_c;
    adapter->fahrenheit_sensor = sensor;
    return adapter;
}

void destroy_temperature_adapter(TemperatureAdapter* adapter) {
    free(adapter);
}

// Client that expects Celsius
void display_temperature(CelsiusSensor* sensor) {
    double temp = sensor->get_temperature_c();
    printf("Temperature: %.2f°C\n", temp);
}

// Another example: Legacy payment system
typedef struct {
    void (*process_credit_card)(const char* card_number, double amount);
} LegacyPayment;

void legacy_process_credit_card(const char* card_number, double amount) {
    printf("Legacy: Processing credit card %s for $%.2f\n", card_number, amount);
}

// Modern payment interface
typedef struct {
    void (*pay)(const char* payment_method, double amount);
} ModernPayment;

// Payment adapter
typedef struct {
    ModernPayment base;
    LegacyPayment* legacy_payment;
} PaymentAdapter;

void adapter_pay(const char* payment_method, double amount) {
    PaymentAdapter* adapter = (PaymentAdapter*)this;
    
    if (strcmp(payment_method, "credit_card") == 0) {
        // For demo, use a dummy card number
        adapter->legacy_payment->process_credit_card("****-****-****-1234", amount);
    } else if (strcmp(payment_method, "paypal") == 0) {
        printf("Modern: Processing PayPal payment for $%.2f\n", amount);
    } else {
        printf("Unsupported payment method: %s\n", payment_method);
    }
}

PaymentAdapter* create_payment_adapter(LegacyPayment* legacy) {
    PaymentAdapter* adapter = malloc(sizeof(PaymentAdapter));
    adapter->base.pay = adapter_pay;
    adapter->legacy_payment = legacy;
    return adapter;
}

void destroy_payment_adapter(PaymentAdapter* adapter) {
    free(adapter);
}

// Usage example
int main() {
    printf("=== Temperature Adapter Example ===\n");
    
    // Create legacy sensor
    FahrenheitSensor fahrenheit_sensor = {get_fahrenheit_temperature};
    
    // Create adapter
    TemperatureAdapter* temp_adapter = create_temperature_adapter(&fahrenheit_sensor);
    
    // Use through modern interface
    display_temperature((CelsiusSensor*)temp_adapter);
    
    printf("\n=== Payment Adapter Example ===\n");
    
    // Create legacy payment system
    LegacyPayment legacy_payment = {legacy_process_credit_card};
    
    // Create payment adapter
    PaymentAdapter* payment_adapter = create_payment_adapter(&legacy_payment);
    
    // Use modern payment interface
    payment_adapter->base.pay("credit_card", 100.0);
    payment_adapter->base.pay("paypal", 50.0);
    payment_adapter->base.pay("bitcoin", 25.0);
    
    // Cleanup
    destroy_temperature_adapter(temp_adapter);
    destroy_payment_adapter(payment_adapter);
    
    return 0;
}
```

### Python Implementation

#### Basic Adapter Pattern
```python
from abc import ABC, abstractmethod
from typing import List

# Target interface
class EuropeanSocketInterface(ABC):
    @abstractmethod
    def voltage(self) -> int: ...
    
    @abstractmethod
    def live(self) -> int: ...
    
    @abstractmethod
    def neutral(self) -> int: ...
    
    @abstractmethod
    def earth(self) -> int: ...

# Adaptee: American socket
class AmericanSocket:
    def voltage(self) -> int:
        return 120
    
    def live(self) -> int:
        return 1
    
    def neutral(self) -> int:
        return -1
    
    # American sockets don't have earth pin
    # This is the incompatibility

# Adapter
class SocketAdapter(EuropeanSocketInterface):
    def __init__(self, american_socket: AmericanSocket):
        self._american_socket = american_socket
    
    def voltage(self) -> int:
        return self._american_socket.voltage()
    
    def live(self) -> int:
        return self._american_socket.live()
    
    def neutral(self) -> int:
        return self._american_socket.neutral()
    
    def earth(self) -> int:
        # Provide default earth connection for American socket
        return 0

# European device that expects European socket interface
class EuropeanDevice:
    def __init__(self, socket: EuropeanSocketInterface):
        self._socket = socket
    
    def power_on(self) -> str:
        v = self._socket.voltage()
        l = self._socket.live()
        n = self._socket.neutral()
        e = self._socket.earth()
        
        return f"Device powered on: {v}V, Live:{l}, Neutral:{n}, Earth:{e}"

# Another example: Data format adapter
class LegacyDataSystem:
    """Legacy system that returns data in old format"""
    def get_data(self) -> List[List[str]]:
        return [
            ["John", "Doe", "30", "Engineer"],
            ["Jane", "Smith", "25", "Designer"],
            ["Bob", "Johnson", "35", "Manager"]
        ]

class ModernDataSystem:
    """Modern system expects data as dictionaries"""
    def display_data(self, data: List[dict]):
        print("Modern Data Display:")
        for item in data:
            print(f"  {item}")

class DataAdapter:
    def __init__(self, legacy_system: LegacyDataSystem):
        self._legacy_system = legacy_system
    
    def get_modern_data(self) -> List[dict]:
        legacy_data = self._legacy_system.get_data()
        modern_data = []
        
        for row in legacy_data:
            modern_data.append({
                "first_name": row[0],
                "last_name": row[1],
                "age": int(row[2]),
                "occupation": row[3]
            })
        
        return modern_data

# Usage example
if __name__ == "__main__":
    print("=== Socket Adapter Example ===")
    
    # Create American socket
    american_socket = AmericanSocket()
    
    # Create adapter
    adapter = SocketAdapter(american_socket)
    
    # Use European device with American socket via adapter
    device = EuropeanDevice(adapter)
    print(device.power_on())
    
    print("\n=== Data Format Adapter Example ===")
    
    # Legacy system
    legacy_system = LegacyDataSystem()
    print("Legacy data format:")
    for row in legacy_system.get_data():
        print(f"  {row}")
    
    # Modern system with adapter
    modern_system = ModernDataSystem()
    adapter = DataAdapter(legacy_system)
    modern_data = adapter.get_modern_data()
    modern_system.display_data(modern_data)
```

#### Advanced Adapter Examples
```python
from abc import ABC, abstractmethod
from datetime import datetime, timedelta
import json
from typing import Any, Dict, List

# Third-party analytics service (Adaptee)
class GoogleAnalytics:
    def track_event(self, event_name: str, user_id: str, properties: Dict[str, Any]) -> None:
        print(f"Google Analytics: Tracking '{event_name}' for user {user_id}")
        print(f"  Properties: {properties}")
    
    def page_view(self, page_url: str, user_id: str, timestamp: str) -> None:
        print(f"Google Analytics: Page view '{page_url}' by user {user_id} at {timestamp}")

# Another third-party service
class MixpanelService:
    def send_event(self, distinct_id: str, event: str, **kwargs) -> None:
        print(f"Mixpanel: Event '{event}' for user {distinct_id}")
        if kwargs:
            print(f"  Additional data: {kwargs}")

# Target interface for our application
class AnalyticsService(ABC):
    @abstractmethod
    def log_event(self, event_type: str, user_id: str, metadata: Dict[str, Any]) -> None: ...
    
    @abstractmethod
    def log_page_view(self, page: str, user_id: str, visit_time: datetime) -> None: ...

# Adapter for Google Analytics
class GoogleAnalyticsAdapter(AnalyticsService):
    def __init__(self, google_analytics: GoogleAnalytics):
        self._ga = google_analytics
    
    def log_event(self, event_type: str, user_id: str, metadata: Dict[str, Any]) -> None:
        # Transform our application's event format to Google Analytics format
        ga_properties = {
            'category': metadata.get('category', 'general'),
            'label': metadata.get('label', ''),
            'value': metadata.get('value', 1)
        }
        self._ga.track_event(event_type, user_id, ga_properties)
    
    def log_page_view(self, page: str, user_id: str, visit_time: datetime) -> None:
        # Format timestamp for Google Analytics
        timestamp = visit_time.strftime("%Y-%m-%d %H:%M:%S")
        self._ga.page_view(page, user_id, timestamp)

# Adapter for Mixpanel
class MixpanelAdapter(AnalyticsService):
    def __init__(self, mixpanel: MixpanelService):
        self._mixpanel = mixpanel
    
    def log_event(self, event_type: str, user_id: str, metadata: Dict[str, Any]) -> None:
        # Transform to Mixpanel format
        self._mixpanel.send_event(
            distinct_id=user_id,
            event=event_type,
            **metadata
        )
    
    def log_page_view(self, page: str, user_id: str, visit_time: datetime) -> None:
        self._mixpanel.send_event(
            distinct_id=user_id,
            event="page_view",
            page=page,
            visit_time=visit_time.isoformat()
        )

# Application that uses the analytics service
class WebApplication:
    def __init__(self, analytics: AnalyticsService):
        self._analytics = analytics
    
    def user_signup(self, user_id: str, email: str) -> None:
        self._analytics.log_event("signup", user_id, {
            'category': 'authentication',
            'label': 'user_registration',
            'email': email,
            'signup_method': 'web'
        })
    
    def user_login(self, user_id: str, page: str) -> None:
        self._analytics.log_page_view(page, user_id, datetime.now())
        self._analytics.log_event("login", user_id, {
            'category': 'authentication',
            'label': 'user_login'
        })
    
    def purchase(self, user_id: str, amount: float, product: str) -> None:
        self._analytics.log_event("purchase", user_id, {
            'category': 'ecommerce',
            'label': product,
            'value': amount,
            'currency': 'USD'
        })

# Database adapter example
class LegacyDatabase:
    """Legacy database with old-fashioned interface"""
    def execute_query(self, sql: str) -> List[tuple]:
        print(f"Legacy DB: Executing '{sql}'")
        # Simulate database results
        return [
            (1, "John Doe", "john@example.com", "2020-01-15"),
            (2, "Jane Smith", "jane@example.com", "2021-03-22")
        ]
    
    def close_connection(self) -> None:
        print("Legacy DB: Closing connection")

class ModernORMMapper:
    """Modern ORM-like interface"""
    def __init__(self, legacy_db: LegacyDatabase):
        self._db = legacy_db
    
    def find_all(self, model_class: str, filters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        # Build SQL from modern interface
        sql = f"SELECT * FROM {model_class}"
        if filters:
            where_clause = " AND ".join([f"{k} = '{v}'" for k, v in filters.items()])
            sql += f" WHERE {where_clause}"
        
        # Execute legacy query
        results = self._db.execute_query(sql)
        
        # Transform to modern format
        modern_results = []
        for row in results:
            modern_results.append({
                'id': row[0],
                'name': row[1],
                'email': row[2],
                'created_at': row[3]
            })
        
        return modern_results
    
    def close(self) -> None:
        self._db.close_connection()

# Usage example
if __name__ == "__main__":
    print("=== Analytics Adapter Example ===")
    
    # Create third-party services
    ga_service = GoogleAnalytics()
    mixpanel_service = MixpanelService()
    
    # Create adapters
    ga_adapter = GoogleAnalyticsAdapter(ga_service)
    mixpanel_adapter = MixpanelAdapter(mixpanel_service)
    
    # Create application with different analytics providers
    app_with_ga = WebApplication(ga_adapter)
    app_with_mixpanel = WebApplication(mixpanel_adapter)
    
    print("\n--- Using Google Analytics ---")
    app_with_ga.user_signup("user123", "test@example.com")
    app_with_ga.user_login("user123", "/dashboard")
    app_with_ga.purchase("user123", 99.99, "Premium Subscription")
    
    print("\n--- Using Mixpanel ---")
    app_with_mixpanel.user_signup("user456", "another@example.com")
    app_with_mixpanel.user_login("user456", "/profile")
    app_with_mixpanel.purchase("user456", 49.99, "Basic Subscription")
    
    print("\n=== Database ORM Adapter Example ===")
    
    legacy_db = LegacyDatabase()
    orm_mapper = ModernORMMapper(legacy_db)
    
    # Use modern ORM interface with legacy database
    users = orm_mapper.find_all("users")
    print("All users:")
    for user in users:
        print(f"  {user}")
    
    # With filters
    filtered_users = orm_mapper.find_all("users", {"name": "John Doe"})
    print("\nFiltered users (name = 'John Doe'):")
    for user in filtered_users:
        print(f"  {user}")
    
    orm_mapper.close()
```

#### Two-Way Adapter Pattern
```python
from abc import ABC, abstractmethod
from typing import List

# Two incompatible interfaces
class XMLParser(ABC):
    @abstractmethod
    def parse_xml(self, xml_data: str) -> dict: ...
    
    @abstractmethod
    def to_xml(self, data: dict) -> str: ...

class JSONParser(ABC):
    @abstractmethod
    def parse_json(self, json_data: str) -> dict: ...
    
    @abstractmethod
    def to_json(self, data: dict) -> str: ...

# Concrete implementations
class SimpleXMLParser(XMLParser):
    def parse_xml(self, xml_data: str) -> dict:
        print("SimpleXMLParser: Parsing XML data")
        # Simplified XML parsing
        return {"source": "xml", "data": xml_data.strip("<>").split("</")[0]}
    
    def to_xml(self, data: dict) -> str:
        print("SimpleXMLParser: Converting to XML")
        return f"<root><data>{data}</data></root>"

class SimpleJSONParser(JSONParser):
    def parse_json(self, json_data: str) -> dict:
        print("SimpleJSONParser: Parsing JSON data")
        # Simplified JSON parsing
        return {"source": "json", "data": json_data.strip("{}").split(":")[1].strip('"')}
    
    def to_json(self, data: dict) -> str:
        print("SimpleJSONParser: Converting to JSON")
        return f'{{"data": "{data}"}}'

# Two-way adapter
class UniversalParserAdapter(XMLParser, JSONParser):
    def __init__(self):
        self._xml_parser = SimpleXMLParser()
        self._json_parser = SimpleJSONParser()
    
    # XML interface implementation using JSON parser
    def parse_xml(self, xml_data: str) -> dict:
        print("UniversalAdapter: Converting XML to JSON and parsing")
        # Convert XML-like string to JSON-like string (simplified)
        json_like = f'{{"value": "{xml_data.strip("<>/")}"}}'
        return self._json_parser.parse_json(json_like)
    
    def to_xml(self, data: dict) -> str:
        print("UniversalAdapter: Converting data to XML via JSON")
        json_str = self._json_parser.to_json(data)
        # Convert JSON-like to XML-like (simplified)
        return f"<data>{json_str.strip('{}').split(':')[1].strip('"')}</data>"
    
    # JSON interface implementation using XML parser
    def parse_json(self, json_data: str) -> dict:
        print("UniversalAdapter: Converting JSON to XML and parsing")
        # Convert JSON-like string to XML-like string (simplified)
        xml_like = f"<root>{json_data.strip('{}').split(':')[1].strip('"')}</root>"
        return self._xml_parser.parse_xml(xml_like)
    
    def to_json(self, data: dict) -> str:
        print("UniversalAdapter: Converting data to JSON via XML")
        xml_str = self._xml_parser.to_xml(data)
        # Convert XML-like to JSON-like (simplified)
        return f'{{"value": "{xml_str.strip("<>/").split(">")[1].split("<")[0]}"}}'

# Usage example
if __name__ == "__main__":
    print("=== Two-Way Adapter Example ===")
    
    adapter = UniversalParserAdapter()
    
    # Use as XML parser
    print("\n--- Using as XML Parser ---")
    xml_data = "<message>Hello XML</message>"
    parsed_xml = adapter.parse_xml(xml_data)
    print(f"Parsed XML: {parsed_xml}")
    
    generated_xml = adapter.to_xml({"message": "Hello World"})
    print(f"Generated XML: {generated_xml}")
    
    # Use as JSON parser
    print("\n--- Using as JSON Parser ---")
    json_data = '{"message": "Hello JSON"}'
    parsed_json = adapter.parse_json(json_data)
    print(f"Parsed JSON: {parsed_json}")
    
    generated_json = adapter.to_json({"message": "Hello World"})
    print(f"Generated JSON: {generated_json}")
    
    # Demonstrate interoperability
    print("\n--- Interoperability ---")
    original_data = {"test": "data"}
    
    # Convert to XML then back to JSON
    xml_output = adapter.to_xml(original_data)
    json_from_xml = adapter.parse_xml(xml_output)
    print(f"XML -> JSON conversion: {json_from_xml}")
    
    # Convert to JSON then back to XML
    json_output = adapter.to_json(original_data)
    xml_from_json = adapter.parse_json(json_output)
    print(f"JSON -> XML conversion: {xml_from_json}")
```

## Advantages and Disadvantages

### Advantages
- **Compatibility**: Enables collaboration between incompatible interfaces
- **Reusability**: Allows reuse of existing functionality
- **Single Responsibility**: Separation of interface conversion from business logic
- **Open/Closed Principle**: Can introduce new adapters without changing existing code

### Disadvantages
- **Complexity**: Can increase overall system complexity
- **Performance overhead**: Additional layer may impact performance
- **Overuse**: Can be overused when refactoring would be better

## Best Practices

1. **Use for integration**: When integrating with legacy systems or third-party libraries
2. **Prefer composition**: Use object adapter (composition) over class adapter (multiple inheritance)
3. **Keep adapters simple**: Focus on interface translation, not business logic
4. **Test thoroughly**: Ensure adapters correctly handle all edge cases
5. **Document mappings**: Clearly document how interfaces are transformed

## Adapter vs Other Patterns

- **vs Bridge**: Adapter makes unrelated classes work together, while Bridge separates abstraction from implementation
- **vs Decorator**: Adapter changes interface, while Decorator adds responsibilities
- **vs Facade**: Adapter makes existing interfaces compatible, while Facade provides a simplified interface to a complex subsystem

The Adapter pattern is essential when you need to integrate components with incompatible interfaces, especially when working with legacy systems, third-party libraries, or when you want to provide a unified interface to multiple similar but incompatible components.