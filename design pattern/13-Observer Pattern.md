# Observer Pattern

## Introduction

The Observer pattern is a behavioral design pattern that defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically.

### Key Characteristics

- **Loose Coupling**: Subjects and observers are loosely coupled
- **Dynamic Relationships**: Observers can be added/removed at runtime
- **Automatic Notification**: Observers are automatically notified of state changes
- **Broadcast Communication**: One subject can notify multiple observers

### Use Cases

- When a change to one object requires changing other objects, and you don't know how many objects need to be changed
- When an object should be able to notify other objects without making assumptions about who these objects are
- When you need to create a publish-subscribe mechanism
- In event handling systems, MVC architectures, and reactive programming

## Implementation Examples

### C++ Implementation

#### Basic Observer Pattern - Weather Station

```cpp
#include <iostream>
#include <vector>
#include <memory>
#include <algorithm>
#include <string>

// Forward declaration
class Observer;

// Subject interface
class Subject {
public:
    virtual ~Subject() = default;
    virtual void registerObserver(std::shared_ptr<Observer> observer) = 0;
    virtual void removeObserver(std::shared_ptr<Observer> observer) = 0;
    virtual void notifyObservers() = 0;
};

// Observer interface
class Observer {
public:
    virtual ~Observer() = default;
    virtual void update(float temperature, float humidity, float pressure) = 0;
    virtual void display() const = 0;
    virtual std::string getName() const = 0;
};

// Concrete Subject - Weather Data
class WeatherData : public Subject {
private:
    std::vector<std::shared_ptr<Observer>> observers;
    float temperature;
    float humidity;
    float pressure;

public:
    void registerObserver(std::shared_ptr<Observer> observer) override {
        observers.push_back(observer);
        std::cout << "Registered observer: " << observer->getName() << std::endl;
    }

    void removeObserver(std::shared_ptr<Observer> observer) override {
        auto it = std::find(observers.begin(), observers.end(), observer);
        if (it != observers.end()) {
            std::cout << "Removed observer: " << observer->getName() << std::endl;
            observers.erase(it);
        }
    }

    void notifyObservers() override {
        std::cout << "\nNotifying " << observers.size() << " observers..." << std::endl;
        for (const auto& observer : observers) {
            observer->update(temperature, humidity, pressure);
        }
    }

    void measurementsChanged() {
        notifyObservers();
    }

    void setMeasurements(float temp, float humidity, float pressure) {
        this->temperature = temp;
        this->humidity = humidity;
        this->pressure = pressure;
        measurementsChanged();
    }

    // Other WeatherData methods...
    float getTemperature() const { return temperature; }
    float getHumidity() const { return humidity; }
    float getPressure() const { return pressure; }
};

// Concrete Observers
class CurrentConditionsDisplay : public Observer, public std::enable_shared_from_this<CurrentConditionsDisplay> {
private:
    float temperature;
    float humidity;
    std::weak_ptr<Subject> weatherData;

public:
    CurrentConditionsDisplay(std::shared_ptr<Subject> weatherData) {
        this->weatherData = weatherData;
        weatherData->registerObserver(shared_from_this());
    }

    ~CurrentConditionsDisplay() {
        if (auto data = weatherData.lock()) {
            // Note: In real implementation, you'd want to remove yourself from subject
        }
    }

    void update(float temperature, float humidity, float pressure) override {
        this->temperature = temperature;
        this->humidity = humidity;
        display();
    }

    void display() const override {
        std::cout << "Current conditions: " << temperature 
                  << "°C and " << humidity << "% humidity" << std::endl;
    }

    std::string getName() const override {
        return "CurrentConditionsDisplay";
    }
};

class StatisticsDisplay : public Observer, public std::enable_shared_from_this<StatisticsDisplay> {
private:
    float maxTemp = 0.0f;
    float minTemp = 200.0f;
    float tempSum = 0.0f;
    int numReadings = 0;
    std::weak_ptr<Subject> weatherData;

public:
    StatisticsDisplay(std::shared_ptr<Subject> weatherData) {
        this->weatherData = weatherData;
        weatherData->registerObserver(shared_from_this());
    }

    void update(float temperature, float humidity, float pressure) override {
        tempSum += temperature;
        numReadings++;

        if (temperature > maxTemp) {
            maxTemp = temperature;
        }

        if (temperature < minTemp) {
            minTemp = temperature;
        }

        display();
    }

    void display() const override {
        std::cout << "Avg/Max/Min temperature = " << (tempSum / numReadings)
                  << "/" << maxTemp << "/" << minTemp << std::endl;
    }

    std::string getName() const override {
        return "StatisticsDisplay";
    }
};

class ForecastDisplay : public Observer, public std::enable_shared_from_this<ForecastDisplay> {
private:
    float currentPressure = 29.92f;
    float lastPressure;
    std::weak_ptr<Subject> weatherData;

public:
    ForecastDisplay(std::shared_ptr<Subject> weatherData) {
        this->weatherData = weatherData;
        weatherData->registerObserver(shared_from_this());
        lastPressure = currentPressure;
    }

    void update(float temperature, float humidity, float pressure) override {
        lastPressure = currentPressure;
        currentPressure = pressure;
        display();
    }

    void display() const override {
        std::cout << "Forecast: ";
        if (currentPressure > lastPressure) {
            std::cout << "Improving weather on the way!" << std::endl;
        } else if (currentPressure == lastPressure) {
            std::cout << "More of the same" << std::endl;
        } else if (currentPressure < lastPressure) {
            std::cout << "Watch out for cooler, rainy weather" << std::endl;
        }
    }

    std::string getName() const override {
        return "ForecastDisplay";
    }
};

class HeatIndexDisplay : public Observer, public std::enable_shared_from_this<HeatIndexDisplay> {
private:
    float heatIndex = 0.0f;
    std::weak_ptr<Subject> weatherData;

public:
    HeatIndexDisplay(std::shared_ptr<Subject> weatherData) {
        this->weatherData = weatherData;
        weatherData->registerObserver(shared_from_this());
    }

    void update(float temperature, float humidity, float pressure) override {
        heatIndex = computeHeatIndex(temperature, humidity);
        display();
    }

    float computeHeatIndex(float t, float rh) {
        // Heat index calculation formula
        return (float)((16.923 + (0.185212 * t) + (5.37941 * rh) - (0.100254 * t * rh) +
                       (0.00941695 * (t * t)) + (0.00728898 * (rh * rh)) +
                       (0.000345372 * (t * t * rh)) - (0.000814971 * (t * rh * rh)) +
                       (0.0000102102 * (t * t * rh * rh)) - (0.000038646 * (t * t * t)) +
                       (0.0000291583 * (rh * rh * rh)) + (0.00000142721 * (t * t * t * rh)) +
                       (0.000000197483 * (t * rh * rh * rh)) - (0.0000000218429 * (t * t * t * rh * rh)) +
                       (0.000000000843296 * (t * t * rh * rh * rh)) -
                       (0.0000000000481975 * (t * t * t * rh * rh * rh))));
    }

    void display() const override {
        std::cout << "Heat index is " << heatIndex << std::endl;
    }

    std::string getName() const override {
        return "HeatIndexDisplay";
    }
};

// Usage example
void weatherStationDemo() {
    std::cout << "=== Observer Pattern - Weather Station ===" << std::endl;
    
    auto weatherData = std::make_shared<WeatherData>();
    
    // Create displays (observers)
    auto currentDisplay = std::make_shared<CurrentConditionsDisplay>(weatherData);
    auto statisticsDisplay = std::make_shared<StatisticsDisplay>(weatherData);
    auto forecastDisplay = std::make_shared<ForecastDisplay>(weatherData);
    auto heatIndexDisplay = std::make_shared<HeatIndexDisplay>(weatherData);
    
    // Simulate new weather measurements
    std::cout << "\n--- First Measurement ---" << std::endl;
    weatherData->setMeasurements(25.0f, 65.0f, 30.4f);
    
    std::cout << "\n--- Second Measurement ---" << std::endl;
    weatherData->setMeasurements(27.0f, 70.0f, 29.2f);
    
    std::cout << "\n--- Third Measurement ---" << std::endl;
    weatherData->setMeasurements(23.0f, 90.0f, 29.2f);
    
    // Remove an observer
    std::cout << "\n--- Removing Statistics Display ---" << std::endl;
    weatherData->removeObserver(statisticsDisplay);
    
    std::cout << "\n--- Fourth Measurement (without statistics) ---" << std::endl;
    weatherData->setMeasurements(20.0f, 75.0f, 30.1f);
}

int main() {
    weatherStationDemo();
    return 0;
}
```

