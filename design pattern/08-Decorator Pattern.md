# Decorator Pattern

## Introduction

The Decorator pattern is a structural design pattern that allows behavior to be added to individual objects, dynamically, without affecting the behavior of other objects from the same class. It provides a flexible alternative to subclassing for extending functionality.

### Key Characteristics

- **Dynamic Composition**: Add responsibilities to objects at runtime
- **Transparent Wrapping**: Decorators wrap components and maintain the same interface
- **Recursive Composition**: Can nest decorators arbitrarily
- **Single Responsibility**: Each decorator adds one specific behavior
- **Alternative to Inheritance**: More flexible than static inheritance

### Use Cases

- When you need to add responsibilities to individual objects dynamically and transparently
- When extension by subclassing is impractical (too many combinations)
- When you want to add and remove responsibilities at runtime
- When you need to keep new functionality separate from core functionality
- When you cannot break existing code but need to add new features

## Implementation Examples

### C++ Implementation

#### Basic Decorator Pattern - Coffee Shop Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>

// Component interface
class Beverage {
public:
    virtual ~Beverage() = default;
    virtual std::string getDescription() const = 0;
    virtual double cost() const = 0;
    virtual void prepare() const {
        std::cout << "Preparing: " << getDescription() << std::endl;
    }
};

// Concrete Components
class Espresso : public Beverage {
public:
    std::string getDescription() const override {
        return "Espresso";
    }
    
    double cost() const override {
        return 1.99;
    }
};

class HouseBlend : public Beverage {
public:
    std::string getDescription() const override {
        return "House Blend Coffee";
    }
    
    double cost() const override {
        return 0.89;
    }
};

class DarkRoast : public Beverage {
public:
    std::string getDescription() const override {
        return "Dark Roast Coffee";
    }
    
    double cost() const override {
        return 0.99;
    }
};

// Decorator base class
class CondimentDecorator : public Beverage {
protected:
    std::unique_ptr<Beverage> beverage;

public:
    CondimentDecorator(std::unique_ptr<Beverage> beverage) 
        : beverage(std::move(beverage)) {}
    
    std::string getDescription() const override {
        return beverage->getDescription();
    }
    
    double cost() const override {
        return beverage->cost();
    }
    
    void prepare() const override {
        beverage->prepare();
    }
};

// Concrete Decorators
class Milk : public CondimentDecorator {
public:
    Milk(std::unique_ptr<Beverage> beverage) 
        : CondimentDecorator(std::move(beverage)) {}
    
    std::string getDescription() const override {
        return beverage->getDescription() + ", Milk";
    }
    
    double cost() const override {
        return beverage->cost() + 0.20;
    }
};

class Mocha : public CondimentDecorator {
public:
    Mocha(std::unique_ptr<Beverage> beverage) 
        : CondimentDecorator(std::move(beverage)) {}
    
    std::string getDescription() const override {
        return beverage->getDescription() + ", Mocha";
    }
    
    double cost() const override {
        return beverage->cost() + 0.30;
    }
};

class Whip : public CondimentDecorator {
public:
    Whip(std::unique_ptr<Beverage> beverage) 
        : CondimentDecorator(std::move(beverage)) {}
    
    std::string getDescription() const override {
        return beverage->getDescription() + ", Whip";
    }
    
    double cost() const override {
        return beverage->cost() + 0.15;
    }
};

class Soy : public CondimentDecorator {
public:
    Soy(std::unique_ptr<Beverage> beverage) 
        : CondimentDecorator(std::move(beverage)) {}
    
    std::string getDescription() const override {
        return beverage->getDescription() + ", Soy";
    }
    
    double cost() const override {
        return beverage->cost() + 0.25;
    }
};

class Caramel : public CondimentDecorator {
public:
    Caramel(std::unique_ptr<Beverage> beverage) 
        : CondimentDecorator(std::move(beverage)) {}
    
    std::string getDescription() const override {
        return beverage->getDescription() + ", Caramel";
    }
    
