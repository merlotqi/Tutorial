# Flyweight Pattern

## Introduction

The Flyweight pattern is a structural design pattern that minimizes memory usage by sharing as much data as possible with similar objects. It's used when you need to create a large number of similar objects efficiently.

### Key Characteristics
- **Shared State**: Intrinsic state is shared among multiple objects
- **Unique State**: Extrinsic state is stored or computed externally
- **Memory Efficiency**: Reduces memory footprint by sharing common data
- **Object Pooling**: Maintains a pool of reusable objects

### Use Cases
- When an application uses a large number of objects
- When storage costs are high due to object quantity
- When most object state can be made extrinsic
- When groups of objects can be replaced by relatively few shared objects
- When application doesn't depend on object identity

## Implementation Examples

### C++ Implementation

#### Text Editor Character Flyweight
```cpp
#include <iostream>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

// Flyweight class - Character properties that can be shared
class CharacterStyle {
private:
    std::string fontFamily;
    int fontSize;
    bool isBold;
    bool isItalic;
    std::string color;

public:
    CharacterStyle(const std::string& font, int size, bool bold, bool italic, const std::string& col)
        : fontFamily(font), fontSize(size), isBold(bold), isItalic(italic), color(col) {}
    
    // Getters
    std::string getFontFamily() const { return fontFamily; }
    int getFontSize() const { return fontSize; }
    bool getIsBold() const { return isBold; }
    bool getIsItalic() const { return isItalic; }
    std::string getColor() const { return color; }
    
    void render() const {
        std::cout << "Style: " << fontFamily << " " << fontSize << "px ";
        if (isBold) std::cout << "Bold ";
        if (isItalic) std::cout << "Italic ";
        std::cout << color << std::endl;
    }
    
    // For use in unordered_map
    bool operator==(const CharacterStyle& other) const {
        return fontFamily == other.fontFamily &&
               fontSize == other.fontSize &&
               isBold == other.isBold &&
               isItalic == other.isItalic &&
               color == other.color;
    }
};

// Hash function for CharacterStyle
namespace std {
    template<>
    struct hash<CharacterStyle> {
        size_t operator()(const CharacterStyle& style) const {
            return hash<string>()(style.getFontFamily()) ^
                   hash<int>()(style.getFontSize()) ^
                   hash<bool>()(style.getIsBold()) ^
                   hash<bool>()(style.getIsItalic()) ^
                   hash<string>()(style.getColor());
        }
    };
}

// Flyweight Factory
class StyleFactory {
private:
    std::unordered_map<CharacterStyle, std::shared_ptr<CharacterStyle>> styles;

public:
    std::shared_ptr<CharacterStyle> getStyle(const std::string& font, int size, 
                                           bool bold, bool italic, const std::string& color) {
        CharacterStyle key(font, size, bold, italic, color);
        
        if (styles.find(key) == styles.end()) {
            styles[key] = std::make_shared<CharacterStyle>(font, size, bold, italic, color);
            std::cout << "Created new style: " << font << " " << size << "px" << std::endl;
        } else {
            std::cout << "Reusing existing style: " << font << " " << size << "px" << std::endl;
        }
        
        return styles[key];
    }
    
    int getStyleCount() const {
        return styles.size();
    }
};

// Concrete Flyweight - Character with extrinsic state
class Character {
private:
    char symbol;
    int position;
    std::shared_ptr<CharacterStyle> style;

public:
    Character(char sym, int pos, std::shared_ptr<CharacterStyle> sty)
        : symbol(sym), position(pos), style(sty) {}
    
    void render() const {
        std::cout << "Char '" << symbol << "' at position " << position << " - ";
        style->render();
    }
    
    char getSymbol() const { return symbol; }
    int getPosition() const { return position; }
};

// Text Document using Flyweights
class TextDocument {
private:
    std::vector<std::unique_ptr<Character>> characters;
    StyleFactory& styleFactory;

public:
    TextDocument(StyleFactory& factory) : styleFactory(factory) {}
    
    void addCharacter(char symbol, int position, const std::string& font, 
                     int size, bool bold, bool italic, const std::string& color) {
        auto style = styleFactory.getStyle(font, size, bold, italic, color);
        characters.push_back(std::make_unique<Character>(symbol, position, style));
    }
    
    void render() const {
        std::cout << "\n=== Document Content ===" << std::endl;
        for (const auto& ch : characters) {
            ch->render();
        }
    }
    
    void showStatistics() const {
        std::cout << "\n=== Memory Statistics ===" << std::endl;
        std::cout << "Total characters: " << characters.size() << std::endl;
        std::cout << "Unique styles: " << styleFactory.getStyleCount() << std::endl;
        std::cout << "Memory saved: " << (characters.size() - styleFactory.getStyleCount()) 
                  << " style objects" << std::endl;
    }
};

// Usage example
void textEditorDemo() {
    std::cout << "=== Flyweight Pattern - Text Editor ===" << std::endl;
    
    StyleFactory styleFactory;
    TextDocument document(styleFactory);
    
    // Add characters with shared styles
    document.addCharacter('H', 0, "Arial", 12, true, false, "Black");
    document.addCharacter('e', 1, "Arial", 12, true, false, "Black");
    document.addCharacter('l', 2, "Arial", 12, true, false, "Black");
    document.addCharacter('l', 3, "Arial", 12, true, false, "Black");
    document.addCharacter('o', 4, "Arial", 12, true, false, "Black");
    
    document.addCharacter('W', 6, "Arial", 14, false, true, "Blue");
    document.addCharacter('o', 7, "Arial", 14, false, true, "Blue");
    document.addCharacter('r', 8, "Arial", 14, false, true, "Blue");
    document.addCharacter('l', 9, "Arial", 14, false, true, "Blue");
    document.addCharacter('d', 10, "Arial", 14, false, true, "Blue");
    
    document.addCharacter('!', 11, "Times New Roman", 16, true, true, "Red");
    
    // Render document
    document.render();
    document.showStatistics();
}

int main() {
    textEditorDemo();
    return 0;
}
```