#### Event Management System

```cpp
#include <iostream>
#include <vector>
#include <memory>
#include <algorithm>
#include <string>
#include <map>
#include <functional>

// Event types
enum class EventType {
    MOUSE_CLICK,
    KEY_PRESS,
    WINDOW_RESIZE,
    DATA_LOADED,
    NETWORK_RESPONSE
};

// Event data structure
struct Event {
    EventType type;
    std::string data;
    void* source;
    
    Event(EventType t, const std::string& d = "", void* s = nullptr)
        : type(t), data(d), source(s) {}
};

// Observer interface
class EventObserver {
public:
    virtual ~EventObserver() = default;
    virtual void onEvent(const Event& event) = 0;
    virtual std::string getName() const = 0;
};

// Subject (Event Manager)
class EventManager {
private:
    std::map<EventType, std::vector<std::shared_ptr<EventObserver>>> observers;

public:
    void subscribe(EventType eventType, std::shared_ptr<EventObserver> observer) {
        observers[eventType].push_back(observer);
        std::cout << observer->getName() << " subscribed to event type " 
                  << static_cast<int>(eventType) << std::endl;
    }

    void unsubscribe(EventType eventType, std::shared_ptr<EventObserver> observer) {
        auto& eventObservers = observers[eventType];
        auto it = std::find(eventObservers.begin(), eventObservers.end(), observer);
        if (it != eventObservers.end()) {
            std::cout << observer->getName() << " unsubscribed from event type " 
                      << static_cast<int>(eventType) << std::endl;
            eventObservers.erase(it);
        }
    }

    void notify(const Event& event) {
        auto it = observers.find(event.type);
        if (it != observers.end()) {
            std::cout << "\nNotifying " << it->second.size() 
                      << " observers for event type " << static_cast<int>(event.type) << std::endl;
            for (const auto& observer : it->second) {
                observer->onEvent(event);
            }
        }
    }

    void publish(EventType eventType, const std::string& data = "", void* source = nullptr) {
        Event event(eventType, data, source);
        notify(event);
    }
};

// Concrete Observers
class UIManager : public EventObserver {
public:
    void onEvent(const Event& event) override {
        switch (event.type) {
            case EventType::MOUSE_CLICK:
                std::cout << "UIManager: Handling mouse click at " << event.data << std::endl;
                break;
            case EventType::KEY_PRESS:
                std::cout << "UIManager: Key pressed: " << event.data << std::endl;
                break;
            case EventType::WINDOW_RESIZE:
                std::cout << "UIManager: Window resized to " << event.data << std::endl;
                break;
            default:
                // Ignore other events
                break;
        }
    }

    std::string getName() const override {
        return "UIManager";
    }
};

class DataProcessor : public EventObserver {
public:
    void onEvent(const Event& event) override {
        switch (event.type) {
            case EventType::DATA_LOADED:
                std::cout << "DataProcessor: Processing loaded data: " << event.data << std::endl;
                processData(event.data);
                break;
            case EventType::NETWORK_RESPONSE:
                std::cout << "DataProcessor: Handling network response: " << event.data << std::endl;
                break;
            default:
                // Ignore other events
                break;
        }
    }

    void processData(const std::string& data) {
        std::cout << "DataProcessor: Analyzing data... Done!" << std::endl;
    }

    std::string getName() const override {
        return "DataProcessor";
    }
};

class NetworkManager : public EventObserver {
public:
    void onEvent(const Event& event) override {
        if (event.type == EventType::NETWORK_RESPONSE) {
            std::cout << "NetworkManager: Received network data: " << event.data << std::endl;
            // Could trigger new events based on network response
        }
    }

    std::string getName() const override {
        return "NetworkManager";
    }
};

class Logger : public EventObserver {
public:
    void onEvent(const Event& event) override {
        std::cout << "Logger: Event " << static_cast<int>(event.type) 
                  << " - " << event.data << std::endl;
    }

    std::string getName() const override {
        return "Logger";
    }
};

// Usage example
void eventSystemDemo() {
    std::cout << "=== Observer Pattern - Event Management System ===" << std::endl;
    
    EventManager eventManager;
    
    // Create observers
    auto uiManager = std::make_shared<UIManager>();
    auto dataProcessor = std::make_shared<DataProcessor>();
    auto networkManager = std::make_shared<NetworkManager>();
    auto logger = std::make_shared<Logger>();
    
    // Subscribe observers to events
    eventManager.subscribe(EventType::MOUSE_CLICK, uiManager);
    eventManager.subscribe(EventType::KEY_PRESS, uiManager);
    eventManager.subscribe(EventType::WINDOW_RESIZE, uiManager);
    
    eventManager.subscribe(EventType::DATA_LOADED, dataProcessor);
    eventManager.subscribe(EventType::NETWORK_RESPONSE, dataProcessor);
    
    eventManager.subscribe(EventType::NETWORK_RESPONSE, networkManager);
    
    // Logger subscribes to all events
    eventManager.subscribe(EventType::MOUSE_CLICK, logger);
    eventManager.subscribe(EventType::KEY_PRESS, logger);
    eventManager.subscribe(EventType::WINDOW_RESIZE, logger);
    eventManager.subscribe(EventType::DATA_LOADED, logger);
    eventManager.subscribe(EventType::NETWORK_RESPONSE, logger);
    
    // Simulate events
    std::cout << "\n--- Simulating User Interface Events ---" << std::endl;
    eventManager.publish(EventType::MOUSE_CLICK, "(100, 200)");
    eventManager.publish(EventType::KEY_PRESS, "Enter");
    eventManager.publish(EventType::WINDOW_RESIZE, "800x600");
    
    std::cout << "\n--- Simulating Data Events ---" << std::endl;
    eventManager.publish(EventType::DATA_LOADED, "user_data.json");
    eventManager.publish(EventType::NETWORK_RESPONSE, "HTTP 200 OK");
    
    // Unsubscribe and test
    std::cout << "\n--- Unsubscribing Logger ---" << std::endl;
    eventManager.unsubscribe(EventType::MOUSE_CLICK, logger);
    eventManager.unsubscribe(EventType::KEY_PRESS, logger);
    eventManager.unsubscribe(EventType::WINDOW_RESIZE, logger);
    eventManager.unsubscribe(EventType::DATA_LOADED, logger);
    eventManager.unsubscribe(EventType::NETWORK_RESPONSE, logger);
    
    std::cout << "\n--- Event after unsubscribing Logger ---" << std::endl;
    eventManager.publish(EventType::KEY_PRESS, "Space");
}

int main() {
    eventSystemDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Observer function pointer type
typedef void (*UpdateFunction)(void* context, const char* stockSymbol, double price, int volume);

// Observer structure
typedef struct Observer {
    void* context;
    UpdateFunction update;
    char name[50];
    struct Observer* next;
} Observer;

// Subject structure
typedef struct Stock {
    char symbol[10];
    double price;
    int volume;
    Observer* observers;
    
    void (*setPrice)(struct Stock* self, double newPrice);
    void (*setVolume)(struct Stock* self, int newVolume);
    void (*registerObserver)(struct Stock* self, Observer* observer);
    void (*removeObserver)(struct Stock* self, const char* observerName);
    void (*notifyObservers)(struct Stock* self);
} Stock;

// Stock methods implementation
void stockSetPrice(Stock* self, double newPrice) {
    double oldPrice = self->price;
    self->price = newPrice;
    printf("Stock %s price changed: $%.2f -> $%.2f\n", self->symbol, oldPrice, newPrice);
    self->notifyObservers(self);
}

void stockSetVolume(Stock* self, int newVolume) {
    self->volume = newVolume;
    printf("Stock %s volume changed to: %d\n", self->symbol, newVolume);
    self->notifyObservers(self);
}

void stockRegisterObserver(Stock* self, Observer* observer) {
    observer->next = self->observers;
    self->observers = observer;
    printf("Registered observer: %s\n", observer->name);
}

void stockRemoveObserver(Stock* self, const char* observerName) {
    Observer** current = &(self->observers);
    
    while (*current != NULL) {
        if (strcmp((*current)->name, observerName) == 0) {
            Observer* toRemove = *current;
            *current = toRemove->next;
            printf("Removed observer: %s\n", observerName);
            free(toRemove);
            return;
        }
        current = &((*current)->next);
    }
    printf("Observer %s not found\n", observerName);
}

void stockNotifyObservers(Stock* self) {
    Observer* current = self->observers;
    int count = 0;
    
    while (current != NULL) {
        count++;
        current = current->next;
    }
    
    printf("Notifying %d observers for stock %s\n", count, self->symbol);
    
    current = self->observers;
    while (current != NULL) {
        current->update(current->context, self->symbol, self->price, self->volume);
        current = current->next;
    }
}

// Stock constructor
Stock* createStock(const char* symbol, double initialPrice) {
    Stock* stock = (Stock*)malloc(sizeof(Stock));
    strcpy(stock->symbol, symbol);
    stock->price = initialPrice;
    stock->volume = 0;
    stock->observers = NULL;
    
    stock->setPrice = stockSetPrice;
    stock->setVolume = stockSetVolume;
    stock->registerObserver = stockRegisterObserver;
    stock->removeObserver = stockRemoveObserver;
    stock->notifyObservers = stockNotifyObservers;
    
    return stock;
}

// Concrete Observers
void priceDisplayUpdate(void* context, const char* stockSymbol, double price, int volume) {
    printf("PriceDisplay: %s is now $%.2f\n", stockSymbol, price);
}

void volumeDisplayUpdate(void* context, const char* stockSymbol, double price, int volume) {
    printf("VolumeDisplay: %s volume: %d shares\n", stockSymbol, volume);
}

void tradingStrategyUpdate(void* context, const char* stockSymbol, double price, int volume) {
    double* threshold = (double*)context;
    if (price > *threshold) {
        printf("TradingStrategy: SELL %s at $%.2f (above threshold $%.2f)\n", 
               stockSymbol, price, *threshold);
    } else if (price < *threshold * 0.9) {
        printf("TradingStrategy: BUY %s at $%.2f (below threshold $%.2f)\n", 
               stockSymbol, price, *threshold);
    }
}

void alertSystemUpdate(void* context, const char* stockSymbol, double price, int volume) {
    double* previousPrice = (double*)context;
    double change = ((price - *previousPrice) / *previousPrice) * 100;
    
    if (abs(change) >= 5.0) {  // 5% change threshold
        printf("ALERT: %s changed by %.2f%%! ($%.2f -> $%.2f)\n", 
               stockSymbol, change, *previousPrice, price);
    }
    
    *previousPrice = price;
}

// Create observer helper functions
Observer* createPriceDisplayObserver(const char* name) {
    Observer* observer = (Observer*)malloc(sizeof(Observer));
    strcpy(observer->name, name);
    observer->context = NULL;
    observer->update = priceDisplayUpdate;
    observer->next = NULL;
    return observer;
}

Observer* createVolumeDisplayObserver(const char* name) {
    Observer* observer = (Observer*)malloc(sizeof(Observer));
    strcpy(observer->name, name);
    observer->context = NULL;
    observer->update = volumeDisplayUpdate;
    observer->next = NULL;
    return observer;
}

Observer* createTradingStrategyObserver(const char* name, double threshold) {
    Observer* observer = (Observer*)malloc(sizeof(Observer));
    strcpy(observer->name, name);
    
    double* context = (double*)malloc(sizeof(double));
    *context = threshold;
    observer->context = context;
    observer->update = tradingStrategyUpdate;
    observer->next = NULL;
    return observer;
}

Observer* createAlertSystemObserver(const char* name, double initialPrice) {
    Observer* observer = (Observer*)malloc(sizeof(Observer));
    strcpy(observer->name, name);
    
    double* context = (double*)malloc(sizeof(double));
    *context = initialPrice;
    observer->context = context;
    observer->update = alertSystemUpdate;
    observer->next = NULL;
    return observer;
}

// Demo function
void stockMarketDemo() {
    printf("=== Observer Pattern - Stock Market ===\n");
    
    // Create stocks
    Stock* apple = createStock("AAPL", 150.0);
    Stock* google = createStock("GOOGL", 2800.0);
    
    // Create observers
    Observer* priceDisplay1 = createPriceDisplayObserver("AAPL Price Display");
    Observer* priceDisplay2 = createPriceDisplayObserver("GOOGL Price Display");
    Observer* volumeDisplay = createVolumeDisplayObserver("Volume Display");
    Observer* tradingStrategy = createTradingStrategyObserver("Trading Bot", 155.0);
    Observer* alertSystem = createAlertSystemObserver("Alert System", 150.0);
    
    // Register observers
    apple->registerObserver(apple, priceDisplay1);
    apple->registerObserver(apple, volumeDisplay);
    apple->registerObserver(apple, tradingStrategy);
    apple->registerObserver(apple, alertSystem);
    
    google->registerObserver(google, priceDisplay2);
    google->registerObserver(google, volumeDisplay);
    
    // Simulate stock market activity
    printf("\n--- Stock Market Opening ---\n");
    apple->setVolume(apple, 1000000);
    google->setVolume(google, 500000);
    
    printf("\n--- Price Changes ---\n");
    apple->setPrice(apple, 152.5);
    apple->setPrice(apple, 148.0);
    apple->setPrice(apple, 160.0);  // Should trigger trading strategy
    
    google->setPrice(google, 2850.0);
    google->setPrice(google, 2820.0);
    
    printf("\n--- Volume Updates ---\n");
    apple->setVolume(apple, 2000000);
    google->setVolume(google, 750000);
    
    printf("\n--- Removing Observer ---\n");
    apple->removeObserver(apple, "Trading Bot");
    
    printf("\n--- More Price Changes ---\n");
    apple->setPrice(apple, 158.0);
    apple->setPrice(apple, 142.0);  // Big drop - should trigger alert
    
    // Cleanup
    free(apple);
    free(google);
    free(priceDisplay1);
    free(priceDisplay2);
    free(volumeDisplay);
    free(tradingStrategy->context);
    free(tradingStrategy);
    free(alertSystem->context);
    free(alertSystem);
}

int main() {
    stockMarketDemo();
    return 0;
}
```