    double cost() const override {
        return beverage->cost() + 0.35;
    }
};

// Usage example
void coffeeShopDemo() {
    std::cout << "=== Coffee Shop Order System ===" << std::endl;
    
    // Order 1: Plain espresso
    std::cout << "\nOrder 1:" << std::endl;
    auto order1 = std::make_unique<Espresso>();
    order1->prepare();
    std::cout << "Cost: $" << order1->cost() << std::endl;
    
    // Order 2: House blend with double mocha and whip
    std::cout << "\nOrder 2:" << std::endl;
    auto order2 = std::make_unique<HouseBlend>();
    order2 = std::make_unique<Mocha>(std::move(order2));
    order2 = std::make_unique<Mocha>(std::move(order2));
    order2 = std::make_unique<Whip>(std::move(order2));
    order2->prepare();
    std::cout << "Cost: $" << order2->cost() << std::endl;
    
    // Order 3: Dark roast with all condiments
    std::cout << "\nOrder 3:" << std::endl;
    auto order3 = std::make_unique<DarkRoast>();
    order3 = std::make_unique<Milk>(std::move(order3));
    order3 = std::make_unique<Mocha>(std::move(order3));
    order3 = std::make_unique<Whip>(std::move(order3));
    order3 = std::make_unique<Soy>(std::move(order3));
    order3 = std::make_unique<Caramel>(std::move(order3));
    order3->prepare();
    std::cout << "Cost: $" << order3->cost() << std::endl;
}

