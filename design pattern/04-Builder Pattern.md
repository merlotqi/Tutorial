# Builder Pattern

## Introduction

The Builder pattern is a creational design pattern that separates the construction of a complex object from its representation, allowing the same construction process to create different representations.

### Key Characteristics
- **Step-by-step construction**: Breaks down object creation into discrete steps
- **Flexible representation**: Same construction process can create different representations
- **Isolated complexity**: Construction logic is separated from the actual object
- **Fluent interface**: Often uses method chaining for readable code

### Use Cases
- When creating complex objects with many optional parameters
- When the construction process should allow different representations of the object
- When you want to avoid telescoping constructors (constructors with many parameters)
- When you need to create objects step by step, possibly with variations

## Implementation Examples

### C++ Implementation

#### Basic Builder Pattern
```cpp
#include <iostream>
#include <string>
#include <vector>
#include <memory>

// Product class
class Computer {
private:
    std::string cpu;
    std::string ram;
    std::string storage;
    std::string gpu;
    bool bluetooth;
    bool wifi;

public:
    Computer(const std::string& cpu, const std::string& ram, 
             const std::string& storage, const std::string& gpu = "",
             bool bluetooth = false, bool wifi = false)
        : cpu(cpu), ram(ram), storage(storage), gpu(gpu),
          bluetooth(bluetooth), wifi(wifi) {}

    void display() const {
        std::cout << "Computer Configuration:\n";
        std::cout << "  CPU: " << cpu << "\n";
        std::cout << "  RAM: " << ram << "\n";
        std::cout << "  Storage: " << storage << "\n";
        if (!gpu.empty()) {
            std::cout << "  GPU: " << gpu << "\n";
        }
        std::cout << "  Bluetooth: " << (bluetooth ? "Yes" : "No") << "\n";
        std::cout << "  WiFi: " << (wifi ? "Yes" : "No") << "\n";
    }
};

// Abstract Builder
class ComputerBuilder {
public:
    virtual ~ComputerBuilder() = default;
    virtual void setCPU(const std::string& cpu) = 0;
    virtual void setRAM(const std::string& ram) = 0;
    virtual void setStorage(const std::string& storage) = 0;
    virtual void setGPU(const std::string& gpu) = 0;
    virtual void setBluetooth(bool enabled) = 0;
    virtual void setWifi(bool enabled) = 0;
    virtual Computer* getResult() = 0;
};

// Concrete Builder
class ConcreteComputerBuilder : public ComputerBuilder {
private:
    std::string cpu;
    std::string ram;
    std::string storage;
    std::string gpu;
    bool bluetooth = false;
    bool wifi = false;

public:
    void setCPU(const std::string& cpu) override {
        this->cpu = cpu;
    }

    void setRAM(const std::string& ram) override {
        this->ram = ram;
    }

    void setStorage(const std::string& storage) override {
        this->storage = storage;
    }

    void setGPU(const std::string& gpu) override {
        this->gpu = gpu;
    }

    void setBluetooth(bool enabled) override {
        this->bluetooth = enabled;
    }

    void setWifi(bool enabled) override {
        this->wifi = enabled;
    }

    Computer* getResult() override {
        return new Computer(cpu, ram, storage, gpu, bluetooth, wifi);
    }
};

// Director
class ComputerEngineer {
private:
    ComputerBuilder* builder;

public:
    void setBuilder(ComputerBuilder* builder) {
        this->builder = builder;
    }

    void buildGamingComputer() {
        builder->setCPU("Intel i9-13900K");
        builder->setRAM("32GB DDR5");
        builder->setStorage("2TB NVMe SSD");
        builder->setGPU("NVIDIA RTX 4090");
        builder->setBluetooth(true);
        builder->setWifi(true);
    }

    void buildOfficeComputer() {
        builder->setCPU("Intel i5-12400");
        builder->setRAM("16GB DDR4");
        builder->setStorage("512GB SSD");
        builder->setBluetooth(true);
        builder->setWifi(true);
    }

    void buildBudgetComputer() {
        builder->setCPU("AMD Ryzen 5 5600G");
        builder->setRAM("8GB DDR4");
        builder->setStorage("256GB SSD");
        // No dedicated GPU, using integrated graphics
    }
};

// Usage example
int main() {
    ConcreteComputerBuilder builder;
    ComputerEngineer engineer;

    // Build a gaming computer
    engineer.setBuilder(&builder);
    engineer.buildGamingComputer();
    Computer* gamingPC = builder.getResult();
    gamingPC->display();
    std::cout << "\n";

    // Build an office computer
    engineer.buildOfficeComputer();
    Computer* officePC = builder.getResult();
    officePC->display();
    std::cout << "\n";

    delete gamingPC;
    delete officePC;

    return 0;
}
```