### Python Implementation

#### News Agency and Subscribers

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime
import random

# Subject interface
class NewsAgency(ABC):
    @abstractmethod
    def register_subscriber(self, subscriber: 'Subscriber') -> None: ...
    
    @abstractmethod
    def remove_subscriber(self, subscriber: 'Subscriber') -> None: ...
    
    @abstractmethod
    def notify_subscribers(self) -> None: ...

# Observer interface
class Subscriber(ABC):
    @abstractmethod
    def update(self, news: Dict[str, Any]) -> None: ...
    
    @abstractmethod
    def get_name(self) -> str: ...

# Concrete Subject - News Agency
class ReutersNewsAgency(NewsAgency):
    def __init__(self, name: str):
        self.name = name
        self._subscribers: List[Subscriber] = []
        self._latest_news: Dict[str, Any] = {}
        self._news_count = 0
    
    def register_subscriber(self, subscriber: Subscriber) -> None:
        if subscriber not in self._subscribers:
            self._subscribers.append(subscriber)
            print(f"{subscriber.get_name()} subscribed to {self.name}")
    
    def remove_subscriber(self, subscriber: Subscriber) -> None:
        if subscriber in self._subscribers:
            self._subscribers.remove(subscriber)
            print(f"{subscriber.get_name()} unsubscribed from {self.name}")
    
    def notify_subscribers(self) -> None:
        print(f"\n{self.name} notifying {len(self._subscribers)} subscribers...")
        for subscriber in self._subscribers:
            subscriber.update(self._latest_news)
    
    def publish_news(self, category: str, headline: str, content: str, priority: str = "normal") -> None:
        self._news_count += 1
        self._latest_news = {
            "id": self._news_count,
            "agency": self.name,
            "category": category,
            "headline": headline,
            "content": content,
            "priority": priority,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "breaking": priority == "breaking"
        }
        
        print(f"\n📰 {self.name} published: {headline}")
        self.notify_subscribers()
    
    def get_subscriber_count(self) -> int:
        return len(self._subscribers)

