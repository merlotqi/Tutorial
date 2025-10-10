# Composite Pattern

## Introduction

The Composite pattern is a structural design pattern that allows you to compose objects into tree structures to represent part-whole hierarchies. It lets clients treat individual objects and compositions of objects uniformly.

### Key Characteristics

- **Tree Structure**: Represents hierarchical part-whole relationships
- **Uniform Treatment**: Clients can treat individual objects and compositions uniformly
- **Recursive Composition**: Components can contain other components
- **Transparent Structure**: Clients don't need to know if they're dealing with leaf or composite nodes

### Use Cases

- When you need to represent part-whole hierarchies of objects
- When you want clients to ignore differences between individual objects and compositions
- When you need to build recursive tree structures
- When you want to apply operations recursively over object hierarchies

## Implementation Examples

### C++ Implementation

#### File System Composite Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <algorithm>

// Component interface
class FileSystemComponent {
public:
    virtual ~FileSystemComponent() = default;
    virtual std::string getName() const = 0;
    virtual long getSize() const = 0;
    virtual void display(const std::string& indent = "") const = 0;
    virtual void add(std::unique_ptr<FileSystemComponent> component) {
        throw std::runtime_error("Cannot add to leaf component");
    }
    virtual void remove(FileSystemComponent* component) {
        throw std::runtime_error("Cannot remove from leaf component");
    }
    virtual FileSystemComponent* getChild(int index) {
        throw std::runtime_error("Cannot get child from leaf component");
    }
};

// Leaf - File
class File : public FileSystemComponent {
private:
    std::string name;
    long size;

public:
    File(const std::string& name, long size) : name(name), size(size) {}
    
    std::string getName() const override {
        return name;
    }
    
    long getSize() const override {
        return size;
    }
    
    void display(const std::string& indent = "") const override {
        std::cout << indent << "📄 " << name << " (" << size << " bytes)" << std::endl;
    }
};

// Composite - Directory
class Directory : public FileSystemComponent {
private:
    std::string name;
    std::vector<std::unique_ptr<FileSystemComponent>> children;

public:
    Directory(const std::string& name) : name(name) {}
    
    std::string getName() const override {
        return name;
    }
    
    long getSize() const override {
        long totalSize = 0;
        for (const auto& child : children) {
            totalSize += child->getSize();
        }
        return totalSize;
    }
    
    void display(const std::string& indent = "") const override {
        std::cout << indent << "📁 " << name << " (" << getSize() << " bytes)" << std::endl;
        std::string newIndent = indent + "  ";
        for (const auto& child : children) {
            child->display(newIndent);
        }
    }
    
    void add(std::unique_ptr<FileSystemComponent> component) override {
        children.push_back(std::move(component));
    }
    
    void remove(FileSystemComponent* component) override {
        children.erase(
            std::remove_if(children.begin(), children.end(),
                [component](const std::unique_ptr<FileSystemComponent>& ptr) {
                    return ptr.get() == component;
                }),
            children.end()
        );
    }
    
    FileSystemComponent* getChild(int index) override {
        if (index >= 0 && index < children.size()) {
            return children[index].get();
        }
        return nullptr;
    }
    
    int getChildCount() const {
        return children.size();
    }
};

// Usage example
void fileSystemDemo() {
    std::cout << "=== Composite Pattern - File System ===" << std::endl;
    
    // Create files
    auto file1 = std::make_unique<File>("document.txt", 1500);
    auto file2 = std::make_unique<File>("image.jpg", 250000);
    auto file3 = std::make_unique<File>("notes.md", 800);
    auto file4 = std::make_unique<File>("data.csv", 3200);
    auto file5 = std::make_unique<File>("config.json", 1200);
    
    // Create directories
    auto rootDir = std::make_unique<Directory>("Root");
    auto documentsDir = std::make_unique<Directory>("Documents");
    auto imagesDir = std::make_unique<Directory>("Images");
    auto workDir = std::make_unique<Directory>("Work");
    
    // Build directory structure
    documentsDir->add(std::make_unique<File>("resume.pdf", 1800));
    documentsDir->add(std::move(file1));
    documentsDir->add(std::move(file3));
    
    imagesDir->add(std::move(file2));
    imagesDir->add(std::make_unique<File>("photo.png", 180000));
    
    workDir->add(std::move(file4));
    workDir->add(std::move(file5));
    workDir->add(std::make_unique<Directory>("Projects"));
    
    // Add subdirectories to root
    rootDir->add(std::move(documentsDir));
    rootDir->add(std::move(imagesDir));
    rootDir->add(std::move(workDir));
    
    // Display the entire file system
    std::cout << "\nFile System Structure:" << std::endl;
    rootDir->display();
    
    // Demonstrate uniform treatment
    std::cout << "\n=== Uniform Treatment Demo ===" << std::endl;
    std::vector<std::unique_ptr<FileSystemComponent>> components;
    components.push_back(std::make_unique<File>("single_file.exe", 5000));
    components.push_back(std::make_unique<Directory>("Empty Folder"));
    
    auto smallDir = std::make_unique<Directory>("Small Directory");
    smallDir->add(std::make_unique<File>("file1.txt", 100));
    smallDir->add(std::make_unique<File>("file2.txt", 200));
    components.push_back(std::move(smallDir));
    
    for (const auto& component : components) {
        std::cout << "\nComponent: " << component->getName() << std::endl;
        std::cout << "Size: " << component->getSize() << " bytes" << std::endl;
        component->display();
    }
}