int main() {
    coffeeShopDemo();
    return 0;
}
```

#### Text Processing Decorator Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <algorithm>

// Component interface
class TextComponent {
public:
    virtual ~TextComponent() = default;
    virtual std::string getText() const = 0;
    virtual void setText(const std::string& text) = 0;
    virtual std::string format() const = 0;
};

// Concrete Component
class PlainText : public TextComponent {
private:
    std::string text;

public:
    PlainText(const std::string& text = "") : text(text) {}
    
    std::string getText() const override {
        return text;
    }
    
    void setText(const std::string& text) override {
        this->text = text;
    }
    
    std::string format() const override {
        return text;
    }
};

// Decorator base class
class TextDecorator : public TextComponent {
protected:
    std::unique_ptr<TextComponent> component;

public:
    TextDecorator(std::unique_ptr<TextComponent> component) 
        : component(std::move(component)) {}
    
    std::string getText() const override {
        return component->getText();
    }
    
    void setText(const std::string& text) override {
        component->setText(text);
    }
    
    std::string format() const override {
        return component->format();
    }
};

// Concrete Decorators
class BoldDecorator : public TextDecorator {
public:
    BoldDecorator(std::unique_ptr<TextComponent> component) 
        : TextDecorator(std::move(component)) {}
    
    std::string format() const override {
        return "<b>" + component->format() + "</b>";
    }
};

class ItalicDecorator : public TextDecorator {
public:
    ItalicDecorator(std::unique_ptr<TextComponent> component) 
        : TextDecorator(std::move(component)) {}
    
    std::string format() const override {
        return "<i>" + component->format() + "</i>";
    }
};

class UnderlineDecorator : public TextDecorator {
public:
    UnderlineDecorator(std::unique_ptr<TextComponent> component) 
        : TextDecorator(std::move(component)) {}
    
    std::string format() const override {
        return "<u>" + component->format() + "</u>";
    }
};

class ColorDecorator : public TextDecorator {
private:
    std::string color;

public:
    ColorDecorator(std::unique_ptr<TextComponent> component, const std::string& color) 
        : TextDecorator(std::move(component)), color(color) {}
    
    std::string format() const override {
        return "<span style=\"color:" + color + "\">" + component->format() + "</span>";
    }
};

class UppercaseDecorator : public TextDecorator {
public:
    UppercaseDecorator(std::unique_ptr<TextComponent> component) 
        : TextDecorator(std::move(component)) {}
    
    std::string format() const override {
        std::string text = component->format();
        std::transform(text.begin(), text.end(), text.begin(), ::toupper);
        return text;
    }
};

class ReverseDecorator : public TextDecorator {
public:
    ReverseDecorator(std::unique_ptr<TextComponent> component) 
        : TextDecorator(std::move(component)) {}
    
    std::string format() const override {
        std::string text = component->format();
        std::reverse(text.begin(), text.end());
        return text;
    }
};

// Usage example
void textProcessingDemo() {
    std::cout << "=== Text Processing with Decorators ===" << std::endl;
    
    // Plain text
    auto text1 = std::make_unique<PlainText>("Hello, World!");
    std::cout << "Plain: " << text1->format() << std::endl;
    
    // Bold and italic
    auto text2 = std::make_unique<PlainText>("Decorator Pattern");
    text2 = std::make_unique<BoldDecorator>(std::move(text2));
    text2 = std::make_unique<ItalicDecorator>(std::move(text2));
    std::cout << "Bold+Italic: " << text2->format() << std::endl;
    
    // Complex formatting
    auto text3 = std::make_unique<PlainText>("Advanced Text");
    text3 = std::make_unique<ColorDecorator>(std::move(text3), "blue");
    text3 = std::make_unique<UnderlineDecorator>(std::move(text3));
    text3 = std::make_unique<BoldDecorator>(std::move(text3));
    std::cout << "Complex: " << text3->format() << std::endl;
    
    // Text transformation
    auto text4 = std::make_unique<PlainText>("transform me");
    text4 = std::make_unique<UppercaseDecorator>(std::move(text4));
    text4 = std::make_unique<ReverseDecorator>(std::move(text4));
    std::cout << "Transformed: " << text4->format() << std::endl;
    
    // All decorators combined
    auto text5 = std::make_unique<PlainText>("Everything");
    text5 = std::make_unique<BoldDecorator>(std::move(text5));
    text5 = std::make_unique<ItalicDecorator>(std::move(text5));
    text5 = std::make_unique<UnderlineDecorator>(std::move(text5));
    text5 = std::make_unique<ColorDecorator>(std::move(text5), "red");
    text5 = std::make_unique<UppercaseDecorator>(std::move(text5));
    std::cout << "Everything: " << text5->format() << std::endl;
}

int main() {
    textProcessingDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Component interface
typedef struct Text {
    char* (*get_text)(struct Text* self);
    void (*set_text)(struct Text* self, const char* text);
    char* (*render)(struct Text* self);
    void (*destroy)(struct Text* self);
} Text;

// Concrete Component
typedef struct {
    Text base;
    char* text;
} PlainText;

char* plaintext_get_text(Text* self) {
    PlainText* plaintext = (PlainText*)self;
    return plaintext->text;
}

void plaintext_set_text(Text* self, const char* text) {
    PlainText* plaintext = (PlainText*)self;
    free(plaintext->text);
    plaintext->text = strdup(text);
}

char* plaintext_render(Text* self) {
    PlainText* plaintext = (PlainText*)self;
    return strdup(plaintext->text);
}

void plaintext_destroy(Text* self) {
    PlainText* plaintext = (PlainText*)self;
    free(plaintext->text);
    free(plaintext);
}

PlainText* create_plaintext(const char* text) {
    PlainText* plaintext = malloc(sizeof(PlainText));
    plaintext->base.get_text = plaintext_get_text;
    plaintext->base.set_text = plaintext_set_text;
    plaintext->base.render = plaintext_render;
    plaintext->base.destroy = plaintext_destroy;
    plaintext->text = strdup(text);
    return plaintext;
}

// Decorator base structure
typedef struct {
    Text base;
    Text* wrapped;
} TextDecorator;

char* decorator_get_text(Text* self) {
    TextDecorator* decorator = (TextDecorator*)self;
    return decorator->wrapped->get_text(decorator->wrapped);
}

void decorator_set_text(Text* self, const char* text) {
    TextDecorator* decorator = (TextDecorator*)self;
    decorator->wrapped->set_text(decorator->wrapped, text);
}

char* decorator_render(Text* self) {
    TextDecorator* decorator = (TextDecorator*)self;
    return decorator->wrapped->render(decorator->wrapped);
}

void decorator_destroy(Text* self) {
    TextDecorator* decorator = (TextDecorator*)self;
    decorator->wrapped->destroy(decorator->wrapped);
    free(decorator);
}

// Bold Decorator
typedef struct {
    TextDecorator base;
} BoldDecorator;

char* bold_render(Text* self) {
    BoldDecorator* bold = (BoldDecorator*)self;
    char* wrapped_text = bold->base.wrapped->render(bold->base.wrapped);
    char* result = malloc(strlen(wrapped_text) + 7); // <b></b> + null terminator
    sprintf(result, "<b>%s</b>", wrapped_text);
    free(wrapped_text);
    return result;
}

BoldDecorator* create_bold_decorator(Text* text) {
    BoldDecorator* bold = malloc(sizeof(BoldDecorator));
    bold->base.base.get_text = decorator_get_text;
    bold->base.base.set_text = decorator_set_text;
    bold->base.base.render = bold_render;
    bold->base.base.destroy = decorator_destroy;
    bold->base.wrapped = text;
    return bold;
}

// Italic Decorator
typedef struct {
    TextDecorator base;
} ItalicDecorator;

char* italic_render(Text* self) {
    ItalicDecorator* italic = (ItalicDecorator*)self;
    char* wrapped_text = italic->base.wrapped->render(italic->base.wrapped);
    char* result = malloc(strlen(wrapped_text) + 7); // <i></i> + null terminator
    sprintf(result, "<i>%s</i>", wrapped_text);
    free(wrapped_text);
    return result;
}

ItalicDecorator* create_italic_decorator(Text* text) {
    ItalicDecorator* italic = malloc(sizeof(ItalicDecorator));
    italic->base.base.get_text = decorator_get_text;
    italic->base.base.set_text = decorator_set_text;
    italic->base.base.render = italic_render;
    italic->base.base.destroy = decorator_destroy;
    italic->base.wrapped = text;
    return italic;
}

// Uppercase Decorator
typedef struct {
    TextDecorator base;
} UppercaseDecorator;

char* uppercase_render(Text* self) {
    UppercaseDecorator* uppercase = (UppercaseDecorator*)self;
    char* wrapped_text = uppercase->base.wrapped->render(uppercase->base.wrapped);
    char* result = strdup(wrapped_text);
    
    // Convert to uppercase
    for (int i = 0; result[i]; i++) {
        result[i] = toupper(result[i]);
    }
    
    free(wrapped_text);
    return result;
}

UppercaseDecorator* create_uppercase_decorator(Text* text) {
    UppercaseDecorator* uppercase = malloc(sizeof(UppercaseDecorator));
    uppercase->base.base.get_text = decorator_get_text;
    uppercase->base.base.set_text = decorator_set_text;
    uppercase->base.base.render = uppercase_render;
    uppercase->base.base.destroy = decorator_destroy;
    uppercase->base.wrapped = text;
    return uppercase;
}

// Color Decorator
typedef struct {
    TextDecorator base;
    char* color;
} ColorDecorator;

char* color_render(Text* self) {
    ColorDecorator* color_decorator = (ColorDecorator*)self;
    char* wrapped_text = color_decorator->base.wrapped->render(color_decorator->base.wrapped);
    char* result = malloc(strlen(wrapped_text) + strlen(color_decorator->color) + 20);
    sprintf(result, "<span style=\"color:%s\">%s</span>", color_decorator->color, wrapped_text);
    free(wrapped_text);
    return result;
}

void color_destroy(Text* self) {
    ColorDecorator* color_decorator = (ColorDecorator*)self;
    free(color_decorator->color);
    decorator_destroy(self);
}

ColorDecorator* create_color_decorator(Text* text, const char* color) {
    ColorDecorator* color_decorator = malloc(sizeof(ColorDecorator));
    color_decorator->base.base.get_text = decorator_get_text;
    color_decorator->base.base.set_text = decorator_set_text;
    color_decorator->base.base.render = color_render;
    color_decorator->base.base.destroy = color_destroy;
    color_decorator->base.wrapped = text;
    color_decorator->color = strdup(color);
    return color_decorator;
}

// Demo function
void demonstrate_text_decorators() {
    printf("=== Text Decorators in C ===\n\n");
    
    // Create plain text
    PlainText* plain = create_plaintext("Hello, World!");
    printf("Plain text: %s\n", plain->base.render((Text*)plain));
    
    // Bold text
    BoldDecorator* bold = create_bold_decorator((Text*)plain);
    printf("Bold text: %s\n", bold->base.base.render((Text*)bold));
    
    // Bold and italic
    ItalicDecorator* italic = create_italic_decorator((Text*)bold);
    printf("Bold+Italic: %s\n", italic->base.base.render((Text*)italic));
    
    // Uppercase
    PlainText* plain2 = create_plaintext("decorator pattern");
    UppercaseDecorator* upper = create_uppercase_decorator((Text*)plain2);
    printf("Uppercase: %s\n", upper->base.base.render((Text*)upper));
    
    // Color
    PlainText* plain3 = create_plaintext("Colored Text");
    ColorDecorator* color = create_color_decorator((Text*)plain3, "blue");
    printf("Colored: %s\n", color->base.base.render((Text*)color));
    
    // Complex combination
    PlainText* plain4 = create_plaintext("Everything");
    BoldDecorator* bold2 = create_bold_decorator((Text*)plain4);
    ItalicDecorator* italic2 = create_italic_decorator((Text*)bold2);
    ColorDecorator* color2 = create_color_decorator((Text*)italic2, "red");
    UppercaseDecorator* upper2 = create_uppercase_decorator((Text*)color2);
    printf("Everything: %s\n", upper2->base.base.render((Text*)upper2));
    
    // Cleanup
    upper2->base.base.destroy((Text*)upper2);
    color->base.base.destroy((Text*)color);
    upper->base.base.destroy((Text*)upper);
    italic->base.base.destroy((Text*)italic);
    plain2->base.destroy((Text*)plain2);
    plain3->base.destroy((Text*)plain3);
}

int main() {
    demonstrate_text_decorators();
    return 0;
}
```