# Concrete Observers
class Newspaper(Subscriber):
    def __init__(self, name: str, sections: List[str]):
        self.name = name
        self.sections = sections
        self.published_articles: List[Dict[str, Any]] = []
    
    def update(self, news: Dict[str, Any]) -> None:
        # Only publish news in relevant sections
        if news["category"] in self.sections or "all" in self.sections:
            self.publish_article(news)
    
    def publish_article(self, news: Dict[str, Any]) -> None:
        priority_indicator = "🚨 " if news["breaking"] else ""
        self.published_articles.append(news)
        print(f"📖 {self.name} publishes: {priority_indicator}{news['headline']}")
    
    def get_name(self) -> str:
        return self.name
    
    def show_front_page(self) -> None:
        print(f"\n=== {self.name} Front Page ===")
        recent_articles = self.published_articles[-5:]  # Last 5 articles
        for article in recent_articles:
            breaking = "🚨 BREAKING: " if article["breaking"] else ""
            print(f"• {breaking}{article['headline']} ({article['timestamp']})")

class TVChannel(Subscriber):
    def __init__(self, name: str, broadcast_region: str):
        self.name = name
        self.broadcast_region = broadcast_region
        self.news_bulletins: List[Dict[str, Any]] = []
    
    def update(self, news: Dict[str, Any]) -> None:
        # TV channels prioritize breaking news
        if news["breaking"]:
            self.broadcast_breaking_news(news)
        else:
            self.schedule_news_segment(news)
    
    def broadcast_breaking_news(self, news: Dict[str, Any]) -> None:
        self.news_bulletins.append(news)
        print(f"📺 {self.name} INTERRUPTS BROADCAST: 🚨 {news['headline']} 🚨")
    
    def schedule_news_segment(self, news: Dict[str, Any]) -> None:
        self.news_bulletins.append(news)
        print(f"📺 {self.name} schedules: {news['headline']} for next news segment")
    
    def get_name(self) -> str:
        return self.name
    
    def show_bulletins(self) -> None:
        print(f"\n=== {self.name} News Bulletins ===")
        for bulletin in self.news_bulletins[-3:]:  # Last 3 bulletins
            breaking = "🚨 " if bulletin["breaking"] else ""
            print(f"• {breaking}{bulletin['headline']}")