int main() {
    fileSystemDemo();
    return 0;
}
```

#### Graphic System Composite Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <algorithm>

// Component interface
class Graphic {
public:
    virtual ~Graphic() = default;
    virtual void draw() const = 0;
    virtual void move(int x, int y) = 0;
    virtual void add(std::unique_ptr<Graphic> graphic) {
        throw std::runtime_error("Cannot add to primitive graphic");
    }
    virtual void remove(Graphic* graphic) {
        throw std::runtime_error("Cannot remove from primitive graphic");
    }
    virtual std::string getName() const = 0;
    virtual Graphic* getChild(int index) {
        throw std::runtime_error("Cannot get child from primitive graphic");
    }
};

// Leaf - Dot
class Dot : public Graphic {
private:
    int x, y;
    std::string name;

public:
    Dot(int x, int y, const std::string& name = "Dot") : x(x), y(y), name(name) {}
    
    void draw() const override {
        std::cout << "Drawing Dot at (" << x << ", " << y << ")" << std::endl;
    }
    
    void move(int x, int y) override {
        this->x += x;
        this->y += y;
        std::cout << "Moved Dot to (" << this->x << ", " << this->y << ")" << std::endl;
    }
    
    std::string getName() const override {
        return name;
    }
    
    int getX() const { return x; }
    int getY() const { return y; }
};

// Leaf - Circle
class Circle : public Graphic {
private:
    int x, y;
    int radius;
    std::string name;

public:
    Circle(int x, int y, int radius, const std::string& name = "Circle") 
        : x(x), y(y), radius(radius), name(name) {}
    
    void draw() const override {
        std::cout << "Drawing Circle at (" << x << ", " << y << ") with radius " << radius << std::endl;
    }
    
    void move(int x, int y) override {
        this->x += x;
        this->y += y;
        std::cout << "Moved Circle to (" << this->x << ", " << this->y << ")" << std::endl;
    }
    
    std::string getName() const override {
        return name;
    }
};

// Leaf - Rectangle
class Rectangle : public Graphic {
private:
    int x, y;
    int width, height;
    std::string name;

public:
    Rectangle(int x, int y, int width, int height, const std::string& name = "Rectangle") 
        : x(x), y(y), width(width), height(height), name(name) {}
    
    void draw() const override {
        std::cout << "Drawing Rectangle at (" << x << ", " << y 
                  << ") with size " << width << "x" << height << std::endl;
    }
    
    void move(int x, int y) override {
        this->x += x;
        this->y += y;
        std::cout << "Moved Rectangle to (" << this->x << ", " << this->y << ")" << std::endl;
    }
    
    std::string getName() const override {
        return name;
    }
};

// Composite - Compound Graphic
class CompoundGraphic : public Graphic {
private:
    std::vector<std::unique_ptr<Graphic>> children;
    std::string name;

public:
    CompoundGraphic(const std::string& name = "Compound Graphic") : name(name) {}
    
    void draw() const override {
        std::cout << "=== Drawing Compound Graphic: " << name << " ===" << std::endl;
        for (const auto& child : children) {
            child->draw();
        }
        std::cout << "=== Finished Drawing Compound Graphic ===" << std::endl;
    }
    
    void move(int x, int y) override {
        std::cout << "Moving all children in " << name << " by (" << x << ", " << y << ")" << std::endl;
        for (const auto& child : children) {
            child->move(x, y);
        }
    }
    
    std::string getName() const override {
        return name;
    }
    
    void add(std::unique_ptr<Graphic> graphic) override {
        children.push_back(std::move(graphic));
        std::cout << "Added " << children.back()->getName() << " to " << name << std::endl;
    }
    
    void remove(Graphic* graphic) override {
        auto it = std::find_if(children.begin(), children.end(),
            [graphic](const std::unique_ptr<Graphic>& ptr) {
                return ptr.get() == graphic;
            });
        
        if (it != children.end()) {
            std::cout << "Removed " << (*it)->getName() << " from " << name << std::endl;
            children.erase(it);
        }
    }
    
    Graphic* getChild(int index) override {
        if (index >= 0 && index < children.size()) {
            return children[index].get();
        }
        return nullptr;
    }
    
    size_t getChildCount() const {
        return children.size();
    }
    
    // Additional composite-specific operations
    void listChildren() const {
        std::cout << "Children of " << name << ":" << std::endl;
        for (size_t i = 0; i < children.size(); ++i) {
            std::cout << "  " << i + 1 << ". " << children[i]->getName() << std::endl;
        }
    }
};

// Graphic Editor using Composite pattern
class GraphicEditor {
private:
    std::vector<std::unique_ptr<Graphic>> graphics;

public:
    void addGraphic(std::unique_ptr<Graphic> graphic) {
        graphics.push_back(std::move(graphic));
    }
    
    void drawAll() {
        std::cout << "\n=== Drawing All Graphics ===" << std::endl;
        for (const auto& graphic : graphics) {
            graphic->draw();
            std::cout << std::endl;
        }
    }
    
    void moveAll(int x, int y) {
        std::cout << "\n=== Moving All Graphics by (" << x << ", " << y << ") ===" << std::endl;
        for (const auto& graphic : graphics) {
            graphic->move(x, y);
        }
    }
    
    void listAll() {
        std::cout << "\n=== All Graphics ===" << std::endl;
        for (size_t i = 0; i < graphics.size(); ++i) {
            std::cout << i + 1 << ". " << graphics[i]->getName() << std::endl;
        }
    }
};

// Usage example
void graphicSystemDemo() {
    std::cout << "=== Composite Pattern - Graphic System ===" << std::endl;
    
    GraphicEditor editor;
    
    // Create individual graphics
    auto dot1 = std::make_unique<Dot>(10, 20, "Red Dot");
    auto circle1 = std::make_unique<Circle>(50, 60, 15, "Blue Circle");
    auto rectangle1 = std::make_unique<Rectangle>(100, 150, 40, 30, "Green Rectangle");
    
    // Create compound graphics
    auto house = std::make_unique<CompoundGraphic>("House");
    house->add(std::make_unique<Rectangle>(0, 0, 100, 80, "House Base"));
    house->add(std::make_unique<Rectangle>(20, 0, 30, 50, "Door"));
    house->add(std::make_unique<Rectangle>(70, 20, 20, 20, "Window"));
    
    auto tree = std::make_unique<CompoundGraphic>("Tree");
    tree->add(std::make_unique<Rectangle>(45, 0, 10, 50, "Tree Trunk"));
    tree->add(std::make_unique<Circle>(50, -20, 25, "Tree Top"));
    
    auto scene = std::make_unique<CompoundGraphic>("Complete Scene");
    scene->add(std::make_unique<Dot>(5, 5, "Sun"));
    scene->add(std::move(house));
    scene->add(std::move(tree));
    
    // Add all graphics to editor
    editor.addGraphic(std::move(dot1));
    editor.addGraphic(std::move(circle1));
    editor.addGraphic(std::move(rectangle1));
    editor.addGraphic(std::move(scene));
    
    // Demonstrate operations
    editor.listAll();
    editor.drawAll();
    editor.moveAll(5, 10);
    editor.drawAll();
    
    // Demonstrate nested composites
    std::cout << "\n=== Nested Composites Demo ===" << std::endl;
    auto universe = std::make_unique<CompoundGraphic>("Universe");
    
    auto solarSystem = std::make_unique<CompoundGraphic>("Solar System");
    solarSystem->add(std::make_unique<Circle>(0, 0, 10, "Sun"));
    solarSystem->add(std::make_unique<Circle>(30, 0, 2, "Earth"));
    solarSystem->add(std::make_unique<Circle>(50, 0, 3, "Mars"));
    
    auto galaxy = std::make_unique<CompoundGraphic>("Galaxy");
    galaxy->add(std::move(solarSystem));
    galaxy->add(std::make_unique<Circle>(100, 100, 8, "Distant Star"));
    
    universe->add(std::move(galaxy));
    universe->add(std::make_unique<Dot>(-50, -50, "Distant Galaxy"));
    
    universe->draw();
}

int main() {
    graphicSystemDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Component interface
typedef struct Employee {
    char name[50];
    char position[50];
    double salary;
    
    void (*print)(struct Employee* self, int depth);
    void (*add)(struct Employee* self, struct Employee* subordinate);
    void (*remove)(struct Employee* self, struct Employee* subordinate);
    double (*get_total_salary)(struct Employee* self);
    int (*get_subordinate_count)(struct Employee* self);
} Employee;

// Leaf - Individual Employee
typedef struct {
    Employee base;
} IndividualEmployee;

void individual_print(Employee* self, int depth) {
    for (int i = 0; i < depth; i++) printf("  ");
    printf("👤 %s - %s ($%.2f)\n", self->name, self->position, self->salary);
}

void individual_add(Employee* self, Employee* subordinate) {
    printf("Cannot add subordinates to individual employee %s\n", self->name);
}

void individual_remove(Employee* self, Employee* subordinate) {
    printf("Cannot remove subordinates from individual employee %s\n", self->name);
}

double individual_get_total_salary(Employee* self) {
    return self->salary;
}

int individual_get_subordinate_count(Employee* self) {
    return 0;
}

IndividualEmployee* create_individual_employee(const char* name, const char* position, double salary) {
    IndividualEmployee* employee = malloc(sizeof(IndividualEmployee));
    strcpy(employee->base.name, name);
    strcpy(employee->base.position, position);
    employee->base.salary = salary;
    employee->base.print = individual_print;
    employee->base.add = individual_add;
    employee->base.remove = individual_remove;
    employee->base.get_total_salary = individual_get_total_salary;
    employee->base.get_subordinate_count = individual_get_subordinate_count;
    return employee;
}

// Composite - Manager
typedef struct {
    Employee base;
    Employee** subordinates;
    int subordinate_count;
    int capacity;
} Manager;

void manager_print(Employee* self, int depth) {
    Manager* manager = (Manager*)self;
    
    for (int i = 0; i < depth; i++) printf("  ");
    printf("👨‍💼 %s - %s ($%.2f) [%d subordinates]\n", 
           self->name, self->position, self->salary, manager->subordinate_count);
    
    for (int i = 0; i < manager->subordinate_count; i++) {
        manager->subordinates[i]->print(manager->subordinates[i], depth + 1);
    }
}

void manager_add(Employee* self, Employee* subordinate) {
    Manager* manager = (Manager*)self;
    
    // Resize array if needed
    if (manager->subordinate_count >= manager->capacity) {
        manager->capacity = manager->capacity == 0 ? 4 : manager->capacity * 2;
        manager->subordinates = realloc(manager->subordinates, 
                                      manager->capacity * sizeof(Employee*));
    }
    
    manager->subordinates[manager->subordinate_count++] = subordinate;
    printf("Added %s to %s's team\n", subordinate->name, self->name);
}

void manager_remove(Employee* self, Employee* subordinate) {
    Manager* manager = (Manager*)self;
    
    for (int i = 0; i < manager->subordinate_count; i++) {
        if (manager->subordinates[i] == subordinate) {
            // Shift remaining elements
            for (int j = i; j < manager->subordinate_count - 1; j++) {
                manager->subordinates[j] = manager->subordinates[j + 1];
            }
            manager->subordinate_count--;
            printf("Removed %s from %s's team\n", subordinate->name, self->name);
            return;
        }
    }
    printf("Employee %s not found in %s's team\n", subordinate->name, self->name);
}

double manager_get_total_salary(Employee* self) {
    Manager* manager = (Manager*)self;
    double total = self->salary;
    
    for (int i = 0; i < manager->subordinate_count; i++) {
        total += manager->subordinates[i]->get_total_salary(manager->subordinates[i]);
    }
    
    return total;
}

int manager_get_subordinate_count(Employee* self) {
    Manager* manager = (Manager*)self;
    return manager->subordinate_count;
}

Manager* create_manager(const char* name, const char* position, double salary) {
    Manager* manager = malloc(sizeof(Manager));
    strcpy(manager->base.name, name);
    strcpy(manager->base.position, position);
    manager->base.salary = salary;
    manager->base.print = manager_print;
    manager->base.add = manager_add;
    manager->base.remove = manager_remove;
    manager->base.get_total_salary = manager_get_total_salary;
    manager->base.get_subordinate_count = manager_get_subordinate_count;
    manager->subordinates = NULL;
    manager->subordinate_count = 0;
    manager->capacity = 0;
    return manager;
}

void destroy_employee(Employee* employee) {
    // For managers, we need to handle subordinate array
    if (employee->get_subordinate_count(employee) > 0) {
        Manager* manager = (Manager*)employee;
        free(manager->subordinates);
    }
    free(employee);
}

// Department structure using Composite pattern
typedef struct {
    char name[50];
    Employee** employees;
    int employee_count;
    int capacity;
} Department;

void department_add_employee(Department* dept, Employee* employee) {
    if (dept->employee_count >= dept->capacity) {
        dept->capacity = dept->capacity == 0 ? 4 : dept->capacity * 2;
        dept->employees = realloc(dept->employees, dept->capacity * sizeof(Employee*));
    }
    
    dept->employees[dept->employee_count++] = employee;
}

void department_print(Department* dept) {
    printf("\n=== Department: %s ===\n", dept->name);
    printf("Total Employees: %d\n", dept->employee_count);
    printf("Organization Structure:\n");
    
    for (int i = 0; i < dept->employee_count; i++) {
        dept->employees[i]->print(dept->employees[i], 0);
    }
}

double department_get_total_salary(Department* dept) {
    double total = 0;
    for (int i = 0; i < dept->employee_count; i++) {
        total += dept->employees[i]->get_total_salary(dept->employees[i]);
    }
    return total;
}

// Demo function
void organization_demo() {
    printf("=== Composite Pattern - Organization Structure ===\n");
    
    // Create individual employees
    Employee* dev1 = (Employee*)create_individual_employee("Alice", "Senior Developer", 95000);
    Employee* dev2 = (Employee*)create_individual_employee("Bob", "Junior Developer", 75000);
    Employee* dev3 = (Employee*)create_individual_employee("Charlie", "Developer", 85000);
    Employee* tester1 = (Employee*)create_individual_employee("Diana", "QA Engineer", 80000);
    Employee* designer1 = (Employee*)create_individual_employee("Eve", "UI/UX Designer", 90000);
    
    // Create managers
    Manager* devManager = create_manager("Frank", "Development Manager", 120000);
    Manager* qaManager = create_manager("Grace", "QA Manager", 110000);
    Manager* designManager = create_manager("Henry", "Design Manager", 115000);
    Manager* cto = create_manager("Ivan", "CTO", 200000);
    
    // Build organization structure
    devManager->base.add((Employee*)devManager, dev1);
    devManager->base.add((Employee*)devManager, dev2);
    devManager->base.add((Employee*)devManager, dev3);
    
    qaManager->base.add((Employee*)qaManager, tester1);
    designManager->base.add((Employee*)designManager, designer1);
    
    cto->base.add((Employee*)cto, (Employee*)devManager);
    cto->base.add((Employee*)cto, (Employee*)qaManager);
    cto->base.add((Employee*)cto, (Employee*)designManager);
    
    // Create department
    Department engineering;
    strcpy(engineering.name, "Engineering");
    engineering.employees = NULL;
    engineering.employee_count = 0;
    engineering.capacity = 0;
    
    department_add_employee(&engineering, (Employee*)cto);
    
    // Display organization
    department_print(&engineering);
    
    // Display statistics
    printf("\n=== Department Statistics ===\n");
    printf("Total Salary Budget: $%.2f\n", department_get_total_salary(&engineering));
    printf("CTO's Team Size: %d\n", cto->base.get_subordinate_count((Employee*)cto));
    printf("Development Team Size: %d\n", devManager->base.get_subordinate_count((Employee*)devManager));
    
    // Demonstrate uniform treatment
    printf("\n=== Uniform Treatment Demo ===\n");
    Employee* employees[] = {dev1, (Employee*)devManager, (Employee*)cto};
    int num_employees = sizeof(employees) / sizeof(employees[0]);
    
    for (int i = 0; i < num_employees; i++) {
        printf("\nEmployee: %s\n", employees[i]->name);
        printf("Position: %s\n", employees[i]->position);
        printf("Salary: $%.2f\n", employees[i]->salary);
        printf("Total Team Salary: $%.2f\n", employees[i]->get_total_salary(employees[i]));
        printf("Subordinate Count: %d\n", employees[i]->get_subordinate_count(employees[i]));
        printf("Structure:\n");
        employees[i]->print(employees[i], 1);
    }
    
    // Cleanup
    destroy_employee(dev1);
    destroy_employee(dev2);
    destroy_employee(dev3);
    destroy_employee(tester1);
    destroy_employee(designer1);
    destroy_employee((Employee*)devManager);
    destroy_employee((Employee*)qaManager);
    destroy_employee((Employee*)designManager);
    destroy_employee((Employee*)cto);
    free(engineering.employees);
}

int main() {
    organization_demo();
    return 0;
}
```

