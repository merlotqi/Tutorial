# Mediator Pattern

## Introduction

The Mediator Pattern is a behavioral design pattern that reduces coupling between components by forcing them to communicate through a mediator object. Instead of components communicating directly with each other, they communicate through the mediator, which handles the coordination and control.

### Key Characteristics

- **Centralized Control**: All communication flows through a central mediator
- **Loose Coupling**: Components don't need to know about each other
- **Simplified Communication**: Reduces the number of connections between objects
- **Single Responsibility**: Mediator handles complex communication logic

### Use Cases

- Chat rooms and messaging systems
- Air traffic control systems
- GUI components coordination
- Microservices communication
- Game character interactions
- Workflow management systems

## Implementation Examples

### C++ Implementation

#### Air Traffic Control System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <ctime>

// Forward declaration
class Aircraft;

// Mediator Interface
class AirTrafficControl {
public:
    virtual ~AirTrafficControl() = default;
    virtual void register_aircraft(std::shared_ptr<Aircraft> aircraft) = 0;
    virtual void send_message(const std::string& from, const std::string& to, 
                            const std::string& message) = 0;
    virtual void request_landing(const std::string& aircraft_id) = 0;
    virtual void request_takeoff(const std::string& aircraft_id) = 0;
    virtual void report_position(const std::string& aircraft_id, 
                               double latitude, double longitude, int altitude) = 0;
};

// Colleague Interface
class Aircraft {
protected:
    std::string id;
    std::string model;
    double latitude;
    double longitude;
    int altitude;
    int speed;
    bool in_air;
    std::weak_ptr<AirTrafficControl> atc;

public:
    Aircraft(const std::string& aircraft_id, const std::string& aircraft_model,
             std::shared_ptr<AirTrafficControl> controller)
        : id(aircraft_id), model(aircraft_model), latitude(0.0), longitude(0.0),
          altitude(0), speed(0), in_air(false), atc(controller) {}
    
    virtual ~Aircraft() = default;
    
    std::string get_id() const { return id; }
    std::string get_model() const { return model; }
    double get_latitude() const { return latitude; }
    double get_longitude() const { return longitude; }
    int get_altitude() const { return altitude; }
    int get_speed() const { return speed; }
    bool is_in_air() const { return in_air; }
    
    void set_position(double lat, double lon, int alt) {
        latitude = lat;
        longitude = lon;
        altitude = alt;
    }
    
    void set_speed(int spd) {
        speed = spd;
    }
    
    void send_message(const std::string& to, const std::string& message) {
        if (auto controller = atc.lock()) {
            controller->send_message(id, to, message);
        }
    }
    
    void request_landing() {
        if (auto controller = atc.lock()) {
            controller->request_landing(id);
        }
    }
    
    void request_takeoff() {
        if (auto controller = atc.lock()) {
            controller->request_takeoff(id);
        }
    }
    
    void report_position() {
        if (auto controller = atc.lock()) {
            controller->report_position(id, latitude, longitude, altitude);
        }
    }
    
    virtual void receive_message(const std::string& from, const std::string& message) {
        std::cout << "[" << id << "] Message from " << from << ": " << message << std::endl;
    }
    
    virtual void receive_landing_clearance(bool cleared, const std::string& runway = "") {
        if (cleared) {
            std::cout << "[" << id << "] Landing clearance granted on runway " << runway << std::endl;
            in_air = false;
            speed = 0;
        } else {
            std::cout << "[" << id << "] Landing clearance denied. Hold position." << std::endl;
        }
    }
    
    virtual void receive_takeoff_clearance(bool cleared, const std::string& runway = "") {
        if (cleared) {
            std::cout << "[" << id << "] Takeoff clearance granted on runway " << runway << std::endl;
            in_air = true;
            speed = 280;
        } else {
            std::cout << "[" << id << "] Takeoff clearance denied. Wait for clearance." << std::endl;
        }
    }
};

// Concrete Colleagues
class PassengerAircraft : public Aircraft {
private:
    int passenger_count;
    std::string airline;

public:
    PassengerAircraft(const std::string& aircraft_id, const std::string& aircraft_model,
                     int passengers, const std::string& airline_name,
                     std::shared_ptr<AirTrafficControl> controller)
        : Aircraft(aircraft_id, aircraft_model, controller),
          passenger_count(passengers), airline(airline_name) {}
    
    void receive_message(const std::string& from, const std::string& message) override {
        std::cout << "[" << airline << " " << id << "] Message from " << from 
                  << ": " << message << std::endl;
    }
    
    void receive_landing_clearance(bool cleared, const std::string& runway = "") override {
        Aircraft::receive_landing_clearance(cleared, runway);
        if (cleared) {
            std::cout << "[" << airline << " " << id << "] Preparing for landing with " 
                      << passenger_count << " passengers" << std::endl;
        }
    }
    
    int get_passenger_count() const { return passenger_count; }
    std::string get_airline() const { return airline; }
};

class CargoAircraft : public Aircraft {
private:
    double cargo_weight;
    std::string cargo_type;

public:
    CargoAircraft(const std::string& aircraft_id, const std::string& aircraft_model,
                 double weight, const std::string& type,
                 std::shared_ptr<AirTrafficControl> controller)
        : Aircraft(aircraft_id, aircraft_model, controller),
          cargo_weight(weight), cargo_type(type) {}
    
    void receive_message(const std::string& from, const std::string& message) override {
        std::cout << "[CARGO " << id << "] Message from " << from << ": " << message << std::endl;
    }
    
    void receive_landing_clearance(bool cleared, const std::string& runway = "") override {
        Aircraft::receive_landing_clearance(cleared, runway);
        if (cleared) {
            std::cout << "[CARGO " << id << "] Heavy cargo landing with " 
                      << cargo_weight << " tons of " << cargo_type << std::endl;
        }
    }
    
    double get_cargo_weight() const { return cargo_weight; }
    std::string get_cargo_type() const { return cargo_type; }
};

class EmergencyAircraft : public Aircraft {
private:
    std::string emergency_type;
    int priority_level;

public:
    EmergencyAircraft(const std::string& aircraft_id, const std::string& aircraft_model,
                     const std::string& emergency, int priority,
                     std::shared_ptr<AirTrafficControl> controller)
        : Aircraft(aircraft_id, aircraft_model, controller),
          emergency_type(emergency), priority_level(priority) {}
    