class OnlineNewsPortal(Subscriber):
    def __init__(self, name: str, website: str):
        self.name = name
        self.website = website
        self.articles: List[Dict[str, Any]] = []
        self.push_notifications_sent = 0
    
    def update(self, news: Dict[str, Any]) -> None:
        self.publish_online(news)
        
        # Send push notification for important news
        if news["breaking"] or news["priority"] == "high":
            self.send_push_notification(news)
    
    def publish_online(self, news: Dict[str, Any]) -> None:
        self.articles.append(news)
        print(f"🌐 {self.name} publishes online: {news['headline']}")
    
    def send_push_notification(self, news: Dict[str, Any]) -> None:
        self.push_notifications_sent += 1
        urgency = "🚨 " if news["breaking"] else "🔔 "
        print(f"📱 {self.name} sends push: {urgency}{news['headline']}")
    
    def get_name(self) -> str:
        return self.name
    
    def show_latest_articles(self) -> None:
        print(f"\n=== {self.name} Latest Articles ===")
        for article in self.articles[-5:]:
            breaking = "🚨 " if article["breaking"] else ""
            print(f"• {breaking}{article['headline']}")

class NewsAggregator(Subscriber):
    def __init__(self, name: str):
        self.name = name
        self.all_news: List[Dict[str, Any]] = []
        self.categories: Dict[str, int] = {}
    
    def update(self, news: Dict[str, Any]) -> None:
        self.all_news.append(news)
        
        # Track news by category
        category = news["category"]
        self.categories[category] = self.categories.get(category, 0) + 1
        
        print(f"📊 {self.name} aggregated: {news['headline']}")
    
    def get_name(self) -> str:
        return self.name
    
    def show_statistics(self) -> None:
        print(f"\n=== {self.name} News Statistics ===")
        print(f"Total articles: {len(self.all_news)}")
        print("Articles by category:")
        for category, count in self.categories.items():
            print(f"  {category}: {count}")
        
        breaking_count = sum(1 for news in self.all_news if news["breaking"])
        print(f"Breaking news: {breaking_count}")

