# Prototype Pattern

## Introduction

The Prototype pattern is a creational design pattern that allows creating new objects by copying existing objects (prototypes) rather than creating new instances from scratch. This pattern is particularly useful when object creation is expensive or complex.

### Key Characteristics
- **Object Cloning**: Creates new objects by copying existing prototypes
- **Reduced Overhead**: Avoids expensive initialization operations
- **Flexibility**: Clients can create new objects without knowing their concrete classes
- **Dynamic Configuration**: Prototypes can be configured at runtime

### Use Cases
- When object creation is more expensive than copying
- When the system should be independent of how its products are created, composed, and represented
- When classes to instantiate are specified at runtime
- When you need to avoid building a class hierarchy of factories that parallels the class hierarchy of products

## Implementation Examples

### C++ Implementation

#### Basic Prototype Pattern
```cpp
#include <iostream>
#include <string>
#include <memory>
#include <unordered_map>

// Prototype interface
class Prototype {
public:
    virtual ~Prototype() = default;
    virtual std::unique_ptr<Prototype> clone() const = 0;
    virtual void display() const = 0;
    virtual void setValue(const std::string& value) = 0;
};

// Concrete Prototype
class ConcretePrototype : public Prototype {
private:
    std::string data;
    int number;
    std::string* metadata;

public:
    ConcretePrototype(const std::string& data, int number, const std::string& meta)
        : data(data), number(number), metadata(new std::string(meta)) {}

    // Copy constructor for deep copy
    ConcretePrototype(const ConcretePrototype& other)
        : data(other.data), number(other.number), metadata(new std::string(*other.metadata)) {}

    ~ConcretePrototype() {
        delete metadata;
    }

    std::unique_ptr<Prototype> clone() const override {
        return std::make_unique<ConcretePrototype>(*this);
    }

    void display() const override {
        std::cout << "ConcretePrototype: data='" << data 
                  << "', number=" << number 
                  << ", metadata='" << *metadata << "'" << std::endl;
    }

    void setValue(const std::string& value) override {
        data = value;
    }

    void setNumber(int num) {
        number = num;
    }

    void setMetadata(const std::string& meta) {
        *metadata = meta;
    }
};

// Prototype Registry
class PrototypeRegistry {
private:
    std::unordered_map<std::string, std::unique_ptr<Prototype>> prototypes;

public:
    void registerPrototype(const std::string& key, std::unique_ptr<Prototype> prototype) {
        prototypes[key] = std::move(prototype);
    }

    std::unique_ptr<Prototype> createPrototype(const std::string& key) {
        auto it = prototypes.find(key);
        if (it != prototypes.end()) {
            return it->second->clone();
        }
        return nullptr;
    }

    void listPrototypes() const {
        std::cout << "Registered prototypes:" << std::endl;
        for (const auto& pair : prototypes) {
            std::cout << "  " << pair.first << ": ";
            pair.second->display();
        }
    }
};

// Usage example
int main() {
    PrototypeRegistry registry;

    // Register some prototypes
    registry.registerPrototype("default", 
        std::make_unique<ConcretePrototype>("default_data", 100, "default_meta"));
    
    registry.registerPrototype("advanced", 
        std::make_unique<ConcretePrototype>("advanced_data", 200, "advanced_meta"));

    // Display registered prototypes
    registry.listPrototypes();
    std::cout << std::endl;

    // Create objects from prototypes
    auto obj1 = registry.createPrototype("default");
    auto obj2 = registry.createPrototype("advanced");
    auto obj3 = registry.createPrototype("default");

    if (obj1) {
        std::cout << "Object 1 (default): ";
        obj1->display();
    }

    if (obj2) {
        std::cout << "Object 2 (advanced): ";
        obj2->display();
    }

    if (obj3) {
        // Modify the cloned object
        obj3->setValue("modified_data");
        std::cout << "Object 3 (modified): ";
        obj3->display();
    }

    // Verify original prototype is unchanged
    std::cout << "\nOriginal prototypes remain unchanged:" << std::endl;
    registry.listPrototypes();

    return 0;
}
```