#### Game Terrain Flyweight
```cpp
#include <iostream>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>
#include <random>

// Intrinsic state - Terrain type properties (shared)
class TerrainType {
private:
    std::string name;
    std::string texture;
    bool isWalkable;
    int movementCost;
    std::string color;

public:
    TerrainType(const std::string& name, const std::string& texture, 
                bool walkable, int cost, const std::string& color)
        : name(name), texture(texture), isWalkable(walkable), 
          movementCost(cost), color(color) {}
    
    void render(int x, int y) const {
        std::cout << "[" << color << " " << name << " at (" << x << "," << y << ")]";
    }
    
    std::string getName() const { return name; }
    std::string getTexture() const { return texture; }
    bool getIsWalkable() const { return isWalkable; }
    int getMovementCost() const { return movementCost; }
    std::string getColor() const { return color; }
    
    bool operator==(const TerrainType& other) const {
        return name == other.name &&
               texture == other.texture &&
               isWalkable == other.isWalkable &&
               movementCost == other.movementCost &&
               color == other.color;
    }
};

// Hash function for TerrainType
namespace std {
    template<>
    struct hash<TerrainType> {
        size_t operator()(const TerrainType& terrain) const {
            return hash<string>()(terrain.getName()) ^
                   hash<string>()(terrain.getTexture()) ^
                   hash<bool>()(terrain.getIsWalkable()) ^
                   hash<int>()(terrain.getMovementCost()) ^
                   hash<string>()(terrain.getColor());
        }
    };
}

// Flyweight Factory for Terrain types
class TerrainFactory {
private:
    std::unordered_map<TerrainType, std::shared_ptr<TerrainType>> terrainTypes;

public:
    std::shared_ptr<TerrainType> getTerrainType(const std::string& name, 
                                               const std::string& texture,
                                               bool walkable, int cost, 
                                               const std::string& color) {
        TerrainType key(name, texture, walkable, cost, color);
        
        if (terrainTypes.find(key) == terrainTypes.end()) {
            terrainTypes[key] = std::make_shared<TerrainType>(name, texture, walkable, cost, color);
            std::cout << "Created new terrain type: " << name << std::endl;
        }
        
        return terrainTypes[key];
    }
    
    int getTypeCount() const {
        return terrainTypes.size();
    }
    
    void listTerrainTypes() const {
        std::cout << "\nAvailable Terrain Types:" << std::endl;
        for (const auto& pair : terrainTypes) {
            std::cout << " - " << pair.first.getName() << " (Cost: " 
                      << pair.first.getMovementCost() << ")" << std::endl;
        }
    }
};

// Concrete Flyweight - Tile with extrinsic state (position)
class Tile {
private:
    int x, y;
    std::shared_ptr<TerrainType> terrainType;
    bool hasTree;  // Extrinsic state - specific to this tile
    bool hasWater; // Extrinsic state - specific to this tile

public:
    Tile(int x, int y, std::shared_ptr<TerrainType> type, bool tree = false, bool water = false)
        : x(x), y(y), terrainType(type), hasTree(tree), hasWater(water) {}
    
    void render() const {
        terrainType->render(x, y);
        if (hasTree) std::cout << "🌲";
        if (hasWater) std::cout << "💧";
        std::cout << " ";
    }
    
    int getMovementCost() const {
        int cost = terrainType->getMovementCost();
        if (hasTree) cost += 2;    // Trees increase movement cost
        if (hasWater) cost += 3;   // Water significantly increases cost
        return cost;
    }
    
    bool isWalkable() const {
        return terrainType->getIsWalkable() && !hasWater; // Can't walk on water
    }
    
    void setTree(bool hasTree) { this->hasTree = hasTree; }
    void setWater(bool hasWater) { this->hasWater = hasWater; }
};

// Game World using Flyweight pattern
class GameWorld {
private:
    std::vector<std::vector<std::unique_ptr<Tile>>> grid;
    TerrainFactory& terrainFactory;
    int width, height;

public:
    GameWorld(TerrainFactory& factory, int w, int h) 
        : terrainFactory(factory), width(w), height(h) {
        initializeGrid();
    }
    
    void initializeGrid() {
        // Create terrain types
        auto grass = terrainFactory.getTerrainType("Grass", "grass.png", true, 1, "Green");
        auto forest = terrainFactory.getTerrainType("Forest", "forest.png", true, 2, "DarkGreen");
        auto mountain = terrainFactory.getTerrainType("Mountain", "mountain.png", false, 999, "Gray");
        auto water = terrainFactory.getTerrainType("Water", "water.png", false, 999, "Blue");
        
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dis(0, 100);
        
        // Create grid with random terrain
        for (int y = 0; y < height; ++y) {
            std::vector<std::unique_ptr<Tile>> row;
            for (int x = 0; x < width; ++x) {
                std::shared_ptr<TerrainType> type;
                bool hasTree = false;
                bool hasWater = false;
                
                int randVal = dis(gen);
                if (randVal < 60) {
                    type = grass;
                    hasTree = (dis(gen) < 20); // 20% chance of tree on grass
                } else if (randVal < 85) {
                    type = forest;
                    hasTree = true; // Forests always have trees
                } else if (randVal < 95) {
                    type = mountain;
                } else {
                    type = water;
                    hasWater = true;
                }
                
                row.push_back(std::make_unique<Tile>(x, y, type, hasTree, hasWater));
            }
            grid.push_back(std::move(row));
        }
    }
    
    void render() const {
        std::cout << "\n=== Game World ===" << std::endl;
        for (const auto& row : grid) {
            for (const auto& tile : row) {
                tile->render();
            }
            std::cout << std::endl;
        }
    }
    
    void calculatePath(int startX, int startY, int endX, int endY) const {
        std::cout << "\n=== Path Calculation ===" << std::endl;
        std::cout << "From (" << startX << "," << startY << ") to (" 
                  << endX << "," << endY << ")" << std::endl;
        
        int totalCost = 0;
        int x = startX, y = startY;
        
        while (x != endX || y != endY) {
            if (x < endX) x++;
            else if (x > endX) x--;
            
            if (y < endY) y++;
            else if (y > endY) y--;
            
            if (x >= 0 && x < width && y >= 0 && y < height) {
                int cost = grid[y][x]->getMovementCost();
                totalCost += cost;
                std::cout << "Move to (" << x << "," << y << ") - Cost: " << cost << std::endl;
                
                if (!grid[y][x]->isWalkable()) {
                    std::cout << "Path blocked by unwalkable terrain!" << std::endl;
                    break;
                }
            }
        }
        
        std::cout << "Total movement cost: " << totalCost << std::endl;
    }
    
    void showStatistics() const {
        int totalTiles = width * height;
        std::cout << "\n=== World Statistics ===" << std::endl;
        std::cout << "World size: " << width << "x" << height << " = " << totalTiles << " tiles" << std::endl;
        std::cout << "Unique terrain types: " << terrainFactory.getTypeCount() << std::endl;
        std::cout << "Memory saved: " << (totalTiles - terrainFactory.getTypeCount()) 
                  << " terrain objects" << std::endl;
    }
};

// Usage example
void gameWorldDemo() {
    std::cout << "=== Flyweight Pattern - Game World ===" << std::endl;
    
    TerrainFactory terrainFactory;
    GameWorld world(terrainFactory, 8, 6); // 8x6 world
    
    world.render();
    world.calculatePath(0, 0, 7, 5);
    world.showStatistics();
    terrainFactory.listTerrainTypes();
}

int main() {
    gameWorldDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Intrinsic state - Tree type (shared)
typedef struct {
    char name[50];
    char texture[50];
    int max_height;
    char color[20];
    bool is_evergreen;
} TreeType;

// Flyweight Factory for Tree types
typedef struct {
    TreeType** tree_types;
    int count;
    int capacity;
} TreeTypeFactory;

TreeType* tree_type_factory_get_type(TreeTypeFactory* factory, 
                                   const char* name, const char* texture,
                                   int max_height, const char* color, 
                                   bool is_evergreen) {
    // Check if type already exists
    for (int i = 0; i < factory->count; i++) {
        TreeType* existing = factory->tree_types[i];
        if (strcmp(existing->name, name) == 0 &&
            strcmp(existing->texture, texture) == 0 &&
            existing->max_height == max_height &&
            strcmp(existing->color, color) == 0 &&
            existing->is_evergreen == is_evergreen) {
            printf("Reusing existing tree type: %s\n", name);
            return existing;
        }
    }
    
    // Create new type
    if (factory->count >= factory->capacity) {
        factory->capacity = factory->capacity == 0 ? 4 : factory->capacity * 2;
        factory->tree_types = realloc(factory->tree_types, 
                                    factory->capacity * sizeof(TreeType*));
    }
    
    TreeType* new_type = malloc(sizeof(TreeType));
    strcpy(new_type->name, name);
    strcpy(new_type->texture, texture);
    new_type->max_height = max_height;
    strcpy(new_type->color, color);
    new_type->is_evergreen = is_evergreen;
    
    factory->tree_types[factory->count++] = new_type;
    printf("Created new tree type: %s\n", name);
    
    return new_type;
}

void tree_type_factory_list_types(TreeTypeFactory* factory) {
    printf("\nAvailable Tree Types:\n");
    for (int i = 0; i < factory->count; i++) {
        TreeType* type = factory->tree_types[i];
        printf(" - %s (Max height: %dm, Color: %s, %s)\n", 
               type->name, type->max_height, type->color,
               type->is_evergreen ? "Evergreen" : "Deciduous");
    }
}

void tree_type_factory_destroy(TreeTypeFactory* factory) {
    for (int i = 0; i < factory->count; i++) {
        free(factory->tree_types[i]);
    }
    free(factory->tree_types);
}

// Concrete Flyweight - Tree with extrinsic state
typedef struct {
    int x, y;
    int age;
    int current_height;
    TreeType* type;
    bool has_fruits;
} Tree;

Tree* tree_create(int x, int y, int age, TreeType* type, bool has_fruits) {
    Tree* tree = malloc(sizeof(Tree));
    tree->x = x;
    tree->y = y;
    tree->age = age;
    tree->type = type;
    tree->has_fruits = has_fruits;
    
    // Calculate current height based on age and max height
    int max_possible_height = (age * type->max_height) / 100; // Simple growth model
    tree->current_height = max_possible_height > type->max_height ? 
                          type->max_height : max_possible_height;
    
    return tree;
}

void tree_render(const Tree* tree) {
    const char* fruit_symbol = tree->has_fruits ? "🍎" : "";
    printf("🌲 %s at (%d,%d) - Age: %dy, Height: %dm/%dm %s\n", 
           tree->type->name, tree->x, tree->y, tree->age, 
           tree->current_height, tree->type->max_height, fruit_symbol);
}

void tree_destroy(Tree* tree) {
    free(tree);
}

// Forest using Flyweight pattern
typedef struct {
    Tree** trees;
    int tree_count;
    int capacity;
    TreeTypeFactory* type_factory;
} Forest;

void forest_init(Forest* forest, TreeTypeFactory* factory) {
    forest->trees = NULL;
    forest->tree_count = 0;
    forest->capacity = 0;
    forest->type_factory = factory;
}

void forest_add_tree(Forest* forest, int x, int y, int age, 
                    const char* type_name, const char* texture,
                    int max_height, const char* color, 
                    bool is_evergreen, bool has_fruits) {
    // Get or create tree type (intrinsic state)
    TreeType* type = tree_type_factory_get_type(forest->type_factory,
                                               type_name, texture, max_height,
                                               color, is_evergreen);
    
    // Create tree with extrinsic state
    if (forest->tree_count >= forest->capacity) {
        forest->capacity = forest->capacity == 0 ? 10 : forest->capacity * 2;
        forest->trees = realloc(forest->trees, forest->capacity * sizeof(Tree*));
    }
    
    forest->trees[forest->tree_count++] = tree_create(x, y, age, type, has_fruits);
}

void forest_render(const Forest* forest) {
    printf("\n=== Forest ===\n");
    for (int i = 0; i < forest->tree_count; i++) {
        tree_render(forest->trees[i]);
    }
}

void forest_show_statistics(const Forest* forest) {
    printf("\n=== Forest Statistics ===\n");
    printf("Total trees: %d\n", forest->tree_count);
    printf("Unique tree types: %d\n", forest->type_factory->count);
    printf("Memory saved: %d tree type objects\n", 
           forest->tree_count - forest->type_factory->count);
}

void forest_destroy(Forest* forest) {
    for (int i = 0; i < forest->tree_count; i++) {
        tree_destroy(forest->trees[i]);
    }
    free(forest->trees);
}

// Demo function
void forest_demo() {
    printf("=== Flyweight Pattern - Forest Simulation ===\n");
    
    TreeTypeFactory type_factory = {0};
    Forest forest;
    forest_init(&forest, &type_factory);
    
    // Add trees with shared types
    forest_add_tree(&forest, 10, 20, 5, "Oak", "oak_texture.png", 30, "Green", false, true);
    forest_add_tree(&forest, 15, 25, 3, "Oak", "oak_texture.png", 30, "Green", false, false);
    forest_add_tree(&forest, 20, 30, 8, "Oak", "oak_texture.png", 30, "Green", false, true);
    
    forest_add_tree(&forest, 5, 15, 10, "Pine", "pine_texture.png", 40, "DarkGreen", true, false);
    forest_add_tree(&forest, 25, 35, 7, "Pine", "pine_texture.png", 40, "DarkGreen", true, false);
    forest_add_tree(&forest, 30, 40, 12, "Pine", "pine_texture.png", 40, "DarkGreen", true, false);
    
    forest_add_tree(&forest, 8, 12, 2, "Maple", "maple_texture.png", 25, "Red", false, false);
    forest_add_tree(&forest, 18, 22, 4, "Maple", "maple_texture.png", 25, "Red", false, true);
    forest_add_tree(&forest, 28, 32, 6, "Maple", "maple_texture.png", 25, "Red", false, false);
    
    forest_add_tree(&forest, 12, 18, 15, "Birch", "birch_texture.png", 20, "White", false, false);
    forest_add_tree(&forest, 22, 28, 9, "Birch", "birch_texture.png", 20, "White", false, true);
    
    // Render forest and show statistics
    forest_render(&forest);
    forest_show_statistics(&forest);
    tree_type_factory_list_types(&type_factory);
    
    // Cleanup
    forest_destroy(&forest);
    tree_type_factory_destroy(&type_factory);
}

int main() {
    forest_demo();
    return 0;
}
```