### Python Implementation

#### Menu System Composite Example

```python
from abc import ABC, abstractmethod
from typing import List, Optional
from dataclasses import dataclass

# Component interface
class MenuComponent(ABC):
    @abstractmethod
    def get_name(self) -> str: ...
    
    @abstractmethod
    def get_description(self) -> str: ...
    
    @abstractmethod
    def get_price(self) -> float: ...
    
    @abstractmethod
    def is_vegetarian(self) -> bool: ...
    
    @abstractmethod
    def print(self, indent: str = "") -> None: ...
    
    def add(self, component: 'MenuComponent') -> None:
        raise NotImplementedError("Cannot add to leaf component")
    
    def remove(self, component: 'MenuComponent') -> None:
        raise NotImplementedError("Cannot remove from leaf component")
    
    def get_child(self, index: int) -> Optional['MenuComponent']:
        raise NotImplementedError("Cannot get child from leaf component")

# Leaf - Menu Item
class MenuItem(MenuComponent):
    def __init__(self, name: str, description: str, price: float, vegetarian: bool = False):
        self._name = name
        self._description = description
        self._price = price
        self._vegetarian = vegetarian
    
    def get_name(self) -> str:
        return self._name
    
    def get_description(self) -> str:
        return self._description
    
    def get_price(self) -> float:
        return self._price
    
    def is_vegetarian(self) -> bool:
        return self._vegetarian
    
    def print(self, indent: str = "") -> None:
        veg_symbol = "🌱" if self._vegetarian else "🍖"
        print(f"{indent}{veg_symbol} {self._name} - ${self._price:.2f}")
        print(f"{indent}  {self._description}")

# Composite - Menu
class Menu(MenuComponent):
    def __init__(self, name: str, description: str):
        self._name = name
        self._description = description
        self._children: List[MenuComponent] = []
    
    def get_name(self) -> str:
        return self._name
    
    def get_description(self) -> str:
        return self._description
    
    def get_price(self) -> float:
        # Menus don't have prices themselves
        raise NotImplementedError("Menu doesn't have a price")
    
    def is_vegetarian(self) -> bool:
        # Menus aren't vegetarian or non-vegetarian
        raise NotImplementedError("Menu doesn't have vegetarian status")
    
    def print(self, indent: str = "") -> None:
        print(f"{indent}📋 {self._name} - {self._description}")
        print(f"{indent}{'=' * (len(self._name) + len(self._description) + 3)}")
        
        new_indent = indent + "  "
        for child in self._children:
            child.print(new_indent)
    
    def add(self, component: MenuComponent) -> None:
        self._children.append(component)
    
    def remove(self, component: MenuComponent) -> None:
        self._children.remove(component)
    
    def get_child(self, index: int) -> Optional[MenuComponent]:
        if 0 <= index < len(self._children):
            return self._children[index]
        return None
    
    def get_children_count(self) -> int:
        return len(self._children)
    
    # Menu-specific operations
    def get_vegetarian_items(self) -> List[MenuItem]:
        vegetarian_items = []
        for child in self._children:
            if isinstance(child, MenuItem) and child.is_vegetarian():
                vegetarian_items.append(child)
            elif isinstance(child, Menu):
                vegetarian_items.extend(child.get_vegetarian_items())
        return vegetarian_items
    
    def find_item(self, name: str) -> Optional[MenuItem]:
        for child in self._children:
            if isinstance(child, MenuItem) and child.get_name().lower() == name.lower():
                return child
            elif isinstance(child, Menu):
                found = child.find_item(name)
                if found:
                    return found
        return None

# Waitress class that works with the composite structure
class Waitress:
    def __init__(self, menu: MenuComponent):
        self._menu = menu
    
    def print_menu(self) -> None:
        print("=== RESTAURANT MENU ===")
        self._menu.print()
    
    def print_vegetarian_menu(self) -> None:
        print("=== VEGETARIAN MENU ===")
        vegetarian_items = self._get_vegetarian_items(self._menu)
        for item in vegetarian_items:
            item.print("  ")
    
    def _get_vegetarian_items(self, component: MenuComponent) -> List[MenuItem]:
        items = []
        if isinstance(component, MenuItem) and component.is_vegetarian():
            items.append(component)
        elif isinstance(component, Menu):
            for child in component._children:
                items.extend(self._get_vegetarian_items(child))
        return items
    
    def find_dish(self, name: str) -> None:
        item = self._find_item_in_component(self._menu, name)
        if item:
            print(f"Found: ", end="")
            item.print()
        else:
            print(f"Dish '{name}' not found")
    
    def _find_item_in_component(self, component: MenuComponent, name: str) -> Optional[MenuItem]:
        if isinstance(component, MenuItem) and component.get_name().lower() == name.lower():
            return component
        elif isinstance(component, Menu):
            for child in component._children:
                found = self._find_item_in_component(child, name)
                if found:
                    return found
        return None

# Demo function
def restaurant_menu_demo():
    print("=== Composite Pattern - Restaurant Menu System ===\n")
    
    # Create main menu
    main_menu = Menu("Main Menu", "All our delicious offerings")
    
    # Create breakfast menu
    breakfast_menu = Menu("Breakfast Menu", "Start your day right")
    breakfast_menu.add(MenuItem("Pancakes", "Fluffy buttermilk pancakes with maple syrup", 8.99, True))
    breakfast_menu.add(MenuItem("Eggs Benedict", "Poached eggs on English muffin with hollandaise", 12.99))
    breakfast_menu.add(MenuItem("Oatmeal", "Steel-cut oats with berries and honey", 6.99, True))
    
    # Create lunch menu
    lunch_menu = Menu("Lunch Menu", "Midday delights")
    lunch_menu.add(MenuItem("Caesar Salad", "Fresh romaine with Caesar dressing and croutons", 10.99))
    lunch_menu.add(MenuItem("Veggie Burger", "Plant-based patty with avocado and sprouts", 11.99, True))
    lunch_menu.add(MenuItem("Club Sandwich", "Triple-decker turkey sandwich with bacon", 13.99))
    
    # Create dinner menu
    dinner_menu = Menu("Dinner Menu", "Evening specialties")
    dinner_menu.add(MenuItem("Steak", "Grilled ribeye with mashed potatoes", 24.99))
    dinner_menu.add(MenuItem("Salmon", "Baked salmon with lemon butter sauce", 22.99))
    dinner_menu.add(MenuItem("Pasta Primavera", "Fresh pasta with seasonal vegetables", 16.99, True))
    
    # Create dessert menu
    dessert_menu = Menu("Dessert Menu", "Sweet endings")
    dessert_menu.add(MenuItem("Chocolate Cake", "Rich chocolate layer cake", 7.99, True))
    dessert_menu.add(MenuItem("Cheesecake", "New York style cheesecake with berry sauce", 8.99))
    dessert_menu.add(MenuItem("Ice Cream", "Vanilla bean ice cream with hot fudge", 6.99, True))
    
    # Create beverage menu
    beverage_menu = Menu("Beverage Menu", "Thirst quenchers")
    beverage_menu.add(MenuItem("Coffee", "Freshly brewed coffee", 2.99, True))
    beverage_menu.add(MenuItem("Fresh Juice", "Orange, apple, or carrot juice", 4.99, True))
    beverage_menu.add(MenuItem("Soda", "Coke, Pepsi, or Sprite", 2.49, True))
    
    # Build menu hierarchy
    main_menu.add(breakfast_menu)
    main_menu.add(lunch_menu)
    main_menu.add(dinner_menu)
    main_menu.add(dessert_menu)
    main_menu.add(beverage_menu)
    
    # Create waitress and demonstrate
    waitress = Waitress(main_menu)
    
    # Print entire menu
    waitress.print_menu()
    
    # Print vegetarian options
    print("\n")
    waitress.print_vegetarian_menu()
    
    # Search for dishes
    print("\n")
    waitress.find_dish("pancakes")
    waitress.find_dish("steak")
    waitress.find_dish("pizza")  # Not in menu
    
    # Demonstrate uniform treatment
    print("\n=== Uniform Treatment Demo ===")
    menu_components = [
        MenuItem("Test Item", "A test menu item", 9.99),
        Menu("Test Menu", "A test menu")
    ]
    
    for component in menu_components:
        print(f"\nComponent: {component.get_name()}")
        try:
            component.print("  ")
        except Exception as e:
            print(f"  Cannot print: {e}")

if __name__ == "__main__":
    restaurant_menu_demo()
```