#### Advanced Prototype with Different Object Types
```cpp
#include <iostream>
#include <string>
#include <memory>
#include <vector>
#include <cmath>

// Abstract Shape prototype
class Shape : public Prototype {
protected:
    std::string color;
    int x, y;

public:
    Shape(const std::string& color, int x, int y) : color(color), x(x), y(y) {}
    virtual ~Shape() = default;

    void setPosition(int newX, int newY) {
        x = newX;
        y = newY;
    }

    void setColor(const std::string& newColor) {
        color = newColor;
    }

    virtual double area() const = 0;
    virtual void draw() const = 0;
};

// Concrete Shape: Circle
class Circle : public Shape {
private:
    double radius;

public:
    Circle(const std::string& color, int x, int y, double radius) 
        : Shape(color, x, y), radius(radius) {}

    Circle(const Circle& other) 
        : Shape(other.color, other.x, other.y), radius(other.radius) {}

    std::unique_ptr<Prototype> clone() const override {
        return std::make_unique<Circle>(*this);
    }

    void display() const override {
        std::cout << "Circle: color='" << color << "', position=(" << x << "," << y 
                  << "), radius=" << radius << ", area=" << area() << std::endl;
    }

    void setValue(const std::string& value) override {
        color = value;
    }

    double area() const override {
        return M_PI * radius * radius;
    }

    void draw() const override {
        std::cout << "Drawing Circle at (" << x << "," << y << ") with radius " << radius << std::endl;
    }

    void setRadius(double newRadius) {
        radius = newRadius;
    }
};

// Concrete Shape: Rectangle
class Rectangle : public Shape {
private:
    double width, height;

public:
    Rectangle(const std::string& color, int x, int y, double width, double height) 
        : Shape(color, x, y), width(width), height(height) {}

    Rectangle(const Rectangle& other) 
        : Shape(other.color, other.x, other.y), width(other.width), height(other.height) {}

    std::unique_ptr<Prototype> clone() const override {
        return std::make_unique<Rectangle>(*this);
    }

    void display() const override {
        std::cout << "Rectangle: color='" << color << "', position=(" << x << "," << y 
                  << "), size=" << width << "x" << height << ", area=" << area() << std::endl;
    }

    void setValue(const std::string& value) override {
        color = value;
    }

    double area() const override {
        return width * height;
    }

    void draw() const override {
        std::cout << "Drawing Rectangle at (" << x << "," << y << ") with size " 
                  << width << "x" << height << std::endl;
    }

    void setSize(double w, double h) {
        width = w;
        height = h;
    }
};

// Graphics Editor using Prototype pattern
class GraphicsEditor {
private:
    std::unordered_map<std::string, std::unique_ptr<Shape>> shapeTemplates;

public:
    void registerShape(const std::string& name, std::unique_ptr<Shape> shape) {
        shapeTemplates[name] = std::move(shape);
    }

    std::unique_ptr<Shape> createShape(const std::string& name, int x, int y) {
        auto it = shapeTemplates.find(name);
        if (it != shapeTemplates.end()) {
            auto shape = std::unique_ptr<Shape>(static_cast<Shape*>(it->second->clone().release()));
            shape->setPosition(x, y);
            return shape;
        }
        return nullptr;
    }

    void listTemplates() const {
        std::cout << "Available shape templates:" << std::endl;
        for (const auto& pair : shapeTemplates) {
            std::cout << "  " << pair.first << ": ";
            pair.second->display();
        }
    }
};

// Usage example
int main() {
    GraphicsEditor editor;

    // Register shape templates
    editor.registerShape("red_circle", 
        std::make_unique<Circle>("red", 0, 0, 10.0));
    editor.registerShape("blue_rectangle", 
        std::make_unique<Rectangle>("blue", 0, 0, 20.0, 15.0));
    editor.registerShape("green_circle", 
        std::make_unique<Circle>("green", 0, 0, 5.0));

    // List available templates
    editor.listTemplates();
    std::cout << std::endl;

    // Create shapes from templates
    std::vector<std::unique_ptr<Shape>> shapes;
    
    shapes.push_back(editor.createShape("red_circle", 10, 20));
    shapes.push_back(editor.createShape("blue_rectangle", 30, 40));
    shapes.push_back(editor.createShape("green_circle", 50, 60));

    // Modify some clones
    if (shapes.size() > 1) {
        auto circle = dynamic_cast<Circle*>(shapes[0].get());
        if (circle) {
            circle->setRadius(15.0);
        }
        
        auto rect = dynamic_cast<Rectangle*>(shapes[1].get());
        if (rect) {
            rect->setSize(25.0, 20.0);
        }
    }

    // Display all shapes
    std::cout << "Created shapes:" << std::endl;
    for (const auto& shape : shapes) {
        if (shape) {
            shape->display();
            shape->draw();
        }
    }

    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Prototype interface
typedef struct Prototype {
    void* (*clone)(const struct Prototype* self);
    void (*display)(const struct Prototype* self);
    void (*destroy)(struct Prototype* self);
} Prototype;

// Concrete prototype: Document
typedef struct {
    Prototype prototype;
    char* title;
    char* content;
    int page_count;
    char* author;
} Document;

void document_display(const Prototype* self) {
    Document* doc = (Document*)self;
    printf("Document: title='%s', author='%s', pages=%d\n", 
           doc->title, doc->author, doc->page_count);
    printf("Content: %s\n", doc->content);
}

void* document_clone(const Prototype* self) {
    Document* original = (Document*)self;
    Document* copy = malloc(sizeof(Document));
    
    // Set up function pointers
    copy->prototype.clone = document_clone;
    copy->prototype.display = document_display;
    copy->prototype.destroy = original->prototype.destroy;
    
    // Deep copy strings
    copy->title = strdup(original->title);
    copy->content = strdup(original->content);
    copy->author = strdup(original->author);
    copy->page_count = original->page_count;
    
    return copy;
}

void document_destroy(Prototype* self) {
    Document* doc = (Document*)self;
    free(doc->title);
    free(doc->content);
    free(doc->author);
    free(doc);
}

Document* create_document(const char* title, const char* content, 
                         int page_count, const char* author) {
    Document* doc = malloc(sizeof(Document));
    doc->prototype.clone = document_clone;
    doc->prototype.display = document_display;
    doc->prototype.destroy = document_destroy;
    
    doc->title = strdup(title);
    doc->content = strdup(content);
    doc->author = strdup(author);
    doc->page_count = page_count;
    
    return doc;
}

// Prototype registry
typedef struct {
    Prototype** prototypes;
    char** keys;
    int count;
    int capacity;
} PrototypeRegistry;

PrototypeRegistry* create_registry() {
    PrototypeRegistry* registry = malloc(sizeof(PrototypeRegistry));
    registry->capacity = 10;
    registry->count = 0;
    registry->prototypes = malloc(registry->capacity * sizeof(Prototype*));
    registry->keys = malloc(registry->capacity * sizeof(char*));
    return registry;
}

void registry_register(PrototypeRegistry* registry, const char* key, Prototype* prototype) {
    if (registry->count >= registry->capacity) {
        registry->capacity *= 2;
        registry->prototypes = realloc(registry->prototypes, registry->capacity * sizeof(Prototype*));
        registry->keys = realloc(registry->keys, registry->capacity * sizeof(char*));
    }
    
    registry->keys[registry->count] = strdup(key);
    registry->prototypes[registry->count] = prototype;
    registry->count++;
}

Prototype* registry_create(PrototypeRegistry* registry, const char* key) {
    for (int i = 0; i < registry->count; i++) {
        if (strcmp(registry->keys[i], key) == 0) {
            return registry->prototypes[i]->clone(registry->prototypes[i]);
        }
    }
    return NULL;
}

void registry_destroy(PrototypeRegistry* registry) {
    for (int i = 0; i < registry->count; i++) {
        free(registry->keys[i]);
        registry->prototypes[i]->destroy(registry->prototypes[i]);
    }
    free(registry->prototypes);
    free(registry->keys);
    free(registry);
}

// Usage example
int main() {
    // Create prototype registry
    PrototypeRegistry* registry = create_registry();
    
    // Register some document templates
    registry_register(registry, "report_template", 
        (Prototype*)create_document("Monthly Report", "This is the report content...", 5, "John Doe"));
    
    registry_register(registry, "memo_template", 
        (Prototype*)create_document("Office Memo", "Memo content goes here...", 2, "Jane Smith"));
    
    // Create documents from templates
    printf("=== Creating documents from templates ===\n");
    
    Document* report1 = (Document*)registry_create(registry, "report_template");
    Document* report2 = (Document*)registry_create(registry, "report_template");
    Document* memo1 = (Document*)registry_create(registry, "memo_template");
    
    if (report1) {
        printf("Report 1 (original):\n");
        report1->prototype.display((Prototype*)report1);
        printf("\n");
    }
    
    if (report2) {
        // Modify the cloned report
        free(report2->title);
        report2->title = strdup("Q4 Financial Report");
        free(report2->content);
        report2->content = strdup("Updated financial data...");
        report2->page_count = 8;
        
        printf("Report 2 (modified):\n");
        report2->prototype.display((Prototype*)report2);
        printf("\n");
    }
    
    if (memo1) {
        printf("Memo 1:\n");
        memo1->prototype.display((Prototype*)memo1);
        printf("\n");
    }
    
    // Cleanup
    if (report1) report1->prototype.destroy((Prototype*)report1);
    if (report2) report2->prototype.destroy((Prototype*)report2);
    if (memo1) memo1->prototype.destroy((Prototype*)memo1);
    registry_destroy(registry);
    
    return 0;
}
```