### Python Implementation

#### Icon Flyweight for GUI Applications
```python
from abc import ABC, abstractmethod
from typing import Dict, List, Tuple
from enum import Enum
import os

class IconType(Enum):
    FOLDER = "folder"
    FILE = "file"
    IMAGE = "image"
    DOCUMENT = "document"
    MUSIC = "music"
    VIDEO = "video"

# Flyweight - Icon properties (intrinsic state)
class Icon:
    def __init__(self, icon_type: IconType, filename: str, color: str, width: int = 32, height: int = 32):
        self.icon_type = icon_type
        self.filename = filename
        self.color = color
        self.width = width
        self.height = height
        self._load_icon_data()
    
    def _load_icon_data(self):
        # Simulate loading icon data from file
        # In real implementation, this would load actual image data
        self.data = f"ICON_DATA:{self.icon_type.value}_{self.filename}"
        print(f"Loaded icon: {self.filename} ({self.icon_type.value})")
    
    def render(self, x: int, y: int) -> None:
        print(f"Rendering {self.filename} at position ({x}, {y}) "
              f"[{self.width}x{self.height}, color: {self.color}]")
    
    def get_memory_size(self) -> int:
        # Simulate memory usage calculation
        return len(self.data) + len(self.filename) + len(self.color) + 20

# Flyweight Factory
class IconFactory:
    def __init__(self):
        self._icons: Dict[Tuple[IconType, str, str], Icon] = {}
    
    def get_icon(self, icon_type: IconType, filename: str, color: str) -> Icon:
        key = (icon_type, filename, color)
        
        if key not in self._icons:
            self._icons[key] = Icon(icon_type, filename, color)
            print(f"Created new icon: {filename}")
        else:
            print(f"Reused existing icon: {filename}")
        
        return self._icons[key]
    
    def get_icon_count(self) -> int:
        return len(self._icons)
    
    def list_icons(self) -> None:
        print("\nAvailable Icons:")
        for (icon_type, filename, color), icon in self._icons.items():
            print(f" - {filename} ({icon_type.value}, {color})")

# Concrete Flyweight - File System Item with extrinsic state
class FileSystemItem:
    def __init__(self, name: str, path: str, icon: Icon, size: int = 0, is_hidden: bool = False):
        self.name = name
        self.path = path
        self.icon = icon
        self.size = size
        self.is_hidden = is_hidden
        self.x = 0
        self.y = 0
    
    def render(self) -> None:
        hidden_indicator = " (Hidden)" if self.is_hidden else ""
        size_info = f" - {self.size} bytes" if self.size > 0 else ""
        print(f"📄 {self.name}{hidden_indicator}{size_info}")
        self.icon.render(self.x, self.y)
    
    def set_position(self, x: int, y: int) -> None:
        self.x = x
        self.y = y
    
    def get_display_info(self) -> Dict:
        return {
            "name": self.name,
            "path": self.path,
            "type": self.icon.icon_type.value,
            "size": self.size,
            "hidden": self.is_hidden,
            "position": (self.x, self.y)
        }

# File Manager using Flyweight pattern
class FileManager:
    def __init__(self):
        self.icon_factory = IconFactory()
        self.items: List[FileSystemItem] = []
        self.grid_width = 4
    
    def add_file(self, name: str, path: str, file_type: IconType, size: int = 0, 
                 is_hidden: bool = False, color: str = "default") -> None:
        filename = f"{file_type.value}_icon.png"
        icon = self.icon_factory.get_icon(file_type, filename, color)
        item = FileSystemItem(name, path, icon, size, is_hidden)
        self.items.append(item)
    
    def arrange_grid(self) -> None:
        print("\nArranging items in grid...")
        for i, item in enumerate(self.items):
            row = i // self.grid_width
            col = i % self.grid_width
            x = col * 100
            y = row * 80
            item.set_position(x, y)
    
    def render_desktop(self) -> None:
        print("\n=== Desktop View ===")
        self.arrange_grid()
        for item in self.items:
            item.render()
    
    def list_by_type(self, icon_type: IconType) -> List[FileSystemItem]:
        return [item for item in self.items if item.icon.icon_type == icon_type]
    
    def show_statistics(self) -> None:
        total_items = len(self.items)
        unique_icons = self.icon_factory.get_icon_count()
        total_memory = sum(item.icon.get_memory_size() for item in self.items[:unique_icons])
        
        print(f"\n=== Memory Statistics ===")
        print(f"Total items: {total_items}")
        print(f"Unique icons: {unique_icons}")
        print(f"Memory used by icons: {total_memory} units")
        print(f"Memory saved: {(total_items - unique_icons) * 50} units (estimated)")
        
        # Show breakdown by type
        type_count = {}
        for item in self.items:
            item_type = item.icon.icon_type
            type_count[item_type] = type_count.get(item_type, 0) + 1
        
        print(f"\nItems by type:")
        for item_type, count in type_count.items():
            print(f" - {item_type.value}: {count} items")

# Demo function
def file_manager_demo():
    print("=== Flyweight Pattern - File Manager ===\n")
    
    file_manager = FileManager()
    
    # Add files with shared icons
    file_manager.add_file("Documents", "/home/user/documents", IconType.FOLDER, 0, False, "blue")
    file_manager.add_file("Pictures", "/home/user/pictures", IconType.FOLDER, 0, False, "yellow")
    file_manager.add_file("Music", "/home/user/music", IconType.FOLDER, 0, False, "green")
    file_manager.add_file("Videos", "/home/user/videos", IconType.FOLDER, 0, False, "red")
    
    file_manager.add_file("report.pdf", "/home/user/documents/report.pdf", IconType.DOCUMENT, 1500000)
    file_manager.add_file("presentation.pptx", "/home/user/documents/presentation.pptx", IconType.DOCUMENT, 2500000)
    file_manager.add_file("notes.txt", "/home/user/documents/notes.txt", IconType.DOCUMENT, 5000)
    
    file_manager.add_file("photo1.jpg", "/home/user/pictures/photo1.jpg", IconType.IMAGE, 3500000)
    file_manager.add_file("photo2.png", "/home/user/pictures/photo2.png", IconType.IMAGE, 2800000)
    file_manager.add_file("screenshot.png", "/home/user/pictures/screenshot.png", IconType.IMAGE, 1200000)
    
    file_manager.add_file("song1.mp3", "/home/user/music/song1.mp3", IconType.MUSIC, 8500000)
    file_manager.add_file("song2.flac", "/home/user/music/song2.flac", IconType.MUSIC, 45000000)
    
    file_manager.add_file("movie1.mp4", "/home/user/videos/movie1.mp4", IconType.VIDEO, 1500000000)
    file_manager.add_file("clip.mov", "/home/user/videos/clip.mov", IconType.VIDEO, 500000000)
    
    file_manager.add_file(".hidden_file", "/home/user/.hidden_file", IconType.FILE, 100, True)
    file_manager.add_file("config.ini", "/home/user/config.ini", IconType.FILE, 2000)
    
    # Demonstrate the system
    file_manager.render_desktop()
    file_manager.show_statistics()
    
    # List documents only
    print(f"\n=== Document Files ===")
    documents = file_manager.list_by_type(IconType.DOCUMENT)
    for doc in documents:
        info = doc.get_display_info()
        print(f" - {info['name']} ({info['size']} bytes)")
    
    # Show factory contents
    file_manager.icon_factory.list_icons()

if __name__ == "__main__":
    file_manager_demo()
```