# Demo function
def news_agency_demo():
    print("=== Observer Pattern - News Agency System ===\n")
    
    # Create news agency
    reuters = ReutersNewsAgency("Reuters")
    
    # Create subscribers
    ny_times = Newspaper("The New York Times", ["politics", "business", "technology"])
    cnn = TVChannel("CNN", "International")
    buzzfeed = OnlineNewsPortal("BuzzFeed News", "buzzfeed.com/news")
    news_api = NewsAggregator("NewsAPI Aggregator")
    
    # Register subscribers
    reuters.register_subscriber(ny_times)
    reuters.register_subscriber(cnn)
    reuters.register_subscriber(buzzfeed)
    reuters.register_subscriber(news_api)
    
    # Simulate news publishing
    print(f"\n--- Daily News Publishing ---")
    reuters.publish_news("politics", "New Legislation Passes in Senate", 
                        "The Senate has passed new legislation regarding...", "high")
    
    reuters.publish_news("technology", "Apple Announces New iPhone", 
                        "Apple unveiled its latest iPhone model with...", "normal")
    
    reuters.publish_news("business", "Stock Market Reaches All-Time High", 
                        "The stock market closed at a record high today...", "normal")
    
    # Breaking news!
    print(f"\n--- Breaking News ---")
    reuters.publish_news("politics", "President Announces Resignation", 
                        "In a surprise announcement, the president...", "breaking")
    
    reuters.publish_news("sports", "Team Wins Championship in Overtime", 
                        "An incredible comeback victory in the finals...", "high")
    
    # Unsubscribe a subscriber
    print(f"\n--- Unsubscribing ---")
    reuters.remove_subscriber(buzzfeed)
    
    # More news after unsubscribe
    reuters.publish_news("technology", "Major Cybersecurity Breach Discovered", 
                        "Security researchers have discovered...", "high")
    
    # Show subscriber outputs
    print(f"\n--- Subscriber Outputs ---")
    ny_times.show_front_page()
    cnn.show_bulletins()
    buzzfeed.show_latest_articles()
    news_api.show_statistics()
    
    # Final statistics
    print(f"\n=== Agency Statistics ===")
    print(f"Total subscribers: {reuters.get_subscriber_count()}")

if __name__ == "__main__":
    news_agency_demo()