### Python Implementation

#### Basic Prototype Pattern
```python
import copy
from abc import ABC, abstractmethod
from typing import Any, Dict
from dataclasses import dataclass, field

# Prototype interface
class Prototype(ABC):
    @abstractmethod
    def clone(self) -> 'Prototype':
        pass
    
    @abstractmethod
    def display(self) -> None:
        pass

# Concrete prototype
@dataclass
class Car(Prototype):
    model: str
    color: str
    engine: str
    features: Dict[str, Any] = field(default_factory=dict)
    
    def clone(self) -> 'Car':
        # Deep copy to ensure all nested objects are also copied
        return copy.deepcopy(self)
    
    def display(self) -> None:
        print(f"Car: {self.model}, Color: {self.color}, Engine: {self.engine}")
        if self.features:
            print("  Features:")
            for key, value in self.features.items():
                print(f"    {key}: {value}")
    
    def add_feature(self, key: str, value: Any) -> None:
        self.features[key] = value

# Prototype registry
class CarRegistry:
    def __init__(self):
        self._templates: Dict[str, Car] = {}
    
    def register_car(self, name: str, car: Car) -> None:
        self._templates[name] = car
    
    def create_car(self, name: str) -> Car:
        if name not in self._templates:
            raise ValueError(f"Car template '{name}' not found")
        return self._templates[name].clone()
    
    def list_templates(self) -> None:
        print("Available car templates:")
        for name, car in self._templates.items():
            print(f"  {name}: ", end="")
            car.display()

# Usage example
if __name__ == "__main__":
    # Create registry
    registry = CarRegistry()
    
    # Register car templates
    sports_car = Car("Sports", "Red", "V8", {"turbo": True, "seats": 2})
    family_car = Car("SUV", "Blue", "V6", {"seats": 7, "sunroof": True})
    electric_car = Car("Sedan", "White", "Electric", {"battery": "100kWh", "autopilot": True})
    
    registry.register_car("sports_template", sports_car)
    registry.register_car("family_template", family_car)
    registry.register_car("electric_template", electric_car)
    
    # List available templates
    registry.list_templates()
    print("\n" + "="*50 + "\n")
    
    # Create cars from templates
    car1 = registry.create_car("sports_template")
    car2 = registry.create_car("family_template")
    car3 = registry.create_car("electric_template")
    
    print("Original cloned cars:")
    car1.display()
    car2.display()
    car3.display()
    
    print("\n" + "="*50 + "\n")
    
    # Modify cloned cars
    car1.color = "Yellow"
    car1.add_feature("spoiler", "Large")
    
    car2.model = "Minivan"
    car2.features["entertainment"] = "DVD System"
    
    car3.add_feature("fast_charging", True)
    
    print("Modified cloned cars:")
    car1.display()
    car2.display()
    car3.display()
    
    print("\n" + "="*50 + "\n")
    
    # Verify original templates are unchanged
    print("Original templates remain unchanged:")
    registry.list_templates()
```