#### UI Components Composite Example

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from dataclasses import dataclass
from enum import Enum

class Alignment(Enum):
    LEFT = "left"
    CENTER = "center"
    RIGHT = "right"
    JUSTIFY = "justify"

# Component interface
class UIComponent(ABC):
    @abstractmethod
    def render(self, indent: str = "") -> None: ...
    
    @abstractmethod
    def get_name(self) -> str: ...
    
    @abstractmethod
    def get_width(self) -> int: ...
    
    @abstractmethod
    def get_height(self) -> int: ...
    
    def add(self, component: 'UIComponent') -> None:
        raise NotImplementedError("Cannot add to leaf component")
    
    def remove(self, component: 'UIComponent') -> None:
        raise NotImplementedError("Cannot remove from leaf component")
    
    def get_child(self, index: int) -> 'UIComponent':
        raise NotImplementedError("Cannot get child from leaf component")
    
    def handle_event(self, event: str) -> bool:
        return False

# Leaf components
class Button(UIComponent):
    def __init__(self, name: str, text: str, width: int = 100, height: int = 30):
        self._name = name
        self._text = text
        self._width = width
        self._height = height
        self._enabled = True
    
    def render(self, indent: str = "") -> None:
        status = "ENABLED" if self._enabled else "DISABLED"
        print(f"{indent}[{self._text}] ({self._width}x{self._height}) - {status}")
    
    def get_name(self) -> str:
        return self._name
    
    def get_width(self) -> int:
        return self._width
    
    def get_height(self) -> int:
        return self._height
    
    def handle_event(self, event: str) -> bool:
        if event == "click" and self._enabled:
            print(f"Button '{self._text}' clicked!")
            return True
        return False
    
    def set_enabled(self, enabled: bool) -> None:
        self._enabled = enabled