#### Fluent Builder Pattern
```cpp
#include <iostream>
#include <string>
#include <memory>

// Product
class Pizza {
private:
    std::string size;
    std::string crust;
    bool cheese;
    bool pepperoni;
    bool mushrooms;
    bool onions;
    bool bacon;

public:
    Pizza(const std::string& size, const std::string& crust)
        : size(size), crust(crust), cheese(false), pepperoni(false),
          mushrooms(false), onions(false), bacon(false) {}

    void setCheese(bool value) { cheese = value; }
    void setPepperoni(bool value) { pepperoni = value; }
    void setMushrooms(bool value) { mushrooms = value; }
    void setOnions(bool value) { onions = value; }
    void setBacon(bool value) { bacon = value; }

    void display() const {
        std::cout << "Pizza Order:\n";
        std::cout << "  Size: " << size << "\n";
        std::cout << "  Crust: " << crust << "\n";
        std::cout << "  Toppings:\n";
        if (cheese) std::cout << "    - Cheese\n";
        if (pepperoni) std::cout << "    - Pepperoni\n";
        if (mushrooms) std::cout << "    - Mushrooms\n";
        if (onions) std::cout << "    - Onions\n";
        if (bacon) std::cout << "    - Bacon\n";
    }
};

// Fluent Builder
class PizzaBuilder {
private:
    std::string size;
    std::string crust;
    bool cheese = false;
    bool pepperoni = false;
    bool mushrooms = false;
    bool onions = false;
    bool bacon = false;

public:
    PizzaBuilder& setSize(const std::string& size) {
        this->size = size;
        return *this;
    }

    PizzaBuilder& setCrust(const std::string& crust) {
        this->crust = crust;
        return *this;
    }

    PizzaBuilder& addCheese() {
        this->cheese = true;
        return *this;
    }

    PizzaBuilder& addPepperoni() {
        this->pepperoni = true;
        return *this;
    }

    PizzaBuilder& addMushrooms() {
        this->mushrooms = true;
        return *this;
    }

    PizzaBuilder& addOnions() {
        this->onions = true;
        return *this;
    }

    PizzaBuilder& addBacon() {
        this->bacon = true;
        return *this;
    }

    Pizza* build() {
        Pizza* pizza = new Pizza(size, crust);
        pizza->setCheese(cheese);
        pizza->setPepperoni(pepperoni);
        pizza->setMushrooms(mushrooms);
        pizza->setOnions(onions);
        pizza->setBacon(bacon);
        return pizza;
    }
};

// Usage example
int main() {
    // Using fluent interface for building pizzas
    PizzaBuilder builder;

    Pizza* margherita = builder.setSize("Large")
                              .setCrust("Thin")
                              .addCheese()
                              .build();
    margherita->display();
    std::cout << "\n";

    Pizza* supreme = builder.setSize("Medium")
                           .setCrust("Thick")
                           .addCheese()
                           .addPepperoni()
                           .addMushrooms()
                           .addOnions()
                           .addBacon()
                           .build();
    supreme->display();
    std::cout << "\n";

    delete margherita;
    delete supreme;

    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Product structure
typedef struct {
    char* type;
    char* engine;
    int seats;
    bool gps;
    bool air_conditioning;
    bool sunroof;
} Car;

// Builder structure
typedef struct {
    char* type;
    char* engine;
    int seats;
    bool gps;
    bool air_conditioning;
    bool sunroof;
} CarBuilder;

CarBuilder* car_builder_create() {
    CarBuilder* builder = (CarBuilder*)malloc(sizeof(CarBuilder));
    builder->type = NULL;
    builder->engine = NULL;
    builder->seats = 4; // default
    builder->gps = false;
    builder->air_conditioning = false;
    builder->sunroof = false;
    return builder;
}

CarBuilder* car_builder_set_type(CarBuilder* builder, const char* type) {
    if (builder->type) free(builder->type);
    builder->type = strdup(type);
    return builder;
}

CarBuilder* car_builder_set_engine(CarBuilder* builder, const char* engine) {
    if (builder->engine) free(builder->engine);
    builder->engine = strdup(engine);
    return builder;
}

CarBuilder* car_builder_set_seats(CarBuilder* builder, int seats) {
    builder->seats = seats;
    return builder;
}

CarBuilder* car_builder_set_gps(CarBuilder* builder, bool gps) {
    builder->gps = gps;
    return builder;
}

CarBuilder* car_builder_set_air_conditioning(CarBuilder* builder, bool ac) {
    builder->air_conditioning = ac;
    return builder;
}

CarBuilder* car_builder_set_sunroof(CarBuilder* builder, bool sunroof) {
    builder->sunroof = sunroof;
    return builder;
}

Car* car_builder_build(CarBuilder* builder) {
    Car* car = (Car*)malloc(sizeof(Car));
    car->type = strdup(builder->type);
    car->engine = strdup(builder->engine);
    car->seats = builder->seats;
    car->gps = builder->gps;
    car->air_conditioning = builder->air_conditioning;
    car->sunroof = builder->sunroof;
    return car;
}

void car_builder_destroy(CarBuilder* builder) {
    if (builder->type) free(builder->type);
    if (builder->engine) free(builder->engine);
    free(builder);
}

void car_display(const Car* car) {
    printf("Car Configuration:\n");
    printf("  Type: %s\n", car->type);
    printf("  Engine: %s\n", car->engine);
    printf("  Seats: %d\n", car->seats);
    printf("  GPS: %s\n", car->gps ? "Yes" : "No");
    printf("  Air Conditioning: %s\n", car->air_conditioning ? "Yes" : "No");
    printf("  Sunroof: %s\n", car->sunroof ? "Yes" : "No");
}

void car_destroy(Car* car) {
    free(car->type);
    free(car->engine);
    free(car);
}

// Director functions
Car* build_sports_car() {
    CarBuilder* builder = car_builder_create();
    Car* car = car_builder_set_type(builder, "Sports")
                ->car_builder_set_engine(builder, "V8")
                ->car_builder_set_seats(builder, 2)
                ->car_builder_set_gps(builder, true)
                ->car_builder_set_air_conditioning(builder, true)
                ->car_builder_set_sunroof(builder, true)
                ->car_builder_build(builder);
    car_builder_destroy(builder);
    return car;
}

Car* build_family_car() {
    CarBuilder* builder = car_builder_create();
    Car* car = car_builder_set_type(builder, "SUV")
                ->car_builder_set_engine(builder, "V6")
                ->car_builder_set_seats(builder, 7)
                ->car_builder_set_gps(builder, true)
                ->car_builder_set_air_conditioning(builder, true)
                ->car_builder_set_sunroof(builder, false)
                ->car_builder_build(builder);
    car_builder_destroy(builder);
    return car;
}

// Usage example
int main() {
    printf("=== Sports Car ===\n");
    Car* sports_car = build_sports_car();
    car_display(sports_car);
    car_destroy(sports_car);

    printf("\n=== Family Car ===\n");
    Car* family_car = build_family_car();
    car_display(family_car);
    car_destroy(family_car);

    printf("\n=== Custom Car ===\n");
    CarBuilder* builder = car_builder_create();
    Car* custom_car = car_builder_set_type(builder, "Sedan")
                     ->car_builder_set_engine(builder, "I4")
                     ->car_builder_set_seats(builder, 5)
                     ->car_builder_set_gps(builder, true)
                     ->car_builder_set_air_conditioning(builder, true)
                     ->car_builder_set_sunroof(builder, true)
                     ->car_builder_build(builder);
    car_display(custom_car);
    car_destroy(custom_car);
    car_builder_destroy(builder);

    return 0;
}
```