#### Advanced Prototype with Complex Objects
```python
import copy
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from enum import Enum

class CharacterClass(Enum):
    WARRIOR = "Warrior"
    MAGE = "Mage"
    ROGUE = "Rogue"
    CLERIC = "Cleric"

# Complex prototype: Game Character
class GameCharacter(Prototype):
    def __init__(self, name: str, char_class: CharacterClass, level: int = 1):
        self.name = name
        self.char_class = char_class
        self.level = level
        self.attributes = {
            "strength": 10,
            "dexterity": 10,
            "intelligence": 10,
            "wisdom": 10,
            "charisma": 10
        }
        self.skills: List[str] = []
        self.equipment: Dict[str, str] = {}
        self.inventory: List[str] = []
    
    def clone(self) -> 'GameCharacter':
        return copy.deepcopy(self)
    
    def display(self) -> None:
        print(f"Character: {self.name} ({self.char_class.value}) - Level {self.level}")
        print(f"  Attributes: {self.attributes}")
        print(f"  Skills: {', '.join(self.skills) if self.skills else 'None'}")
        print(f"  Equipment: {self.equipment}")
        print(f"  Inventory: {', '.join(self.inventory) if self.inventory else 'Empty'}")
    
    def set_attribute(self, attr: str, value: int) -> None:
        if attr in self.attributes:
            self.attributes[attr] = value
    
    def add_skill(self, skill: str) -> None:
        self.skills.append(skill)
    
    def equip_item(self, slot: str, item: str) -> None:
        self.equipment[slot] = item
    
    def add_to_inventory(self, item: str) -> None:
        self.inventory.append(item)
    
    def level_up(self) -> None:
        self.level += 1

# Character Template Manager
class CharacterTemplateManager:
    def __init__(self):
        self._templates: Dict[str, GameCharacter] = {}
        self._initialize_templates()
    
    def _initialize_templates(self) -> None:
        # Warrior template
        warrior = GameCharacter("Warrior Template", CharacterClass.WARRIOR)
        warrior.set_attribute("strength", 16)
        warrior.set_attribute("dexterity", 12)
        warrior.set_attribute("intelligence", 8)
        warrior.add_skill("Sword Mastery")
        warrior.add_skill("Shield Block")
        warrior.equip_item("weapon", "Longsword")
        warrior.equip_item("armor", "Chainmail")
        self._templates["warrior"] = warrior
        
        # Mage template
        mage = GameCharacter("Mage Template", CharacterClass.MAGE)
        mage.set_attribute("strength", 8)
        mage.set_attribute("intelligence", 16)
        mage.set_attribute("wisdom", 14)
        mage.add_skill("Fireball")
        mage.add_skill("Teleport")
        mage.equip_item("weapon", "Staff")
        mage.equip_item("armor", "Robe")
        mage.add_to_inventory("Mana Potion")
        self._templates["mage"] = mage
        
        # Rogue template
        rogue = GameCharacter("Rogue Template", CharacterClass.ROGUE)
        rogue.set_attribute("dexterity", 16)
        rogue.set_attribute("strength", 12)
        rogue.set_attribute("charisma", 14)
        rogue.add_skill("Stealth")
        rogue.add_skill("Lockpicking")
        rogue.equip_item("weapon", "Dagger")
        rogue.equip_item("armor", "Leather Armor")
        rogue.add_to_inventory("Lockpicks")
        self._templates["rogue"] = rogue
    
    def create_character(self, template_name: str, name: str) -> GameCharacter:
        if template_name not in self._templates:
            raise ValueError(f"Template '{template_name}' not found")
        
        character = self._templates[template_name].clone()
        character.name = name
        return character
    
    def register_template(self, name: str, template: GameCharacter) -> None:
        self._templates[name] = template
    
    def list_templates(self) -> None:
        print("Available character templates:")
        for name, template in self._templates.items():
            print(f"  {name}: ", end="")
            template.display()

# Usage example
if __name__ == "__main__":
    template_manager = CharacterTemplateManager()
    
    print("=== Character Templates ===")
    template_manager.list_templates()
    
    print("\n" + "="*60 + "\n")
    
    # Create characters from templates
    characters = [
        template_manager.create_character("warrior", "Aragorn"),
        template_manager.create_character("mage", "Gandalf"),
        template_manager.create_character("rogue", "Legolas")
    ]
    
    print("=== Initial Characters ===")
    for char in characters:
        char.display()
        print()
    
    print("="*60 + "\n")
    
    # Customize the cloned characters
    characters[0].level_up()  # Aragorn levels up
    characters[0].add_skill("Leadership")
    characters[0].equip_item("shield", "Tower Shield")
    
    characters[1].set_attribute("intelligence", 18)  # Gandalf is wise
    characters[1].add_skill("Lightning Bolt")
    characters[1].add_to_inventory("Ancient Tome")
    
    characters[2].set_attribute("dexterity", 18)  # Legolas is agile
    characters[2].add_skill("Archery")
    characters[2].equip_item("ranged", "Longbow")
    
    print("=== Customized Characters ===")
    for char in characters:
        char.display()
        print()
    
    print("="*60 + "\n")
    
    # Verify templates remain unchanged
    print("=== Original Templates (Unchanged) ===")
    template_manager.list_templates()
```