    void request_emergency_landing() {
        std::cout << "[" << id << "] EMERGENCY: " << emergency_type 
                  << " - Requesting immediate landing!" << std::endl;
        request_landing();
    }
    
    void receive_landing_clearance(bool cleared, const std::string& runway = "") override {
        if (cleared) {
            std::cout << "[" << id << "] EMERGENCY LANDING CLEARED on runway " << runway << std::endl;
            in_air = false;
            speed = 0;
        }
    }
    
    int get_priority_level() const { return priority_level; }
    std::string get_emergency_type() const { return emergency_type; }
};

// Concrete Mediator
class TowerControl : public AirTrafficControl {
private:
    std::unordered_map<std::string, std::shared_ptr<Aircraft>> aircrafts;
    std::vector<std::string> available_runways;
    std::vector<std::string> occupied_runways;
    int communication_count;

public:
    TowerControl() : communication_count(0) {
        // Initialize runways
        available_runways = {"09L", "09R", "27L", "27R"};
    }
    
    void register_aircraft(std::shared_ptr<Aircraft> aircraft) override {
        aircrafts[aircraft->get_id()] = aircraft;
        std::cout << "Tower: Aircraft " << aircraft->get_id() << " registered." << std::endl;
    }
    
    void send_message(const std::string& from, const std::string& to, 
                     const std::string& message) override {
        communication_count++;
        
        if (aircrafts.find(to) != aircrafts.end()) {
            std::cout << "Tower: Routing message from " << from << " to " << to << std::endl;
            aircrafts[to]->receive_message(from, message);
        } else if (to == "ALL") {
            std::cout << "Tower: Broadcasting message from " << from << " to all aircraft" << std::endl;
            for (auto& pair : aircrafts) {
                if (pair.first != from) {
                    pair.second->receive_message(from, message);
                }
            }
        } else {
            std::cout << "Tower: Aircraft " << to << " not found." << std::endl;
        }
    }
    
    void request_landing(const std::string& aircraft_id) override {
        std::cout << "Tower: Landing request from " << aircraft_id << std::endl;
        
        if (aircrafts.find(aircraft_id) == aircrafts.end()) {
            std::cout << "Tower: Unknown aircraft " << aircraft_id << std::endl;
            return;
        }
        
        auto aircraft = aircrafts[aircraft_id];
        
        // Check for emergencies first
        if (auto emergency_ac = std::dynamic_pointer_cast<EmergencyAircraft>(aircraft)) {
            handle_emergency_landing(emergency_ac);
            return;
        }
        
        // Check runway availability
        if (!available_runways.empty()) {
            std::string runway = available_runways.back();
            available_runways.pop_back();
            occupied_runways.push_back(runway);
            
            aircraft->receive_landing_clearance(true, runway);
            
            // Schedule runway release
            std::cout << "Tower: Runway " << runway << " occupied by " << aircraft_id << std::endl;
        } else {
            aircraft->receive_landing_clearance(false);
            std::cout << "Tower: No available runways for " << aircraft_id 
                      << ". Added to holding pattern." << std::endl;
        }
    }
    
    void request_takeoff(const std::string& aircraft_id) override {
        std::cout << "Tower: Takeoff request from " << aircraft_id << std::endl;
        
        if (!available_runways.empty()) {
            std::string runway = available_runways.back();
            available_runways.pop_back();
            occupied_runways.push_back(runway);
            
            aircrafts[aircraft_id]->receive_takeoff_clearance(true, runway);
            std::cout << "Tower: Runway " << runway << " assigned for takeoff to " << aircraft_id << std::endl;
        } else {
            aircrafts[aircraft_id]->receive_takeoff_clearance(false);
            std::cout << "Tower: No available runways for takeoff for " << aircraft_id << std::endl;
        }
    }
    
    void report_position(const std::string& aircraft_id, 
                        double latitude, double longitude, int altitude) override {
        auto aircraft = aircrafts[aircraft_id];
        aircraft->set_position(latitude, longitude, altitude);
        
        std::cout << "Tower: Position report from " << aircraft_id 
                  << " - Lat: " << latitude << ", Lon: " << longitude 
                  << ", Alt: " << altitude << "ft" << std::endl;
        
        // Check for potential conflicts
        check_airspace_conflicts(aircraft_id);
    }
    
    void release_runway(const std::string& runway) {
        auto it = std::find(occupied_runways.begin(), occupied_runways.end(), runway);
        if (it != occupied_runways.end()) {
            occupied_runways.erase(it);
            available_runways.push_back(runway);
            std::cout << "Tower: Runway " << runway << " released and available." << std::endl;
        }
    }
    
    void show_status() const {
        std::cout << "\n=== TOWER STATUS ===" << std::endl;
        std::cout << "Available runways: ";
        for (const auto& runway : available_runways) {
            std::cout << runway << " ";
        }
        std::cout << std::endl;
        
        std::cout << "Occupied runways: ";
        for (const auto& runway : occupied_runways) {
            std::cout << runway << " ";
        }
        std::cout << std::endl;
        
        std::cout << "Registered aircraft: " << aircrafts.size() << std::endl;
        std::cout << "Total communications: " << communication_count << std::endl;
        
        std::cout << "\nAircraft details:" << std::endl;
        for (const auto& pair : aircrafts) {
            std::cout << "- " << pair.first << " (" << pair.second->get_model() 
                      << ") - Altitude: " << pair.second->get_altitude() 
                      << "ft, In air: " << (pair.second->is_in_air() ? "Yes" : "No") << std::endl;
        }
    }

private:
    void handle_emergency_landing(std::shared_ptr<EmergencyAircraft> aircraft) {
        std::cout << "Tower: HANDLING EMERGENCY for " << aircraft->get_id() 
                  << " - " << aircraft->get_emergency_type() << std::endl;
        
        // Emergency gets highest priority - clear a runway if needed
        if (available_runways.empty() && !occupied_runways.empty()) {
            std::string runway = occupied_runways.back();
            occupied_runways.pop_back();
            available_runways.push_back(runway);
            std::cout << "Tower: Cleared runway " << runway << " for emergency landing" << std::endl;
        }
        
        if (!available_runways.empty()) {
            std::string runway = available_runways.back();
            available_runways.pop_back();
            occupied_runways.push_back(runway);
            
            aircraft->receive_landing_clearance(true, runway);
            
            // Alert all other aircraft
            send_message("TOWER", "ALL", "EMERGENCY IN PROGRESS - Maintain safe distance");
        }
    }
    