### Python Implementation

#### Basic Builder Pattern
```python
from abc import ABC, abstractmethod
from typing import List, Optional

# Product
class House:
    def __init__(self):
        self.foundation: Optional[str] = None
        self.structure: Optional[str] = None
        self.roof: Optional[str] = None
        self.windows: List[str] = []
        self.doors: List[str] = []
        self.garage: Optional[str] = None
        self.garden: Optional[str] = None
        self.swimming_pool: Optional[str] = None
    
    def __str__(self) -> str:
        details = [
            f"Foundation: {self.foundation}",
            f"Structure: {self.structure}",
            f"Roof: {self.roof}",
            f"Windows: {', '.join(self.windows) if self.windows else 'None'}",
            f"Doors: {', '.join(self.doors) if self.doors else 'None'}",
            f"Garage: {self.garage or 'No'}",
            f"Garden: {self.garden or 'No'}",
            f"Swimming Pool: {self.swimming_pool or 'No'}"
        ]
        return "\n".join(details)

# Abstract Builder
class HouseBuilder(ABC):
    def __init__(self):
        self.house = House()
    
    @abstractmethod
    def build_foundation(self) -> None: ...
    
    @abstractmethod
    def build_structure(self) -> None: ...
    
    @abstractmethod
    def build_roof(self) -> None: ...
    
    @abstractmethod
    def build_windows(self) -> None: ...
    
    @abstractmethod
    def build_doors(self) -> None: ...
    
    def build_garage(self) -> None:
        pass
    
    def build_garden(self) -> None:
        pass
    
    def build_swimming_pool(self) -> None:
        pass
    
    def get_house(self) -> House:
        return self.house

# Concrete Builders
class BasicHouseBuilder(HouseBuilder):
    def build_foundation(self) -> None:
        self.house.foundation = "Concrete slab"
    
    def build_structure(self) -> None:
        self.house.structure = "Wood frame"
    
    def build_roof(self) -> None:
        self.house.roof = "Asphalt shingles"
    
    def build_windows(self) -> None:
        self.house.windows = ["Standard vinyl windows"]
    
    def build_doors(self) -> None:
        self.house.doors = ["Basic wooden front door"]

class LuxuryHouseBuilder(HouseBuilder):
    def build_foundation(self) -> None:
        self.house.foundation = "Reinforced concrete"
    
    def build_structure(self) -> None:
        self.house.structure = "Steel frame with brick walls"
    
    def build_roof(self) -> None:
        self.house.roof = "Clay tiles"
    
    def build_windows(self) -> None:
        self.house.windows = ["Double-paned energy efficient windows", "Bay windows"]
    
    def build_doors(self) -> None:
        self.house.doors = ["Solid oak front door", "French patio doors"]
    
    def build_garage(self) -> None:
        self.house.garage = "3-car attached garage"
    
    def build_garden(self) -> None:
        self.house.garden = "Landscaped garden with fountain"
    
    def build_swimming_pool(self) -> None:
        self.house.swimming_pool = "Heated swimming pool"

# Director
class ConstructionEngineer:
    def __init__(self, builder: HouseBuilder):
        self.builder = builder
    
    def construct_house(self) -> House:
        self.builder.build_foundation()
        self.builder.build_structure()
        self.builder.build_roof()
        self.builder.build_windows()
        self.builder.build_doors()
        self.builder.build_garage()
        self.builder.build_garden()
        self.builder.build_swimming_pool()
        return self.builder.get_house()
    
    def construct_basic_house(self) -> House:
        self.builder.build_foundation()
        self.builder.build_structure()
        self.builder.build_roof()
        self.builder.build_windows()
        self.builder.build_doors()
        return self.builder.get_house()

# Usage
if __name__ == "__main__":
    print("=== Basic House ===")
    basic_builder = BasicHouseBuilder()
    engineer = ConstructionEngineer(basic_builder)
    basic_house = engineer.construct_basic_house()
    print(basic_house)
    
    print("\n=== Luxury House ===")
    luxury_builder = LuxuryHouseBuilder()
    engineer = ConstructionEngineer(luxury_builder)
    luxury_house = engineer.construct_house()
    print(luxury_house)
```