class TextField(UIComponent):
    def __init__(self, name: str, placeholder: str = "", width: int = 200, height: int = 25):
        self._name = name
        self._placeholder = placeholder
        self._width = width
        self._height = height
        self._text = ""
    
    def render(self, indent: str = "") -> None:
        display_text = self._text if self._text else self._placeholder
        print(f"{indent}[{display_text}] ({self._width}x{self._height})")
    
    def get_name(self) -> str:
        return self._name
    
    def get_width(self) -> int:
        return self._width
    
    def get_height(self) -> int:
        return self._height
    
    def handle_event(self, event: str) -> bool:
        if event.startswith("text_input:"):
            self._text = event.split(":", 1)[1]
            print(f"TextField updated: '{self._text}'")
            return True
        return False
    
    def get_text(self) -> str:
        return self._text

class Label(UIComponent):
    def __init__(self, name: str, text: str, alignment: Alignment = Alignment.LEFT):
        self._name = name
        self._text = text
        self._alignment = alignment
        self._width = len(text) * 8  # Approximate width based on text length
        self._height = 20
    
    def render(self, indent: str = "") -> None:
        align_symbol = {
            Alignment.LEFT: "←",
            Alignment.CENTER: "↔",
            Alignment.RIGHT: "→",
            Alignment.JUSTIFY: "⇄"
        }[self._alignment]
        print(f"{indent}{align_symbol} {self._text}")
    
    def get_name(self) -> str:
        return self._name
    
    def get_width(self) -> int:
        return self._width
    
    def get_height(self) -> int:
        return self._height