#### Prototype with Customizable Cloning
```python
import copy
from typing import List, Set, Any

# Advanced prototype with customizable cloning behavior
class ConfigurablePrototype:
    def __init__(self, name: str, data: Dict[str, Any], tags: List[str] = None):
        self.name = name
        self.data = data
        self.tags = tags or []
        self._clone_behavior = "deep"  # deep, shallow, or custom
    
    def set_clone_behavior(self, behavior: str) -> None:
        valid_behaviors = {"deep", "shallow", "custom"}
        if behavior not in valid_behaviors:
            raise ValueError(f"Clone behavior must be one of {valid_behaviors}")
        self._clone_behavior = behavior
    
    def clone(self) -> 'ConfigurablePrototype':
        if self._clone_behavior == "deep":
            return self._deep_clone()
        elif self._clone_behavior == "shallow":
            return self._shallow_clone()
        else:
            return self._custom_clone()
    
    def _deep_clone(self) -> 'ConfigurablePrototype':
        """Create a complete deep copy"""
        cloned = ConfigurablePrototype(
            name=self.name,
            data=copy.deepcopy(self.data),
            tags=copy.deepcopy(self.tags)
        )
        cloned._clone_behavior = self._clone_behavior
        return cloned
    
    def _shallow_clone(self) -> 'ConfigurablePrototype':
        """Create a shallow copy (shared nested objects)"""
        cloned = ConfigurablePrototype(
            name=self.name,
            data=self.data.copy(),  # shallow copy of dict
            tags=self.tags.copy()   # shallow copy of list
        )
        cloned._clone_behavior = self._clone_behavior
        return cloned
    
    def _custom_clone(self) -> 'ConfigurablePrototype':
        """Custom cloning logic - reset some fields, keep others"""
        cloned = ConfigurablePrototype(
            name=f"Copy_of_{self.name}",
            data={k: v for k, v in self.data.items() if not k.startswith('_')},
            tags=[tag for tag in self.tags if tag != "template"]
        )
        cloned._clone_behavior = self._clone_behavior
        return cloned
    
    def display(self) -> None:
        print(f"Prototype: {self.name}")
        print(f"  Data: {self.data}")
        print(f"  Tags: {self.tags}")
        print(f"  Clone Behavior: {self._clone_behavior}")
        print(f"  Memory ID: {id(self)}")

# Usage example
if __name__ == "__main__":
    print("=== Configurable Prototype Demo ===")
    
    # Create original prototype
    original = ConfigurablePrototype(
        name="Original",
        data={
            "value": 100,
            "nested": {"a": 1, "b": 2},
            "_private": "secret"
        },
        tags=["template", "important"]
    )
    
    print("Original object:")
    original.display()
    print()
    
    # Test different clone behaviors
    behaviors = ["deep", "shallow", "custom"]
    
    for behavior in behaviors:
        print(f"=== {behavior.upper()} CLONE ===")
        original.set_clone_behavior(behavior)
        cloned = original.clone()
        cloned.display()
        
        # Modify cloned object to see behavior differences
        cloned.data["value"] = 200
        cloned.data["nested"]["a"] = 999
        cloned.tags.append("modified")
        
        print("After modification:")
        print("  Original data:", original.data)
        print("  Cloned data:", cloned.data)
        print("  Original tags:", original.tags)
        print("  Cloned tags:", cloned.tags)
        print()
```