    void check_airspace_conflicts(const std::string& reporting_aircraft) {
        auto reporter = aircrafts[reporting_aircraft];
        
        for (const auto& pair : aircrafts) {
            if (pair.first != reporting_aircraft && pair.second->is_in_air()) {
                double distance = calculate_distance(reporter->get_latitude(), reporter->get_longitude(),
                                                   pair.second->get_latitude(), pair.second->get_longitude());
                int alt_diff = std::abs(reporter->get_altitude() - pair.second->get_altitude());
                
                if (distance < 5.0 && alt_diff < 1000) { // 5 nautical miles, 1000ft
                    std::cout << "Tower: WARNING - Potential conflict between " 
                              << reporting_aircraft << " and " << pair.first << std::endl;
                    send_message("TOWER", reporting_aircraft, 
                                "Adjust course - traffic proximity warning");
                    send_message("TOWER", pair.first, 
                                "Adjust course - traffic proximity warning");
                }
            }
        }
    }
    
    double calculate_distance(double lat1, double lon1, double lat2, double lon2) {
        // Simplified distance calculation
        return std::sqrt(std::pow(lat2 - lat1, 2) + std::pow(lon2 - lon1, 2));
    }
};

// Demo function
void atcDemo() {
    std::cout << "=== Mediator Pattern - Air Traffic Control System ===" << std::endl;
    
    auto tower = std::make_shared<TowerControl>();
    
    // Create various aircraft
    auto flight_ua101 = std::make_shared<PassengerAircraft>("UA101", "Boeing 737", 
                                                          180, "United Airlines", tower);
    auto flight_aa202 = std::make_shared<PassengerAircraft>("AA202", "Airbus A320", 
                                                          150, "American Airlines", tower);
    auto cargo_flight = std::make_shared<CargoAircraft>("FX303", "Boeing 767", 
                                                       45.5, "Electronics", tower);
    auto emergency_flight = std::make_shared<EmergencyAircraft>("EM404", "Cessna 172", 
                                                              "Engine trouble", 1, tower);
    
    // Register aircraft with tower
    tower->register_aircraft(flight_ua101);
    tower->register_aircraft(flight_aa202);
    tower->register_aircraft(cargo_flight);
    tower->register_aircraft(emergency_flight);
    
    // Simulate air traffic operations
    std::cout << "\n--- Simulating Air Traffic ---" << std::endl;
    
    // Aircraft report positions
    flight_ua101->set_position(40.7128, -74.0060, 35000);
    flight_ua101->set_speed(450);
    flight_ua101->report_position();
    
    flight_aa202->set_position(40.7589, -73.9851, 32000);
    flight_aa202->set_speed(420);
    flight_aa202->report_position();
    
    cargo_flight->set_position(40.6413, -73.7781, 1000);
    cargo_flight->set_speed(180);
    cargo_flight->report_position();
    
    // Communication between aircraft
    flight_ua101->send_message("AA202", "United 101 to American 202, good morning!");
    flight_aa202->send_message("UA101", "American 202 to United 101, morning! Beautiful day for flying.");
    
    // Landing requests
    std::cout << "\n--- Landing Operations ---" << std::endl;
    cargo_flight->request_landing();
    flight_ua101->request_landing();
    flight_aa202->request_landing();
    
    // Emergency situation
    std::cout << "\n--- Emergency Situation ---" << std::endl;
    emergency_flight->set_position(40.7829, -73.9654, 5000);
    emergency_flight->report_position();
    emergency_flight->request_emergency_landing();
    
    // Release runways and continue operations
    std::cout << "\n--- Runway Management ---" << std::endl;
    tower->release_runway("09L");
    tower->release_runway("09R");
    
    // Takeoff requests
    std::cout << "\n--- Takeoff Operations ---" << std::endl;
    cargo_flight->request_takeoff();
    flight_ua101->request_takeoff();
    
    // Show final status
    tower->show_status();
}