class Checkbox(UIComponent):
    def __init__(self, name: str, text: str, checked: bool = False):
        self._name = name
        self._text = text
        self._checked = checked
        self._width = len(text) * 8 + 20
        self._height = 20
    
    def render(self, indent: str = "") -> None:
        status = "☑" if self._checked else "☐"
        print(f"{indent}{status} {self._text}")
    
    def get_name(self) -> str:
        return self._name
    
    def get_width(self) -> int:
        return self._width
    
    def get_height(self) -> int:
        return self._height
    
    def handle_event(self, event: str) -> bool:
        if event == "toggle":
            self._checked = not self._checked
            status = "checked" if self._checked else "unchecked"
            print(f"Checkbox '{self._text}' {status}")
            return True
        return False
    
    def is_checked(self) -> bool:
        return self._checked

# Composite components
class Panel(UIComponent):
    def __init__(self, name: str, title: str = "", width: int = 300, height: int = 200):
        self._name = name
        self._title = title
        self._width = width
        self._height = height
        self._children: List[UIComponent] = []
        self._visible = True
    
    def render(self, indent: str = "") -> None:
        if not self._visible:
            return
            
        border = "=" * (len(self._title) + 4) if self._title else "=" * 20
        print(f"{indent}{border}")
        if self._title:
            print(f"{indent}= {self._title} =")
            print(f"{indent}{border}")
        
        new_indent = indent + "  "
        for child in self._children:
            child.render(new_indent)
        
        print(f"{indent}{border}")
    
    def get_name(self) -> str:
        return self._name
    
    def get_width(self) -> int:
        return self._width
    
    def get_height(self) -> int:
        return self._height
    
    def add(self, component: UIComponent) -> None:
        self._children.append(component)
    
    def remove(self, component: UIComponent) -> None:
        self._children.remove(component)
    
    def get_child(self, index: int) -> UIComponent:
        return self._children[index]
    
    def get_children_count(self) -> int:
        return len(self._children)
    
    def handle_event(self, event: str) -> bool:
        # Propagate event to children
        handled = False
        for child in self._children:
            if child.handle_event(event):
                handled = True
        return handled
    
    def set_visible(self, visible: bool) -> None:
        self._visible = visible

