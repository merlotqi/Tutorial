# Memento Pattern

## Introduction

The Memento Pattern is a behavioral design pattern that allows capturing and externalizing an object's internal state without violating encapsulation, so that the object can be restored to this state later. It provides the ability to undo and redo operations.

### Key Characteristics

- **State Preservation**: Captures object state without exposing internal details
- **Encapsulation Protection**: Doesn't violate the object's encapsulation
- **Undo/Redo Support**: Enables implementation of undo and redo functionality
- **State Snapshot**: Creates snapshots of object state at specific points in time

### Use Cases

- Text editors with undo/redo functionality
- Game save/load systems
- Transaction rollback in databases
- Configuration management
- Browser history navigation
- Document version control

## Implementation Examples

### C++ Implementation

#### Text Editor with Undo/Redo

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <stack>
#include <ctime>
#include <sstream>

// Memento: Stores the state of the TextDocument
class TextMemento {
private:
    std::string content;
    std::string timestamp;
    size_t cursor_position;
    std::string memento_name;

public:
    TextMemento(const std::string& text, size_t cursor_pos, const std::string& name = "")
        : content(text), cursor_position(cursor_pos), memento_name(name) {
        // Generate timestamp
        std::time_t now = std::time(nullptr);
        timestamp = std::ctime(&now);
        timestamp.pop_back(); // Remove newline
        
        if (memento_name.empty()) {
            memento_name = "Snapshot_" + timestamp;
        }
    }

    // Getters
    std::string get_content() const { return content; }
    std::string get_timestamp() const { return timestamp; }
    size_t get_cursor_position() const { return cursor_position; }
    std::string get_name() const { return memento_name; }

    void display() const {
        std::cout << "Memento: " << memento_name << std::endl;
        std::cout << "Time: " << timestamp << std::endl;
        std::cout << "Cursor: " << cursor_position << std::endl;
        std::cout << "Content Preview: \"";
        if (content.length() <= 50) {
            std::cout << content;
        } else {
            std::cout << content.substr(0, 47) << "...";
        }
        std::cout << "\"" << std::endl;
    }
};

// Originator: The object whose state needs to be saved
class TextDocument {
private:
    std::string content;
    size_t cursor_position;
    std::string document_name;

public:
    TextDocument(const std::string& name = "Untitled") 
        : content(""), cursor_position(0), document_name(name) {}

    // Business operations that change state
    void write(const std::string& text) {
        content.insert(cursor_position, text);
        cursor_position += text.length();
        std::cout << "Written: \"" << text << "\" at position " << cursor_position << std::endl;
    }

    void delete_text(size_t length) {
        if (cursor_position + length <= content.length()) {
            std::string deleted = content.substr(cursor_position, length);
            content.erase(cursor_position, length);
            std::cout << "Deleted: \"" << deleted << "\" (" << length << " chars)" << std::endl;
        }
    }

    void set_cursor(size_t position) {
        cursor_position = std::min(position, content.length());
        std::cout << "Cursor moved to position " << cursor_position << std::endl;
    }

    void insert_at(size_t position, const std::string& text) {
        if (position <= content.length()) {
            content.insert(position, text);
            std::cout << "Inserted: \"" << text << "\" at position " << position << std::endl;
        }
    }

    // Creates a memento containing current state
    std::shared_ptr<TextMemento> create_memento(const std::string& name = "") const {
        std::cout << "Creating snapshot: " << (name.empty() ? "auto_save" : name) << std::endl;
        return std::make_shared<TextMemento>(content, cursor_position, name);
    }

    // Restores state from a memento
    void restore_from_memento(const std::shared_ptr<TextMemento>& memento) {
        content = memento->get_content();
        cursor_position = memento->get_cursor_position();
        std::cout << "Restored from snapshot: " << memento->get_name() << std::endl;
    }

    // Display current state
    void display() const {
        std::cout << "\n=== " << document_name << " ===" << std::endl;
        std::cout << "Cursor: " << cursor_position << std::endl;
        std::cout << "Content: \"" << content << "\"" << std::endl;
        std::cout << "Length: " << content.length() << " characters" << std::endl;
    }

    // Getters
    std::string get_content() const { return content; }
    size_t get_cursor_position() const { return cursor_position; }
    std::string get_document_name() const { return document_name; }
};

// Caretaker: Manages mementos without knowing their internal structure
class DocumentHistory {
private:
    std::stack<std::shared_ptr<TextMemento>> undo_stack;
    std::stack<std::shared_ptr<TextMemento>> redo_stack;
    std::vector<std::shared_ptr<TextMemento>> named_snapshots;
    size_t max_history_size;

public:
    DocumentHistory(size_t max_size = 100) : max_history_size(max_size) {}

    // Save current state for undo
    void save_state(const std::shared_ptr<TextMemento>& memento) {
        undo_stack.push(memento);
        
        // Clear redo stack when new state is saved
        while (!redo_stack.empty()) {
            redo_stack.pop();
        }

        // Limit history size
        if (undo_stack.size() > max_history_size) {
            std::stack<std::shared_ptr<TextMemento>> temp;
            while (undo_stack.size() > max_history_size / 2) {
                temp.push(undo_stack.top());
                undo_stack.pop();
            }
            while (!undo_stack.empty()) undo_stack.pop();
            while (!temp.empty()) {
                undo_stack.push(temp.top());
                temp.pop();
            }
        }

        std::cout << "State saved. Undo stack size: " << undo_stack.size() << std::endl;
    }

    // Save named snapshot
    void save_named_snapshot(const std::shared_ptr<TextMemento>& memento) {
        named_snapshots.push_back(memento);
        std::cout << "Named snapshot saved: " << memento->get_name() << std::endl;
    }

    // Undo operation
    std::shared_ptr<TextMemento> undo() {
        if (undo_stack.size() <= 1) { // Keep at least one state
            std::cout << "Nothing to undo" << std::endl;
            return nullptr;
        }

        // Current state goes to redo stack
        redo_stack.push(undo_stack.top());
        undo_stack.pop();

        // Return previous state
        auto previous_state = undo_stack.top();
        std::cout << "Undo to: " << previous_state->get_name() << std::endl;
        return previous_state;
    }