### Python Implementation

#### Basic Decorator Pattern - Pizza Example

```python
from abc import ABC, abstractmethod
from typing import List

# Component interface
class Pizza(ABC):
    @abstractmethod
    def get_description(self) -> str: ...
    
    @abstractmethod
    def get_cost(self) -> float: ...
    
    def display(self) -> None:
        print(f"{self.get_description()} | Cost: ${self.get_cost():.2f}")

# Concrete Components
class MargheritaPizza(Pizza):
    def get_description(self) -> str:
        return "Margherita Pizza"
    
    def get_cost(self) -> float:
        return 8.99

class PepperoniPizza(Pizza):
    def get_description(self) -> str:
        return "Pepperoni Pizza"
    
    def get_cost(self) -> float:
        return 10.99

class VeggiePizza(Pizza):
    def get_description(self) -> str:
        return "Veggie Pizza"
    
    def get_cost(self) -> float:
        return 9.99

# Decorator base class
class PizzaDecorator(Pizza):
    def __init__(self, pizza: Pizza):
        self._pizza = pizza
    
    def get_description(self) -> str:
        return self._pizza.get_description()
    
    def get_cost(self) -> float:
        return self._pizza.get_cost()

# Concrete Decorators - Toppings
class CheeseDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + ", Extra Cheese"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 1.50

class MushroomDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + ", Mushrooms"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 1.00

class OliveDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + ", Olives"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 0.75

class PepperDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + ", Bell Peppers"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 0.80

class OnionDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + ", Onions"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 0.60

class SausageDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + ", Sausage"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 2.00

# Size Decorators
class LargeSizeDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return "Large " + self._pizza.get_description()
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 3.00

class ExtraLargeSizeDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return "Extra Large " + self._pizza.get_description()
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 5.00

# Crust Decorators
class ThinCrustDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + " (Thin Crust)"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 0.50

class StuffedCrustDecorator(PizzaDecorator):
    def get_description(self) -> str:
        return self._pizza.get_description() + " (Stuffed Crust)"
    
    def get_cost(self) -> float:
        return self._pizza.get_cost() + 2.00

# Pizza Order System
class PizzaOrder:
    def __init__(self):
        self.pizzas: List[Pizza] = []
    
    def add_pizza(self, pizza: Pizza) -> None:
        self.pizzas.append(pizza)
    
    def display_order(self) -> None:
        print("=== Pizza Order ===")
        total_cost = 0.0
        for i, pizza in enumerate(self.pizzas, 1):
            print(f"{i}. ", end="")
            pizza.display()
            total_cost += pizza.get_cost()
        print(f"Total: ${total_cost:.2f}")
        print("=" * 20)

# Demo function
def pizza_shop_demo():
    print("=== Pizza Shop Order System ===\n")
    
    order = PizzaOrder()
    
    # Order 1: Basic Margherita
    pizza1 = MargheritaPizza()
    order.add_pizza(pizza1)
    
    # Order 2: Pepperoni with extra cheese and mushrooms
    pizza2 = PepperoniPizza()
    pizza2 = CheeseDecorator(pizza2)
    pizza2 = MushroomDecorator(pizza2)
    order.add_pizza(pizza2)
    
    # Order 3: Veggie pizza with all veggies, large size, stuffed crust
    pizza3 = VeggiePizza()
    pizza3 = MushroomDecorator(pizza3)
    pizza3 = OliveDecorator(pizza3)
    pizza3 = PepperDecorator(pizza3)
    pizza3 = OnionDecorator(pizza3)
    pizza3 = LargeSizeDecorator(pizza3)
    pizza3 = StuffedCrustDecorator(pizza3)
    order.add_pizza(pizza3)
    
    # Order 4: Everything pizza
    pizza4 = PepperoniPizza()
    pizza4 = CheeseDecorator(pizza4)
    pizza4 = MushroomDecorator(pizza4)
    pizza4 = OliveDecorator(pizza4)
    pizza4 = PepperDecorator(pizza4)
    pizza4 = OnionDecorator(pizza4)
    pizza4 = SausageDecorator(pizza4)
    pizza4 = ExtraLargeSizeDecorator(pizza4)
    pizza4 = StuffedCrustDecorator(pizza4)
    order.add_pizza(pizza4)
    
    order.display_order()

if __name__ == "__main__":
    pizza_shop_demo()
```

