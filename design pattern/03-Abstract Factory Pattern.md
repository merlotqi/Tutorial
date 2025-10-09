# Abstract Factory Pattern

## Introduction

The Abstract Factory pattern is a creational design pattern that provides an interface for creating families of related or dependent objects without specifying their concrete classes.

### Key Characteristics
- **Family Creation**: Creates groups of related objects
- **Interface-based**: Works with interfaces rather than concrete implementations
- **Consistency**: Ensures created objects are compatible with each other
- **Encapsulation**: Hides concrete class instantiation from client code

### Use Cases
- When a system needs to be independent of how its products are created, composed, and represented
- When a system should be configured with multiple families of products
- When you need to enforce that related products are used together
- When you want to provide a class library of products and reveal only their interfaces

## Implementation Examples

### C++ Implementation

#### Basic Abstract Factory
```cpp
#include <iostream>
#include <memory>
#include <string>

// Abstract Product A
class Button {
public:
    virtual ~Button() = default;
    virtual void render() = 0;
    virtual void onClick() = 0;
};

// Abstract Product B
class Checkbox {
public:
    virtual ~Checkbox() = default;
    virtual void render() = 0;
    virtual void onToggle() = 0;
};

// Concrete Products for Windows
class WindowsButton : public Button {
public:
    void render() override {
        std::cout << "Rendering Windows-style button" << std::endl;
    }
    
    void onClick() override {
        std::cout << "Windows button clicked!" << std::endl;
    }
};

class WindowsCheckbox : public Checkbox {
public:
    void render() override {
        std::cout << "Rendering Windows-style checkbox" << std::endl;
    }
    
    void onToggle() override {
        std::cout << "Windows checkbox toggled!" << std::endl;
    }
};

// Concrete Products for macOS
class MacButton : public Button {
public:
    void render() override {
        std::cout << "Rendering macOS-style button" << std::endl;
    }
    
    void onClick() override {
        std::cout << "Mac button clicked!" << std::endl;
    }
};

class MacCheckbox : public Checkbox {
public:
    void render() override {
        std::cout << "Rendering macOS-style checkbox" << std::endl;
    }
    
    void onToggle() override {
        std::cout << "Mac checkbox toggled!" << std::endl;
    }
};

// Abstract Factory
class GUIFactory {
public:
    virtual ~GUIFactory() = default;
    virtual std::unique_ptr<Button> createButton() = 0;
    virtual std::unique_ptr<Checkbox> createCheckbox() = 0;
};

// Concrete Factories
class WindowsFactory : public GUIFactory {
public:
    std::unique_ptr<Button> createButton() override {
        return std::make_unique<WindowsButton>();
    }
    
    std::unique_ptr<Checkbox> createCheckbox() override {
        return std::make_unique<WindowsCheckbox>();
    }
};

class MacFactory : public GUIFactory {
public:
    std::unique_ptr<Button> createButton() override {
        return std::make_unique<MacButton>();
    }
    
    std::unique_ptr<Checkbox> createCheckbox() override {
        return std::make_unique<MacCheckbox>();
    }
};

// Client code
class Application {
private:
    std::unique_ptr<GUIFactory> factory;
    std::unique_ptr<Button> button;
    std::unique_ptr<Checkbox> checkbox;

public:
    Application(std::unique_ptr<GUIFactory> factory) 
        : factory(std::move(factory)) {}
    
    void createUI() {
        button = this->factory->createButton();
        checkbox = this->factory->createCheckbox();
    }
    
    void renderUI() {
        button->render();
        checkbox->render();
    }
    
    void interact() {
        button->onClick();
        checkbox->onToggle();
    }
};

// Usage example
int main() {
    // Configurable based on runtime environment
    std::string os = "windows"; // This could come from config
    
    std::unique_ptr<GUIFactory> factory;
    
    if (os == "windows") {
        factory = std::make_unique<WindowsFactory>();
    } else if (os == "mac") {
        factory = std::make_unique<MacFactory>();
    }
    
    Application app(std::move(factory));
    app.createUI();
    app.renderUI();
    app.interact();
    
    return 0;
}
```

