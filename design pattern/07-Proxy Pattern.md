# Proxy Pattern

## Introduction

The Proxy pattern is a structural design pattern that provides a surrogate or placeholder for another object to control access to it. A proxy acts as an intermediary between the client and the real object, adding additional functionality without changing the real object's code.

### Key Characteristics

- **Access Control**: Controls access to the real object
- **Additional Functionality**: Adds extra behavior like caching, logging, or security
- **Lazy Initialization**: Defers object creation until necessary
- **Location Transparency**: Client interacts with proxy as if it were the real object

### Use Cases

- **Virtual Proxy**: For expensive objects that should be created on demand
- **Protection Proxy**: To control access to sensitive operations
- **Remote Proxy**: To represent objects in different address spaces
- **Caching Proxy**: To cache results of expensive operations
- **Logging Proxy**: To log method calls and parameters

## Implementation Examples

### C++ Implementation

#### Virtual Proxy (Lazy Loading)

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <chrono>

// Subject interface
class Image {
public:
    virtual ~Image() = default;
    virtual void display() = 0;
    virtual std::string getName() const = 0;
};

// Real Subject - Expensive to create
class HighResolutionImage : public Image {
private:
    std::string filename;
    
    void loadImageFromDisk() {
        std::cout << "Loading high resolution image from disk: " << filename << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(2)); // Simulate heavy loading
        std::cout << "Image loaded successfully!" << std::endl;
    }

public:
    HighResolutionImage(const std::string& file) : filename(file) {
        loadImageFromDisk();
    }
    
    void display() override {
        std::cout << "Displaying high resolution image: " << filename << std::endl;
    }
    
    std::string getName() const override {
        return filename;
    }
};

// Virtual Proxy - Lazy loading
class ImageProxy : public Image {
private:
    std::string filename;
    mutable std::unique_ptr<HighResolutionImage> realImage;
    
    void loadRealImage() const {
        if (!realImage) {
            std::cout << "Proxy: Creating real image object..." << std::endl;
            realImage = std::make_unique<HighResolutionImage>(filename);
        }
    }

public:
    ImageProxy(const std::string& file) : filename(file) {
        std::cout << "Proxy created for: " << filename << std::endl;
    }
    
    void display() override {
        loadRealImage();
        realImage->display();
    }
    
    std::string getName() const override {
        return filename;
    }
    
    // Additional proxy functionality
    void showInfo() const {
        std::cout << "Proxy info - Image: " << filename 
                  << ", Loaded: " << (realImage ? "Yes" : "No") << std::endl;
    }
};

// Protection Proxy Example
class BankAccount {
public:
    virtual ~BankAccount() = default;
    virtual void deposit(double amount) = 0;
    virtual void withdraw(double amount) = 0;
    virtual double getBalance() const = 0;
};

class RealBankAccount : public BankAccount {
private:
    double balance;
    std::string owner;

public:
    RealBankAccount(const std::string& owner, double initialBalance = 0.0) 
        : owner(owner), balance(initialBalance) {}
    
    void deposit(double amount) override {
        balance += amount;
        std::cout << owner << " deposited $" << amount << std::endl;
    }
    
    void withdraw(double amount) override {
        if (amount <= balance) {
            balance -= amount;
            std::cout << owner << " withdrew $" << amount << std::endl;
        } else {
            std::cout << "Insufficient funds for withdrawal!" << std::endl;
        }
    }
    
    double getBalance() const override {
        return balance;
    }
};

class BankAccountProxy : public BankAccount {
private:
    RealBankAccount* realAccount;
    std::string userRole;

public:
    BankAccountProxy(const std::string& owner, const std::string& role, double initialBalance = 0.0)
        : userRole(role) {
        realAccount = new RealBankAccount(owner, initialBalance);
    }
    
    ~BankAccountProxy() {
        delete realAccount;
    }
    
    void deposit(double amount) override {
        if (userRole == "admin" || userRole == "teller") {
            realAccount->deposit(amount);
        } else {
            std::cout << "Access denied: Insufficient permissions for deposit" << std::endl;
        }
    }
    
    void withdraw(double amount) override {
        if (userRole == "admin") {
            realAccount->withdraw(amount);
        } else if (userRole == "teller" && amount <= 1000.0) {
            realAccount->withdraw(amount);
        } else {
            std::cout << "Access denied: Insufficient permissions for withdrawal" << std::endl;
        }
    }
    
