# Command Pattern

## Introduction

The Command Pattern is a behavioral design pattern that turns a request into a stand-alone object containing all information about the request. This transformation lets you parameterize methods with different requests, delay or queue a request's execution, and support undoable operations.

### Key Characteristics
- **Request Encapsulation**: Encapsulates a request as an object
- **Decoupling**: Separates the object that invokes the operation from the one that knows how to perform it
- **Undo/Redo Support**: Enables implementation of undo and redo functionality
- **Queueing & Logging**: Allows requests to be queued, logged, or executed at different times

### Use Cases
- GUI buttons and menu items
- Macro recording and playback
- Transactional behavior
- Undo/redo functionality
- Task scheduling and job queues
- Network request handling

## Implementation Examples

### C++ Implementation

#### Smart Home System Example
```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <unordered_map>
#include <chrono>
#include <queue>

// Command Interface
class Command {
public:
    virtual ~Command() = default;
    virtual void execute() = 0;
    virtual void undo() = 0;
    virtual std::string get_name() const = 0;
};

// Receiver Classes
class Light {
private:
    std::string location;
    bool is_on;
    int brightness;

public:
    Light(const std::string& loc) : location(loc), is_on(false), brightness(100) {}
    
    void turn_on() {
        is_on = true;
        std::cout << location << " light is ON (brightness: " << brightness << "%)" << std::endl;
    }
    
    void turn_off() {
        is_on = false;
        std::cout << location << " light is OFF" << std::endl;
    }
    
    void set_brightness(int level) {
        brightness = level;
        if (is_on) {
            std::cout << location << " light brightness set to " << brightness << "%" << std::endl;
        }
    }
    
    bool get_state() const { return is_on; }
    int get_brightness() const { return brightness; }
    std::string get_location() const { return location; }
};

class Thermostat {
private:
    double temperature;
    double target_temperature;
    std::string mode; // "heat", "cool", "off"

public:
    Thermostat() : temperature(72.0), target_temperature(72.0), mode("off") {}
    
    void set_temperature(double temp) {
        target_temperature = temp;
        std::cout << "Thermostat set to " << target_temperature << "°F" << std::endl;
        update_mode();
    }
    
    void set_mode(const std::string& new_mode) {
        mode = new_mode;
        std::cout << "Thermostat mode set to: " << mode << std::endl;
    }
    
    double get_temperature() const { return temperature; }
    double get_target_temperature() const { return target_temperature; }
    std::string get_mode() const { return mode; }

private:
    void update_mode() {
        if (temperature < target_temperature - 2) {
            mode = "heat";
        } else if (temperature > target_temperature + 2) {
            mode = "cool";
        } else {
            mode = "off";
        }
    }
};

class GarageDoor {
private:
    bool is_open;
    bool light_on;

public:
    GarageDoor() : is_open(false), light_on(false) {}
    
    void open() {
        is_open = true;
        light_on = true;
        std::cout << "Garage door is OPEN" << std::endl;
    }
    
    void close() {
        is_open = false;
        light_on = false;
        std::cout << "Garage door is CLOSED" << std::endl;
    }
    
    void toggle_light() {
        light_on = !light_on;
        std::cout << "Garage door light is " << (light_on ? "ON" : "OFF") << std::endl;
    }
    
    bool is_door_open() const { return is_open; }
    bool is_light_on() const { return light_on; }
};

// Concrete Commands
class LightOnCommand : public Command {
private:
    Light& light;
    int previous_brightness;
    bool previous_state;

public:
    LightOnCommand(Light& l) : light(l), previous_brightness(100), previous_state(false) {}
    
    void execute() override {
        previous_state = light.get_state();
        previous_brightness = light.get_brightness();
        light.turn_on();
    }
    
    void undo() override {
        if (!previous_state) {
            light.turn_off();
        }
        light.set_brightness(previous_brightness);
        std::cout << "Undo: Restored " << light.get_location() << " light state" << std::endl;
    }
    
    std::string get_name() const override {
        return "Turn ON " + light.get_location() + " light";
    }
};

class LightOffCommand : public Command {
private:
    Light& light;
    int previous_brightness;
    bool previous_state;

public:
    LightOffCommand(Light& l) : light(l), previous_brightness(100), previous_state(false) {}
    
    void execute() override {
        previous_state = light.get_state();
        previous_brightness = light.get_brightness();
        light.turn_off();
    }
    
    void undo() override {
        if (previous_state) {
            light.turn_on();
            light.set_brightness(previous_brightness);
        }
        std::cout << "Undo: Restored " << light.get_location() << " light state" << std::endl;
    }
    
    std::string get_name() const override {
        return "Turn OFF " + light.get_location() + " light";
    }
};

class ThermostatCommand : public Command {
private:
    Thermostat& thermostat;
    double temperature;
    double previous_temperature;
    std::string previous_mode;

public:
    ThermostatCommand(Thermostat& t, double temp) 
        : thermostat(t), temperature(temp), previous_temperature(72.0), previous_mode("off") {}
    
    void execute() override {
        previous_temperature = thermostat.get_target_temperature();
        previous_mode = thermostat.get_mode();
        thermostat.set_temperature(temperature);
    }
    
    void undo() override {
        thermostat.set_temperature(previous_temperature);
        thermostat.set_mode(previous_mode);
        std::cout << "Undo: Restored thermostat to " << previous_temperature << "°F" << std::endl;
    }
    
    std::string get_name() const override {
        return "Set thermostat to " + std::to_string((int)temperature) + "°F";
    }
};

class GarageDoorCommand : public Command {
private:
    GarageDoor& garage_door;
    bool previous_state;
    bool previous_light_state;

public:
    GarageDoorCommand(GarageDoor& gd) : garage_door(gd), previous_state(false), previous_light_state(false) {}
    
    void execute() override {
        previous_state = garage_door.is_door_open();
        previous_light_state = garage_door.is_light_on();
        
        if (garage_door.is_door_open()) {
            garage_door.close();
        } else {
            garage_door.open();
        }
    }
    
    void undo() override {
        if (previous_state) {
            garage_door.open();
        } else {
            garage_door.close();
        }
        
        if (previous_light_state != garage_door.is_light_on()) {
            garage_door.toggle_light();
        }
        std::cout << "Undo: Restored garage door state" << std::endl;
    }
    
    std::string get_name() const override {
        return "Toggle garage door";
    }
};

// Macro Command
class MacroCommand : public Command {
private:
    std::vector<std::unique_ptr<Command>> commands;
    std::string name;

public:
    MacroCommand(const std::string& macro_name) : name(macro_name) {}
    
    void add_command(std::unique_ptr<Command> cmd) {
        commands.push_back(std::move(cmd));
    }
    
    void execute() override {
        std::cout << "Executing macro: " << name << std::endl;
        for (auto& cmd : commands) {
            cmd->execute();
        }
    }
    
    void undo() override {
        std::cout << "Undoing macro: " << name << std::endl;
        for (auto it = commands.rbegin(); it != commands.rend(); ++it) {
            (*it)->undo();
        }
    }
    
    std::string get_name() const override {
        return "Macro: " + name;
    }
};

// Invoker
class RemoteControl {
private:
    std::vector<std::unique_ptr<Command>> on_commands;
    std::vector<std::unique_ptr<Command>> off_commands;
    std::unique_ptr<Command> undo_command;
    std::vector<std::unique_ptr<Command>> command_history;
    size_t history_limit;

public:
    RemoteControl(size_t slots = 5, size_t history_size = 10) 
        : on_commands(slots), off_commands(slots), history_limit(history_size) {}
    
    void set_command(size_t slot, std::unique_ptr<Command> on_cmd, std::unique_ptr<Command> off_cmd) {
        if (slot < on_commands.size()) {
            on_commands[slot] = std::move(on_cmd);
            off_commands[slot] = std::move(off_cmd);
        }
    }
    
    void press_on_button(size_t slot) {
        if (slot < on_commands.size() && on_commands[slot]) {
            on_commands[slot]->execute();
            add_to_history(std::move(on_commands[slot]));
            // Recreate the command for future use
            on_commands[slot] = create_command_copy(slot, true);
        }
    }
    
    void press_off_button(size_t slot) {
        if (slot < off_commands.size() && off_commands[slot]) {
            off_commands[slot]->execute();
            add_to_history(std::move(off_commands[slot]));
            off_commands[slot] = create_command_copy(slot, false);
        }
    }
    
    void press_undo() {
        if (!command_history.empty()) {
            auto last_command = std::move(command_history.back());
            command_history.pop_back();
            last_command->undo();
        } else {
            std::cout << "No commands to undo" << std::endl;
        }
    }
    
    void show_history() const {
        std::cout << "\n=== Command History ===" << std::endl;
        for (size_t i = 0; i < command_history.size(); ++i) {
            std::cout << i + 1 << ". " << command_history[i]->get_name() << std::endl;
        }
    }

private:
    void add_to_history(std::unique_ptr<Command> cmd) {
        command_history.push_back(std::move(cmd));
        if (command_history.size() > history_limit) {
            command_history.erase(command_history.begin());
        }
    }
    
    std::unique_ptr<Command> create_command_copy(size_t slot, bool is_on) {
        // In real implementation, you'd clone the command
        // For simplicity, we return nullptr (actual implementation would require cloning)
        return nullptr;
    }
};

// Demo function
void smartHomeDemo() {
    std::cout << "=== Command Pattern - Smart Home System ===" << std::endl;
    
    // Create receivers
    Light living_room_light("Living Room");
    Light kitchen_light("Kitchen");
    Thermostat thermostat;
    GarageDoor garage_door;
    
    // Create commands
    auto living_room_light_on = std::make_unique<LightOnCommand>(living_room_light);
    auto living_room_light_off = std::make_unique<LightOffCommand>(living_room_light);
    auto kitchen_light_on = std::make_unique<LightOnCommand>(kitchen_light);
    auto kitchen_light_off = std::make_unique<LightOffCommand>(kitchen_light);
    auto thermostat_72 = std::make_unique<ThermostatCommand>(thermostat, 72.0);
    auto thermostat_68 = std::make_unique<ThermostatCommand>(thermostat, 68.0);
    auto garage_door_toggle = std::make_unique<GarageDoorCommand>(garage_door);
    
    // Create macro command for "Good Morning" scene
    auto good_morning_macro = std::make_unique<MacroCommand>("Good Morning");
    good_morning_macro->add_command(std::make_unique<LightOnCommand>(living_room_light));
    good_morning_macro->add_command(std::make_unique<LightOnCommand>(kitchen_light));
    good_morning_macro->add_command(std::make_unique<ThermostatCommand>(thermostat, 70.0));
    
    // Setup remote control
    RemoteControl remote(5, 10);
    
    remote.set_command(0, std::move(living_room_light_on), std::move(living_room_light_off));
    remote.set_command(1, std::move(kitchen_light_on), std::move(kitchen_light_off));
    remote.set_command(2, std::move(thermostat_72), std::move(thermostat_68));
    remote.set_command(3, std::move(garage_door_toggle), nullptr);
    remote.set_command(4, std::move(good_morning_macro), nullptr);
    
    // Test the remote
    std::cout << "\n--- Testing Individual Commands ---" << std::endl;
    remote.press_on_button(0);  // Living room light on
    remote.press_on_button(1);  // Kitchen light on
    remote.press_on_button(2);  // Set thermostat to 72
    remote.press_on_button(3);  // Open garage door
    
    std::cout << "\n--- Testing Undo Functionality ---" << std::endl;
    remote.press_undo();  // Undo garage door
    remote.press_undo();  // Undo thermostat
    
    std::cout << "\n--- Testing Macro Command ---" << std::endl;
    remote.press_on_button(4);  // Execute Good Morning macro
    
    // Show command history
    remote.show_history();
}

int main() {
    smartHomeDemo();
    return 0;
}
```