#### CSS Style Flyweight for Web Applications
```python
from abc import ABC, abstractmethod
from typing import Dict, List, Set, Any
from dataclasses import dataclass
from enum import Enum

class CSSProperty(Enum):
    COLOR = "color"
    BACKGROUND_COLOR = "background-color"
    FONT_SIZE = "font-size"
    FONT_FAMILY = "font-family"
    FONT_WEIGHT = "font-weight"
    BORDER = "border"
    PADDING = "padding"
    MARGIN = "margin"
    WIDTH = "width"
    HEIGHT = "height"

# Flyweight - CSS Style Rule (intrinsic state)
class CSSStyle:
    def __init__(self, selector: str, properties: Dict[CSSProperty, str]):
        self.selector = selector
        self.properties = properties.copy()  # Important: make a copy!
        self._compute_hash()
    
    def _compute_hash(self) -> None:
        # Create a hashable representation for caching
        props_tuple = tuple(sorted((prop.value, value) for prop, value in self.properties.items()))
        self._hash = hash((self.selector, props_tuple))
    
    def apply_to_element(self, element_id: str) -> None:
        print(f"Applying {self.selector} to element #{element_id}")
        for prop, value in self.properties.items():
            print(f"  {prop.value}: {value}")
    
    def get_css_code(self) -> str:
        css_lines = [f"{self.selector} {{"]
        for prop, value in self.properties.items():
            css_lines.append(f"  {prop.value}: {value};")
        css_lines.append("}")
        return "\n".join(css_lines)
    
    def __hash__(self) -> int:
        return self._hash
    
    def __eq__(self, other) -> bool:
        if not isinstance(other, CSSStyle):
            return False
        return (self.selector == other.selector and 
                self.properties == other.properties)

# Flyweight Factory for CSS Styles
class CSSStyleFactory:
    def __init__(self):
        self._styles: Dict[int, CSSStyle] = {}
        self._creation_count = 0
        self._reuse_count = 0
    
    def get_style(self, selector: str, properties: Dict[CSSProperty, str]) -> CSSStyle:
        # Create temporary style to compute hash
        temp_style = CSSStyle(selector, properties)
        
        if temp_style._hash in self._styles:
            self._reuse_count += 1
            # print(f"Reusing existing style: {selector}")
            return self._styles[temp_style._hash]
        else:
            self._creation_count += 1
            # Store the actual style we'll use
            self._styles[temp_style._hash] = temp_style
            # print(f"Created new style: {selector}")
            return temp_style
    
    def get_statistics(self) -> Dict[str, Any]:
        return {
            "total_styles": len(self._styles),
            "styles_created": self._creation_count,
            "styles_reused": self._reuse_count,
            "memory_saved": self._reuse_count
        }
    
    def list_styles(self) -> None:
        print("\nAvailable CSS Styles:")
        for style in self._styles.values():
            print(f" - {style.selector} ({len(style.properties)} properties)")

# Concrete Flyweight - HTML Element with extrinsic state
class HTMLElement:
    def __init__(self, element_id: str, tag: str, content: str, style: CSSStyle, 
                 classes: List[str] = None, parent_id: str = None):
        self.element_id = element_id
        self.tag = tag
        self.content = content
        self.style = style
        self.classes = classes or []
        self.parent_id = parent_id
        self.children: List['HTMLElement'] = []
    
    def render(self, indent: int = 0) -> None:
        indent_str = "  " * indent
        class_attr = f" class=\"{' '.join(self.classes)}\"" if self.classes else ""
        
        print(f"{indent_str}<{self.tag} id=\"{self.element_id}\"{class_attr}>")
        print(f"{indent_str}  {self.content}")
        
        # Apply CSS style
        self.style.apply_to_element(self.element_id)
        
        for child in self.children:
            child.render(indent + 1)
        
        print(f"{indent_str}</{self.tag}>")
    
    def add_child(self, child: 'HTMLElement') -> None:
        self.children.append(child)
    
    def get_full_css(self) -> str:
        return self.style.get_css_code()

# Web Page using Flyweight pattern
class WebPage:
    def __init__(self, title: str):
        self.title = title
        self.style_factory = CSSStyleFactory()
        self.elements: List[HTMLElement] = []
        self._defined_styles: Set[CSSStyle] = set()
    
    def create_style(self, selector: str, **properties) -> CSSStyle:
        css_properties = {}
        for key, value in properties.items():
            try:
                css_prop = CSSProperty(key.replace('_', '-'))
                css_properties[css_prop] = value
            except ValueError:
                print(f"Warning: Unknown CSS property '{key}'")
        
        style = self.style_factory.get_style(selector, css_properties)
        self._defined_styles.add(style)
        return style
    
    def add_element(self, element: HTMLElement) -> None:
        self.elements.append(element)
    
    def build_sample_page(self) -> None:
        # Define reusable styles
        heading_style = self.create_style(
            ".heading",
            color="#333333",
            font_family="Arial, sans-serif",
            font_size="24px",
            font_weight="bold",
            margin_bottom="10px"
        )
        
        paragraph_style = self.create_style(
            ".paragraph",
            color="#666666",
            font_family="Georgia, serif",
            font_size="16px",
            line_height="1.5",
            margin_bottom="15px"
        )
        
        button_style = self.create_style(
            ".button",
            background_color="#007bff",
            color="white",
            padding="10px 20px",
            border="none",
            font_size="14px",
            cursor="pointer"
        )
        
        container_style = self.create_style(
            ".container",
            width="80%",
            margin="0 auto",
            padding="20px",
            background_color="#f8f9fa"
        )
        
        # Create page structure
        header = HTMLElement("header", "header", "My Website", heading_style)
        
        main_container = HTMLElement("main", "div", "", container_style, ["container"])
        
        welcome_heading = HTMLElement("welcome", "h1", "Welcome to Our Site", heading_style)
        welcome_paragraph = HTMLElement("intro", "p", 
                                       "This is a sample webpage demonstrating the Flyweight pattern.", 
                                       paragraph_style)
        
        button1 = HTMLElement("btn1", "button", "Learn More", button_style)
        button2 = HTMLElement("btn2", "button", "Contact Us", button_style)
        
        # Build hierarchy
        main_container.add_child(welcome_heading)
        main_container.add_child(welcome_paragraph)
        main_container.add_child(button1)
        main_container.add_child(button2)
        
        self.add_element(header)
        self.add_element(main_container)
    
    def render_page(self) -> None:
        print(f"=== {self.title} ===\n")
        print("<!DOCTYPE html>")
        print("<html>")
        print("<head>")
        print("  <title>{}</title>".format(self.title))
        print("  <style>")
        
        # Output all unique CSS styles
        for style in self._defined_styles:
            print(style.get_css_code())
        
        print("  </style>")
        print("</head>")
        print("<body>")
        
        for element in self.elements:
            element.render(1)
        
        print("</body>")
        print("</html>")
    
    def show_statistics(self) -> None:
        stats = self.style_factory.get_statistics()
        total_elements = sum(1 for _ in self._traverse_elements())
        
        print(f"\n=== Performance Statistics ===")
        print(f"Total HTML elements: {total_elements}")
        print(f"Unique CSS styles: {stats['total_styles']}")
        print(f"Styles created: {stats['styles_created']}")
        print(f"Styles reused: {stats['styles_reused']}")
        print(f"Memory savings: {stats['memory_saved']} style objects")
        
        if stats['styles_created'] > 0:
            reuse_ratio = stats['styles_reused'] / (stats['styles_created'] + stats['styles_reused'])
            print(f"Style reuse ratio: {reuse_ratio:.1%}")
    
    def _traverse_elements(self):
        """Generator to traverse all elements recursively"""
        stack = self.elements.copy()
        while stack:
            element = stack.pop()
            yield element
            stack.extend(element.children)

# Demo function
def web_page_demo():
    print("=== Flyweight Pattern - Web Page Styling ===\n")
    
    # Create a web page
    page = WebPage("Flyweight Pattern Demo")
    page.build_sample_page()
    
    # Add more elements with shared styles
    for i in range(3):
        paragraph_style = page.create_style(
            ".paragraph",
            color="#666666",
            font_family="Georgia, serif",
            font_size="16px",
            line_height="1.5",
            margin_bottom="15px"
        )
        
        new_para = HTMLElement(f"para{i}", "p", 
                              f"This is additional paragraph #{i+1} with shared styling.", 
                              paragraph_style)
        page.add_element(new_para)
    
    # Add more buttons with shared style
    for i in range(2):
        button_style = page.create_style(
            ".button",
            background_color="#007bff",
            color="white",
            padding="10px 20px",
            border="none",
            font_size="14px",
            cursor="pointer"
        )
        
        new_button = HTMLElement(f"extra-btn{i}", "button", 
                                f"Extra Button {i+1}", button_style)
        page.add_element(new_button)
    
    # Render the page
    page.render_page()
    
    # Show statistics
    page.show_statistics()
    
    # List available styles
    page.style_factory.list_styles()

if __name__ == "__main__":
    web_page_demo()
```