    double getBalance() const override {
        if (userRole == "admin" || userRole == "teller" || userRole == "customer") {
            return realAccount->getBalance();
        } else {
            std::cout << "Access denied: Cannot view balance" << std::endl;
            return 0.0;
        }
    }
};

// Usage example
int main() {
    std::cout << "=== Virtual Proxy Example ===" << std::endl;
    
    // Create proxy - real image not loaded yet
    ImageProxy image1("photo1.jpg");
    image1.showInfo();
    
    // Real image loaded only when needed
    std::cout << "\nCalling display() - will load real image:" << std::endl;
    image1.display();
    
    std::cout << "\n=== Protection Proxy Example ===" << std::endl;
    
    // Different users with different permissions
    BankAccountProxy adminAccount("John Doe", "admin", 5000.0);
    BankAccountProxy tellerAccount("John Doe", "teller", 5000.0);
    BankAccountProxy customerAccount("John Doe", "customer", 5000.0);
    
    std::cout << "\nAdmin operations:" << std::endl;
    adminAccount.deposit(1000.0);
    adminAccount.withdraw(2000.0);
    std::cout << "Balance: $" << adminAccount.getBalance() << std::endl;
    
    std::cout << "\nTeller operations:" << std::endl;
    tellerAccount.deposit(500.0);
    tellerAccount.withdraw(500.0);  // Allowed
    tellerAccount.withdraw(1500.0); // Denied
    std::cout << "Balance: $" << tellerAccount.getBalance() << std::endl;
    
    std::cout << "\nCustomer operations:" << std::endl;
    customerAccount.deposit(100.0); // Denied
    customerAccount.withdraw(100.0); // Denied
    std::cout << "Balance: $" << customerAccount.getBalance() << std::endl;
    
    return 0;
}
```

#### Smart Pointer Proxy

```cpp
#include <iostream>
#include <memory>
#include <vector>

// Resource-intensive object
class ExpensiveObject {
private:
    int id;
    
public:
    ExpensiveObject(int objId) : id(objId) {
        std::cout << "Creating ExpensiveObject " << id << " (heavy initialization)" << std::endl;
    }
    
    ~ExpensiveObject() {
        std::cout << "Destroying ExpensiveObject " << id << std::endl;
    }
    
    void operation() {
        std::cout << "ExpensiveObject " << id << " performing operation" << std::endl;
    }
    
    int getId() const { return id; }
};

// Smart proxy that manages lifetime
template<typename T>
class SmartProxy {
private:
    mutable std::shared_ptr<T> realObject;
    int objectId;
    
    void ensureCreated() const {
        if (!realObject) {
            realObject = std::make_shared<T>(objectId);
        }
    }

public:
    SmartProxy(int id) : objectId(id) {
        std::cout << "SmartProxy created for object " << id << std::endl;
    }
    
    // Delegate operations to real object
    void operation() {
        ensureCreated();
        realObject->operation();
    }
    
    // Access underlying object
    std::shared_ptr<T> getRealObject() {
        ensureCreated();
        return realObject;
    }
    
    // Proxy-specific functionality
    bool isCreated() const {
        return realObject != nullptr;
    }
    
    int getObjectId() const {
        return objectId;
    }
};