#### Text Editor with Undo/Redo

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <stack>
#include <sstream>

// Command Interface
class TextCommand {
public:
    virtual ~TextCommand() = default;
    virtual void execute() = 0;
    virtual void undo() = 0;
    virtual std::string get_description() const = 0;
};

// Receiver
class TextDocument {
private:
    std::string content;
    size_t cursor_position;

public:
    TextDocument() : content(""), cursor_position(0) {}
    
    void insert_text(const std::string& text) {
        content.insert(cursor_position, text);
        cursor_position += text.length();
    }
    
    void delete_text(size_t length) {
        if (cursor_position + length <= content.length()) {
            content.erase(cursor_position, length);
        }
    }
    
    void set_cursor(size_t position) {
        cursor_position = std::min(position, content.length());
    }
    
    void replace_text(const std::string& new_text, size_t start, size_t length) {
        if (start + length <= content.length()) {
            content.replace(start, length, new_text);
        }
    }
    
    std::string get_content() const { return content; }
    size_t get_cursor_position() const { return cursor_position; }
    size_t get_length() const { return content.length(); }
    
    void display() const {
        std::cout << "Document: \"" << content << "\"" << std::endl;
        std::cout << "Cursor: " << cursor_position << std::endl;
    }
};

// Concrete Commands
class InsertCommand : public TextCommand {
private:
    TextDocument& document;
    std::string text_to_insert;
    size_t insert_position;

public:
    InsertCommand(TextDocument& doc, const std::string& text, size_t position)
        : document(doc), text_to_insert(text), insert_position(position) {}
    
