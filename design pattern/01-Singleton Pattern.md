# Singleton Pattern

## Introduction

The Singleton pattern is a creational design pattern that ensures a class has only one instance and provides a global point of access to that instance.

### Key Characteristics

- **Single Instance**: Guarantees that only one instance of the class exists
- **Global Access**: Provides a unified access point for other objects to use the instance
- **Lazy Initialization**: Typically creates the instance only when first requested
- **Thread Safety**: Ensures instance creation remains unique in multi-threaded environments

### Use Cases

- When you need to control shared resources (e.g., configuration files, log managers)
- When objects are frequently created and destroyed
- When object creation is resource-intensive and reuse is beneficial
- When you need strict control over global variables

## Implementation Examples

### C++ Implementation

#### C++ Basic Version

```cpp
#include <iostream>
#include <mutex>

class Singleton {
private:
    static Singleton* instance;
    static std::mutex mutex;
    
    // Private constructor to prevent instantiation
    Singleton() {
        std::cout << "Singleton instance created" << std::endl;
    }
    
    // Prevent copying
    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton&) = delete;

public:
    static Singleton* getInstance() {
        std::lock_guard<std::mutex> lock(mutex);
        if (instance == nullptr) {
            instance = new Singleton();
        }
        return instance;
    }
    
    void showMessage() {
        std::cout << "Hello from Singleton!" << std::endl;
    }
    
    static void destroyInstance() {
        std::lock_guard<std::mutex> lock(mutex);
        delete instance;
        instance = nullptr;
    }
};

// Initialize static members
Singleton* Singleton::instance = nullptr;
std::mutex Singleton::mutex;

// Usage example
int main() {
    Singleton* singleton1 = Singleton::getInstance();
    singleton1->showMessage();
    
    Singleton* singleton2 = Singleton::getInstance();
    singleton2->showMessage();
    
    // Both pointers point to the same instance
    std::cout << "Are both instances the same? " 
              << (singleton1 == singleton2 ? "Yes" : "No") << std::endl;
    
    Singleton::destroyInstance();
    return 0;
}
```

#### Modern C++ Version (C++11 and later)

```cpp
#include <iostream>
#include <memory>
#include <mutex>

class ModernSingleton {
private:
    ModernSingleton() {
        std::cout << "Modern Singleton created" << std::endl;
    }

public:
    static ModernSingleton& getInstance() {
        static ModernSingleton instance;
        return instance;
    }
    
    void showMessage() {
        std::cout << "Hello from Modern Singleton!" << std::endl;
    }
    
    // Prevent copying
    ModernSingleton(const ModernSingleton&) = delete;
    ModernSingleton& operator=(const ModernSingleton&) = delete;
};

// Usage
int main() {
    ModernSingleton& singleton1 = ModernSingleton::getInstance();
    singleton1.showMessage();
    
    ModernSingleton& singleton2 = ModernSingleton::getInstance();
    singleton2.showMessage();
    
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

typedef struct {
    int data;
    void (*printMessage)(void);
} Singleton;

static Singleton* instance = NULL;
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void printMessageImpl(void) {
    printf("Hello from C Singleton!\n");
}

Singleton* getInstance() {
    pthread_mutex_lock(&mutex);
    if (instance == NULL) {
        instance = (Singleton*)malloc(sizeof(Singleton));
        instance->data = 0;
        instance->printMessage = printMessageImpl;
        printf("Singleton instance created in C\n");
    }
    pthread_mutex_unlock(&mutex);
    return instance;
}

void destroyInstance() {
    pthread_mutex_lock(&mutex);
    if (instance != NULL) {
        free(instance);
        instance = NULL;
        printf("Singleton instance destroyed\n");
    }
    pthread_mutex_unlock(&mutex);
}

// Usage example
int main() {
    Singleton* s1 = getInstance();
    s1->printMessage();
    s1->data = 42;
    
    Singleton* s2 = getInstance();
    s2->printMessage();
    printf("Data from s2: %d\n", s2->data);
    printf("Same instance? %s\n", (s1 == s2) ? "Yes" : "No");
    
    destroyInstance();
    return 0;
}
```

### Python Implementation

#### Python Basic Version

```python
class Singleton:
    _instance = None
    
    def __init__(self):
        if Singleton._instance is not None:
            raise Exception("This class is a singleton!")
        else:
            Singleton._instance = self
            print("Singleton instance created")
    
    @staticmethod
    def get_instance():
        if Singleton._instance is None:
            Singleton()
        return Singleton._instance
    
    def show_message(self):
        print("Hello from Python Singleton!")

# Usage
if __name__ == "__main__":
    singleton1 = Singleton.get_instance()
    singleton1.show_message()
    
    singleton2 = Singleton.get_instance()
    singleton2.show_message()
    
    print(f"Are both instances the same? {singleton1 is singleton2}")
```

#### Thread-Safe Python Version

```python
import threading

class ThreadSafeSingleton:
    _instance = None
    _lock = threading.Lock()
    
    def __init__(self):
        if ThreadSafeSingleton._instance is not None:
            raise Exception("This class is a singleton!")
        else:
            ThreadSafeSingleton._instance = self
            print("Thread-safe Singleton instance created")
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls()
        return cls._instance
    
    def show_message(self):
        print("Hello from Thread-safe Python Singleton!")

# Usage with threads
def test_singleton(thread_id):
    singleton = ThreadSafeSingleton.get_instance()
    singleton.show_message()
    print(f"Thread {thread_id} using singleton")

if __name__ == "__main__":
    threads = []
    for i in range(5):
        thread = threading.Thread(target=test_singleton, args=(i,))
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
```

#### Python Metaclass Implementation

```python
class SingletonMeta(type):
    _instances = {}
    
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            instance = super().__call__(*args, **kwargs)
            cls._instances[cls] = instance
        return cls._instances[cls]

class DatabaseConnection(metaclass=SingletonMeta):
    def __init__(self):
        print("Database connection established")
        self.connection_data = "Connected to database"
    
    def query(self, sql):
        print(f"Executing: {sql}")
        return f"Results for: {sql}"

# Usage
if __name__ == "__main__":
    db1 = DatabaseConnection()
    db2 = DatabaseConnection()
    
    print(db1.query("SELECT * FROM users"))
    print(f"Same connection? {db1 is db2}")
```

## Advantages and Disadvantages

### Advantages

- **Controlled access**: Single point of access to the instance
- **Reduced memory usage**: Only one instance exists in memory
- **Global state management**: Useful for shared resources
- **Lazy initialization**: Instance created only when needed

### Disadvantages

- **Global state**: Can introduce hidden dependencies
- **Testing difficulties**: Hard to unit test due to global state
- **Thread safety complexity**: Requires careful implementation in multi-threaded environments
- **Violates Single Responsibility Principle**: Manages both its business logic and instance creation

## Best Practices

1. **Use when truly necessary**: Only use Singleton when you absolutely need a single instance
2. **Consider dependency injection**: Often a better alternative for managing shared resources
3. **Ensure thread safety**: Always consider multi-threading scenarios
4. **Provide cleanup mechanism**: Allow proper resource cleanup when needed
5. **Document clearly**: Make it obvious that the class is a Singleton

This pattern should be used judiciously as it can introduce global state into your application, which can make code harder to test and maintain.