    // Redo operation
    std::shared_ptr<TextMemento> redo() {
        if (redo_stack.empty()) {
            std::cout << "Nothing to redo" << std::endl;
            return nullptr;
        }

        auto next_state = redo_stack.top();
        redo_stack.pop();
        undo_stack.push(next_state);

        std::cout << "Redo to: " << next_state->get_name() << std::endl;
        return next_state;
    }

    // Get named snapshot by name
    std::shared_ptr<TextMemento> get_named_snapshot(const std::string& name) const {
        for (const auto& snapshot : named_snapshots) {
            if (snapshot->get_name() == name) {
                return snapshot;
            }
        }
        return nullptr;
    }

    // Display history information
    void show_history() const {
        std::cout << "\n=== Document History ===" << std::endl;
        std::cout << "Undo stack: " << undo_stack.size() << " states" << std::endl;
        std::cout << "Redo stack: " << redo_stack.size() << " states" << std::endl;
        std::cout << "Named snapshots: " << named_snapshots.size() << std::endl;

        if (!named_snapshots.empty()) {
            std::cout << "\nNamed Snapshots:" << std::endl;
            for (const auto& snapshot : named_snapshots) {
                std::cout << "- " << snapshot->get_name() << " (" << snapshot->get_timestamp() << ")" << std::endl;
            }
        }

        if (!undo_stack.empty()) {
            std::cout << "\nCurrent State:" << std::endl;
            undo_stack.top()->display();
        }
    }

    // Clear history
    void clear_history() {
        while (!undo_stack.empty()) undo_stack.pop();
        while (!redo_stack.empty()) redo_stack.pop();
        named_snapshots.clear();
        std::cout << "History cleared" << std::endl;
    }
};

// Advanced Text Editor that uses the memento pattern
class AdvancedTextEditor {
private:
    TextDocument document;
    DocumentHistory history;

public:
    AdvancedTextEditor(const std::string& doc_name = "Untitled") 
        : document(doc_name) {
        // Save initial state
        history.save_state(document.create_memento("Initial_State"));
    }

    // Text operations with automatic state saving
    void write_text(const std::string& text) {
        save_current_state();
        document.write(text);
    }

    void delete_text(size_t length) {
        save_current_state();
        document.delete_text(length);
    }

    void move_cursor(size_t position) {
        save_current_state();
        document.set_cursor(position);
    }

    void insert_text_at(size_t position, const std::string& text) {
        save_current_state();
        document.insert_at(position, text);
    }

    // Undo/Redo operations
    void undo() {
        auto memento = history.undo();
        if (memento) {
            document.restore_from_memento(memento);
        }
    }

    void redo() {
        auto memento = history.redo();
        if (memento) {
            document.restore_from_memento(memento);
        }
    }

    // Manual snapshot management
    void save_snapshot(const std::string& name) {
        auto memento = document.create_memento(name);
        history.save_named_snapshot(memento);
    }

    void restore_snapshot(const std::string& name) {
        auto memento = history.get_named_snapshot(name);
        if (memento) {
            save_current_state(); // Save current state before restoring
            document.restore_from_memento(memento);
            history.save_state(memento); // Update current state in history
        } else {
            std::cout << "Snapshot '" << name << "' not found" << std::endl;
        }
    }

    // Display functions
    void show_document() const {
        document.display();
    }

    void show_history() const {
        history.show_history();
    }

    // Get document info
    std::string get_document_name() const {
        return document.get_document_name();
    }

private:
    void save_current_state() {
        history.save_state(document.create_memento());
    }
};

// Demo function
void textEditorDemo() {
    std::cout << "=== Memento Pattern - Advanced Text Editor ===" << std::endl;
    
    AdvancedTextEditor editor("MyDocument.txt");

    std::cout << "\n--- Initial Document ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- Editing Document ---" << std::endl;
    editor.write_text("Hello, this is a sample document.");
    editor.move_cursor(6);
    editor.write_text(" everyone");
    editor.move_cursor(35);
    editor.write_text(" We are demonstrating the Memento pattern.");

    std::cout << "\n--- Current Document ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- Saving Manual Snapshot ---" << std::endl;
    editor.save_snapshot("After_Introduction");

    std::cout << "\n--- More Editing ---" << std::endl;
    editor.move_cursor(0);
    editor.write_text("DOCUMENT START: ");
    editor.move_cursor(100); // Beyond current content
    editor.write_text(" This is the end of the document.");

    std::cout << "\n--- Document After More Editing ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- Undo Operations ---" << std::endl;
    editor.undo(); // Undo last write
    editor.undo(); // Undo "DOCUMENT START: "
    
    std::cout << "\n--- Document After Undo ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- Redo Operation ---" << std::endl;
    editor.redo(); // Redo "DOCUMENT START: "
    
    std::cout << "\n--- Document After Redo ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- Restore Named Snapshot ---" << std::endl;
    editor.restore_snapshot("After_Introduction");
    
    std::cout << "\n--- Document After Snapshot Restore ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- History Overview ---" << std::endl;
    editor.show_history();

    std::cout << "\n--- Complex Editing Sequence ---" << std::endl;
    editor.write_text(" Let's add some more text.");
    editor.delete_text(5);
    editor.write_text(" additional");
    editor.move_cursor(10);
    editor.write_text("INSERT ");

    std::cout << "\n--- Final Document ---" << std::endl;
    editor.show_document();

    std::cout << "\n--- Multiple Undo ---" << std::endl;
    for (int i = 0; i < 5; ++i) {
        editor.undo();
    }

    std::cout << "\n--- Document After Multiple Undo ---" << std::endl;
    editor.show_document();
}