#### Fluent Builder Pattern in Python
```python
from typing import List, Optional

# Product
class Burger:
    def __init__(self):
        self.bun: Optional[str] = None
        self.patty: Optional[str] = None
        self.cheese: Optional[str] = None
        self.vegetables: List[str] = []
        self.sauces: List[str] = []
        self.extra_toppings: List[str] = []
    
    def __str__(self) -> str:
        details = [
            f"Bun: {self.bun}",
            f"Patty: {self.patty}",
            f"Cheese: {self.cheese or 'No'}",
            f"Vegetables: {', '.join(self.vegetables) if self.vegetables else 'None'}",
            f"Sauces: {', '.join(self.sauces) if self.sauces else 'None'}",
            f"Extra Toppings: {', '.join(self.extra_toppings) if self.extra_toppings else 'None'}"
        ]
        return "\n".join(details)

# Fluent Builder
class BurgerBuilder:
    def __init__(self):
        self.burger = Burger()
    
    def set_bun(self, bun_type: str) -> 'BurgerBuilder':
        self.burger.bun = bun_type
        return self
    
    def set_patty(self, patty_type: str) -> 'BurgerBuilder':
        self.burger.patty = patty_type
        return self
    
    def add_cheese(self, cheese_type: str) -> 'BurgerBuilder':
        self.burger.cheese = cheese_type
        return self
    
    def add_vegetable(self, vegetable: str) -> 'BurgerBuilder':
        self.burger.vegetables.append(vegetable)
        return self
    
    def add_sauce(self, sauce: str) -> 'BurgerBuilder':
        self.burger.sauces.append(sauce)
        return self
    
    def add_extra_topping(self, topping: str) -> 'BurgerBuilder':
        self.burger.extra_toppings.append(topping)
        return self
    
    def build(self) -> Burger:
        return self.burger

# Director with predefined burger recipes
class BurgerChef:
    @staticmethod
    def create_cheeseburger() -> Burger:
        return (BurgerBuilder()
                .set_bun("Sesame seed bun")
                .set_patty("Beef patty")
                .add_cheese("American cheese")
                .add_vegetable("Lettuce")
                .add_vegetable("Tomato")
                .add_vegetable("Onion")
                .add_sauce("Ketchup")
                .add_sauce("Mustard")
                .build())
    
    @staticmethod
    def create_bacon_burger() -> Burger:
        return (BurgerBuilder()
                .set_bun("Brioche bun")
                .set_patty("Angus beef patty")
                .add_cheese("Cheddar cheese")
                .add_vegetable("Lettuce")
                .add_vegetable("Tomato")
                .add_extra_topping("Bacon")
                .add_sauce("BBQ sauce")
                .add_sauce("Mayonnaise")
                .build())
    
    @staticmethod
    def create_veggie_burger() -> Burger:
        return (BurgerBuilder()
                .set_bun("Whole wheat bun")
                .set_patty("Black bean patty")
                .add_vegetable("Lettuce")
                .add_vegetable("Tomato")
                .add_vegetable("Onion")
                .add_vegetable("Pickles")
                .add_vegetable("Avocado")
                .add_sauce("Vegan mayo")
                .add_sauce("Mustard")
                .build())

# Usage
if __name__ == "__main__":
    print("=== Cheeseburger ===")
    cheeseburger = BurgerChef.create_cheeseburger()
    print(cheeseburger)
    
    print("\n=== Bacon Burger ===")
    bacon_burger = BurgerChef.create_bacon_burger()
    print(bacon_burger)
    
    print("\n=== Veggie Burger ===")
    veggie_burger = BurgerChef.create_veggie_burger()
    print(veggie_burger)
    
    print("\n=== Custom Burger ===")
    custom_burger = (BurgerBuilder()
                    .set_bun("Gluten-free bun")
                    .set_patty("Chicken patty")
                    .add_cheese("Swiss cheese")
                    .add_vegetable("Lettuce")
                    .add_vegetable("Tomato")
                    .add_extra_topping("Fried egg")
                    .add_sauce("Sriracha mayo")
                    .build())
    print(custom_burger)
```