## Advantages and Disadvantages

### Advantages
- **Reduced initialization cost**: Avoids expensive constructor operations
- **Simplified object creation**: Clients don't need to know concrete classes
- **Runtime object configuration**: Objects can be configured before cloning
- **Reduced subclassing**: Avoids creating extensive class hierarchies
- **Dynamic object creation**: New objects can be added at runtime

### Disadvantages
- **Complex cloning**: Deep copying complex objects can be challenging
- **Circular references**: Can cause issues during cloning
- **Overhead**: Cloning might be expensive for very large objects
- **Implementation complexity**: Each class must implement cloning logic

## Best Practices

1. **Use for expensive objects**: When object creation is more costly than copying
2. **Implement proper cloning**: Ensure deep vs shallow copy behavior is appropriate
3. **Use prototype registry**: Manage and organize prototype instances
4. **Consider object relationships**: Handle circular references carefully
5. **Document cloning behavior**: Clearly specify whether copies are deep or shallow

## Prototype vs Other Patterns

- **vs Factory Method**: Prototype clones existing objects, while Factory Method creates new objects from scratch
- **vs Singleton**: Prototype creates new instances by copying, while Singleton ensures only one instance exists
- **vs Builder**: Prototype copies existing objects, while Builder constructs objects step by step

The Prototype pattern is particularly useful in scenarios where:
- Object creation is expensive or complex
- You need to create objects that are similar to existing ones
- You want to avoid the overhead of subclassing
- The classes to instantiate are specified at runtime