    void execute() override {
        document.set_cursor(insert_position);
        document.insert_text(text_to_insert);
    }
    
    void undo() override {
        document.set_cursor(insert_position);
        document.delete_text(text_to_insert.length());
    }
    
    std::string get_description() const override {
        return "Insert \"" + text_to_insert + "\" at position " + std::to_string(insert_position);
    }
};

class DeleteCommand : public TextCommand {
private:
    TextDocument& document;
    size_t delete_position;
    size_t delete_length;
    std::string deleted_text;

public:
    DeleteCommand(TextDocument& doc, size_t position, size_t length)
        : document(doc), delete_position(position), delete_length(length) {}
    
    void execute() override {
        // Store the text being deleted for undo
        std::string content = document.get_content();
        if (delete_position + delete_length <= content.length()) {
            deleted_text = content.substr(delete_position, delete_length);
        }
        document.set_cursor(delete_position);
        document.delete_text(delete_length);
    }
    
    void undo() override {
        document.set_cursor(delete_position);
        document.insert_text(deleted_text);
    }
    
    std::string get_description() const override {
        return "Delete " + std::to_string(delete_length) + " characters from position " + std::to_string(delete_position);
    }
};

class ReplaceCommand : public TextCommand {
private:
    TextDocument& document;
    size_t replace_position;
    size_t replace_length;
    std::string new_text;
    std::string old_text;

public:
    ReplaceCommand(TextDocument& doc, size_t position, size_t length, const std::string& text)
        : document(doc), replace_position(position), replace_length(length), new_text(text) {}
    
    void execute() override {
        std::string content = document.get_content();
        if (replace_position + replace_length <= content.length()) {
            old_text = content.substr(replace_position, replace_length);
        }
        document.replace_text(new_text, replace_position, replace_length);
        document.set_cursor(replace_position + new_text.length());
    }
    
    void undo() override {
        document.replace_text(old_text, replace_position, new_text.length());
        document.set_cursor(replace_position + old_text.length());
    }
    
    std::string get_description() const override {
        return "Replace " + std::to_string(replace_length) + " chars at " + 
               std::to_string(replace_position) + " with \"" + new_text + "\"";
    }
};

// Invoker with Undo/Redo support
class TextEditor {
private:
    TextDocument document;
    std::stack<std::unique_ptr<TextCommand>> undo_stack;
    std::stack<std::unique_ptr<TextCommand>> redo_stack;
    size_t max_history_size;

public:
    TextEditor(size_t history_size = 50) : max_history_size(history_size) {}
    