int main() {
    textEditorDemo();
    return 0;
}
```

#### Game Save System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <map>
#include <stack>
#include <ctime>
#include <random>

// Game State Memento
class GameSave {
private:
    std::string player_name;
    int level;
    int health;
    int score;
    std::map<std::string, int> inventory;
    std::string location;
    double play_time;
    std::string save_name;
    std::string timestamp;

public:
    GameSave(const std::string& name, int lvl, int hp, int scr, 
             const std::map<std::string, int>& inv, const std::string& loc, 
             double time, const std::string& save_slot = "")
        : player_name(name), level(lvl), health(hp), score(scr), 
          inventory(inv), location(loc), play_time(time), save_name(save_slot) {
        
        // Generate timestamp
        std::time_t now = std::time(nullptr);
        timestamp = std::ctime(&now);
        timestamp.pop_back();
        
        if (save_name.empty()) {
            save_name = "QuickSave_" + std::to_string(std::time(nullptr));
        }
    }

    // Getters
    std::string get_player_name() const { return player_name; }
    int get_level() const { return level; }
    int get_health() const { return health; }
    int get_score() const { return score; }
    std::map<std::string, int> get_inventory() const { return inventory; }
    std::string get_location() const { return location; }
    double get_play_time() const { return play_time; }
    std::string get_save_name() const { return save_name; }
    std::string get_timestamp() const { return timestamp; }

    void display() const {
        std::cout << "\n=== Game Save: " << save_name << " ===" << std::endl;
        std::cout << "Player: " << player_name << std::endl;
        std::cout << "Level: " << level << std::endl;
        std::cout << "Health: " << health << "/100" << std::endl;
        std::cout << "Score: " << score << std::endl;
        std::cout << "Location: " << location << std::endl;
        std::cout << "Play Time: " << play_time << " hours" << std::endl;
        std::cout << "Timestamp: " << timestamp << std::endl;
        
        std::cout << "Inventory: ";
        if (inventory.empty()) {
            std::cout << "Empty";
        } else {
            for (const auto& item : inventory) {
                std::cout << item.first << "(" << item.second << ") ";
            }
        }
        std::cout << std::endl;
    }
};

// Game Character (Originator)
class GameCharacter {
private:
    std::string name;
    int level;
    int health;
    int score;
    std::map<std::string, int> inventory;
    std::string current_location;
    double total_play_time;

public:
    GameCharacter(const std::string& char_name) 
        : name(char_name), level(1), health(100), score(0), 
          current_location("Starting Area"), total_play_time(0.0) {
        
        // Starting inventory
        inventory["Health Potion"] = 3;
        inventory["Gold"] = 50;
    }

    // Game actions that change state
    void level_up() {
        level++;
        health = 100; // Full health on level up
        std::cout << name << " leveled up to level " << level << "!" << std::endl;
    }

    void take_damage(int damage) {
        health = std::max(0, health - damage);
        std::cout << name << " took " << damage << " damage. Health: " << health << "/100" << std::endl;
    }

    void heal(int amount) {
        health = std::min(100, health + amount);
        std::cout << name << " healed " << amount << " HP. Health: " << health << "/100" << std::endl;
    }

    void add_score(int points) {
        score += points;
        std::cout << name << " gained " << points << " points. Total score: " << score << std::endl;
    }

    void add_item(const std::string& item, int quantity = 1) {
        inventory[item] += quantity;
        std::cout << "Added " << quantity << " " << item << "(s) to inventory" << std::endl;
    }

    void use_item(const std::string& item) {
        if (inventory[item] > 0) {
            inventory[item]--;
            if (inventory[item] == 0) {
                inventory.erase(item);
            }
            std::cout << "Used one " << item << std::endl;
        } else {
            std::cout << "No " << item << " in inventory" << std::endl;
        }
    }

    void move_to(const std::string& location) {
        current_location = location;
        std::cout << name << " moved to " << location << std::endl;
    }

    void add_play_time(double hours) {
        total_play_time += hours;
    }

    // Create save memento
    std::shared_ptr<GameSave> create_save(const std::string& save_name = "") const {
        return std::make_shared<GameSave>(name, level, health, score, 
                                         inventory, current_location, 
                                         total_play_time, save_name);
    }

    // Restore from save memento
    void load_save(const std::shared_ptr<GameSave>& save) {
        name = save->get_player_name();
        level = save->get_level();
        health = save->get_health();
        score = save->get_score();
        inventory = save->get_inventory();
        current_location = save->get_location();
        total_play_time = save->get_play_time();
        
        std::cout << "Game loaded from save: " << save->get_save_name() << std::endl;
    }

    // Display current state
    void display_status() const {
        std::cout << "\n=== " << name << "'s Status ===" << std::endl;
        std::cout << "Level: " << level << std::endl;
        std::cout << "Health: " << health << "/100" << std::endl;
        std::cout << "Score: " << score << std::endl;
        std::cout << "Location: " << current_location << std::endl;
        std::cout << "Play Time: " << total_play_time << " hours" << std::endl;
        
        std::cout << "Inventory: ";
        if (inventory.empty()) {
            std::cout << "Empty";
        } else {
            for (const auto& item : inventory) {
                std::cout << item.first << "(" << item.second << ") ";
            }
        }
        std::cout << std::endl;
    }

    // Getters
    std::string get_name() const { return name; }
    int get_level() const { return level; }
    int get_health() const { return health; }
};

// Save Manager (Caretaker)
class SaveManager {
private:
    std::map<std::string, std::shared_ptr<GameSave>> save_slots;
    std::stack<std::shared_ptr<GameSave>> quick_saves;
    size_t max_quick_saves;

public:
    SaveManager(size_t max_quick = 10) : max_quick_saves(max_quick) {}

    // Save to named slot
    void save_to_slot(const std::string& slot_name, const std::shared_ptr<GameSave>& save) {
        save_slots[slot_name] = save;
        std::cout << "Game saved to slot: " << slot_name << std::endl;
    }

    // Quick save
    void quick_save(const std::shared_ptr<GameSave>& save) {
        quick_saves.push(save);
        
        // Limit quick save stack size
        if (quick_saves.size() > max_quick_saves) {
            std::stack<std::shared_ptr<GameSave>> temp;
            while (quick_saves.size() > max_quick_saves / 2) {
                temp.push(quick_saves.top());
                quick_saves.pop();
            }
            while (!quick_saves.empty()) quick_saves.pop();
            while (!temp.empty()) {
                quick_saves.push(temp.top());
                temp.pop();
            }
        }
        
        std::cout << "Quick save created. Total quick saves: " << quick_saves.size() << std::endl;
    }

    // Load from named slot
    std::shared_ptr<GameSave> load_from_slot(const std::string& slot_name) const {
        auto it = save_slots.find(slot_name);
        if (it != save_slots.end()) {
            std::cout << "Loading from slot: " << slot_name << std::endl;
            return it->second;
        } else {
            std::cout << "Save slot '" << slot_name << "' not found!" << std::endl;
            return nullptr;
        }
    }

    // Load last quick save
    std::shared_ptr<GameSave> load_last_quick_save() {
        if (!quick_saves.empty()) {
            auto save = quick_saves.top();
            std::cout << "Loading last quick save: " << save->get_save_name() << std::endl;
            return save;
        } else {
            std::cout << "No quick saves available!" << std::endl;
            return nullptr;
        }
    }

    // Show all saves
    void show_saves() const {
        std::cout << "\n=== Save Manager ===" << std::endl;
        
        std::cout << "Named Save Slots:" << std::endl;
        if (save_slots.empty()) {
            std::cout << "  No named saves" << std::endl;
        } else {
            for (const auto& slot : save_slots) {
                std::cout << "  " << slot.first << " - " << slot.second->get_timestamp() << std::endl;
            }
        }
        
        std::cout << "Quick Saves: " << quick_saves.size() << std::endl;
        if (!quick_saves.empty()) {
            std::cout << "Last Quick Save: " << quick_saves.top()->get_timestamp() << std::endl;
        }
    }

    // Delete save slot
    void delete_save_slot(const std::string& slot_name) {
        if (save_slots.erase(slot_name)) {
            std::cout << "Deleted save slot: " << slot_name << std::endl;
        } else {
            std::cout << "Save slot '" << slot_name << "' not found!" << std::endl;
        }
    }

    // Clear all quick saves
    void clear_quick_saves() {
        while (!quick_saves.empty()) quick_saves.pop();
        std::cout << "All quick saves cleared" << std::endl;
    }
};

// Game System
class GameSystem {
private:
    GameCharacter player;
    SaveManager save_manager;
    std::mt19937 rng;

public:
    GameSystem(const std::string& player_name) 
        : player(player_name), rng(std::random_device{}()) {}

    // Game actions with auto-save capability
    void play_game_session(double hours = 1.0) {
        std::cout << "\n--- Playing Game for " << hours << " hours ---" << std::endl;
        
        player.add_play_time(hours);
        
        // Simulate random game events
        std::uniform_int_distribution<int> event_dist(1, 5);
        int events = event_dist(rng);
        
        for (int i = 0; i < events; ++i) {
            simulate_random_event();
        }
        
        // Auto-save after session
        save_manager.quick_save(player.create_save());
    }

    void manual_save(const std::string& slot_name) {
        save_manager.save_to_slot(slot_name, player.create_save(slot_name));
    }

    void load_game(const std::string& slot_name) {
        auto save = save_manager.load_from_slot(slot_name);
        if (save) {
            player.load_save(save);
        }
    }

    void load_last_quick_save() {
        auto save = save_manager.load_last_quick_save();
        if (save) {
            player.load_save(save);
        }
    }

    void show_player_status() const {
        player.display_status();
    }

    void show_save_info() const {
        save_manager.show_saves();
    }

    // Direct character actions (for demo)
    void level_up() { player.level_up(); }
    void take_damage(int damage) { player.take_damage(damage); }
    void heal(int amount) { player.heal(amount); }
    void add_score(int points) { player.add_score(points); }
    void add_item(const std::string& item, int quantity = 1) { player.add_item(item, quantity); }
    void use_item(const std::string& item) { player.use_item(item); }
    void move_to(const std::string& location) { player.move_to(location); }

private:
    void simulate_random_event() {
        std::uniform_int_distribution<int> dist(1, 6);
        switch (dist(rng)) {
            case 1:
                player.level_up();
                break;
            case 2:
                player.take_damage(dist(rng) * 5);
                break;
            case 3:
                player.heal(dist(rng) * 10);
                break;
            case 4:
                player.add_score(dist(rng) * 100);
                break;
            case 5:
                player.add_item("Magic Scroll", 1);
                break;
            case 6:
                player.move_to("Random Location");
                break;
        }
    }
};

// Demo function
void gameSaveDemo() {
    std::cout << "=== Memento Pattern - Game Save System ===" << std::endl;
    
    GameSystem game("HeroPlayer123");

    std::cout << "\n--- Initial Player Status ---" << std::endl;
    game.show_player_status();

    std::cout << "\n--- First Gaming Session ---" << std::endl;
    game.play_game_session(2.5);

    std::cout << "\n--- Manual Actions ---" << std::endl;
    game.level_up();
    game.add_item("Dragon Sword", 1);
    game.add_score(500);
    game.move_to("Dragon's Lair");

    std::cout << "\n--- Player Status After Actions ---" << std::endl;
    game.show_player_status();

    std::cout << "\n--- Manual Save ---" << std::endl;
    game.manual_save("Before_Dragon_Fight");

    std::cout << "\n--- Second Gaming Session ---" << std::endl;
    game.play_game_session(1.5);
    game.take_damage(30);
    game.use_item("Health Potion");

    std::cout << "\n--- Player Status Before Disaster ---" << std::endl;
    game.show_player_status();

    std::cout << "\n--- Disaster Strikes! ---" << std::endl;
    game.take_damage(80); // Almost dead!
    game.use_item("Health Potion");
    game.take_damage(50); // Player dies

    std::cout << "\n--- Player Status After Disaster ---" << std::endl;
    game.show_player_status();

    std::cout << "\n--- Loading Manual Save ---" << std::endl;
    game.load_game("Before_Dragon_Fight");

    std::cout << "\n--- Player Status After Load ---" << std::endl;
    game.show_player_status();

    std::cout << "\n--- Third Gaming Session ---" << std::endl;
    game.play_game_session(3.0);
    game.add_item("Ancient Artifact", 1);
    game.level_up();

    std::cout << "\n--- Loading Last Quick Save ---" << std::endl;
    game.load_last_quick_save();

    std::cout << "\n--- Final Player Status ---" << std::endl;
    game.show_player_status();

    std::cout << "\n--- Save Manager Status ---" << std::endl;
    game.show_save_info();
}

int main() {
    gameSaveDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAX_CONFIG_ENTRIES 20
#define MAX_KEY_LENGTH 50
#define MAX_VALUE_LENGTH 100
#define MAX_SNAPSHOTS 10

// Configuration Memento
typedef struct {
    char key[MAX_KEY_LENGTH];
    char value[MAX_VALUE_LENGTH];
} ConfigEntry;

typedef struct {
    ConfigEntry entries[MAX_CONFIG_ENTRIES];
    int entry_count;
    char snapshot_name[50];
    time_t timestamp;
} ConfigMemento;

// Originator: Configuration Manager
typedef struct {
    ConfigEntry entries[MAX_CONFIG_ENTRIES];
    int entry_count;
    char config_name[50];
} ConfigManager;

// Caretaker: Configuration History
typedef struct {
    ConfigMemento snapshots[MAX_SNAPSHOTS];
    int snapshot_count;
    int current_snapshot;
} ConfigHistory;

// Memento functions
ConfigMemento* create_config_memento(const ConfigManager* manager, const char* name) {
    ConfigMemento* memento = malloc(sizeof(ConfigMemento));
    
    // Copy all entries
    memento->entry_count = manager->entry_count;
    for (int i = 0; i < manager->entry_count; i++) {
        strcpy(memento->entries[i].key, manager->entries[i].key);
        strcpy(memento->entries[i].value, manager->entries[i].value);
    }
    
    // Set metadata
    strcpy(memento->snapshot_name, name);
    memento->timestamp = time(NULL);
    
    printf("Created snapshot: %s\n", name);
    return memento;
}

void restore_from_memento(ConfigManager* manager, const ConfigMemento* memento) {
    manager->entry_count = memento->entry_count;
    for (int i = 0; i < memento->entry_count; i++) {
        strcpy(manager->entries[i].key, memento->entries[i].key);
        strcpy(manager->entries[i].value, memento->entries[i].value);
    }
    
    printf("Restored from snapshot: %s\n", memento->snapshot_name);
}

void display_memento(const ConfigMemento* memento) {
    printf("\n=== Snapshot: %s ===\n", memento->snapshot_name);
    printf("Timestamp: %s", ctime(&memento->timestamp));
    printf("Entries: %d\n", memento->entry_count);
    
    for (int i = 0; i < memento->entry_count; i++) {
        printf("  %s = %s\n", memento->entries[i].key, memento->entries[i].value);
    }
}

// ConfigManager functions
void config_manager_init(ConfigManager* manager, const char* name) {
    manager->entry_count = 0;
    strcpy(manager->config_name, name);
    printf("Initialized config manager: %s\n", name);
}

void config_manager_set(ConfigManager* manager, const char* key, const char* value) {
    // Check if key already exists
    for (int i = 0; i < manager->entry_count; i++) {
        if (strcmp(manager->entries[i].key, key) == 0) {
            strcpy(manager->entries[i].value, value);
            printf("Updated %s = %s\n", key, value);
            return;
        }
    }
    
    // Add new entry
    if (manager->entry_count < MAX_CONFIG_ENTRIES) {
        strcpy(manager->entries[manager->entry_count].key, key);
        strcpy(manager->entries[manager->entry_count].value, value);
        manager->entry_count++;
        printf("Set %s = %s\n", key, value);
    } else {
        printf("Error: Maximum configuration entries reached!\n");
    }
}

void config_manager_remove(ConfigManager* manager, const char* key) {
    for (int i = 0; i < manager->entry_count; i++) {
        if (strcmp(manager->entries[i].key, key) == 0) {
            // Shift remaining entries
            for (int j = i; j < manager->entry_count - 1; j++) {
                strcpy(manager->entries[j].key, manager->entries[j + 1].key);
                strcpy(manager->entries[j].value, manager->entries[j + 1].value);
            }
            manager->entry_count--;
            printf("Removed %s\n", key);
            return;
        }
    }
    printf("Key %s not found\n", key);
}

char* config_manager_get(const ConfigManager* manager, const char* key) {
    for (int i = 0; i < manager->entry_count; i++) {
        if (strcmp(manager->entries[i].key, key) == 0) {
            return manager->entries[i].value;
        }
    }
    return NULL;
}

void config_manager_display(const ConfigManager* manager) {
    printf("\n=== Configuration: %s ===\n", manager->config_name);
    printf("Total entries: %d\n", manager->entry_count);
    
    for (int i = 0; i < manager->entry_count; i++) {
        printf("%s = %s\n", manager->entries[i].key, manager->entries[i].value);
    }
}

// ConfigHistory functions
void config_history_init(ConfigHistory* history) {
    history->snapshot_count = 0;
    history->current_snapshot = -1;
    printf("Initialized configuration history\n");
}

void config_history_save(ConfigHistory* history, const ConfigMemento* memento) {
    if (history->snapshot_count < MAX_SNAPSHOTS) {
        history->snapshots[history->snapshot_count] = *memento;
        history->current_snapshot = history->snapshot_count;
        history->snapshot_count++;
        printf("Saved snapshot to history. Total: %d\n", history->snapshot_count);
    } else {
        printf("Error: Maximum snapshots reached!\n");
    }
}

ConfigMemento* config_history_get_current(const ConfigHistory* history) {
    if (history->current_snapshot >= 0 && history->current_snapshot < history->snapshot_count) {
        return &history->snapshots[history->current_snapshot];
    }
    return NULL;
}

ConfigMemento* config_history_get_by_name(const ConfigHistory* history, const char* name) {
    for (int i = 0; i < history->snapshot_count; i++) {
        if (strcmp(history->snapshots[i].snapshot_name, name) == 0) {
            return &history->snapshots[i];
        }
    }
    return NULL;
}

void config_history_list(const ConfigHistory* history) {
    printf("\n=== Configuration History ===\n");
    printf("Total snapshots: %d\n", history->snapshot_count);
    
    for (int i = 0; i < history->snapshot_count; i++) {
        printf("%d. %s - %s", i + 1, history->snapshots[i].snapshot_name, 
               ctime(&history->snapshots[i].timestamp));
    }
    
    if (history->current_snapshot >= 0) {
        printf("Current: %s\n", history->snapshots[history->current_snapshot].snapshot_name);
    }
}

// Demo function
void configurationDemo() {
    printf("=== Memento Pattern - Configuration Management System ===\n\n");
    
    ConfigManager config;
    ConfigHistory history;
    
    // Initialize
    config_manager_init(&config, "AppConfig");
    config_history_init(&history);
    
    // Set initial configuration
    printf("\n--- Setting Initial Configuration ---\n");
    config_manager_set(&config, "database.host", "localhost");
    config_manager_set(&config, "database.port", "5432");
    config_manager_set(&config, "database.user", "admin");
    config_manager_set(&config, "app.debug", "true");
    config_manager_set(&config, "app.port", "8080");
    
    config_manager_display(&config);
    
    // Save initial snapshot
    printf("\n--- Saving Initial Snapshot ---\n");
    ConfigMemento* initial_snapshot = create_config_memento(&config, "Initial_Setup");
    config_history_save(&history, initial_snapshot);
    free(initial_snapshot);
    
    // Modify configuration
    printf("\n--- Modifying Configuration ---\n");
    config_manager_set(&config, "database.host", "production-db.example.com");
    config_manager_set(&config, "app.debug", "false");
    config_manager_set(&config, "app.timeout", "30");
    config_manager_remove(&config, "database.user");
    
    config_manager_display(&config);
    
    // Save production snapshot
    printf("\n--- Saving Production Snapshot ---\n");
    ConfigMemento* production_snapshot = create_config_memento(&config, "Production_Config");
    config_history_save(&history, production_snapshot);
    free(production_snapshot);
    
    // More modifications
    printf("\n--- Experimental Changes ---\n");
    config_manager_set(&config, "app.experimental_feature", "enabled");
    config_manager_set(&config, "app.port", "9090");
    config_manager_set(&config, "cache.enabled", "true");
    
    config_manager_display(&config);
    
    // Save experimental snapshot
    printf("\n--- Saving Experimental Snapshot ---\n");
    ConfigMemento* experimental_snapshot = create_config_memento(&config, "Experimental_Config");
    config_history_save(&history, experimental_snapshot);
    free(experimental_snapshot);
    
    // Show history
    config_history_list(&history);
    
    // Restore production configuration
    printf("\n--- Restoring Production Configuration ---\n");
    ConfigMemento* prod_snapshot = config_history_get_by_name(&history, "Production_Config");
    if (prod_snapshot) {
        restore_from_memento(&config, prod_snapshot);
        config_manager_display(&config);
    }
    
    // Restore initial configuration
    printf("\n--- Restoring Initial Configuration ---\n");
    ConfigMemento* init_snapshot = config_history_get_by_name(&history, "Initial_Setup");
    if (init_snapshot) {
        restore_from_memento(&config, init_snapshot);
        config_manager_display(&config);
    }
    
    // Display all snapshots
    printf("\n--- All Snapshots Details ---\n");
    for (int i = 0; i < history.snapshot_count; i++) {
        display_memento(&history.snapshots[i]);
    }
}

int main() {
    configurationDemo();
    return 0;
}
```