// Usage example
int main() {
    std::cout << "=== Smart Proxy Example ===" << std::endl;
    
    std::vector<SmartProxy<ExpensiveObject>> objects;
    
    // Create proxies - no real objects created yet
    for (int i = 1; i <= 3; ++i) {
        objects.emplace_back(i);
    }
    
    std::cout << "\nProxies created, real objects not initialized yet:" << std::endl;
    for (const auto& proxy : objects) {
        std::cout << "Object " << proxy.getObjectId() 
                  << " created: " << (proxy.isCreated() ? "Yes" : "No") << std::endl;
    }
    
    std::cout << "\nUsing some objects:" << std::endl;
    objects[0].operation();  // Creates real object
    objects[2].operation();  // Creates real object
    
    std::cout << "\nAfter using some objects:" << std::endl;
    for (const auto& proxy : objects) {
        std::cout << "Object " << proxy.getObjectId() 
                  << " created: " << (proxy.isCreated() ? "Yes" : "No") << std::endl;
    }
    
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Subject interface
typedef struct {
    void (*request)(void* self);
} Subject;

// Real Subject
typedef struct {
    Subject base;
    char* name;
} RealSubject;

void real_subject_request(void* self) {
    RealSubject* real = (RealSubject*)self;
    printf("RealSubject: Handling request for %s\n", real->name);
}

RealSubject* create_real_subject(const char* name) {
    RealSubject* subject = malloc(sizeof(RealSubject));
    subject->base.request = real_subject_request;
    subject->name = strdup(name);
    return subject;
}

void destroy_real_subject(RealSubject* subject) {
    free(subject->name);
    free(subject);
}

// Protection Proxy
typedef struct {
    Subject base;
    RealSubject* real_subject;
    char* user_role;
    int access_count;
    time_t last_access;
} ProtectionProxy;

int proxy_check_access(ProtectionProxy* proxy, const char* required_role) {
    return strcmp(proxy->user_role, required_role) == 0;
}

void proxy_log_access(ProtectionProxy* proxy) {
    proxy->access_count++;
    proxy->last_access = time(NULL);
    printf("Proxy: Access logged - User: %s, Count: %d\n", 
           proxy->user_role, proxy->access_count);
}

void protection_proxy_request(void* self) {
    ProtectionProxy* proxy = (ProtectionProxy*)self;
    
    proxy_log_access(proxy);
    
    if (proxy_check_access(proxy, "admin")) {
        printf("Proxy: Access granted for admin user\n");
        proxy->real_subject->base.request(proxy->real_subject);
    } else {
        printf("Proxy: Access denied for user role '%s'\n", proxy->user_role);
    }
}

ProtectionProxy* create_protection_proxy(const char* name, const char* user_role) {
    ProtectionProxy* proxy = malloc(sizeof(ProtectionProxy));
    proxy->base.request = protection_proxy_request;
    proxy->real_subject = create_real_subject(name);
    proxy->user_role = strdup(user_role);
    proxy->access_count = 0;
    proxy->last_access = 0;
    return proxy;
}

void destroy_protection_proxy(ProtectionProxy* proxy) {
    destroy_real_subject(proxy->real_subject);
    free(proxy->user_role);
    free(proxy);
}

// Caching Proxy
typedef struct {
    Subject base;
    RealSubject* real_subject;
    char* cache_data;
    time_t cache_time;
    int cache_ttl; // Time to live in seconds
} CachingProxy;

int is_cache_valid(CachingProxy* proxy) {
    if (!proxy->cache_data) return 0;
    
    time_t current_time = time(NULL);
    return (current_time - proxy->cache_time) < proxy->cache_ttl;
}

void caching_proxy_request(void* self) {
    CachingProxy* proxy = (CachingProxy*)self;
    
    if (is_cache_valid(proxy)) {
        printf("CachingProxy: Returning cached result - %s\n", proxy->cache_data);
        return;
    }
    
    printf("CachingProxy: Cache miss, delegating to real subject\n");
    
    // Simulate expensive operation and cache result
    free(proxy->cache_data);
    proxy->cache_data = strdup("Expensive operation result");
    proxy->cache_time = time(NULL);
    
    proxy->real_subject->base.request(proxy->real_subject);
    printf("CachingProxy: Result cached for %d seconds\n", proxy->cache_ttl);
}

CachingProxy* create_caching_proxy(const char* name, int ttl_seconds) {
    CachingProxy* proxy = malloc(sizeof(CachingProxy));
    proxy->base.request = caching_proxy_request;
    proxy->real_subject = create_real_subject(name);
    proxy->cache_data = NULL;
    proxy->cache_time = 0;
    proxy->cache_ttl = ttl_seconds;
    return proxy;
}

void destroy_caching_proxy(CachingProxy* proxy) {
    destroy_real_subject(proxy->real_subject);
    free(proxy->cache_data);
    free(proxy);
}

// Usage example
int main() {
    printf("=== Protection Proxy Example ===\n");
    
    ProtectionProxy* admin_proxy = create_protection_proxy("SensitiveData", "admin");
    ProtectionProxy* user_proxy = create_protection_proxy("SensitiveData", "user");
    
    printf("\nAdmin access:\n");
    admin_proxy->base.request(admin_proxy);
    
    printf("\nUser access:\n");
    user_proxy->base.request(user_proxy);
    
    printf("\n=== Caching Proxy Example ===\n");
    
    CachingProxy* cache_proxy = create_caching_proxy("ExpensiveOperation", 2); // 2 second TTL
    
    printf("\nFirst call (will cache):\n");
    cache_proxy->base.request(cache_proxy);
    
    printf("\nSecond call (immediate, uses cache):\n");
    cache_proxy->base.request(cache_proxy);
    
    printf("\nWaiting 3 seconds...\n");
    sleep(3);
    
    printf("\nThird call (cache expired):\n");
    cache_proxy->base.request(cache_proxy);
    
    // Cleanup
    destroy_protection_proxy(admin_proxy);
    destroy_protection_proxy(user_proxy);
    destroy_caching_proxy(cache_proxy);
    
    return 0;
}
```

### Python Implementation

#### Virtual Proxy and Protection Proxy

```python
import time
from abc import ABC, abstractmethod
from typing import Any, Optional

# Subject interface
class Database(ABC):
    @abstractmethod
    def execute_query(self, query: str) -> Any: ...
    
    @abstractmethod
    def connect(self) -> None: ...
    
    @abstractmethod
    def disconnect(self) -> None: ...

# Real Subject
class RealDatabase(Database):
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self._connected = False
    
    def connect(self) -> None:
        print(f"RealDatabase: Connecting to {self.connection_string}...")
        time.sleep(2)  # Simulate slow connection
        self._connected = True
        print("RealDatabase: Connected successfully!")
    
    def disconnect(self) -> None:
        if self._connected:
            print("RealDatabase: Disconnecting...")
            self._connected = False
            print("RealDatabase: Disconnected!")
    
    def execute_query(self, query: str) -> Any:
        if not self._connected:
            raise RuntimeError("Database not connected")
        
        print(f"RealDatabase: Executing query: {query}")
        time.sleep(1)  # Simulate query execution
        return f"Results for: {query}"
    
    def __del__(self):
        self.disconnect()

# Virtual Proxy - Lazy connection
class DatabaseProxy(Database):
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self._real_database: Optional[RealDatabase] = None
        self._query_cache: dict[str, Any] = {}
    
    def connect(self) -> None:
        if self._real_database is None:
            self._real_database = RealDatabase(self.connection_string)
        self._real_database.connect()
    
    def disconnect(self) -> None:
        if self._real_database:
            self._real_database.disconnect()
    
    def execute_query(self, query: str) -> Any:
        # Lazy connection - connect only when needed
        if self._real_database is None:
            self.connect()
        
        # Cache functionality
        if query in self._query_cache:
            print(f"DatabaseProxy: Returning cached results for: {query}")
            return self._query_cache[query]
        
        # Delegate to real database
        result = self._real_database.execute_query(query)
        
        # Cache the result
        self._query_cache[query] = result
        print(f"DatabaseProxy: Cached results for: {query}")
        
        return result
    
    def clear_cache(self) -> None:
        self._query_cache.clear()
        print("DatabaseProxy: Cache cleared")
    
    def get_cache_stats(self) -> dict:
        return {
            "cached_queries": len(self._query_cache),
            "cache_keys": list(self._query_cache.keys())
        }

# Protection Proxy
class SensitiveOperation(ABC):
    @abstractmethod
    def perform_operation(self, user: str) -> None: ...

class RealSensitiveOperation(SensitiveOperation):
    def perform_operation(self, user: str) -> None:
        print(f"RealSensitiveOperation: Performing sensitive operation for {user}")

class OperationProxy(SensitiveOperation):
    def __init__(self, real_operation: SensitiveOperation):
        self._real_operation = real_operation
        self._admin_users = {"admin", "root", "superuser"}
        self._access_log: list[tuple[str, str]] = []
    
    def perform_operation(self, user: str) -> None:
        # Log access attempt
        self._log_access(user, "attempt")
        
        # Check permissions
        if user not in self._admin_users:
            print(f"OperationProxy: Access denied for user '{user}'")
            self._log_access(user, "denied")
            return
        
        # Perform operation for authorized users
        print(f"OperationProxy: Access granted for user '{user}'")
        self._real_operation.perform_operation(user)
        self._log_access(user, "granted")
    
    def _log_access(self, user: str, status: str) -> None:
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        self._access_log.append((timestamp, user, status))
    
    def get_access_log(self) -> list[tuple[str, str, str]]:
        return self._access_log.copy()

# Usage example
if __name__ == "__main__":
    print("=== Database Virtual Proxy Example ===")
    
    # Create proxy - no real connection yet
    db_proxy = DatabaseProxy("postgresql://localhost:5432/mydb")
    print("Database proxy created (no real connection established)")
    
    # Connection established only when needed
    print("\nExecuting first query:")
    result1 = db_proxy.execute_query("SELECT * FROM users")
    print(f"Result: {result1}")
    
    print("\nExecuting same query again (should use cache):")
    result2 = db_proxy.execute_query("SELECT * FROM users")
    print(f"Result: {result2}")
    
    print("\nExecuting different query:")
    result3 = db_proxy.execute_query("SELECT * FROM orders")
    print(f"Result: {result3}")
    
    print(f"\nCache stats: {db_proxy.get_cache_stats()}")
    
    print("\n=== Protection Proxy Example ===")
    
    real_op = RealSensitiveOperation()
    operation_proxy = OperationProxy(real_op)
    
    # Test different users
    users = ["admin", "user1", "root", "guest"]
    
    for user in users:
        print(f"\nUser '{user}' attempting operation:")
        operation_proxy.perform_operation(user)
    
    print(f"\nAccess log:")
    for timestamp, user, status in operation_proxy.get_access_log():
        print(f"  {timestamp} - {user}: {status}")
```

#### Remote Proxy and Logging Proxy

```python
import json
import time
from abc import ABC, abstractmethod
from datetime import datetime
from typing import Any, Dict, List
import requests  # pip install requests

# Remote service interface
class CurrencyService(ABC):
    @abstractmethod
    def get_exchange_rate(self, from_currency: str, to_currency: str) -> float: ...
    
    @abstractmethod
    def get_currency_list(self) -> List[str]: ...

# Real remote service (simulated)
class RealCurrencyService(CurrencyService):
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.example.com/currency"  # Mock URL
    
    def get_exchange_rate(self, from_currency: str, to_currency: str) -> float:
        # Simulate API call
        print(f"RealCurrencyService: Making API call for {from_currency}->{to_currency}")
        time.sleep(1)  # Simulate network latency
        
        # Mock response - in real implementation, this would be an actual API call
        mock_rates = {
            ("USD", "EUR"): 0.85,
            ("EUR", "USD"): 1.18,
            ("USD", "GBP"): 0.73,
            ("GBP", "USD"): 1.37,
        }
        
        return mock_rates.get((from_currency, to_currency), 1.0)
    
    def get_currency_list(self) -> List[str]:
        print("RealCurrencyService: Fetching currency list from API")
        time.sleep(0.5)
        return ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]