#### Advanced Builder with Validation
```python
from abc import ABC, abstractmethod
from typing import List, Optional
from enum import Enum

class ComputerType(Enum):
    GAMING = "gaming"
    WORKSTATION = "workstation"
    SERVER = "server"
    DESKTOP = "desktop"

# Product
class Computer:
    def __init__(self):
        self.computer_type: Optional[ComputerType] = None
        self.cpu: Optional[str] = None
        self.gpu: Optional[str] = None
        self.ram_gb: int = 0
        self.storage_gb: int = 0
        self.psu_watts: int = 0
        self.cooling_system: Optional[str] = None
        self.motherboard: Optional[str] = None
    
    def __str__(self) -> str:
        return (f"Computer Type: {self.computer_type.value}\n"
                f"CPU: {self.cpu}\n"
                f"GPU: {self.gpu or 'Integrated'}\n"
                f"RAM: {self.ram_gb}GB\n"
                f"Storage: {self.storage_gb}GB\n"
                f"PSU: {self.psu_watts}W\n"
                f"Cooling: {self.cooling_system}\n"
                f"Motherboard: {self.motherboard}")

# Builder with validation
class ComputerBuilder:
    def __init__(self):
        self.computer = Computer()
        self._required_fields = ['computer_type', 'cpu', 'ram_gb', 'storage_gb', 'motherboard']
    
    def set_type(self, computer_type: ComputerType) -> 'ComputerBuilder':
        self.computer.computer_type = computer_type
        return self
    
    def set_cpu(self, cpu: str) -> 'ComputerBuilder':
        self.computer.cpu = cpu
        return self
    
    def set_gpu(self, gpu: str) -> 'ComputerBuilder':
        self.computer.gpu = gpu
        return self
    
    def set_ram(self, ram_gb: int) -> 'ComputerBuilder':
        if ram_gb <= 0:
            raise ValueError("RAM must be positive")
        self.computer.ram_gb = ram_gb
        return self
    
    def set_storage(self, storage_gb: int) -> 'ComputerBuilder':
        if storage_gb <= 0:
            raise ValueError("Storage must be positive")
        self.computer.storage_gb = storage_gb
        return self
    
    def set_psu(self, psu_watts: int) -> 'ComputerBuilder':
        if psu_watts <= 0:
            raise ValueError("PSU wattage must be positive")
        self.computer.psu_watts = psu_watts
        return self
    
    def set_cooling(self, cooling_system: str) -> 'ComputerBuilder':
        self.computer.cooling_system = cooling_system
        return self
    
    def set_motherboard(self, motherboard: str) -> 'ComputerBuilder':
        self.computer.motherboard = motherboard
        return self
    
    def _validate(self) -> None:
        for field in self._required_fields:
            if getattr(self.computer, field) is None:
                raise ValueError(f"Required field '{field}' is not set")
        
        # Type-specific validation
        if self.computer.computer_type == ComputerType.GAMING and not self.computer.gpu:
            raise ValueError("Gaming computer requires a dedicated GPU")
        
        if self.computer.computer_type == ComputerType.SERVER and self.computer.ram_gb < 16:
            raise ValueError("Server computer requires at least 16GB RAM")
    
    def build(self) -> Computer:
        self._validate()
        
        # Set defaults if not provided
        if not self.computer.psu_watts:
            if self.computer.computer_type == ComputerType.GAMING:
                self.computer.psu_watts = 750
            else:
                self.computer.psu_watts = 500
        
        if not self.computer.cooling_system:
            if self.computer.computer_type == ComputerType.GAMING:
                self.computer.cooling_system = "Liquid cooling"
            else:
                self.computer.cooling_system = "Air cooling"
        
        return self.computer

# Director
class ComputerAssembler:
    @staticmethod
    def create_gaming_pc() -> Computer:
        return (ComputerBuilder()
                .set_type(ComputerType.GAMING)
                .set_cpu("Intel Core i9-13900K")
                .set_gpu("NVIDIA RTX 4090")
                .set_ram(32)
                .set_storage(2000)
                .set_motherboard("ASUS ROG Maximus Z790")
                .build())
    
    @staticmethod
    def create_workstation() -> Computer:
        return (ComputerBuilder()
                .set_type(ComputerType.WORKSTATION)
                .set_cpu("AMD Ryzen Threadripper 7970X")
                .set_gpu("NVIDIA RTX A6000")
                .set_ram(128)
                .set_storage(4000)
                .set_motherboard("ASUS Pro WS TRX50-SAGE")
                .build())
    
    @staticmethod
    def create_server() -> Computer:
        return (ComputerBuilder()
                .set_type(ComputerType.SERVER)
                .set_cpu("Intel Xeon Silver 4314")
                .set_ram(64)
                .set_storage(8000)
                .set_motherboard("Supermicro X12DPi-NT6")
                .build())

# Usage
if __name__ == "__main__":
    try:
        print("=== Gaming PC ===")
        gaming_pc = ComputerAssembler.create_gaming_pc()
        print(gaming_pc)
        
        print("\n=== Workstation ===")
        workstation = ComputerAssembler.create_workstation()
        print(workstation)
        
        print("\n=== Server ===")
        server = ComputerAssembler.create_server()
        print(server)
        
        print("\n=== Custom Build ===")
        custom_pc = (ComputerBuilder()
                    .set_type(ComputerType.DESKTOP)
                    .set_cpu("AMD Ryzen 7 7700X")
                    .set_gpu("AMD Radeon RX 7800 XT")
                    .set_ram(16)
                    .set_storage(1000)
                    .set_motherboard("ASUS TUF Gaming B650-PLUS")
                    .build())
        print(custom_pc)
        
    except ValueError as e:
        print(f"Build error: {e}")
```