int main() {
    atcDemo();
    return 0;
}
```

#### Chat Room System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <ctime>

// Forward declaration
class User;

// Mediator Interface
class ChatRoom {
public:
    virtual ~ChatRoom() = default;
    virtual void register_user(std::shared_ptr<User> user) = 0;
    virtual void send_message(const std::string& from, const std::string& to, 
                            const std::string& message) = 0;
    virtual void broadcast_message(const std::string& from, const std::string& message) = 0;
    virtual void create_private_chat(const std::string& user1, const std::string& user2) = 0;
    virtual void show_user_list() const = 0;
};

// Colleague Interface
class User {
protected:
    std::string username;
    std::string status;
    std::weak_ptr<ChatRoom> chat_room;

public:
    User(const std::string& name, std::shared_ptr<ChatRoom> room)
        : username(name), status("online"), chat_room(room) {}
    
    virtual ~User() = default;
    
    std::string get_username() const { return username; }
    std::string get_status() const { return status; }
    
    void set_status(const std::string& new_status) {
        status = new_status;
        std::cout << username << " is now " << status << std::endl;
    }
    
    void send_message(const std::string& to, const std::string& message) {
        if (auto room = chat_room.lock()) {
            room->send_message(username, to, message);
        }
    }
    
    void broadcast_message(const std::string& message) {
        if (auto room = chat_room.lock()) {
            room->broadcast_message(username, message);
        }
    }
    
    virtual void receive_message(const std::string& from, const std::string& message) {
        std::cout << "[" << username << "] Private from " << from << ": " << message << std::endl;
    }
    
    virtual void receive_broadcast(const std::string& from, const std::string& message) {
        std::cout << "[" << username << "] Broadcast from " << from << ": " << message << std::endl;
    }
    
    virtual std::string get_user_type() const = 0;
};

// Concrete Colleagues
class RegularUser : public User {
public:
    RegularUser(const std::string& name, std::shared_ptr<ChatRoom> room)
        : User(name, room) {}
    
    std::string get_user_type() const override {
        return "Regular User";
    }
};

class AdminUser : public User {
private:
    std::vector<std::string> privileges;

public:
    AdminUser(const std::string& name, std::shared_ptr<ChatRoom> room)
        : User(name, room) {
        privileges = {"kick_users", "mute_users", "delete_messages"};
    }
    
    void kick_user(const std::string& target_user) {
        std::cout << "[ADMIN] " << username << " kicked " << target_user << " from the chat room." << std::endl;
        broadcast_message("User " + target_user + " has been kicked by admin.");
    }
    
    void mute_user(const std::string& target_user) {
        std::cout << "[ADMIN] " << username << " muted " << target_user << "." << std::endl;
        send_message(target_user, "You have been muted by an admin.");
    }
    
    std::string get_user_type() const override {
        return "Admin User";
    }
    
    const std::vector<std::string>& get_privileges() const {
        return privileges;
    }
};

class BotUser : public User {
private:
    std::vector<std::string> commands;

public:
    BotUser(const std::string& name, std::shared_ptr<ChatRoom> room)
        : User(name, room) {
        commands = {"!help", "!time", "!users", "!weather"};
        status = "bot";
    }
    
    void receive_broadcast(const std::string& from, const std::string& message) override {
        if (message == "!help") {
            send_help(from);
        } else if (message == "!time") {
            send_time(from);
        } else if (message == "!users") {
            if (auto room = chat_room.lock()) {
                room->show_user_list();
            }
        } else if (message == "!weather") {
            send_weather(from);
        }
    }
    
    std::string get_user_type() const override {
        return "Chat Bot";
    }

private:
    void send_help(const std::string& to) {
        std::string help_msg = "Available commands: ";
        for (const auto& cmd : commands) {
            help_msg += cmd + " ";
        }
        send_message(to, help_msg);
    }
    
    void send_time(const std::string& to) {
        std::time_t now = std::time(nullptr);
        std::string time_str = std::ctime(&now);
        time_str.pop_back(); // Remove newline
        send_message(to, "Current time: " + time_str);
    }
    
    void send_weather(const std::string& to) {
        send_message(to, "Weather: Sunny, 72°F. Perfect chatting weather!");
    }
};

// Concrete Mediator
class ChatRoomMediator : public ChatRoom {
private:
    std::unordered_map<std::string, std::shared_ptr<User>> users;
    std::unordered_map<std::string, std::vector<std::string>> private_chats;
    std::vector<std::string> message_history;
    int message_count;

public:
    ChatRoomMediator() : message_count(0) {}
    
    void register_user(std::shared_ptr<User> user) override {
        users[user->get_username()] = user;
        std::cout << "Chat Room: " << user->get_username() 
                  << " (" << user->get_user_type() << ") joined the room." << std::endl;
        
        // Notify all users
        broadcast_message("SYSTEM", user->get_username() + " joined the chat room.");
    }
    
    void send_message(const std::string& from, const std::string& to, 
                     const std::string& message) override {
        message_count++;
        
        if (users.find(to) != users.end()) {
            users[to]->receive_message(from, message);
            log_message(from, to, message, "PRIVATE");
        } else {
            std::cout << "Chat Room: User " << to << " not found." << std::endl;
        }
    }
    
    void broadcast_message(const std::string& from, const std::string& message) override {
        message_count++;
        
        std::cout << "Chat Room: Broadcast from " << from << ": " << message << std::endl;
        
        for (auto& pair : users) {
            if (pair.first != from) {
                pair.second->receive_broadcast(from, message);
            }
        }
        
        log_message(from, "ALL", message, "BROADCAST");
    }
    
    void create_private_chat(const std::string& user1, const std::string& user2) override {
        if (users.find(user1) != users.end() && users.find(user2) != users.end()) {
            std::string chat_id = user1 < user2 ? user1 + "_" + user2 : user2 + "_" + user1;
            private_chats[chat_id] = {user1, user2};
            
            std::cout << "Chat Room: Private chat created between " << user1 
                      << " and " << user2 << std::endl;
            
            send_message("SYSTEM", user1, "Private chat started with " + user2);
            send_message("SYSTEM", user2, "Private chat started with " + user1);
        }
    }
    
    void show_user_list() const override {
        std::cout << "\n=== ONLINE USERS ===" << std::endl;
        std::cout << "Total users: " << users.size() << std::endl;
        
        for (const auto& pair : users) {
            std::cout << "- " << pair.first << " (" << pair.second->get_user_type() 
                      << ") - Status: " << pair.second->get_status() << std::endl;
        }
    }
    
    void show_chat_stats() const {
        std::cout << "\n=== CHAT ROOM STATISTICS ===" << std::endl;
        std::cout << "Total users: " << users.size() << std::endl;
        std::cout << "Total messages: " << message_count << std::endl;
        std::cout << "Private chats: " << private_chats.size() << std::endl;
        std::cout << "Message history entries: " << message_history.size() << std::endl;
    }
    
    void show_recent_messages(int count = 5) const {
        std::cout << "\n=== RECENT MESSAGES ===" << std::endl;
        int start = std::max(0, (int)message_history.size() - count);
        for (int i = start; i < message_history.size(); ++i) {
            std::cout << message_history[i] << std::endl;
        }
    }

private:
    void log_message(const std::string& from, const std::string& to, 
                    const std::string& message, const std::string& type) {
        std::time_t now = std::time(nullptr);
        std::string time_str = std::ctime(&now);
        time_str.pop_back();
        
        std::string log_entry = "[" + time_str + "] " + type + " " + from + " -> " + to + ": " + message;
        message_history.push_back(log_entry);
        
        // Keep only last 100 messages
        if (message_history.size() > 100) {
            message_history.erase(message_history.begin());
        }
    }
};

// Demo function
void chatRoomDemo() {
    std::cout << "=== Mediator Pattern - Chat Room System ===" << std::endl;
    
    auto chat_room = std::make_shared<ChatRoomMediator>();
    
    // Create users
    auto alice = std::make_shared<RegularUser>("Alice", chat_room);
    auto bob = std::make_shared<RegularUser>("Bob", chat_room);
    auto admin = std::make_shared<AdminUser>("Admin", chat_room);
    auto bot = std::make_shared<BotUser>("ChatBot", chat_room);
    
    // Register users with chat room
    chat_room->register_user(alice);
    chat_room->register_user(bob);
    chat_room->register_user(admin);
    chat_room->register_user(bot);
    
    // Simulate chat activity
    std::cout << "\n--- Chat Activity ---" << std::endl;
    
    alice->broadcast_message("Hello everyone! How are you doing?");
    bob->broadcast_message("Hi Alice! I'm doing great, thanks for asking.");
    admin->broadcast_message("Welcome to the chat room! Please follow the rules.");
    
    // Private messages
    alice->send_message("Bob", "Hey Bob, did you finish that project we were discussing?");
    bob->send_message("Alice", "Yes, just completed it yesterday. Want to review it together?");
    
    // Bot commands
    alice->broadcast_message("!help");
    bob->broadcast_message("!time");
    alice->broadcast_message("!users");
    
    // Admin actions
    auto charlie = std::make_shared<RegularUser>("Charlie", chat_room);
    chat_room->register_user(charlie);
    
    charlie->broadcast_message("SPAM SPAM SPAM!!!");
    admin->kick_user("Charlie");
    
    // User status changes
    alice->set_status("away");
    bob->set_status("busy");
    
    // Create private chat
    chat_room->create_private_chat("Alice", "Bob");
    
    // More private communication
    alice->send_message("Bob", "Let's discuss the project in our private chat.");
    bob->send_message("Alice", "Sure, I'll share the details there.");
    
    // Show statistics and history
    chat_room->show_user_list();
    chat_room->show_chat_stats();
    chat_room->show_recent_messages(8);
}

int main() {
    chatRoomDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Forward declarations
typedef struct SmartDevice SmartDevice;
typedef struct SmartHomeHub SmartHomeHub;

// Mediator structure
typedef struct SmartHomeHub {
    SmartDevice** devices;
    int device_count;
    int capacity;
    void (*send_command)(struct SmartHomeHub*, const char*, const char*, const char*);
    void (*device_status_changed)(struct SmartHomeHub*, const char*, const char*);
    void (*show_status)(struct SmartHomeHub*);
} SmartHomeHub;

// Colleague structure
typedef struct SmartDevice {
    char name[50];
    char type[50];
    bool is_on;
    int power_consumption;
    SmartHomeHub* hub;
    
    void (*turn_on)(struct SmartDevice*);
    void (*turn_off)(struct SmartDevice*);
    void (*update_status)(struct SmartDevice*, const char*);
    void (*receive_command)(struct SmartDevice*, const char*, const char*);
} SmartDevice;

// Device implementations
void light_turn_on(SmartDevice* device) {
    device->is_on = true;
    printf("💡 %s turned ON\n", device->name);
    device->update_status(device, "on");
}

void light_turn_off(SmartDevice* device) {
    device->is_on = false;
    printf("💡 %s turned OFF\n", device->name);
    device->update_status(device, "off");
}

void light_receive_command(SmartDevice* device, const char* command, const char* param) {
    if (strcmp(command, "turn_on") == 0) {
        device->turn_on(device);
    } else if (strcmp(command, "turn_off") == 0) {
        device->turn_off(device);
    } else if (strcmp(command, "dim") == 0) {
        printf("💡 %s dimmed to %s%%\n", device->name, param);
        device->update_status(device, "dimmed");
    }
}

void thermostat_turn_on(SmartDevice* device) {
    device->is_on = true;
    printf("🌡️  %s turned ON\n", device->name);
    device->update_status(device, "on");
}

void thermostat_turn_off(SmartDevice* device) {
    device->is_on = false;
    printf("🌡️  %s turned OFF\n", device->name);
    device->update_status(device, "off");
}

void thermostat_receive_command(SmartDevice* device, const char* command, const char* param) {
    if (strcmp(command, "turn_on") == 0) {
        device->turn_on(device);
    } else if (strcmp(command, "turn_off") == 0) {
        device->turn_off(device);
    } else if (strcmp(command, "set_temperature") == 0) {
        printf("🌡️  %s temperature set to %s°C\n", device->name, param);
        device->update_status(device, "temperature_set");
    }
}

void security_camera_turn_on(SmartDevice* device) {
    device->is_on = true;
    printf("📹 %s turned ON - Recording started\n", device->name);
    device->update_status(device, "recording");
}

void security_camera_turn_off(SmartDevice* device) {
    device->is_on = false;
    printf("📹 %s turned OFF\n", device->name);
    device->update_status(device, "off");
}

void security_camera_receive_command(SmartDevice* device, const char* command, const char* param) {
    if (strcmp(command, "turn_on") == 0) {
        device->turn_on(device);
    } else if (strcmp(command, "turn_off") == 0) {
        device->turn_off(device);
    } else if (strcmp(command, "start_recording") == 0) {
        printf("📹 %s started recording\n", device->name);
        device->update_status(device, "recording");
    } else if (strcmp(command, "detect_motion") == 0) {
        printf("📹 %s detected motion! Alerting other devices...\n", device->name);
        device->update_status(device, "motion_detected");
    }
}

// Common device functions
void device_update_status(SmartDevice* device, const char* status) {
    if (device->hub) {
        device->hub->device_status_changed(device->hub, device->name, status);
    }
}

// Hub implementations
void hub_send_command(SmartHomeHub* hub, const char* device_name, const char* command, const char* param) {
    printf("\n🏠 Hub: Sending command '%s' to %s", command, device_name);
    if (param) {
        printf(" with parameter '%s'", param);
    }
    printf("\n");
    
    for (int i = 0; i < hub->device_count; i++) {
        if (strcmp(hub->devices[i]->name, device_name) == 0) {
            hub->devices[i]->receive_command(hub->devices[i], command, param);
            return;
        }
    }
    printf("Hub: Device %s not found!\n", device_name);
}

void hub_device_status_changed(SmartHomeHub* hub, const char* device_name, const char* status) {
    printf("🏠 Hub: %s status changed to '%s'\n", device_name, status);
    
    // Implement smart home logic based on device status changes
    if (strcmp(status, "motion_detected") == 0) {
        // When motion is detected, turn on lights and start recording
        printf("🏠 Hub: Motion detected! Automatically turning on lights and cameras...\n");
        
        for (int i = 0; i < hub->device_count; i++) {
            if (strstr(hub->devices[i]->type, "light") != NULL) {
                hub_send_command(hub, hub->devices[i]->name, "turn_on", NULL);
            } else if (strstr(hub->devices[i]->type, "camera") != NULL) {
                hub_send_command(hub, hub->devices[i]->name, "start_recording", NULL);
            }
        }
    } else if (strcmp(status, "on") == 0 && strstr(device_name, "light") != NULL) {
        // When lights are turned on, adjust thermostat if it's night time
        printf("🏠 Hub: Light turned on. Checking if we need to adjust climate control...\n");
    }
}

void hub_show_status(SmartHomeHub* hub) {
    printf("\n=== SMART HOME STATUS ===\n");
    printf("Connected devices: %d\n", hub->device_count);
    printf("\nDevice Details:\n");
    
    int total_power = 0;
    for (int i = 0; i < hub->device_count; i++) {
        SmartDevice* device = hub->devices[i];
        printf("- %s (%s): %s, Power: %dW\n", 
               device->name, device->type,
               device->is_on ? "ON" : "OFF",
               device->is_on ? device->power_consumption : 0);
        
        if (device->is_on) {
            total_power += device->power_consumption;
        }
    }
    printf("\nTotal power consumption: %dW\n", total_power);
}

// Factory functions
SmartDevice* create_light(const char* name, SmartHomeHub* hub) {
    SmartDevice* light = malloc(sizeof(SmartDevice));
    strcpy(light->name, name);
    strcpy(light->type, "smart_light");
    light->is_on = false;
    light->power_consumption = 15;
    light->hub = hub;
    light->turn_on = light_turn_on;
    light->turn_off = light_turn_off;
    light->update_status = device_update_status;
    light->receive_command = light_receive_command;
    return light;
}

SmartDevice* create_thermostat(const char* name, SmartHomeHub* hub) {
    SmartDevice* thermostat = malloc(sizeof(SmartDevice));
    strcpy(thermostat->name, name);
    strcpy(thermostat->type, "smart_thermostat");
    thermostat->is_on = false;
    thermostat->power_consumption = 5;
    thermostat->hub = hub;
    thermostat->turn_on = thermostat_turn_on;
    thermostat->turn_off = thermostat_turn_off;
    thermostat->update_status = device_update_status;
    thermostat->receive_command = thermostat_receive_command;
    return thermostat;
}

SmartDevice* create_security_camera(const char* name, SmartHomeHub* hub) {
    SmartDevice* camera = malloc(sizeof(SmartDevice));
    strcpy(camera->name, name);
    strcpy(camera->type, "security_camera");
    camera->is_on = false;
    camera->power_consumption = 8;
    camera->hub = hub;
    camera->turn_on = security_camera_turn_on;
    camera->turn_off = security_camera_turn_off;
    camera->update_status = device_update_status;
    camera->receive_command = security_camera_receive_command;
    return camera;
}

SmartHomeHub* create_smart_home_hub(int capacity) {
    SmartHomeHub* hub = malloc(sizeof(SmartHomeHub));
    hub->devices = malloc(sizeof(SmartDevice*) * capacity);
    hub->device_count = 0;
    hub->capacity = capacity;
    hub->send_command = hub_send_command;
    hub->device_status_changed = hub_device_status_changed;
    hub->show_status = hub_show_status;
    return hub;
}

void hub_register_device(SmartHomeHub* hub, SmartDevice* device) {
    if (hub->device_count < hub->capacity) {
        hub->devices[hub->device_count++] = device;
        printf("🏠 Hub: %s (%s) registered successfully\n", device->name, device->type);
    } else {
        printf("Hub: Cannot register %s - hub capacity reached!\n", device->name);
    }
}

// Demo function
void smartHomeDemo() {
    printf("=== Mediator Pattern - Smart Home System ===\n\n");
    
    // Create smart home hub
    SmartHomeHub* hub = create_smart_home_hub(10);
    
    // Create smart devices
    SmartDevice* living_room_light = create_light("Living Room Light", hub);
    SmartDevice* kitchen_light = create_light("Kitchen Light", hub);
    SmartDevice* main_thermostat = create_thermostat("Main Thermostat", hub);
    SmartDevice* front_camera = create_security_camera("Front Door Camera", hub);
    SmartDevice* back_camera = create_security_camera("Backyard Camera", hub);
    
    // Register devices with hub
    hub_register_device(hub, living_room_light);
    hub_register_device(hub, kitchen_light);
    hub_register_device(hub, main_thermostat);
    hub_register_device(hub, front_camera);
    hub_register_device(hub, back_camera);
    
    // Demonstrate device control through hub
    printf("\n--- Device Control Demo ---\n");
    hub->send_command(hub, "Living Room Light", "turn_on", NULL);
    hub->send_command(hub, "Main Thermostat", "set_temperature", "22");
    hub->send_command(hub, "Kitchen Light", "dim", "75");
    
    printf("\n--- Smart Automation Demo ---\n");
    // Simulate motion detection triggering automation
    hub->send_command(hub, "Front Door Camera", "detect_motion", NULL);
    
    printf("\n--- Individual Device Control ---\n");
    living_room_light->turn_off(living_room_light);
    main_thermostat->turn_on(main_thermostat);
    
    // Show final status
    hub->show_status(hub);
    
    // Cleanup
    free(living_room_light);
    free(kitchen_light);
    free(main_thermostat);
    free(front_camera);
    free(back_camera);
    free(hub->devices);
    free(hub);
}

int main() {
    smartHomeDemo();
    return 0;
}
```