# Remote Proxy with caching and error handling
class CurrencyServiceProxy(CurrencyService):
    def __init__(self, real_service: CurrencyService):
        self._real_service = real_service
        self._cache: Dict[str, Any] = {}
        self._cache_ttl = 300  # 5 minutes
        self._last_cache_update: Dict[str, float] = {}
        self._request_count = 0
    
    def get_exchange_rate(self, from_currency: str, to_currency: str) -> float:
        self._request_count += 1
        cache_key = f"rate_{from_currency}_{to_currency}"
        
        # Check cache
        if self._is_cached_valid(cache_key):
            print(f"CurrencyServiceProxy: Returning cached rate for {from_currency}->{to_currency}")
            return self._cache[cache_key]
        
        try:
            # Call real service
            rate = self._real_service.get_exchange_rate(from_currency, to_currency)
            
            # Cache the result
            self._cache[cache_key] = rate
            self._last_cache_update[cache_key] = time.time()
            print(f"CurrencyServiceProxy: Cached rate for {from_currency}->{to_currency}")
            
            return rate
            
        except Exception as e:
            print(f"CurrencyServiceProxy: Error fetching rate: {e}")
            # Fallback to cached value if available, otherwise return 1.0
            return self._cache.get(cache_key, 1.0)
    
    def get_currency_list(self) -> List[str]:
        cache_key = "currency_list"
        
        if self._is_cached_valid(cache_key):
            print("CurrencyServiceProxy: Returning cached currency list")
            return self._cache[cache_key]
        
        try:
            currencies = self._real_service.get_currency_list()
            self._cache[cache_key] = currencies
            self._last_cache_update[cache_key] = time.time()
            return currencies
        except Exception as e:
            print(f"CurrencyServiceProxy: Error fetching currency list: {e}")
            return self._cache.get(cache_key, [])
    
    def _is_cached_valid(self, cache_key: str) -> bool:
        if cache_key not in self._cache or cache_key not in self._last_cache_update:
            return False
        
        current_time = time.time()
        return (current_time - self._last_cache_update[cache_key]) < self._cache_ttl
    
    def clear_cache(self) -> None:
        self._cache.clear()
        self._last_cache_update.clear()
        print("CurrencyServiceProxy: Cache cleared")
    
    def get_stats(self) -> Dict[str, Any]:
        return {
            "total_requests": self._request_count,
            "cached_items": len(self._cache),
            "cache_keys": list(self._cache.keys())
        }