### Python Implementation

#### Browser History System

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime
import time
from urllib.parse import urlparse
from enum import Enum

class PageLoadStatus(Enum):
    LOADED = "loaded"
    LOADING = "loading"
    ERROR = "error"
    CACHED = "cached"

# Memento: Browser Tab State
class TabMemento:
    def __init__(self, url: str, title: str, scroll_position: int, 
                 content: str, favicon: str, status: PageLoadStatus,
                 memento_name: str = ""):
        self.url = url
        self.title = title
        self.scroll_position = scroll_position
        self.content = content
        self.favicon = favicon
        self.status = status
        self.timestamp = datetime.now()
        self.memento_name = memento_name or f"TabState_{int(self.timestamp.timestamp())}"
    
    def display(self) -> None:
        print(f"\n=== Tab Snapshot: {self.memento_name} ===")
        print(f"URL: {self.url}")
        print(f"Title: {self.title}")
        print(f"Scroll Position: {self.scroll_position}px")
        print(f"Status: {self.status.value}")
        print(f"Favicon: {self.favicon}")
        print(f"Timestamp: {self.timestamp}")
        print(f"Content Preview: {self.content[:100]}...")

# Originator: Browser Tab
class BrowserTab:
    def __init__(self, initial_url: str = "about:blank"):
        self.url = initial_url
        self.title = "New Tab"
        self.scroll_position = 0
        self.content = ""
        self.favicon = "default_icon.ico"
        self.status = PageLoadStatus.LOADED
        self.load_time = 0.0
        self.visit_count = 0
    
    def navigate(self, url: str) -> None:
        print(f"🌐 Navigating to: {url}")
        self.url = url
        self.title = f"Loading {url}..."
        self.scroll_position = 0
        self.status = PageLoadStatus.LOADING
        
        # Simulate page load
        time.sleep(0.5)
        
        # Extract domain for title
        domain = urlparse(url).netloc or "local"
        self.title = f"Welcome to {domain}"
        self.content = f"<html><body><h1>Welcome to {domain}</h1><p>Sample content for {url}</p>" + "<br>" * 50 + "</body></html>"
        self.favicon = f"{domain}_favicon.ico"
        self.status = PageLoadStatus.LOADED
        self.load_time = time.time()
        self.visit_count += 1
        
        print(f"✅ Page loaded: {self.title}")
    
    def scroll(self, pixels: int) -> None:
        self.scroll_position = max(0, self.scroll_position + pixels)
        print(f"📜 Scrolled to position: {self.scroll_position}px")
    
    def refresh(self) -> None:
        print("🔄 Refreshing page...")
        self.status = PageLoadStatus.LOADING
        time.sleep(0.3)
        self.status = PageLoadStatus.LOADED
        self.scroll_position = 0
        print("✅ Page refreshed")
    
    def update_content(self, new_content: str) -> None:
        self.content = new_content
        print("📝 Content updated")
    
    # Create memento
    def create_memento(self, name: str = "") -> TabMemento:
        return TabMemento(
            self.url, self.title, self.scroll_position,
            self.content, self.favicon, self.status,
            name
        )
    
    # Restore from memento
    def restore_from_memento(self, memento: TabMemento) -> None:
        self.url = memento.url
        self.title = memento.title
        self.scroll_position = memento.scroll_position
        self.content = memento.content
        self.favicon = memento.favicon
        self.status = memento.status
        print(f"🔄 Tab restored from snapshot: {memento.memento_name}")
    
    def display(self) -> None:
        print(f"\n=== Browser Tab ===")
        print(f"URL: {self.url}")
        print(f"Title: {self.title}")
        print(f"Scroll: {self.scroll_position}px")
        print(f"Status: {self.status.value}")
        print(f"Favicon: {self.favicon}")
        print(f"Visits: {self.visit_count}")