### Python Implementation

#### Stock Trading System

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime
import random
from enum import Enum

class OrderType(Enum):
    BUY = "BUY"
    SELL = "SELL"

class OrderStatus(Enum):
    PENDING = "PENDING"
    EXECUTED = "EXECUTED"
    PARTIAL = "PARTIAL"
    CANCELLED = "CANCELLED"

# Colleague Interface
class MarketParticipant(ABC):
    def __init__(self, participant_id: str, name: str):
        self.participant_id = participant_id
        self.name = name
        self.portfolio = {}
        self.cash = 0.0
        self.order_history = []
    
    @abstractmethod
    def execute_order(self, order_type: OrderType, symbol: str, quantity: int, price: float) -> bool: ...
    
    @abstractmethod
    def receive_market_data(self, symbol: str, price: float, volume: int) -> None: ...
    
    @abstractmethod
    def receive_order_confirmation(self, order_id: str, status: OrderStatus, 
                                 filled_quantity: int, avg_price: float) -> None: ...

# Concrete Colleagues
class RetailTrader(MarketParticipant):
    def __init__(self, participant_id: str, name: str, initial_cash: float):
        super().__init__(participant_id, name)
        self.cash = initial_cash
        self.risk_tolerance = "MODERATE"
        self.trading_strategy = "SWING"
    
    def execute_order(self, order_type: OrderType, symbol: str, quantity: int, price: float) -> bool:
        order_value = quantity * price
        
        if order_type == OrderType.BUY and order_value > self.cash:
            print(f"❌ {self.name}: Insufficient cash for BUY order")
            return False
        
        if order_type == OrderType.SELL and self.portfolio.get(symbol, 0) < quantity:
            print(f"❌ {self.name}: Insufficient shares for SELL order")
            return False
        
        print(f"📊 {self.name} placing {order_type.value} order: {quantity} {symbol} @ ${price:.2f}")
        return True
    
    def receive_market_data(self, symbol: str, price: float, volume: int) -> None:
        # Retail traders might use this for decision making
        if random.random() < 0.3:  # 30% chance to react to market data
            action = "BUY" if price < 100 else "SELL"
            print(f"📈 {self.name} considering {action} based on {symbol} price ${price:.2f}")
    
    def receive_order_confirmation(self, order_id: str, status: OrderStatus, 
                                 filled_quantity: int, avg_price: float) -> None:
        print(f"✅ {self.name} Order {order_id}: {status.value} - "
              f"{filled_quantity} shares @ ${avg_price:.2f}")
        
        # Update portfolio and cash (simplified)
        # In real implementation, this would update based on actual order details
        if status == OrderStatus.EXECUTED:
            self.order_history.append({
                'order_id': order_id,
                'status': status,
                'filled_quantity': filled_quantity,
                'avg_price': avg_price,
                'timestamp': datetime.now()
            })