## Advantages and Disadvantages

### Advantages
- **Reduced Memory Usage**: Significantly decreases memory footprint by sharing common state
- **Improved Performance**: Fewer objects to create and manage
- **Scalability**: Can handle large numbers of objects efficiently
- **Centralized State Management**: Shared state is managed in one place

### Disadvantages
- **Increased Complexity**: Adds complexity to the codebase
- **Runtime Overhead**: May introduce lookup overhead in the factory
- **Thread Safety**: Requires careful implementation in multi-threaded environments
- **Limited Use Cases**: Only beneficial when large numbers of similar objects are needed

## Best Practices

1. **Identify Intrinsic vs Extrinsic State**: Clearly separate shared and unique state
2. **Use Immutable Shared State**: Ensure flyweight objects are immutable
3. **Implement Proper Hashing**: Use efficient hashing for flyweight lookup
4. **Consider Thread Safety**: Make factory thread-safe if needed
5. **Monitor Memory Usage**: Use the pattern only when memory savings are significant

## Flyweight vs Other Patterns

- **vs Singleton**: Flyweight shares state among multiple objects, Singleton ensures only one instance
- **vs Object Pool**: Flyweight shares immutable state, Object Pool reuses identical objects
- **vs Prototype**: Flyweight shares common data, Prototype clones existing objects
- **vs Factory**: Flyweight Factory manages shared state, Factory creates different object types

The Flyweight pattern is particularly useful in scenarios with large numbers of similar objects, such as text editors, games, GUI applications, and web applications where memory efficiency is crucial.