# Caretaker: Browser History
class BrowserHistory:
    def __init__(self, max_history_size: int = 50):
        self.history: List[TabMemento] = []
        self.forward_stack: List[TabMemento] = []
        self.max_history_size = max_history_size
        self.named_snapshots: Dict[str, TabMemento] = {}
    
    def push_state(self, memento: TabMemento) -> None:
        """Add new state to history"""
        self.history.append(memento)
        self.forward_stack.clear()  # Clear forward stack when new state is added
        
        # Limit history size
        if len(self.history) > self.max_history_size:
            self.history.pop(0)
        
        print(f"📚 History entry added. Total: {len(self.history)}")
    
    def go_back(self) -> TabMemento:
        """Go back to previous state"""
        if len(self.history) < 2:
            print("❌ Cannot go back - no previous page")
            return None
        
        # Current state goes to forward stack
        current = self.history.pop()
        self.forward_stack.append(current)
        
        previous = self.history[-1]
        print(f"⏪ Went back to: {previous.memento_name}")
        return previous
    
    def go_forward(self) -> TabMemento:
        """Go forward to next state"""
        if not self.forward_stack:
            print("❌ Cannot go forward - no next page")
            return None
        
        next_state = self.forward_stack.pop()
        self.history.append(next_state)
        print(f"⏩ Went forward to: {next_state.memento_name}")
        return next_state
    
    def save_named_snapshot(self, name: str, memento: TabMemento) -> None:
        """Save a named snapshot"""
        self.named_snapshots[name] = memento
        print(f"💾 Named snapshot saved: {name}")
    
    def load_named_snapshot(self, name: str) -> TabMemento:
        """Load a named snapshot"""
        if name in self.named_snapshots:
            print(f"📂 Loading named snapshot: {name}")
            return self.named_snapshots[name]
        else:
            print(f"❌ Named snapshot '{name}' not found")
            return None
    
    def clear_history(self) -> None:
        """Clear browsing history"""
        self.history.clear()
        self.forward_stack.clear()
        print("🗑️  Browsing history cleared")
    
    def show_history(self) -> None:
        """Display browsing history"""
        print(f"\n=== Browsing History ===")
        print(f"Back entries: {len(self.history)}")
        print(f"Forward entries: {len(self.forward_stack)}")
        print(f"Named snapshots: {len(self.named_snapshots)}")
        
        if self.history:
            print("\nRecent History:")
            for i, state in enumerate(reversed(self.history[-5:]), 1):
                print(f"{i}. {state.title} ({state.url}) - {state.timestamp.strftime('%H:%M:%S')}")
        
        if self.named_snapshots:
            print("\nNamed Snapshots:")
            for name in self.named_snapshots.keys():
                print(f"- {name}")