class InstitutionalInvestor(MarketParticipant):
    def __init__(self, participant_id: str, name: str, initial_cash: float):
        super().__init__(participant_id, name)
        self.cash = initial_cash
        self.risk_tolerance = "LOW"
        self.investment_strategy = "LONG_TERM"
        self.block_orders = []
    
    def execute_order(self, order_type: OrderType, symbol: str, quantity: int, price: float) -> bool:
        order_value = quantity * price
        
        if order_type == OrderType.BUY and order_value > self.cash * 0.1:  # Position limit
            print(f"❌ {self.name}: Order exceeds position limit")
            return False
        
        print(f"🏛️  {self.name} placing INSTITUTIONAL {order_type.value}: "
              f"{quantity:,} {symbol} @ ${price:.2f}")
        
        # Large orders might be split
        if quantity > 10000:
            print(f"   ↳ Large order - may be executed in blocks")
            self.block_orders.append({
                'symbol': symbol,
                'total_quantity': quantity,
                'remaining_quantity': quantity,
                'order_type': order_type,
                'limit_price': price
            })
        
        return True
    
    def receive_market_data(self, symbol: str, price: float, volume: int) -> None:
        # Institutional investors might use algorithmic trading
        if volume > 100000 and symbol in self.portfolio:
            print(f"🏛️  {self.name} analyzing high volume in {symbol} for potential rebalancing")
    
    def receive_order_confirmation(self, order_id: str, status: OrderStatus, 
                                 filled_quantity: int, avg_price: float) -> None:
        print(f"🏛️  {self.name} Institutional Order {order_id}: "
              f"{status.value} - {filled_quantity:,} shares @ ${avg_price:.2f}")