```

#### E-commerce Notification System

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime
from enum import Enum
import smtplib
from email.mime.text import MIMEText
import json

class OrderStatus(Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

# Subject interface
class Order(ABC):
    @abstractmethod
    def add_observer(self, observer: 'OrderObserver') -> None: ...
    
    @abstractmethod
    def remove_observer(self, observer: 'OrderObserver') -> None: ...
    
    @abstractmethod
    def notify_observers(self) -> None: ...

# Observer interface
class OrderObserver(ABC):
    @abstractmethod
    def update(self, order: 'ConcreteOrder') -> None: ...
    
    @abstractmethod
    def get_name(self) -> str: ...

# Concrete Subject - Order
class ConcreteOrder(Order):
    def __init__(self, order_id: str, customer_email: str, items: List[Dict], total_amount: float):
        self.order_id = order_id
        self.customer_email = customer_email
        self.items = items
        self.total_amount = total_amount
        self.status = OrderStatus.PENDING
        self.status_history: List[Dict[str, Any]] = []
        self._observers: List[OrderObserver] = []
        
        self._add_status_history("Order created")
    
    def add_observer(self, observer: OrderObserver) -> None:
        if observer not in self._observers:
            self._observers.append(observer)
            print(f"Added observer: {observer.get_name()} to order {self.order_id}")
    
    def remove_observer(self, observer: OrderObserver) -> None:
        if observer in self._observers:
            self._observers.remove(observer)
            print(f"Removed observer: {observer.get_name()} from order {self.order_id}")
    
    def notify_observers(self) -> None:
        print(f"\nNotifying {len(self._observers)} observers for order {self.order_id}")
        for observer in self._observers:
            observer.update(self)
    
    def set_status(self, new_status: OrderStatus, notes: str = "") -> None:
        old_status = self.status
        self.status = new_status
        self._add_status_history(f"Status changed: {old_status.value} -> {new_status.value}", notes)
        self.notify_observers()
    
    def _add_status_history(self, event: str, notes: str = "") -> None:
        history_entry = {
            "event": event,
            "timestamp": datetime.now().isoformat(),
            "status": self.status.value,
            "notes": notes
        }
        self.status_history.append(history_entry)
        print(f"Order {self.order_id}: {event}")
    
    def get_order_info(self) -> Dict[str, Any]:
        return {
            "order_id": self.order_id,
            "customer_email": self.customer_email,
            "items": self.items,
            "total_amount": self.total_amount,
            "status": self.status.value,
            "status_history": self.status_history
        }

# Concrete Observers
class EmailNotifier(OrderObserver):
    def __init__(self, smtp_server: str = "localhost", port: int = 587):
        self.smtp_server = smtp_server
        self.port = port
        self.sent_emails: List[Dict] = []
    
    def update(self, order: ConcreteOrder) -> None:
        order_info = order.get_order_info()
        
        if order.status == OrderStatus.CONFIRMED:
            self._send_confirmation_email(order)
        elif order.status == OrderStatus.SHIPPED:
            self._send_shipping_email(order)
        elif order.status == OrderStatus.DELIVERED:
            self._send_delivery_email(order)
        elif order.status == OrderStatus.CANCELLED:
            self._send_cancellation_email(order)
    
    def _send_confirmation_email(self, order: ConcreteOrder) -> None:
        subject = f"Order Confirmed - #{order.order_id}"
        body = f"""
        Dear Customer,
        
        Thank you for your order! Your order #{order.order_id} has been confirmed.
        
        Order Details:
        - Total Amount: ${order.total_amount:.2f}
        - Items: {len(order.items)}
        
        We will notify you when your order ships.
        
        Best regards,
        The Store Team
        """
        self._simulate_send_email(order.customer_email, subject, body)
        self.sent_emails.append({"type": "confirmation", "order_id": order.order_id})
    
    def _send_shipping_email(self, order: ConcreteOrder) -> None:
        subject = f"Order Shipped - #{order.order_id}"
        body = f"""
        Dear Customer,
        
        Great news! Your order #{order.order_id} has been shipped.
        
        Your items are on their way and should arrive soon.
        
        Thank you for shopping with us!
        
        Best regards,
        The Store Team
        """
        self._simulate_send_email(order.customer_email, subject, body)
        self.sent_emails.append({"type": "shipping", "order_id": order.order_id})
    
    def _send_delivery_email(self, order: ConcreteOrder) -> None:
        subject = f"Order Delivered - #{order.order_id}"
        body = f"""
        Dear Customer,
        
        Your order #{order.order_id} has been delivered!
        
        We hope you enjoy your purchase. If you have any questions, please contact our support team.
        
        Thank you for your business!
        
        Best regards,
        The Store Team
        """
        self._simulate_send_email(order.customer_email, subject, body)
        self.sent_emails.append({"type": "delivery", "order_id": order.order_id})
    
    def _send_cancellation_email(self, order: ConcreteOrder) -> None:
        subject = f"Order Cancelled - #{order.order_id}"
        body = f"""
        Dear Customer,
        
        Your order #{order.order_id} has been cancelled.
        
        If this was a mistake or you have any questions, please contact our support team.
        
        Best regards,
        The Store Team
        """
        self._simulate_send_email(order.customer_email, subject, body)
        self.sent_emails.append({"type": "cancellation", "order_id": order.order_id})
    
    def _simulate_send_email(self, to_email: str, subject: str, body: str) -> None:
        # In real implementation, this would actually send an email
        print(f"📧 Email sent to {to_email}: {subject}")
        # print(f"   Body: {body.strip()}")
    
    def get_name(self) -> str:
        return "EmailNotifier"
    
    def show_sent_emails(self) -> None:
        print(f"\n=== Email Notifier Statistics ===")
        print(f"Total emails sent: {len(self.sent_emails)}")
        email_types = {}
        for email in self.sent_emails:
            email_type = email["type"]
            email_types[email_type] = email_types.get(email_type, 0) + 1
        
        for email_type, count in email_types.items():
            print(f"  {email_type}: {count}")

class InventoryManager(OrderObserver):
    def __init__(self):
        self.inventory_updates: List[Dict] = []
    
    def update(self, order: ConcreteOrder) -> None:
        if order.status == OrderStatus.CONFIRMED:
            self._update_inventory(order)
        elif order.status == OrderStatus.CANCELLED:
            self._restore_inventory(order)
    
    def _update_inventory(self, order: ConcreteOrder) -> None:
        print(f"📦 Inventory: Updating stock for order {order.order_id}")
        for item in order.items:
            self.inventory_updates.append({
                "order_id": order.order_id,
                "action": "deduct",
                "item": item["name"],
                "quantity": item["quantity"],
                "timestamp": datetime.now().isoformat()
            })
            print(f"   - Deducted {item['quantity']} of {item['name']}")
    
    def _restore_inventory(self, order: ConcreteOrder) -> None:
        print(f"📦 Inventory: Restoring stock for cancelled order {order.order_id}")
        for item in order.items:
            self.inventory_updates.append({
                "order_id": order.order_id,
                "action": "restore",
                "item": item["name"],
                "quantity": item["quantity"],
                "timestamp": datetime.now().isoformat()
            })
            print(f"   - Restored {item['quantity']} of {item['name']}")
    
    def get_name(self) -> str:
        return "InventoryManager"
    
    def show_inventory_changes(self) -> None:
        print(f"\n=== Inventory Changes ===")
        for update in self.inventory_updates[-5:]:  # Show last 5 changes
            action = "➖ Deducted" if update["action"] == "deduct" else "➕ Restored"
            print(f"  {action} {update['quantity']} {update['item']} (Order: {update['order_id']})")

class AnalyticsTracker(OrderObserver):
    def __init__(self):
        self.analytics_data: List[Dict] = []
        self.revenue_by_status: Dict[str, float] = {}
    
    def update(self, order: ConcreteOrder) -> None:
        order_info = order.get_order_info()
        
        # Track order status changes for analytics
        self.analytics_data.append({
            "order_id": order.order_id,
            "status": order.status.value,
            "timestamp": datetime.now().isoformat(),
            "amount": order.total_amount
        })
        
        # Update revenue tracking
        self._update_revenue_analytics(order)
        
        print(f"📊 Analytics: Tracked {order.status.value} for order {order.order_id}")
    
    def _update_revenue_analytics(self, order: ConcreteOrder) -> None:
        status = order.status.value
        if status not in self.revenue_by_status:
            self.revenue_by_status[status] = 0
        self.revenue_by_status[status] += order.total_amount
    
    def get_name(self) -> str:
        return "AnalyticsTracker"
    
    def show_analytics(self) -> None:
        print(f"\n=== Order Analytics ===")
        print(f"Total orders tracked: {len(self.analytics_data)}")
        print("Revenue by status:")
        for status, revenue in self.revenue_by_status.items():
            print(f"  {status}: ${revenue:.2f}")

class CustomerSupportNotifier(OrderObserver):
    def __init__(self):
        self.support_tickets: List[Dict] = []
    
    def update(self, order: ConcreteOrder) -> None:
        # Create support tickets for certain conditions
        if order.status == OrderStatus.CANCELLED:
            self._create_cancellation_ticket(order)
        elif order.get_order_info()["total_amount"] > 1000:  # High-value orders
            self._create_high_value_ticket(order)
    
    def _create_cancellation_ticket(self, order: ConcreteOrder) -> None:
        ticket = {
            "ticket_id": f"TICKET-{len(self.support_tickets) + 1:06d}",
            "order_id": order.order_id,
            "type": "cancellation",
            "priority": "medium",
            "created_at": datetime.now().isoformat()
        }
        self.support_tickets.append(ticket)
        print(f"🎫 Support: Created cancellation ticket {ticket['ticket_id']} for order {order.order_id}")
    
    def _create_high_value_ticket(self, order: ConcreteOrder) -> None:
        ticket = {
            "ticket_id": f"TICKET-{len(self.support_tickets) + 1:06d}",
            "order_id": order.order_id,
            "type": "high_value",
            "priority": "low",
            "created_at": datetime.now().isoformat(),
            "amount": order.total_amount
        }
        self.support_tickets.append(ticket)
        print(f"🎫 Support: Created high-value order ticket {ticket['ticket_id']} for ${order.total_amount:.2f} order")
    
    def get_name(self) -> str:
        return "CustomerSupportNotifier"
    
    def show_support_tickets(self) -> None:
        print(f"\n=== Support Tickets ===")
        print(f"Total tickets: {len(self.support_tickets)}")
        for ticket in self.support_tickets:
            print(f"  {ticket['ticket_id']}: {ticket['type']} (Order: {ticket['order_id']})")

# Demo function
def ecommerce_demo():
    print("=== Observer Pattern - E-commerce Order System ===\n")
    
    # Create observers
    email_notifier = EmailNotifier()
    inventory_manager = InventoryManager()
    analytics_tracker = AnalyticsTracker()
    support_notifier = CustomerSupportNotifier()
    
    # Create orders
    order1 = ConcreteOrder(
        order_id="ORD-001",
        customer_email="customer1@example.com",
        items=[
            {"name": "Laptop", "quantity": 1, "price": 999.99},
            {"name": "Mouse", "quantity": 1, "price": 29.99}
        ],
        total_amount=1029.98
    )
    
    order2 = ConcreteOrder(
        order_id="ORD-002",
        customer_email="customer2@example.com",
        items=[
            {"name": "Book", "quantity": 2, "price": 15.99},
            {"name": "Pen", "quantity": 3, "price": 2.99}
        ],
        total_amount=41.95
    )
    
    # Register observers to orders
    for order in [order1, order2]:
        order.add_observer(email_notifier)
        order.add_observer(inventory_manager)
        order.add_observer(analytics_tracker)
        order.add_observer(support_notifier)
    
    # Simulate order lifecycle
    print(f"\n--- Processing Order {order1.order_id} ---")
    order1.set_status(OrderStatus.CONFIRMED)
    order1.set_status(OrderStatus.SHIPPED, "Shipped via UPS")
    order1.set_status(OrderStatus.DELIVERED, "Left at front door")
    
    print(f"\n--- Processing Order {order2.order_id} ---")
    order2.set_status(OrderStatus.CONFIRMED)
    order2.set_status(OrderStatus.CANCELLED, "Customer requested cancellation")
    
    # Create another order and don't register all observers
    order3 = ConcreteOrder(
        order_id="ORD-003",
        customer_email="customer3@example.com",
        items=[{"name": "Headphones", "quantity": 1, "price": 199.99}],
        total_amount=199.99
    )
    
    # Only register email notifier for this order
    order3.add_observer(email_notifier)
    order3.add_observer(analytics_tracker)
    
    print(f"\n--- Processing Order {order3.order_id} (Limited Observers) ---")
    order3.set_status(OrderStatus.CONFIRMED)
    order3.set_status(OrderStatus.SHIPPED)
    
    # Show observer statistics
    print(f"\n=== System Statistics ===")
    email_notifier.show_sent_emails()
    inventory_manager.show_inventory_changes()
    analytics_tracker.show_analytics()
    support_notifier.show_support_tickets()

if __name__ == "__main__":
    ecommerce_demo()
```