class Form(Panel):
    def __init__(self, name: str, title: str = "Form"):
        super().__init__(name, title, 400, 300)
        self._fields: Dict[str, UIComponent] = {}
    
    def add_field(self, component: UIComponent) -> None:
        self.add(component)
        self._fields[component.get_name()] = component
    
    def get_field_value(self, field_name: str) -> Any:
        field = self._fields.get(field_name)
        if isinstance(field, TextField):
            return field.get_text()
        elif isinstance(field, Checkbox):
            return field.is_checked()
        return None
    
    def submit(self) -> Dict[str, Any]:
        print(f"\n=== Form '{self._title}' Submitted ===")
        data = {}
        for name, field in self._fields.items():
            value = self.get_field_value(name)
            data[name] = value
            print(f"  {name}: {value}")
        return data

class Window(UIComponent):
    def __init__(self, name: str, title: str, width: int = 800, height: int = 600):
        self._name = name
        self._title = title
        self._width = width
        self._height = height
        self._children: List[UIComponent] = []
        self._maximized = False
    
    def render(self, indent: str = "") -> None:
        width = self._width if not self._maximized else "MAXIMIZED"
        print(f"{indent}┌{'─' * (len(self._title) + 2)}┐")
        print(f"{indent}│ {self._title} │")
        print(f"{indent}└{'─' * (len(self._title) + 2)}┘")
        print(f"{indent}Size: {width}x{self._height}")
        
        new_indent = indent + "  "
        for child in self._children:
            child.render(new_indent)
    
    def get_name(self) -> str:
        return self._name
    
    def get_width(self) -> int:
        return self._width if not self._maximized else 1920  # Assume full screen
    
    def get_height(self) -> int:
        return self._height if not self._maximized else 1080  # Assume full screen
    
    def add(self, component: UIComponent) -> None:
        self._children.append(component)
    
    def remove(self, component: UIComponent) -> None:
        self._children.remove(component)
    
    def get_child(self, index: int) -> UIComponent:
        return self._children[index]
    
    def handle_event(self, event: str) -> bool:
        if event == "maximize":
            self._maximized = not self._maximized
            status = "maximized" if self._maximized else "restored"
            print(f"Window '{self._title}' {status}")
            return True
        
        # Propagate to children
        handled = False
        for child in self._children:
            if child.handle_event(event):
                handled = True
        return handled