class MarketMaker(MarketParticipant):
    def __init__(self, participant_id: str, name: str):
        super().__init__(participant_id, name)
        self.cash = 10000000  # Market makers have significant capital
        self.bid_ask_spread = 0.02  # 2 cent spread
        self.inventory = {}
    
    def execute_order(self, order_type: OrderType, symbol: str, quantity: int, price: float) -> bool:
        # Market makers provide liquidity, so they're always ready to trade
        print(f"💼 {self.name} {order_type.value} {quantity} {symbol} @ ${price:.2f} "
              f"(Spread: ${self.bid_ask_spread:.2f})")
        return True
    
    def receive_market_data(self, symbol: str, price: float, volume: int) -> None:
        # Market makers adjust spreads based on volatility and volume
        if volume > 50000:
            self.bid_ask_spread = max(0.01, self.bid_ask_spread * 0.8)  # Tighten spread for high volume
        elif volume < 10000:
            self.bid_ask_spread = min(0.05, self.bid_ask_spread * 1.2)  # Widen spread for low volume
        
        print(f"💼 {self.name} adjusted {symbol} spread to ${self.bid_ask_spread:.2f}")
    
    def receive_order_confirmation(self, order_id: str, status: OrderStatus, 
                                 filled_quantity: int, avg_price: float) -> None:
        print(f"💼 {self.name} Market Maker Order {order_id}: "
              f"{status.value} - {filled_quantity} shares @ ${avg_price:.2f}")