    void execute_command(std::unique_ptr<TextCommand> command) {
        command->execute();
        undo_stack.push(std::move(command));
        
        // Clear redo stack when new command is executed
        while (!redo_stack.empty()) {
            redo_stack.pop();
        }
        
        // Limit history size
        if (undo_stack.size() > max_history_size) {
            std::stack<std::unique_ptr<TextCommand>> temp;
            while (undo_stack.size() > max_history_size / 2) {
                temp.push(std::move(undo_stack.top()));
                undo_stack.pop();
            }
            while (!undo_stack.empty()) undo_stack.pop();
            while (!temp.empty()) {
                undo_stack.push(std::move(temp.top()));
                temp.pop();
            }
        }
    }
    
    void undo() {
        if (!undo_stack.empty()) {
            auto command = std::move(undo_stack.top());
            undo_stack.pop();
            command->undo();
            redo_stack.push(std::move(command));
            std::cout << "Undo: " << redo_stack.top()->get_description() << std::endl;
        } else {
            std::cout << "Nothing to undo" << std::endl;
        }
    }
    
    void redo() {
        if (!redo_stack.empty()) {
            auto command = std::move(redo_stack.top());
            redo_stack.pop();
            command->execute();
            undo_stack.push(std::move(command));
            std::cout << "Redo: " << undo_stack.top()->get_description() << std::endl;
        } else {
            std::cout << "Nothing to redo" << std::endl;
        }
    }
    
    void insert_text(const std::string& text, size_t position) {
        auto command = std::make_unique<InsertCommand>(document, text, position);
        execute_command(std::move(command));
    }
    
    void delete_text(size_t position, size_t length) {
        auto command = std::make_unique<DeleteCommand>(document, position, length);
        execute_command(std::move(command));
    }
    
    void replace_text(size_t position, size_t length, const std::string& new_text) {
        auto command = std::make_unique<ReplaceCommand>(document, position, length, new_text);
        execute_command(std::move(command));
    }
    
    void display_document() const {
        document.display();
    }
    
    void show_history() const {
        std::cout << "\n=== Edit History ===" << std::endl;
        std::cout << "Undo stack: " << undo_stack.size() << " commands" << std::endl;
        std::cout << "Redo stack: " << redo_stack.size() << " commands" << std::endl;
    }
};

// Demo function
void textEditorDemo() {
    std::cout << "=== Command Pattern - Text Editor with Undo/Redo ===" << std::endl;
    
    TextEditor editor;
    
    std::cout << "\n--- Initial Document ---" << std::endl;
    editor.display_document();
    
    std::cout << "\n--- Editing Document ---" << std::endl;
    editor.insert_text("Hello", 0);
    editor.display_document();
    
    editor.insert_text(" World", 5);
    editor.display_document();
    
    editor.replace_text(0, 5, "Hi");
    editor.display_document();
    
    editor.insert_text(" beautiful", 2);
    editor.display_document();
    
    std::cout << "\n--- Undo Operations ---" << std::endl;
    editor.undo(); // Undo "beautiful" insertion
    editor.display_document();
    
    editor.undo(); // Undo replace "Hello" with "Hi"
    editor.display_document();
    
    std::cout << "\n--- Redo Operations ---" << std::endl;
    editor.redo(); // Redo replace operation
    editor.display_document();
    
    std::cout << "\n--- More Editing ---" << std::endl;
    editor.delete_text(2, 3); // Delete " Wor"
    editor.display_document();
    
    editor.insert_text(" C++", 5);
    editor.display_document();
    
    // Show history
    editor.show_history();
    
    std::cout << "\n--- Multiple Undo ---" << std::endl;
    editor.undo();
    editor.undo();
    editor.undo();
    editor.undo();
    editor.display_document();
}