# Browser with multiple tabs
class WebBrowser:
    def __init__(self):
        self.tabs: Dict[int, BrowserTab] = {}
        self.histories: Dict[int, BrowserHistory] = {}
        self.current_tab_id = 0
        self.next_tab_id = 1
    
    def create_new_tab(self, url: str = "about:blank") -> int:
        """Create a new browser tab"""
        tab_id = self.next_tab_id
        self.next_tab_id += 1
        
        self.tabs[tab_id] = BrowserTab(url)
        self.histories[tab_id] = BrowserHistory()
        
        # Save initial state
        initial_memento = self.tabs[tab_id].create_memento("Initial_State")
        self.histories[tab_id].push_state(initial_memento)
        
        print(f"📑 Created new tab #{tab_id} with URL: {url}")
        return tab_id
    
    def close_tab(self, tab_id: int) -> None:
        """Close a browser tab"""
        if tab_id in self.tabs:
            del self.tabs[tab_id]
            del self.histories[tab_id]
            print(f"❌ Closed tab #{tab_id}")
            
            # Switch to another tab if current tab was closed
            if self.current_tab_id == tab_id:
                if self.tabs:
                    self.current_tab_id = next(iter(self.tabs.keys()))
                else:
                    self.current_tab_id = 0
        else:
            print(f"Tab #{tab_id} not found")
    
    def switch_tab(self, tab_id: int) -> None:
        """Switch to a different tab"""
        if tab_id in self.tabs:
            self.current_tab_id = tab_id
            print(f"🔍 Switched to tab #{tab_id}")
        else:
            print(f"Tab #{tab_id} not found")
    
    def navigate_current_tab(self, url: str) -> None:
        """Navigate current tab to URL"""
        if self.current_tab_id == 0:
            print("No active tab")
            return
        
        tab = self.tabs[self.current_tab_id]
        history = self.histories[self.current_tab_id]
        
        # Save current state before navigation
        current_memento = tab.create_memento()
        history.push_state(current_memento)
        
        # Navigate to new URL
        tab.navigate(url)
        
        # Save new state
        new_memento = tab.create_memento()
        history.push_state(new_memento)
    
    def back_current_tab(self) -> None:
        """Go back in current tab"""
        if self.current_tab_id == 0:
            return
        
        history = self.histories[self.current_tab_id]
        previous_state = history.go_back()
        
        if previous_state:
            self.tabs[self.current_tab_id].restore_from_memento(previous_state)
    
    def forward_current_tab(self) -> None:
        """Go forward in current tab"""
        if self.current_tab_id == 0:
            return
        
        history = self.histories[self.current_tab_id]
        next_state = history.go_forward()
        
        if next_state:
            self.tabs[self.current_tab_id].restore_from_memento(next_state)
    
    def save_tab_snapshot(self, name: str) -> None:
        """Save named snapshot of current tab"""
        if self.current_tab_id == 0:
            return
        
        tab = self.tabs[self.current_tab_id]
        history = self.histories[self.current_tab_id]
        
        memento = tab.create_memento(name)
        history.save_named_snapshot(name, memento)
    
    def restore_tab_snapshot(self, name: str) -> None:
        """Restore named snapshot in current tab"""
        if self.current_tab_id == 0:
            return
        
        history = self.histories[self.current_tab_id]
        snapshot = history.load_named_snapshot(name)
        
        if snapshot:
            self.tabs[self.current_tab_id].restore_from_memento(snapshot)
    
    def display_current_tab(self) -> None:
        """Display current tab state"""
        if self.current_tab_id == 0:
            print("No active tab")
            return
        
        print(f"\n=== Current Tab #{self.current_tab_id} ===")
        self.tabs[self.current_tab_id].display()
    
    def display_all_tabs(self) -> None:
        """Display all tabs"""
        print(f"\n=== All Tabs ===")
        for tab_id, tab in self.tabs.items():
            current_indicator = " *" if tab_id == self.current_tab_id else ""
            print(f"Tab #{tab_id}{current_indicator}: {tab.title} ({tab.url})")
    
    def display_tab_history(self, tab_id: int = None) -> None:
        """Display history for a tab"""
        target_tab_id = tab_id or self.current_tab_id
        
        if target_tab_id in self.histories:
            print(f"\n=== History for Tab #{target_tab_id} ===")
            self.histories[target_tab_id].show_history()