#### Extended Abstract Factory with Multiple Products
```cpp
#include <iostream>
#include <memory>
#include <string>

// Abstract Products
class Window {
public:
    virtual ~Window() = default;
    virtual void draw() = 0;
};

class ScrollBar {
public:
    virtual ~ScrollBar() = default;
    virtual void scroll() = 0;
};

class Menu {
public:
    virtual ~Menu() = default;
    virtual void display() = 0;
};

// Concrete Products for Light Theme
class LightWindow : public Window {
public:
    void draw() override {
        std::cout << "Drawing light theme window" << std::endl;
    }
};

class LightScrollBar : public ScrollBar {
public:
    void scroll() override {
        std::cout << "Scrolling light theme scrollbar" << std::endl;
    }
};

class LightMenu : public Menu {
public:
    void display() override {
        std::cout << "Displaying light theme menu" << std::endl;
    }
};

// Concrete Products for Dark Theme
class DarkWindow : public Window {
public:
    void draw() override {
        std::cout << "Drawing dark theme window" << std::endl;
    }
};

class DarkScrollBar : public ScrollBar {
public:
    void scroll() override {
        std::cout << "Scrolling dark theme scrollbar" << std::endl;
    }
};

class DarkMenu : public Menu {
public:
    void display() override {
        std::cout << "Displaying dark theme menu" << std::endl;
    }
};

// Abstract Factory
class ThemeFactory {
public:
    virtual ~ThemeFactory() = default;
    virtual std::unique_ptr<Window> createWindow() = 0;
    virtual std::unique_ptr<ScrollBar> createScrollBar() = 0;
    virtual std::unique_ptr<Menu> createMenu() = 0;
};

// Concrete Factories
class LightThemeFactory : public ThemeFactory {
public:
    std::unique_ptr<Window> createWindow() override {
        return std::make_unique<LightWindow>();
    }
    
    std::unique_ptr<ScrollBar> createScrollBar() override {
        return std::make_unique<LightScrollBar>();
    }
    
    std::unique_ptr<Menu> createMenu() override {
        return std::make_unique<LightMenu>();
    }
};

class DarkThemeFactory : public ThemeFactory {
public:
    std::unique_ptr<Window> createWindow() override {
        return std::make_unique<DarkWindow>();
    }
    
    std::unique_ptr<ScrollBar> createScrollBar() override {
        return std::make_unique<DarkScrollBar>();
    }
    
    std::unique_ptr<Menu> createMenu() override {
        return std::make_unique<DarkMenu>();
    }
};

// Client
class UIApplication {
private:
    std::unique_ptr<ThemeFactory> themeFactory;

public:
    UIApplication(std::unique_ptr<ThemeFactory> factory) 
        : themeFactory(std::move(factory)) {}
    
    void buildUI() {
        auto window = themeFactory->createWindow();
        auto scrollBar = themeFactory->createScrollBar();
        auto menu = themeFactory->createMenu();
        
        window->draw();
        scrollBar->scroll();
        menu->display();
    }
};

// Usage
int main() {
    std::string theme = "dark"; // Could be from user preference
    
    std::unique_ptr<ThemeFactory> factory;
    
    if (theme == "light") {
        factory = std::make_unique<LightThemeFactory>();
    } else if (theme == "dark") {
        factory = std::make_unique<DarkThemeFactory>();
    }
    
    UIApplication app(std::move(factory));
    app.buildUI();
    
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>

// Product types
typedef struct {
    void (*draw)(void);
} Button;

typedef struct {
    void (*render)(void);
} Checkbox;

// Abstract factory interface
typedef struct {
    Button* (*createButton)(void);
    Checkbox* (*createCheckbox)(void);
} GUIFactory;

// Windows products
void windowsButtonDraw(void) {
    printf("Drawing Windows button\n");
}

void windowsCheckboxRender(void) {
    printf("Rendering Windows checkbox\n");
}

Button* createWindowsButton(void) {
    Button* button = (Button*)malloc(sizeof(Button));
    button->draw = windowsButtonDraw;
    return button;
}

Checkbox* createWindowsCheckbox(void) {
    Checkbox* checkbox = (Checkbox*)malloc(sizeof(Checkbox));
    checkbox->render = windowsCheckboxRender;
    return checkbox;
}

// macOS products
void macButtonDraw(void) {
    printf("Drawing macOS button\n");
}

void macCheckboxRender(void) {
    printf("Rendering macOS checkbox\n");
}

Button* createMacButton(void) {
    Button* button = (Button*)malloc(sizeof(Button));
    button->draw = macButtonDraw;
    return button;
}

Checkbox* createMacCheckbox(void) {
    Checkbox* checkbox = (Checkbox*)malloc(sizeof(Checkbox));
    checkbox->render = macCheckboxRender;
    return checkbox;
}

// Factory implementations
GUIFactory* createWindowsFactory(void) {
    GUIFactory* factory = (GUIFactory*)malloc(sizeof(GUIFactory));
    factory->createButton = createWindowsButton;
    factory->createCheckbox = createWindowsCheckbox;
    return factory;
}

GUIFactory* createMacFactory(void) {
    GUIFactory* factory = (GUIFactory*)malloc(sizeof(GUIFactory));
    factory->createButton = createMacButton;
    factory->createCheckbox = createMacCheckbox;
    return factory;
}

// Client code
void buildUI(GUIFactory* factory) {
    Button* button = factory->createButton();
    Checkbox* checkbox = factory->createCheckbox();
    
    button->draw();
    checkbox->render();
    
    free(button);
    free(checkbox);
}

// Usage example
int main() {
    const char* os_type = "mac";
    
    GUIFactory* factory = NULL;
    
    if (strcmp(os_type, "windows") == 0) {
        factory = createWindowsFactory();
    } else if (strcmp(os_type, "mac") == 0) {
        factory = createMacFactory();
    }
    
    if (factory) {
        buildUI(factory);
        free(factory);
    }
    
    return 0;
}
```