int main() {
    textEditorDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Command function pointers
typedef void (*ExecuteFunction)(void*);
typedef void (*UndoFunction)(void*);
typedef const char* (*GetNameFunction)(void*);

// Command structure
typedef struct {
    ExecuteFunction execute;
    UndoFunction undo;
    GetNameFunction get_name;
    void* data;
} Command;

// Receiver: Bank Account
typedef struct {
    char account_holder[50];
    double balance;
    char currency[4];
} BankAccount;

BankAccount* account_create(const char* holder, double initial_balance, const char* curr) {
    BankAccount* account = malloc(sizeof(BankAccount));
    strcpy(account->account_holder, holder);
    account->balance = initial_balance;
    strcpy(account->currency, curr);
    return account;
}

void account_display(const BankAccount* account) {
    printf("Account: %s\n", account->account_holder);
    printf("Balance: %.2f %s\n", account->balance, account->currency);
}

// Command Data Structures
typedef struct {
    BankAccount* account;
    double amount;
} DepositData;

typedef struct {
    BankAccount* account;
    double amount;
} WithdrawData;

typedef struct {
    BankAccount* from_account;
    BankAccount* to_account;
    double amount;
} TransferData;

// Concrete Command Implementations
void deposit_execute(void* data) {
    DepositData* deposit_data = (DepositData*)data;
    deposit_data->account->balance += deposit_data->amount;
    printf("Deposited %.2f %s to %s's account\n", 
           deposit_data->amount, deposit_data->account->currency,
           deposit_data->account->account_holder);
}

void deposit_undo(void* data) {
    DepositData* deposit_data = (DepositData*)data;
    deposit_data->account->balance -= deposit_data->amount;
    printf("Undo deposit: Withdrawn %.2f %s from %s's account\n",
           deposit_data->amount, deposit_data->account->currency,
           deposit_data->account->account_holder);
}

const char* deposit_get_name(void* data) {
    return "Deposit";
}

void withdraw_execute(void* data) {
    WithdrawData* withdraw_data = (WithdrawData*)data;
    if (withdraw_data->account->balance >= withdraw_data->amount) {
        withdraw_data->account->balance -= withdraw_data->amount;
        printf("Withdrawn %.2f %s from %s's account\n",
               withdraw_data->amount, withdraw_data->account->currency,
               withdraw_data->account->account_holder);
    } else {
        printf("Error: Insufficient funds for withdrawal\n");
    }
}

void withdraw_undo(void* data) {
    WithdrawData* withdraw_data = (WithdrawData*)data;
    withdraw_data->account->balance += withdraw_data->amount;
    printf("Undo withdrawal: Deposited %.2f %s to %s's account\n",
           withdraw_data->amount, withdraw_data->account->currency,
           withdraw_data->account->account_holder);
}

const char* withdraw_get_name(void* data) {
    return "Withdraw";
}

void transfer_execute(void* data) {
    TransferData* transfer_data = (TransferData*)data;
    if (transfer_data->from_account->balance >= transfer_data->amount) {
        transfer_data->from_account->balance -= transfer_data->amount;
        transfer_data->to_account->balance += transfer_data->amount;
        printf("Transferred %.2f %s from %s to %s\n",
               transfer_data->amount, transfer_data->from_account->currency,
               transfer_data->from_account->account_holder,
               transfer_data->to_account->account_holder);
    } else {
        printf("Error: Insufficient funds for transfer\n");
    }
}

void transfer_undo(void* data) {
    TransferData* transfer_data = (TransferData*)data;
    transfer_data->from_account->balance += transfer_data->amount;
    transfer_data->to_account->balance -= transfer_data->amount;
    printf("Undo transfer: Returned %.2f %s from %s to %s\n",
           transfer_data->amount, transfer_data->from_account->currency,
           transfer_data->to_account->account_holder,
           transfer_data->from_account->account_holder);
}

const char* transfer_get_name(void* data) {
    return "Transfer";
}

// Command Factory Functions
Command* create_deposit_command(BankAccount* account, double amount) {
    DepositData* data = malloc(sizeof(DepositData));
    data->account = account;
    data->amount = amount;
    
    Command* cmd = malloc(sizeof(Command));
    cmd->execute = deposit_execute;
    cmd->undo = deposit_undo;
    cmd->get_name = deposit_get_name;
    cmd->data = data;
    
    return cmd;
}

Command* create_withdraw_command(BankAccount* account, double amount) {
    WithdrawData* data = malloc(sizeof(WithdrawData));
    data->account = account;
    data->amount = amount;
    
    Command* cmd = malloc(sizeof(Command));
    cmd->execute = withdraw_execute;
    cmd->undo = withdraw_undo;
    cmd->get_name = withdraw_get_name;
    cmd->data = data;
    
    return cmd;
}

Command* create_transfer_command(BankAccount* from, BankAccount* to, double amount) {
    TransferData* data = malloc(sizeof(TransferData));
    data->from_account = from;
    data->to_account = to;
    data->amount = amount;
    
    Command* cmd = malloc(sizeof(Command));
    cmd->execute = transfer_execute;
    cmd->undo = transfer_undo;
    cmd->get_name = transfer_get_name;
    cmd->data = data;
    
    return cmd;
}

// Invoker: Transaction Processor
typedef struct {
    Command** history;
    int history_size;
    int history_capacity;
    int current_position;
} TransactionProcessor;

TransactionProcessor* processor_create(int capacity) {
    TransactionProcessor* processor = malloc(sizeof(TransactionProcessor));
    processor->history = malloc(sizeof(Command*) * capacity);
    processor->history_size = 0;
    processor->history_capacity = capacity;
    processor->current_position = -1;
    return processor;
}

void processor_execute(TransactionProcessor* processor, Command* cmd) {
    cmd->execute(cmd->data);
    
    // Clear redo history
    for (int i = processor->current_position + 1; i < processor->history_size; i++) {
        free(processor->history[i]->data);
        free(processor->history[i]);
    }
    
    processor->history_size = processor->current_position + 1;
    
    // Add to history
    if (processor->history_size >= processor->history_capacity) {
        // Remove oldest command
        free(processor->history[0]->data);
        free(processor->history[0]);
        for (int i = 1; i < processor->history_size; i++) {
            processor->history[i-1] = processor->history[i];
        }
        processor->history_size--;
    }
    
    processor->history[processor->history_size] = cmd;
    processor->history_size++;
    processor->current_position = processor->history_size - 1;
}

void processor_undo(TransactionProcessor* processor) {
    if (processor->current_position >= 0) {
        Command* cmd = processor->history[processor->current_position];
        printf("Undoing: ");
        cmd->undo(cmd->data);
        processor->current_position--;
    } else {
        printf("Nothing to undo\n");
    }
}

void processor_redo(TransactionProcessor* processor) {
    if (processor->current_position < processor->history_size - 1) {
        processor->current_position++;
        Command* cmd = processor->history[processor->current_position];
        printf("Redoing: ");
        cmd->execute(cmd->data);
    } else {
        printf("Nothing to redo\n");
    }
}

void processor_show_history(const TransactionProcessor* processor) {
    printf("\n=== Transaction History ===\n");
    for (int i = 0; i < processor->history_size; i++) {
        const char* name = processor->history[i]->get_name(processor->history[i]->data);
        printf("%d. %s", i + 1, name);
        
        if (i == processor->current_position) {
            printf(" <-- current");
        }
        printf("\n");
    }
}

void processor_destroy(TransactionProcessor* processor) {
    for (int i = 0; i < processor->history_size; i++) {
        free(processor->history[i]->data);
        free(processor->history[i]);
    }
    free(processor->history);
    free(processor);
}

// Demo function
void bankingDemo() {
    printf("=== Command Pattern - Banking System ===\n\n");
    
    // Create bank accounts
    BankAccount* alice_account = account_create("Alice Johnson", 1000.0, "USD");
    BankAccount* bob_account = account_create("Bob Smith", 500.0, "USD");
    
    printf("Initial Account States:\n");
    account_display(alice_account);
    account_display(bob_account);
    
    // Create transaction processor
    TransactionProcessor* processor = processor_create(10);
    
    // Execute various transactions
    printf("\n--- Processing Transactions ---\n");
    processor_execute(processor, create_deposit_command(alice_account, 200.0));
    processor_execute(processor, create_withdraw_command(alice_account, 150.0));
    processor_execute(processor, create_transfer_command(alice_account, bob_account, 300.0));
    processor_execute(processor, create_withdraw_command(bob_account, 100.0));
    
    printf("\n--- Current Account States ---\n");
    account_display(alice_account);
    account_display(bob_account);
    
    // Test undo/redo
    printf("\n--- Testing Undo/Redo ---\n");
    processor_undo(processor); // Undo Bob's withdrawal
    processor_undo(processor); // Undo transfer
    
    printf("\n--- After Undo ---\n");
    account_display(alice_account);
    account_display(bob_account);
    
    processor_redo(processor); // Redo transfer
    
    printf("\n--- After Redo ---\n");
    account_display(alice_account);
    account_display(bob_account);
    
    // Show transaction history
    processor_show_history(processor);
    
    // Cleanup
    processor_destroy(processor);
    free(alice_account);
    free(bob_account);
}

int main() {
    bankingDemo();
    return 0;
}
```

### Python Implementation

#### Task Scheduler System

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime, timedelta
import time
import threading
from queue import Queue, PriorityQueue
from enum import Enum
import uuid

class TaskPriority(Enum):
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4

class TaskStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

# Command Interface
class TaskCommand(ABC):
    @abstractmethod
    def execute(self) -> Any: ...
    
    @abstractmethod
    def undo(self) -> Any: ...
    
    @abstractmethod
    def get_description(self) -> str: ...
    
    @abstractmethod
    def get_task_id(self) -> str: ...

# Concrete Commands
class EmailCommand(TaskCommand):
    def __init__(self, task_id: str, to_address: str, subject: str, body: str):
        self.task_id = task_id
        self.to_address = to_address
        self.subject = subject
        self.body = body
        self.execution_time = None
        self.status = TaskStatus.PENDING
    
    def execute(self) -> str:
        self.status = TaskStatus.RUNNING
        self.execution_time = datetime.now()
        
        # Simulate email sending
        print(f"[Email] Sending email to {self.to_address}")
        print(f"Subject: {self.subject}")
        print(f"Body: {self.body}")
        time.sleep(1)  # Simulate network delay
        
        # Simulate random success/failure
        import random
        if random.random() < 0.9:  # 90% success rate
            self.status = TaskStatus.COMPLETED
            result = f"Email sent successfully to {self.to_address}"
            print(f"✓ {result}")
        else:
            self.status = TaskStatus.FAILED
            result = f"Failed to send email to {self.to_address}"
            print(f"✗ {result}")
        
        return result
    
    def undo(self) -> str:
        # Can't actually unsend an email, but we can mark it as recalled
        self.status = TaskStatus.CANCELLED
        result = f"Email recall requested for message to {self.to_address}"
        print(f"↶ {result}")
        return result
    
    def get_description(self) -> str:
        return f"Send email to {self.to_address}: {self.subject}"
    
    def get_task_id(self) -> str:
        return self.task_id

class DataProcessingCommand(TaskCommand):
    def __init__(self, task_id: str, data_source: str, operation: str, parameters: Dict):
        self.task_id = task_id
        self.data_source = data_source
        self.operation = operation
        self.parameters = parameters
        self.original_data = None
        self.processed_data = None
        self.status = TaskStatus.PENDING
    
    def execute(self) -> str:
        self.status = TaskStatus.RUNNING
        print(f"[Data Processing] Processing {self.data_source}")
        
        # Simulate data loading
        self.original_data = f"Sample data from {self.data_source}"
        print(f"Loaded data: {len(self.original_data)} characters")
        
        # Simulate processing
        time.sleep(2)
        
        if self.operation == "clean":
            self.processed_data = self.original_data.upper()
            result = "Data cleaning completed"
        elif self.operation == "analyze":
            word_count = len(self.original_data.split())
            self.processed_data = f"Analysis: {word_count} words"
            result = "Data analysis completed"
        elif self.operation == "transform":
            self.processed_data = self.original_data.replace(" ", "_")
            result = "Data transformation completed"
        else:
            self.processed_data = self.original_data
            result = "Unknown operation, data unchanged"
        
        self.status = TaskStatus.COMPLETED
        print(f"✓ {result}")
        return result
    
    def undo(self) -> str:
        self.status = TaskStatus.CANCELLED
        self.processed_data = None
        result = f"Data processing reverted for {self.data_source}"
        print(f"↶ {result}")
        return result
    
    def get_description(self) -> str:
        return f"Process {self.data_source} with {self.operation}"
    
    def get_task_id(self) -> str:
        return self.task_id

class FileOperationCommand(TaskCommand):
    def __init__(self, task_id: str, operation: str, file_path: str, content: str = None):
        self.task_id = task_id
        self.operation = operation
        self.file_path = file_path
        self.content = content
        self.backup_content = None
        self.status = TaskStatus.PENDING
    
    def execute(self) -> str:
        self.status = TaskStatus.RUNNING
        print(f"[File Operation] {self.operation} {self.file_path}")
        
        try:
            if self.operation == "create":
                self.backup_content = ""  # No backup for new files
                with open(self.file_path, 'w') as f:
                    f.write(self.content or "Default content")
                result = f"File {self.file_path} created"
            
            elif self.operation == "delete":
                # Backup content before deletion
                try:
                    with open(self.file_path, 'r') as f:
                        self.backup_content = f.read()
                except FileNotFoundError:
                    self.backup_content = None
                
                import os
                os.remove(self.file_path)
                result = f"File {self.file_path} deleted"
            
            elif self.operation == "modify":
                # Backup original content
                with open(self.file_path, 'r') as f:
                    self.backup_content = f.read()
                
                with open(self.file_path, 'w') as f:
                    f.write(self.content)
                result = f"File {self.file_path} modified"
            
            else:
                result = f"Unknown operation: {self.operation}"
            
            self.status = TaskStatus.COMPLETED
            print(f"✓ {result}")
            return result
            
        except Exception as e:
            self.status = TaskStatus.FAILED
            result = f"File operation failed: {str(e)}"
            print(f"✗ {result}")
            return result
    
    def undo(self) -> str:
        try:
            if self.operation == "create":
                import os
                os.remove(self.file_path)
                result = f"Created file {self.file_path} removed"
            
            elif self.operation == "delete" and self.backup_content is not None:
                with open(self.file_path, 'w') as f:
                    f.write(self.backup_content)
                result = f"Deleted file {self.file_path} restored"
            
            elif self.operation == "modify" and self.backup_content is not None:
                with open(self.file_path, 'w') as f:
                    f.write(self.backup_content)
                result = f"File {self.file_path} restored to original content"
            
            else:
                result = f"Cannot undo {self.operation} operation"
            
            self.status = TaskStatus.CANCELLED
            print(f"↶ {result}")
            return result
            
        except Exception as e:
            result = f"Undo failed: {str(e)}"
            print(f"✗ {result}")
            return result
    
    def get_description(self) -> str:
        return f"{self.operation.capitalize()} file {self.file_path}"
    
    def get_task_id(self) -> str:
        return self.task_id

# Scheduled Task Wrapper
class ScheduledTask:
    def __init__(self, command: TaskCommand, scheduled_time: datetime, 
                 priority: TaskPriority = TaskPriority.NORMAL):
        self.command = command
        self.scheduled_time = scheduled_time
        self.priority = priority
        self.status = TaskStatus.PENDING
    
    def __lt__(self, other):
        # For priority queue: higher priority and earlier time comes first
        if self.priority.value != other.priority.value:
            return self.priority.value > other.priority.value
        return self.scheduled_time < other.scheduled_time

# Invoker: Task Scheduler
class TaskScheduler:
    def __init__(self):
        self.task_queue = PriorityQueue()
        self.completed_tasks: List[ScheduledTask] = []
        self.failed_tasks: List[ScheduledTask] = []
        self.is_running = False
        self.worker_thread = None
    
    def schedule_task(self, command: TaskCommand, 
                     scheduled_time: datetime = None,
                     priority: TaskPriority = TaskPriority.NORMAL) -> str:
        
        if scheduled_time is None:
            scheduled_time = datetime.now()
        
        task = ScheduledTask(command, scheduled_time, priority)
        self.task_queue.put(task)
        
        print(f"📅 Scheduled: {command.get_description()}")
        print(f"   Time: {scheduled_time}, Priority: {priority.name}")
        
        return command.get_task_id()
    
    def start(self):
        self.is_running = True
        self.worker_thread = threading.Thread(target=self._process_tasks)
        self.worker_thread.daemon = True
        self.worker_thread.start()
        print("🚀 Task scheduler started")
    
    def stop(self):
        self.is_running = False
        if self.worker_thread:
            self.worker_thread.join()
        print("🛑 Task scheduler stopped")
    
    def _process_tasks(self):
        while self.is_running:
            try:
                if not self.task_queue.empty():
                    task = self.task_queue.queue[0]  # Peek at the next task
                    
                    if datetime.now() >= task.scheduled_time:
                        # It's time to execute this task
                        task = self.task_queue.get()
                        
                        print(f"\n⏰ Executing scheduled task: {task.command.get_description()}")
                        try:
                            result = task.command.execute()
                            task.status = TaskStatus.COMPLETED
                            self.completed_tasks.append(task)
                            print(f"✅ Task completed: {result}")
                        except Exception as e:
                            task.status = TaskStatus.FAILED
                            self.failed_tasks.append(task)
                            print(f"❌ Task failed: {str(e)}")
                
                time.sleep(1)  # Check every second
                
            except Exception as e:
                print(f"Error in task processor: {str(e)}")
                time.sleep(5)
    
    def cancel_task(self, task_id: str) -> bool:
        # This is simplified - in real implementation, you'd need to search the queue
        print(f"Attempting to cancel task {task_id}")
        return False
    
    def get_stats(self) -> Dict[str, int]:
        pending = self.task_queue.qsize()
        completed = len(self.completed_tasks)
        failed = len(self.failed_tasks)
        
        return {
            "pending": pending,
            "completed": completed,
            "failed": failed,
            "total": pending + completed + failed
        }
    
    def show_schedule(self):
        print("\n" + "="*50)
        print("📋 CURRENT TASK SCHEDULE")
        print("="*50)
        
        # Convert priority queue to list for display
        tasks = []
        temp_queue = PriorityQueue()
        
        while not self.task_queue.empty():
            task = self.task_queue.get()
            tasks.append(task)
            temp_queue.put(task)
        
        # Restore the queue
        self.task_queue = temp_queue
        
        if not tasks:
            print("No scheduled tasks")
            return
        
        for i, task in enumerate(tasks, 1):
            status_icon = "⏳" if task.status == TaskStatus.PENDING else "⚡" if task.status == TaskStatus.RUNNING else "✅"
            print(f"{i}. {status_icon} [{task.priority.name}] {task.command.get_description()}")
            print(f"   🕐 {task.scheduled_time} (ID: {task.command.get_task_id()})")

# Demo function
def taskSchedulerDemo():
    print("=== Command Pattern - Task Scheduler System ===\n")
    
    scheduler = TaskScheduler()
    
    # Create various tasks
    now = datetime.now()
    
    # Email tasks
    email_task1 = EmailCommand(
        str(uuid.uuid4()),
        "user@example.com",
        "Welcome to our service",
        "Thank you for joining our platform!"
    )
    
    email_task2 = EmailCommand(
        str(uuid.uuid4()),
        "admin@company.com",
        "System Report",
        "Daily system metrics and performance report."
    )
    
    # Data processing tasks
    data_task = DataProcessingCommand(
        str(uuid.uuid4()),
        "sales_data.csv",
        "analyze",
        {"format": "csv", "encoding": "utf-8"}
    )
    
    # File operation tasks
    file_task = FileOperationCommand(
        str(uuid.uuid4()),
        "create",
        "report.txt",
        "This is a generated report file."
    )
    
    # Schedule tasks with different times and priorities
    print("--- Scheduling Tasks ---")
    scheduler.schedule_task(email_task1, now + timedelta(seconds=2), TaskPriority.HIGH)
    scheduler.schedule_task(data_task, now + timedelta(seconds=5), TaskPriority.NORMAL)
    scheduler.schedule_task(email_task2, now + timedelta(seconds=8), TaskPriority.LOW)
    scheduler.schedule_task(file_task, now + timedelta(seconds=3), TaskPriority.CRITICAL)
    
    # Show initial schedule
    scheduler.show_schedule()
    
    # Start the scheduler
    scheduler.start()
    
    # Let it run for a while
    print("\n--- Processing Tasks (15 seconds) ---")
    time.sleep(15)
    
    # Stop the scheduler
    scheduler.stop()
    
    # Show final statistics
    stats = scheduler.get_stats()
    print("\n--- Final Statistics ---")
    print(f"Completed: {stats['completed']}")
    print(f"Failed: {stats['failed']}")
    print(f"Pending: {stats['pending']}")
    
    # Test undo functionality
    print("\n--- Testing Undo Functionality ---")
    if scheduler.completed_tasks:
        task_to_undo = scheduler.completed_tasks[0]
        print(f"Undoing: {task_to_undo.command.get_description()}")
        task_to_undo.command.undo()

if __name__ == "__main__":
    taskSchedulerDemo()
```

## Advantages and Disadvantages

### Advantages

- **Decouples Invoker and Receiver**: Separates object that invokes operation from object that performs it
- **Undo/Redo Support**: Easy to implement undo and redo functionality
- **Queueing and Logging**: Commands can be queued, logged, or executed remotely
- **Macro Commands**: Can combine multiple commands into one
- **Extensibility**: Easy to add new commands without changing existing code

### Disadvantages

- **Increased Complexity**: Can lead to many command classes for simple operations
- **Overhead**: Additional layers of abstraction may impact performance
- **Memory Usage**: Storing command history for undo/redo can consume significant memory

## Best Practices

1. **Use for Complex Operations**: When you need to parameterize objects with operations
2. **Implement Undo Carefully**: Consider memory usage and performance for undo functionality
3. **Keep Commands Lightweight**: Avoid putting business logic in command classes
4. **Use Composite for Macros**: Implement macro commands using composite pattern
5. **Consider Memory Management**: Be mindful of command history size in memory-constrained environments

## Command vs Other Patterns

- **vs Strategy**: Command focuses on invoking operations, Strategy focuses on algorithm selection
- **vs Memento**: Both support undo, but Command stores operation, Memento stores state
- **vs Observer**: Command encapsulates requests, Observer handles notifications
- **vs Template Method**: Command uses composition, Template Method uses inheritance

The Command pattern is essential for implementing features like undo/redo systems, task queues, macro recording, and transactional operations. It provides excellent flexibility for managing operations and their lifecycle.