# Demo function
def browserHistoryDemo():
    print("=== Memento Pattern - Web Browser History System ===\n")
    
    browser = WebBrowser()
    
    # Create tabs and browse
    print("--- Creating Tabs and Browsing ---")
    tab1 = browser.create_new_tab("https://www.google.com")
    browser.switch_tab(tab1)
    
    browser.navigate_current_tab("https://www.github.com")
    browser.navigate_current_tab("https://www.stackoverflow.com")
    
    # Create second tab
    tab2 = browser.create_new_tab("https://www.python.org")
    browser.switch_tab(tab2)
    browser.navigate_current_tab("https://www.djangoproject.com")
    
    # Display current state
    browser.display_all_tabs()
    browser.display_current_tab()
    
    # Test navigation history
    print("\n--- Testing Back/Forward Navigation ---")
    browser.back_current_tab()
    browser.display_current_tab()
    
    browser.forward_current_tab()
    browser.display_current_tab()
    
    # Save named snapshot
    print("\n--- Saving Named Snapshots ---")
    browser.save_tab_snapshot("Python_Django_Setup")
    
    # More browsing
    browser.navigate_current_tab("https://www.postgresql.org")
    browser.navigate_current_tab("https://www.redis.io")
    
    browser.display_current_tab()
    
    # Restore named snapshot
    print("\n--- Restoring Named Snapshot ---")
    browser.restore_tab_snapshot("Python_Django_Setup")
    browser.display_current_tab()
    
    # Test multiple back
    print("\n--- Multiple Back Navigation ---")
    browser.switch_tab(tab1)
    browser.display_current_tab()
    
    browser.back_current_tab()
    browser.back_current_tab()
    browser.display_current_tab()
    
    # Show histories
    browser.display_tab_history(tab1)
    browser.display_tab_history(tab2)
    
    # Complex scenario
    print("\n--- Complex Browsing Scenario ---")
    tab3 = browser.create_new_tab("https://www.wikipedia.org")
    browser.switch_tab(tab3)
    
    browser.navigate_current_tab("https://en.wikipedia.org/wiki/Design_Patterns")
    browser.save_tab_snapshot("Design_Patterns_Article")
    
    browser.navigate_current_tab("https://en.wikipedia.org/wiki/Software_engineering")
    browser.navigate_current_tab("https://en.wikipedia.org/wiki/Computer_science")
    
    # Multiple back and forward
    for _ in range(3):
        browser.back_current_tab()
    
    browser.display_current_tab()
    
    for _ in range(2):
        browser.forward_current_tab()
    
    browser.display_current_tab()
    
    # Final state
    print("\n--- Final Browser State ---")
    browser.display_all_tabs()
    for tab_id in browser.tabs.keys():
        browser.display_tab_history(tab_id)