# UI Application using Composite pattern
class UIApplication:
    def __init__(self, name: str):
        self._name = name
        self._windows: List[Window] = []
    
    def add_window(self, window: Window) -> None:
        self._windows.append(window)
    
    def render(self) -> None:
        print(f"=== {self._name} ===")
        for window in self._windows:
            window.render()
            print()
    
    def handle_event(self, event: str) -> None:
        print(f"\nHandling event: {event}")
        handled = False
        for window in self._windows:
            if window.handle_event(event):
                handled = True
        if not handled:
            print(f"Event '{event}' not handled by any component")

# Demo function
def ui_system_demo():
    print("=== Composite Pattern - UI System ===\n")
    
    # Create application
    app = UIApplication("My Application")
    
    # Create login window
    login_window = Window("login_window", "Login", 400, 300)
    
    login_form = Form("login_form", "Please Login")
    login_form.add_field(Label("username_label", "Username:"))
    login_form.add_field(TextField("username_field", "Enter username"))
    login_form.add_field(Label("password_label", "Password:"))
    login_form.add_field(TextField("password_field", "Enter password"))
    login_form.add_field(Checkbox("remember_me", "Remember me"))
    login_form.add_field(Button("login_button", "Login"))
    login_form.add_field(Button("cancel_button", "Cancel"))
    
    login_window.add(login_form)
    
    # Create main application window
    main_window = Window("main_window", "Main Application", 800, 600)
    
    # Create toolbar
    toolbar = Panel("toolbar", "Toolbar", 800, 50)
    toolbar.add(Button("new_btn", "New"))
    toolbar.add(Button("open_btn", "Open"))
    toolbar.add(Button("save_btn", "Save"))
    toolbar.add(Button("print_btn", "Print"))
    
    # Create sidebar
    sidebar = Panel("sidebar", "Navigation", 200, 500)
    sidebar.add(Button("home_btn", "Home"))
    sidebar.add(Button("profile_btn", "Profile"))
    sidebar.add(Button("settings_btn", "Settings"))
    sidebar.add(Button("help_btn", "Help"))
    
    # Create content area
    content = Panel("content", "Content", 580, 500)
    content.add(Label("welcome_label", "Welcome to the Application!", Alignment.CENTER))
    content.add(TextField("search_field", "Search...", 300, 30))
    content.add(Button("search_btn", "Search"))
    
    # Add panels to main window
    main_window.add(toolbar)
    main_window.add(sidebar)
    main_window.add(content)
    
    # Add windows to application
    app.add_window(login_window)
    app.add_window(main_window)
    
    # Render the application
    app.render()
    
    # Demonstrate event handling
    print("\n=== Event Handling Demo ===")
    app.handle_event("click")  # Click login button
    app.handle_event("text_input:john_doe")  # Input text
    app.handle_event("toggle")  # Toggle checkbox
    app.handle_event("maximize")  # Maximize window
    
    # Demonstrate form submission
    print("\n=== Form Interaction ===")
    # Simulate user interaction
    login_form.get_child(1).handle_event("text_input:john_doe")  # Username
    login_form.get_child(3).handle_event("text_input:password123")  # Password
    login_form.get_child(4).handle_event("toggle")  # Remember me
    login_form.submit()
    
    # Demonstrate uniform treatment
    print("\n=== Uniform Treatment ===")
    components = [
        Button("test_btn", "Test Button"),
        Panel("test_panel", "Test Panel"),
        login_form
    ]
    
    for component in components:
        print(f"\nComponent: {component.get_name()}")
        print(f"Size: {component.get_width()}x{component.get_height()}")
        component.render("  ")
        print(f"Handles click: {component.handle_event('click')}")

if __name__ == "__main__":
    ui_system_demo()
```

## Advantages and Disadvantages

### Advantages

- **Uniform Treatment**: Clients can treat individual objects and compositions uniformly
- **Simplified Client Code**: Clients don't need to know if they're dealing with leaf or composite nodes
- **Easy to Add New Components**: New component types can be added easily
- **Flexible Structure**: Tree structures can be built and modified dynamically
- **Recursive Operations**: Operations can be applied recursively over the entire structure

### Disadvantages

- **Overgeneralization**: Might make the design overly general and harder to understand
- **Type Safety**: May compromise type safety in statically typed languages
- **Performance**: Can be less efficient than specialized solutions for specific cases
- **Complexity**: Can make the system more complex than necessary for simple hierarchies

## Best Practices

1. **Use for True Hierarchies**: Only use when you have genuine part-whole relationships
2. **Keep Interface Minimal**: Component interface should be as small as possible
3. **Handle Leaf Operations Gracefully**: Provide reasonable defaults for leaf-specific operations in composites
4. **Consider Caching**: Cache computed values in composites for better performance
5. **Use Transparently**: Design so clients don't need to distinguish between leaves and composites

## Composite vs Other Patterns

- **vs Decorator**: Composite builds tree structures, Decorator adds responsibilities to objects
- **vs Iterator**: Composite can work with iterators to traverse the tree structure
- **vs Visitor**: Composite can work with visitors to perform operations on the tree
- **vs Builder**: Composite structures can be built using builders

The Composite pattern is particularly useful when you need to represent part-whole hierarchies, when you want clients to ignore differences between individual objects and compositions, and when you need to apply operations recursively over object hierarchies.