## Advantages and Disadvantages

### Advantages
- **Step-by-step construction**: Complex objects can be built step by step
- **Reusable construction code**: Same construction process can create different representations
- **Isolated construction logic**: Construction code is separated from business logic
- **Fine control**: Provides precise control over the construction process
- **Fluent interface**: Method chaining makes code more readable

### Disadvantages
- **Complexity**: Requires creating multiple additional classes
- **Overhead**: May be overkill for simple objects
- **Maintenance**: Need to maintain parallel builder hierarchy

## Best Practices

1. **Use for complex objects**: When objects have many components or require complex initialization
2. **Implement validation**: Add validation logic in the build method
3. **Provide sensible defaults**: Set reasonable defaults for optional parameters
4. **Use fluent interface**: Enable method chaining for better readability
5. **Consider static factory methods**: Provide common configurations as static methods

## Builder vs Other Patterns

- **vs Factory Method**: Builder focuses on step-by-step construction of complex objects, while Factory Method focuses on creating single objects
- **vs Abstract Factory**: Builder constructs complex objects step by step, while Abstract Factory creates families of related objects
- **vs Prototype**: Builder constructs new objects from scratch, while Prototype clones existing objects

The Builder pattern is particularly useful when you need to create objects with many optional parameters or when the construction process involves multiple steps that need to be executed in a specific order.00000000000000000000000