if __name__ == "__main__":
    browserHistoryDemo()
```

## Advantages and Disadvantages

### Advantages

- **Preserves Encapsulation**: Doesn't expose object's internal state
- **Simplifies Originator**: Originator doesn't need to manage state history
- **Easy State Restoration**: Simple mechanism to restore previous states
- **Snapshot Capability**: Can capture state at any point in time
- **Undo/Redo Implementation**: Perfect foundation for undo/redo functionality

### Disadvantages

- **Memory Consumption**: Can use significant memory if states are large
- **Performance Overhead**: Creating and restoring mementos can be expensive
- **Complexity**: Adds additional classes and complexity to the system
- **Memento Storage**: Caretaker needs to manage memento lifecycle

## Best Practices

1. **Use for Critical State**: Only save state that's necessary for restoration
2. **Implement Memento Limits**: Set reasonable limits on history size
3. **Consider Serialization**: For persistent storage, implement memento serialization
4. **Optimize Large States**: For large states, consider incremental or differential snapshots
5. **Clear Old States**: Implement cleanup mechanisms for old mementos

## Memento vs Other Patterns

- **vs Command**: Memento stores state, Command stores operations
- **vs Prototype**: Memento captures specific state, Prototype clones entire object
- **vs Snapshot**: Memento is a specific implementation of snapshot pattern
- **vs State**: Memento captures state, State pattern manages state transitions

The Memento pattern is essential for implementing features like undo/redo, save/load systems, and state restoration. It's widely used in text editors, graphic editors, games, and any application where users need to revert to previous states.