# Mediator
class StockExchange:
    def __init__(self):
        self.participants: Dict[str, MarketParticipant] = {}
        self.order_book = {}
        self.transaction_history = []
        self.stock_prices = {
            'AAPL': 150.0,
            'GOOGL': 2800.0,
            'TSLA': 250.0,
            'AMZN': 3300.0,
            'MSFT': 300.0
        }
        self.volume_data = {symbol: 0 for symbol in self.stock_prices.keys()}
    
    def register_participant(self, participant: MarketParticipant) -> None:
        self.participants[participant.participant_id] = participant
        print(f"🏦 Exchange: {participant.name} registered as {type(participant).__name__}")
    
    def place_order(self, participant_id: str, order_type: OrderType, 
                   symbol: str, quantity: int, limit_price: float = None) -> str:
        if participant_id not in self.participants:
            return "ERROR: Participant not registered"
        
        participant = self.participants[participant_id]
        current_price = self.stock_prices.get(symbol)
        
        if not current_price:
            return "ERROR: Invalid symbol"
        
        # Use limit price if provided, otherwise use market price
        execution_price = limit_price if limit_price else current_price
        
        # Check if order can be executed
        if not participant.execute_order(order_type, symbol, quantity, execution_price):
            return "ERROR: Order validation failed"
        
        # Generate order ID
        order_id = f"ORD{len(self.transaction_history) + 1:06d}"
        
        # Simulate order execution
        filled_quantity = self._execute_order(order_id, participant, order_type, 
                                            symbol, quantity, execution_price)
        
        # Update market data
        self._update_market_data(symbol, execution_price, filled_quantity)
        
        # Notify all participants
        self._broadcast_market_data(symbol, execution_price, filled_quantity)
        
        return order_id
    
    def _execute_order(self, order_id: str, participant: MarketParticipant,
                      order_type: OrderType, symbol: str, quantity: int, price: float) -> int:
        # Simulate order matching and execution
        filled_quantity = quantity
        
        # Add some randomness to execution
        if random.random() < 0.1:  # 10% chance of partial fill
            filled_quantity = random.randint(1, quantity - 1)
            status = OrderStatus.PARTIAL
        else:
            status = OrderStatus.EXECUTED
        
        # Record transaction
        transaction = {
            'order_id': order_id,
            'participant': participant.name,
            'order_type': order_type,
            'symbol': symbol,
            'quantity': filled_quantity,
            'price': price,
            'timestamp': datetime.now(),
            'status': status
        }
        self.transaction_history.append(transaction)
        
        # Notify the participant
        participant.receive_order_confirmation(order_id, status, filled_quantity, price)
        
        return filled_quantity
    
    def _update_market_data(self, symbol: str, price: float, volume: int) -> None:
        # Update stock price with some random movement
        price_change = (random.random() - 0.5) * 2  # -1 to +1
        self.stock_prices[symbol] = max(0.01, price + price_change)
        self.volume_data[symbol] += volume
    
    def _broadcast_market_data(self, symbol: str, price: float, volume: int) -> None:
        for participant in self.participants.values():
            participant.receive_market_data(symbol, price, volume)
    
    def get_market_summary(self) -> Dict[str, Any]:
        total_volume = sum(self.volume_data.values())
        total_transactions = len(self.transaction_history)
        
        return {
            'stocks_traded': len(self.stock_prices),
            'total_volume': total_volume,
            'total_transactions': total_transactions,
            'participants_count': len(self.participants),
            'current_prices': self.stock_prices
        }
    
    def show_market_depth(self, symbol: str) -> None:
        print(f"\n📊 Market Depth for {symbol}:")
        print(f"   Current Price: ${self.stock_prices.get(symbol, 0):.2f}")
        print(f"   Today's Volume: {self.volume_data.get(symbol, 0):,}")
        
        # Show recent transactions for this symbol
        recent_trades = [t for t in self.transaction_history[-5:] if t['symbol'] == symbol]
        if recent_trades:
            print("   Recent Trades:")
            for trade in recent_trades:
                print(f"     {trade['order_type'].value} {trade['quantity']} @ ${trade['price']:.2f}")

# Demo function
def stockTradingDemo():
    print("=== Mediator Pattern - Stock Trading System ===\n")
    
    exchange = StockExchange()
    
    # Create market participants
    retail_trader1 = RetailTrader("RT001", "John Doe", 50000.0)
    retail_trader2 = RetailTrader("RT002", "Jane Smith", 75000.0)
    institution = InstitutionalInvestor("II001", "Global Investments Inc.", 10000000.0)
    market_maker = MarketMaker("MM001", "Liquidity Providers LLC")
    
    # Register participants with exchange
    exchange.register_participant(retail_trader1)
    exchange.register_participant(retail_trader2)
    exchange.register_participant(institution)
    exchange.register_participant(market_maker)
    
    # Simulate trading activity
    print("\n--- Trading Session Started ---")
    
    # Retail traders placing orders
    exchange.place_order("RT001", OrderType.BUY, "AAPL", 100, 149.5)
    exchange.place_order("RT002", OrderType.SELL, "TSLA", 50, 252.0)
    
    # Institutional order
    exchange.place_order("II001", OrderType.BUY, "GOOGL", 5000, 2795.0)
    
    # Market maker providing liquidity
    exchange.place_order("MM001", OrderType.BUY, "AAPL", 1000, 149.8)
    exchange.place_order("MM001", OrderType.SELL, "AAPL", 1000, 150.2)
    
    # More retail trading
    exchange.place_order("RT001", OrderType.BUY, "AMZN", 10)
    exchange.place_order("RT002", OrderType.SELL, "MSFT", 25, 302.0)
    
    # Large institutional order
    exchange.place_order("II001", OrderType.BUY, "TSLA", 10000, 248.0)
    
    print("\n--- Market Summary ---")
    summary = exchange.get_market_summary()
    for key, value in summary.items():
        if key == 'current_prices':
            print(f"Current Prices:")
            for symbol, price in value.items():
                print(f"  {symbol}: ${price:.2f}")
        else:
            print(f"{key.replace('_', ' ').title()}: {value}")
    
    # Show market depth for a popular stock
    exchange.show_market_depth("AAPL")
    
    print(f"\n--- Trading Session Complete ---")
    print(f"Total transactions processed: {len(exchange.transaction_history)}")

if __name__ == "__main__":
    stockTradingDemo()
```

## Advantages and Disadvantages

### Advantages

- **Reduces Coupling**: Eliminates direct connections between components
- **Centralized Control**: All communication logic in one place
- **Simplifies Object Protocols**: Replaces many-to-many with one-to-many
- **Open/Closed Principle**: Easy to add new colleagues without changing existing ones
- **Reusability**: Components are more reusable as they're not tightly coupled

### Disadvantages

- **Mediator Complexity**: Mediator can become a god object if not designed carefully
- **Single Point of Failure**: Mediator becomes critical component
- **Performance Overhead**: All communication goes through mediator
- **Debugging Complexity**: Hard to trace communication flow

## Best Practices

1. **Keep Mediator Focused**: Each mediator should handle a specific domain
2. **Use Interface Segregation**: Define clear interfaces for colleagues
3. **Avoid God Object**: Don't put all business logic in mediator
4. **Consider Event Bus**: For complex systems, consider using event bus pattern
5. **Testability**: Mediator makes it easier to test components in isolation

## Mediator vs Other Patterns

- **vs Observer**: Mediator encapsulates collective behavior, Observer defines one-to-many dependency
- **vs Facade**: Mediator promotes bidirectional communication, Facade provides simple interface to subsystem
- **vs Command**: Mediator handles communication between objects, Command encapsulates requests as objects
- **vs Proxy**: Mediator coordinates multiple objects, Proxy controls access to one object

The Mediator pattern is essential for managing complex communication in systems where multiple components need to interact without creating tight coupling. It's particularly useful in GUI frameworks, chat systems, trading platforms, and IoT device coordination.