## Advantages and Disadvantages

### Advantages

- **Loose Coupling**: Subjects and observers are loosely coupled
- **Dynamic Relationships**: Observers can be added/removed at runtime
- **Broadcast Communication**: One subject can notify multiple observers
- **Open/Closed Principle**: Easy to add new observers without changing subjects
- **Reusability**: Observer classes can be reused in different contexts

### Disadvantages

- **Memory Leaks**: Can cause memory leaks if observers aren't properly removed
- **Unexpected Updates**: Observers may receive updates in unexpected order
- **Performance Overhead**: Can impact performance with many observers
- **Complex Debugging**: Hard to debug chains of notifications

## Best Practices

1. **Use for Event Handling**: Ideal for implementing event handling systems
2. **Consider Update Order**: Be mindful of the order in which observers are notified
3. **Avoid Complex Logic in Update**: Keep update methods simple and fast
4. **Use Weak References**: Prevent memory leaks using weak references
5. **Consider Asynchronous Updates**: For performance, consider asynchronous notification

## Observer vs Other Patterns

- **vs Mediator**: Observer defines one-to-many dependency, Mediator centralizes complex communications
- **vs Publish-Subscribe**: Observer is typically synchronous, Pub-Sub is often asynchronous
- **vs Chain of Responsibility**: Observer notifies all observers, Chain passes request along a chain
- **vs Strategy**: Observer changes object behavior reactively, Strategy changes it proactively

The Observer pattern is fundamental in modern software development, especially in GUI frameworks, event-driven architectures, and reactive programming systems. It enables clean separation between business logic and user interface components.