#### Advanced Python Decorators - File Processing

```python
from abc import ABC, abstractmethod
from typing import Any, List, Dict
import gzip
import json
import pickle
from datetime import datetime
import time

# Component interface
class DataProcessor(ABC):
    @abstractmethod
    def process(self, data: Any) -> Any: ...
    
    @abstractmethod
    def get_info(self) -> Dict[str, Any]: ...

# Concrete Component
class FileProcessor(DataProcessor):
    def __init__(self, filename: str):
        self.filename = filename
        self.processed_count = 0
    
    def process(self, data: Any) -> Any:
        self.processed_count += 1
        print(f"FileProcessor: Writing to {self.filename}")
        # In real implementation, this would write to file
        return f"Written to {self.filename}: {data}"
    
    def get_info(self) -> Dict[str, Any]:
        return {
            "type": "FileProcessor",
            "filename": self.filename,
            "processed_count": self.processed_count
        }

# Decorator base class
class ProcessorDecorator(DataProcessor):
    def __init__(self, processor: DataProcessor):
        self._processor = processor
    
    def process(self, data: Any) -> Any:
        return self._processor.process(data)
    
    def get_info(self) -> Dict[str, Any]:
        return self._processor.get_info()

# Compression Decorators
class GzipCompressionDecorator(ProcessorDecorator):
    def process(self, data: Any) -> Any:
        print("GzipCompression: Compressing data")
        # Simulate compression
        compressed_data = f"GZIP[{data}]"
        return self._processor.process(compressed_data)
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["compression"] = "GZIP"
        return info

class ZipCompressionDecorator(ProcessorDecorator):
    def process(self, data: Any) -> Any:
        print("ZipCompression: Compressing data")
        # Simulate compression
        compressed_data = f"ZIP[{data}]"
        return self._processor.process(compressed_data)
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["compression"] = "ZIP"
        return info

# Encryption Decorators
class AESEncryptionDecorator(ProcessorDecorator):
    def __init__(self, processor: DataProcessor, key: str):
        super().__init__(processor)
        self.key = key
    
    def process(self, data: Any) -> Any:
        print(f"AESEncryption: Encrypting data with key {self.key}")
        # Simulate encryption
        encrypted_data = f"AES[{data}]"
        return self._processor.process(encrypted_data)
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["encryption"] = "AES"
        info["key_length"] = len(self.key)
        return info

class RSAEncryptionDecorator(ProcessorDecorator):
    def __init__(self, processor: DataProcessor, public_key: str):
        super().__init__(processor)
        self.public_key = public_key
    
    def process(self, data: Any) -> Any:
        print(f"RSAEncryption: Encrypting data with RSA")
        # Simulate encryption
        encrypted_data = f"RSA[{data}]"
        return self._processor.process(encrypted_data)
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["encryption"] = "RSA"
        return info

# Format Decorators
class JSONFormatDecorator(ProcessorDecorator):
    def process(self, data: Any) -> Any:
        print("JSONFormat: Converting to JSON")
        json_data = json.dumps({"data": data, "timestamp": datetime.now().isoformat()})
        return self._processor.process(json_data)
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["format"] = "JSON"
        return info

class XMLFormatDecorator(ProcessorDecorator):
    def process(self, data: Any) -> Any:
        print("XMLFormat: Converting to XML")
        xml_data = f"<data><content>{data}</content><timestamp>{datetime.now().isoformat()}</timestamp></data>"
        return self._processor.process(xml_data)
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["format"] = "XML"
        return info

# Monitoring Decorators
class LoggingDecorator(ProcessorDecorator):
    def __init__(self, processor: DataProcessor, log_file: str = None):
        super().__init__(processor)
        self.log_file = log_file
        self.logs: List[Dict] = []
    
    def process(self, data: Any) -> Any:
        start_time = time.time()
        
        try:
            result = self._processor.process(data)
            duration = time.time() - start_time
            
            log_entry = {
                "timestamp": datetime.now(),
                "operation": "process",
                "input": str(data),
                "output": str(result),
                "duration": duration,
                "status": "success"
            }
            
            self._log(log_entry)
            return result
            
        except Exception as e:
            duration = time.time() - start_time
            log_entry = {
                "timestamp": datetime.now(),
                "operation": "process",
                "input": str(data),
                "error": str(e),
                "duration": duration,
                "status": "error"
            }
            
            self._log(log_entry)
            raise
    
    def _log(self, entry: Dict) -> None:
        self.logs.append(entry)
        print(f"Logging: {entry['status']} - {entry['input'][:50]}...")
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["logging"] = True
        info["log_count"] = len(self.logs)
        return info

class MetricsDecorator(ProcessorDecorator):
    def __init__(self, processor: DataProcessor):
        super().__init__(processor)
        self.metrics = {
            "total_operations": 0,
            "successful_operations": 0,
            "failed_operations": 0,
            "total_processing_time": 0.0
        }
    
    def process(self, data: Any) -> Any:
        start_time = time.time()
        self.metrics["total_operations"] += 1
        
        try:
            result = self._processor.process(data)
            self.metrics["successful_operations"] += 1
            return result
        except Exception:
            self.metrics["failed_operations"] += 1
            raise
        finally:
            self.metrics["total_processing_time"] += time.time() - start_time
    
    def get_info(self) -> Dict[str, Any]:
        info = super().get_info()
        info["metrics"] = self.metrics.copy()
        if self.metrics["total_operations"] > 0:
            info["metrics"]["success_rate"] = (
                self.metrics["successful_operations"] / self.metrics["total_operations"]
            )
            info["metrics"]["avg_processing_time"] = (
                self.metrics["total_processing_time"] / self.metrics["total_operations"]
            )
        return info

# Demo function
def file_processing_demo():
    print("=== Advanced File Processing with Decorators ===\n")
    
    # Create different processing pipelines
    
    # Pipeline 1: Basic file processing with logging
    print("Pipeline 1: Basic + Logging")
    pipeline1 = LoggingDecorator(FileProcessor("basic.txt"))
    result1 = pipeline1.process("Hello World")
    print(f"Result: {result1}\n")
    
    # Pipeline 2: JSON + GZIP + AES
    print("Pipeline 2: JSON + GZIP + AES")
    pipeline2 = AESEncryptionDecorator(
        GzipCompressionDecorator(
            JSONFormatDecorator(
                FileProcessor("secure.json.gz")
            )
        ), "my_secret_key"
    )
    result2 = pipeline2.process({"message": "Secret data", "level": "high"})
    print(f"Result: {result2}\n")
    
    # Pipeline 3: XML + ZIP + RSA + Metrics + Logging
    print("Pipeline 3: XML + ZIP + RSA + Metrics + Logging")
    pipeline3 = MetricsDecorator(
        LoggingDecorator(
            RSAEncryptionDecorator(
                ZipCompressionDecorator(
                    XMLFormatDecorator(
                        FileProcessor("enterprise.xml.zip")
                    )
                ), "public_key_123"
            )
        )
    )
    
    # Process multiple items to see metrics
    test_data = ["Data 1", "Data 2", "Data 3"]
    for data in test_data:
        try:
            result = pipeline3.process(data)
            print(f"Processed: {result}")
        except Exception as e:
            print(f"Error: {e}")
    
    print("\n=== Pipeline Information ===")
    pipelines = [pipeline1, pipeline2, pipeline3]
    for i, pipeline in enumerate(pipelines, 1):
        print(f"\nPipeline {i} Info:")
        info = pipeline.get_info()
        for key, value in info.items():
            print(f"  {key}: {value}")

if __name__ == "__main__":
    file_processing_demo()
```