### Python Implementation

#### Basic Abstract Factory
```python
from abc import ABC, abstractmethod
from typing import Protocol

# Abstract Products
class Button(Protocol):
    def render(self) -> None: ...
    def on_click(self) -> None: ...

class Checkbox(Protocol):
    def render(self) -> None: ...
    def on_toggle(self) -> None: ...

# Concrete Products - Windows
class WindowsButton:
    def render(self) -> None:
        print("Rendering Windows button")
    
    def on_click(self) -> None:
        print("Windows button clicked!")

class WindowsCheckbox:
    def render(self) -> None:
        print("Rendering Windows checkbox")
    
    def on_toggle(self) -> None:
        print("Windows checkbox toggled!")

# Concrete Products - macOS
class MacButton:
    def render(self) -> None:
        print("Rendering macOS button")
    
    def on_click(self) -> None:
        print("Mac button clicked!")

class MacCheckbox:
    def render(self) -> None:
        print("Rendering macOS checkbox")
    
    def on_toggle(self) -> None:
        print("Mac checkbox toggled!")

# Abstract Factory
class GUIFactory(ABC):
    @abstractmethod
    def create_button(self) -> Button: ...
    
    @abstractmethod
    def create_checkbox(self) -> Checkbox: ...

# Concrete Factories
class WindowsFactory(GUIFactory):
    def create_button(self) -> Button:
        return WindowsButton()
    
    def create_checkbox(self) -> Checkbox:
        return WindowsCheckbox()

class MacFactory(GUIFactory):
    def create_button(self) -> Button:
        return MacButton()
    
    def create_checkbox(self) -> Checkbox:
        return MacCheckbox()

# Client
class Application:
    def __init__(self, factory: GUIFactory):
        self.factory = factory
        self.button = None
        self.checkbox = None
    
    def create_ui(self) -> None:
        self.button = self.factory.create_button()
        self.checkbox = self.factory.create_checkbox()
    
    def render_ui(self) -> None:
        if self.button and self.checkbox:
            self.button.render()
            self.checkbox.render()
    
    def interact(self) -> None:
        if self.button and self.checkbox:
            self.button.on_click()
            self.checkbox.on_toggle()

# Usage
if __name__ == "__main__":
    import sys
    
    # Determine OS (simplified)
    if sys.platform.startswith("win"):
        factory = WindowsFactory()
    elif sys.platform.startswith("darwin"):
        factory = MacFactory()
    else:
        # Default to Windows for other platforms
        factory = WindowsFactory()
    
    app = Application(factory)
    app.create_ui()
    app.render_ui()
    app.interact()
```