# Logging Proxy
class LoggingProxy(CurrencyService):
    def __init__(self, real_service: CurrencyService, log_file: str = "currency_service.log"):
        self._real_service = real_service
        self.log_file = log_file
        self._log_entries: List[Dict[str, Any]] = []
    
    def get_exchange_rate(self, from_currency: str, to_currency: str) -> float:
        start_time = time.time()
        
        try:
            rate = self._real_service.get_exchange_rate(from_currency, to_currency)
            duration = time.time() - start_time
            
            self._log(
                "get_exchange_rate",
                "success",
                duration,
                {"from_currency": from_currency, "to_currency": to_currency, "rate": rate}
            )
            
            return rate
            
        except Exception as e:
            duration = time.time() - start_time
            self._log(
                "get_exchange_rate",
                "error",
                duration,
                {"from_currency": from_currency, "to_currency": to_currency, "error": str(e)}
            )
            raise
    
    def get_currency_list(self) -> List[str]:
        start_time = time.time()
        
        try:
            currencies = self._real_service.get_currency_list()
            duration = time.time() - start_time
            
            self._log(
                "get_currency_list",
                "success",
                duration,
                {"currencies_count": len(currencies)}
            )
            
            return currencies
            
        except Exception as e:
            duration = time.time() - start_time
            self._log(
                "get_currency_list",
                "error",
                duration,
                {"error": str(e)}
            )
            raise
    
    def _log(self, method: str, status: str, duration: float, details: Dict[str, Any]) -> None:
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "method": method,
            "status": status,
            "duration_seconds": round(duration, 3),
            "details": details
        }
        
        self._log_entries.append(log_entry)
        
        # Write to file
        with open(self.log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
    
    def get_logs(self) -> List[Dict[str, Any]]:
        return self._log_entries.copy()
    
    def clear_logs(self) -> None:
        self._log_entries.clear()
        open(self.log_file, 'w').close()  # Clear log file

# Usage example
if __name__ == "__main__":
    print("=== Remote Proxy with Caching ===")
    
    real_service = RealCurrencyService("fake-api-key")
    caching_proxy = CurrencyServiceProxy(real_service)
    logging_proxy = LoggingProxy(caching_proxy)
    
    # First calls - will hit the API
    print("\nFirst call (API call):")
    rate1 = logging_proxy.get_exchange_rate("USD", "EUR")
    print(f"USD->EUR: {rate1}")
    
    print("\nSecond call (cached):")
    rate2 = logging_proxy.get_exchange_rate("USD", "EUR")
    print(f"USD->EUR: {rate2}")
    
    print("\nDifferent currency pair:")
    rate3 = logging_proxy.get_exchange_rate("USD", "GBP")
    print(f"USD->GBP: {rate3}")
    
    print("\nCurrency list:")
    currencies = logging_proxy.get_currency_list()
    print(f"Available currencies: {currencies}")
    
    print(f"\nCaching proxy stats: {caching_proxy.get_stats()}")
    
    print("\n=== Logs ===")
    for log in logging_proxy.get_logs():
        print(f"{log['timestamp']} - {log['method']}: {log['status']} ({log['duration_seconds']}s)")
```

#### Smart Reference Proxy

```python
import weakref
from abc import ABC, abstractmethod
from typing import Any, Optional

# Resource-intensive object
class LargeObject:
    def __init__(self, name: str):
        self.name = name
        self._data = [i for i in range(1000000)]  # Simulate large memory usage
        print(f"LargeObject '{name}' created (memory intensive)")
    
    def process_data(self) -> str:
        return f"Processed {len(self._data)} items from {self.name}"
    
    def get_info(self) -> dict:
        return {
            "name": self.name,
            "data_size": len(self._data),
            "memory_id": id(self)
        }
    
    def __del__(self):
        print(f"LargeObject '{self.name}' destroyed")

# Smart Reference Proxy with memory management
class LargeObjectProxy:
    def __init__(self, name: str):
        self.name = name
        self._real_object: Optional[LargeObject] = None
        self._access_count = 0
        self._max_access_before_cleanup = 3
    
    def _ensure_created(self) -> None:
        if self._real_object is None:
            self._real_object = LargeObject(self.name)
            print(f"Proxy: Created real object for {self.name}")
    
    def _maybe_cleanup(self) -> None:
        if (self._real_object and 
            self._access_count >= self._max_access_before_cleanup):
            print(f"Proxy: Cleaning up {self.name} after {self._access_count} accesses")
            self._real_object = None
            self._access_count = 0
    
    def process_data(self) -> str:
        self._ensure_created()
        self._access_count += 1
        
        result = self._real_object.process_data()
        print(f"Proxy: process_data called (access #{self._access_count})")
        
        self._maybe_cleanup()
        return result
    
    def get_info(self) -> dict:
        self._ensure_created()
        self._access_count += 1
        
        info = self._real_object.get_info()
        info["proxy_access_count"] = self._access_count
        info["is_real_object_loaded"] = self._real_object is not None
        
        print(f"Proxy: get_info called (access #{self._access_count})")
        
        self._maybe_cleanup()
        return info
    
    def force_cleanup(self) -> None:
        if self._real_object:
            print(f"Proxy: Force cleanup of {self.name}")
            self._real_object = None
            self._access_count = 0
    
    def get_proxy_stats(self) -> dict:
        return {
            "name": self.name,
            "access_count": self._access_count,
            "is_loaded": self._real_object is not None,
            "max_access_before_cleanup": self._max_access_before_cleanup
        }

# Usage example with context manager
class ManagedLargeObject:
    def __init__(self, name: str):
        self.proxy = LargeObjectProxy(name)
    
    def __enter__(self):
        return self.proxy
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.proxy.force_cleanup()
        return False

# Usage example
if __name__ == "__main__":
    print("=== Smart Reference Proxy Example ===")
    
    # Create proxy - no real object created yet
    proxy1 = LargeObjectProxy("Object1")
    proxy2 = LargeObjectProxy("Object2")
    
    print("\nInitial state:")
    print(f"Proxy1 stats: {proxy1.get_proxy_stats()}")
    print(f"Proxy2 stats: {proxy2.get_proxy_stats()}")
    
    print("\nUsing proxies (will create real objects):")
    print(proxy1.process_data())
    print(proxy2.process_data())
    
    print("\nAfter first use:")
    print(f"Proxy1 stats: {proxy1.get_proxy_stats()}")
    print(f"Proxy2 stats: {proxy2.get_proxy_stats()}")
    
    print("\nUsing multiple times (will trigger cleanup):")
    for i in range(4):
        print(f"\nAccess #{i + 1}:")
        info = proxy1.get_info()
        print(f"Info: {info}")
    
    print(f"\nFinal Proxy1 stats: {proxy1.get_proxy_stats()}")
    
    print("\n=== Using Context Manager ===")
    with ManagedLargeObject("ManagedObject") as obj:
        print(obj.process_data())
        print(obj.get_info())
    
    print("Context exited - object cleaned up")
```

## Advantages and Disadvantages

### Advantages

- **Controlled Access**: Add security, caching, or logging without changing real object
- **Lazy Initialization**: Defer expensive operations until needed
- **Memory Management**: Smart proxies can manage object lifecycle
- **Remote Access**: Represent objects in different address spaces
- **Additional Functionality**: Easy to add cross-cutting concerns

### Disadvantages

- **Complexity**: Additional layer can make system more complex
- **Performance Overhead**: Extra indirection may impact performance
- **Debugging Difficulty**: Harder to trace through proxy layers

## Best Practices

1. **Use for Cross-Cutting Concerns**: Authentication, logging, caching
2. **Implement Proper Interfaces**: Ensure proxy matches real subject interface
3. **Consider Performance**: Use lazy loading only when beneficial
4. **Handle Errors Gracefully**: Proxy should handle real subject failures
5. **Document Proxy Behavior**: Clearly document what the proxy does

## Proxy vs Other Patterns

- **vs Decorator**: Proxy controls access, Decorator adds behavior
- **vs Adapter**: Proxy uses same interface, Adapter converts between interfaces
- **vs Facade**: Proxy represents one object, Facade represents a subsystem

The Proxy pattern is essential for controlling access to objects, managing resources efficiently, and adding functionality transparently. It's particularly useful in distributed systems, security-sensitive applications, and when working with resource-intensive objects.