## Advantages and Disadvantages

### Advantages

- **Flexibility**: Add responsibilities dynamically at runtime
- **Single Responsibility**: Each decorator has one specific responsibility
- **Open/Closed Principle**: Can extend functionality without modifying existing code
- **Avoids Class Explosion**: Prevents subclass explosion for multiple feature combinations
- **Composition over Inheritance**: Favors object composition over class inheritance

### Disadvantages

- **Complexity**: Can lead to many small classes that complicate the design
- **Debugging Difficulty**: Hard to trace through multiple layers of decorators
- **Initialization Overhead**: Object instantiation can become complex with many decorators
- **Type Identification**: Decorated objects may not be identifiable as their original type

## Best Practices

1. **Use for Cross-Cutting Concerns**: Logging, caching, validation, compression
2. **Keep Decorators Simple**: Each decorator should have a single responsibility
3. **Maintain Interface Compatibility**: Decorators must implement the same interface as components
4. **Consider Order**: The order of decorators can affect the final result
5. **Use for Optional Features**: When features can be added or removed dynamically

## Decorator vs Other Patterns

- **vs Adapter**: Decorator doesn't change interface, Adapter does
- **vs Composite**: Decorator adds responsibilities, Composite builds tree structures
- **vs Strategy**: Decorator changes skin, Strategy changes guts
- **vs Proxy**: Decorator adds functionality, Proxy controls access

The Decorator pattern is particularly useful when you need to add responsibilities to objects dynamically and transparently, without affecting other objects, and when subclassing would lead to an explosion of classes for every possible combination of features.