#### Database Abstract Factory Example
```python
from abc import ABC, abstractmethod
from typing import List, Optional

# Abstract Products
class Connection(ABC):
    @abstractmethod
    def connect(self) -> None: ...
    
    @abstractmethod
    def execute(self, query: str) -> List[dict]: ...
    
    @abstractmethod
    def close(self) -> None: ...

class QueryBuilder(ABC):
    @abstractmethod
    def select(self, table: str, columns: List[str]) -> 'QueryBuilder': ...
    
    @abstractmethod
    def where(self, condition: str) -> 'QueryBuilder': ...
    
    @abstractmethod
    def build(self) -> str: ...

# MySQL Products
class MySQLConnection(Connection):
    def connect(self) -> None:
        print("Connecting to MySQL database")
    
    def execute(self, query: str) -> List[dict]:
        print(f"Executing MySQL query: {query}")
        return [{"id": 1, "name": "MySQL Result"}]
    
    def close(self) -> None:
        print("Closing MySQL connection")

class MySQLQueryBuilder(QueryBuilder):
    def __init__(self):
        self._query = ""
    
    def select(self, table: str, columns: List[str]) -> 'QueryBuilder':
        cols = ", ".join(columns)
        self._query = f"SELECT {cols} FROM {table}"
        return self
    
    def where(self, condition: str) -> 'QueryBuilder':
        self._query += f" WHERE {condition}"
        return self
    
    def build(self) -> str:
        return self._query + ";"

# PostgreSQL Products
class PostgreSQLConnection(Connection):
    def connect(self) -> None:
        print("Connecting to PostgreSQL database")
    
    def execute(self, query: str) -> List[dict]:
        print(f"Executing PostgreSQL query: {query}")
        return [{"id": 1, "name": "PostgreSQL Result"}]
    
    def close(self) -> None:
        print("Closing PostgreSQL connection")

class PostgreSQLQueryBuilder(QueryBuilder):
    def __init__(self):
        self._query = ""
    
    def select(self, table: str, columns: List[str]) -> 'QueryBuilder':
        cols = ", ".join(columns)
        self._query = f'SELECT {cols} FROM "{table}"'
        return self
    
    def where(self, condition: str) -> 'QueryBuilder':
        self._query += f" WHERE {condition}"
        return self
    
    def build(self) -> str:
        return self._query + ";"

# Abstract Factory
class DatabaseFactory(ABC):
    @abstractmethod
    def create_connection(self) -> Connection: ...
    
    @abstractmethod
    def create_query_builder(self) -> QueryBuilder: ...

# Concrete Factories
class MySQLFactory(DatabaseFactory):
    def create_connection(self) -> Connection:
        return MySQLConnection()
    
    def create_query_builder(self) -> QueryBuilder:
        return MySQLQueryBuilder()

class PostgreSQLFactory(DatabaseFactory):
    def create_connection(self) -> Connection:
        return PostgreSQLConnection()
    
    def create_query_builder(self) -> QueryBuilder:
        return PostgreSQLQueryBuilder()

# Client
class DatabaseClient:
    def __init__(self, factory: DatabaseFactory):
        self.factory = factory
        self.connection: Optional[Connection] = None
        self.query_builder: Optional[QueryBuilder] = None
    
    def initialize(self) -> None:
        self.connection = self.factory.create_connection()
        self.query_builder = self.factory.create_query_builder()
        self.connection.connect()
    
    def execute_query(self, table: str, columns: List[str], condition: str = "") -> List[dict]:
        if not self.connection or not self.query_builder:
            raise RuntimeError("Database client not initialized")
        
        query = self.query_builder.select(table, columns)
        if condition:
            query = query.where(condition)
        
        sql = query.build()
        return self.connection.execute(sql)
    
    def close(self) -> None:
        if self.connection:
            self.connection.close()

# Usage
if __name__ == "__main__":
    # Configuration
    db_type = "postgresql"  # Could be from config file
    
    # Choose factory based on configuration
    factory: DatabaseFactory
    if db_type == "mysql":
        factory = MySQLFactory()
    elif db_type == "postgresql":
        factory = PostgreSQLFactory()
    else:
        raise ValueError(f"Unsupported database type: {db_type}")
    
    # Use the factory
    client = DatabaseClient(factory)
    client.initialize()
    
    try:
        results = client.execute_query("users", ["id", "name", "email"], "active = true")
        print(f"Results: {results}")
    finally:
        client.close()
```

#### Modern Python with Type Hints and Registry
```python
from abc import ABC, abstractmethod
from typing import Dict, Type, Protocol
from enum import Enum

class Theme(Enum):
    LIGHT = "light"
    DARK = "dark"
    BLUE = "blue"

# Abstract Products
class Widget(Protocol):
    def render(self) -> str: ...

class Button(Widget):
    def render(self) -> str: ...

class Panel(Widget):
    def render(self) -> str: ...

# Concrete Products
class LightButton:
    def render(self) -> str:
        return "Light theme button"

class LightPanel:
    def render(self) -> str:
        return "Light theme panel"

class DarkButton:
    def render(self) -> str:
        return "Dark theme button"

class DarkPanel:
    def render(self) -> str:
        return "Dark theme panel"

class BlueButton:
    def render(self) -> str:
        return "Blue theme button"

class BluePanel:
    def render(self) -> str:
        return "Blue theme panel"

# Abstract Factory
class ThemeFactory(ABC):
    @abstractmethod
    def create_button(self) -> Button: ...
    
    @abstractmethod
    def create_panel(self) -> Panel: ...

# Concrete Factories
class LightThemeFactory(ThemeFactory):
    def create_button(self) -> Button:
        return LightButton()
    
    def create_panel(self) -> Panel:
        return LightPanel()

class DarkThemeFactory(ThemeFactory):
    def create_button(self) -> Button:
        return DarkButton()
    
    def create_panel(self) -> Panel:
        return DarkPanel()

class BlueThemeFactory(ThemeFactory):
    def create_button(self) -> Button:
        return BlueButton()
    
    def create_panel(self) -> Panel:
        return BluePanel()

# Factory Registry
class ThemeFactoryRegistry:
    _factories: Dict[Theme, Type[ThemeFactory]] = {
        Theme.LIGHT: LightThemeFactory,
        Theme.DARK: DarkThemeFactory,
        Theme.BLUE: BlueThemeFactory,
    }
    
    @classmethod
    def register_factory(cls, theme: Theme, factory_class: Type[ThemeFactory]) -> None:
        cls._factories[theme] = factory_class
    
    @classmethod
    def get_factory(cls, theme: Theme) -> ThemeFactory:
        if theme not in cls._factories:
            raise ValueError(f"No factory registered for theme: {theme}")
        return cls._factories[theme]()
    
    @classmethod
    def get_available_themes(cls) -> list[Theme]:
        return list(cls._factories.keys())

# Client
class UIApplication:
    def __init__(self, theme: Theme):
        self.theme = theme
        self.factory = ThemeFactoryRegistry.get_factory(theme)
        self.widgets: list[Widget] = []
    
    def build_ui(self) -> None:
        button = self.factory.create_button()
        panel = self.factory.create_panel()
        
        self.widgets.extend([button, panel])
    
    def render_ui(self) -> None:
        print(f"Rendering {self.theme.value} theme UI:")
        for widget in self.widgets:
            print(f"  - {widget.render()}")

# Usage
if __name__ == "__main__":
    # Test all available themes
    for theme in ThemeFactoryRegistry.get_available_themes():
        print(f"\n=== {theme.value.upper()} THEME ===")
        app = UIApplication(theme)
        app.build_ui()
        app.render_ui()
    
    # Demonstrate runtime theme switching
    print("\n=== DYNAMIC THEME SWITCHING ===")
    current_theme = Theme.LIGHT
    app = UIApplication(current_theme)
    app.build_ui()
    app.render_ui()
    
    # Switch theme
    print("\nSwitching to dark theme...")
    current_theme = Theme.DARK
    app = UIApplication(current_theme)
    app.build_ui()
    app.render_ui()
```

## Advantages and Disadvantages

### Advantages
- **Consistency**: Ensures compatible products are used together
- **Loose Coupling**: Client code works with interfaces, not concrete classes
- **Single Responsibility**: Product creation code is centralized
- **Open/Closed Principle**: Easy to introduce new product families

### Disadvantages
- **Complexity**: Can result in many classes and interfaces
- **Rigidity**: Adding new products requires modifying all factories
- **Over-engineering**: May be too complex for simple scenarios

## Best Practices

1. **Use for product families**: When you need to create groups of related objects
2. **Design for extensibility**: Make it easy to add new product families
3. **Use dependency injection**: Inject the factory into clients for better testability
4. **Consider factory registration**: Use registry patterns for dynamic factory discovery
5. **Document product compatibility**: Clearly specify which products work together

## Abstract Factory vs Factory Method

- **Factory Method**: Creates one product, uses inheritance
- **Abstract Factory**: Creates families of products, uses composition
- **Factory Method**: Subclasses decide which concrete class to instantiate
- **Abstract Factory**: Concrete factories produce families of related products

The Abstract Factory pattern is ideal when your system needs to work with multiple families of related products, and you want to ensure that products from the same family are used together consistently.