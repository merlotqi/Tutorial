# Template Method Pattern

## Introduction

The Template Method Pattern is a behavioral design pattern that defines the skeleton of an algorithm in a method, deferring some steps to subclasses. It lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.

### Key Characteristics

- **Algorithm Skeleton**: Defines the overall structure of an algorithm
- **Step Deferral**: Allows subclasses to implement specific steps
- **Code Reuse**: Promotes code reuse through inheritance
- **Hollywood Principle**: "Don't call us, we'll call you" - parent class calls subclass methods

### Use Cases

- Framework development
- Code generators
- Data processing pipelines
- Game loops and engines
- Test case frameworks
- Document generation

## Implementation Examples

### C++ Implementation

#### Data Processing Pipeline

```cpp
#include <iostream>
#include <vector>
#include <memory>
#include <string>
#include <algorithm>
#include <fstream>
#include <sstream>

// Abstract Template Class
class DataProcessor {
public:
    virtual ~DataProcessor() = default;

    // Template Method - defines the algorithm skeleton
    void process_data(const std::string& input_file, const std::string& output_file) {
        std::cout << "=== Starting Data Processing ===" << std::endl;
        
        // Step 1: Read input data
        auto data = read_data(input_file);
        std::cout << "Read " << data.size() << " records" << std::endl;
        
        // Step 2: Validate data
        if (!validate_data(data)) {
            std::cout << "Data validation failed!" << std::endl;
            return;
        }
        
        // Step 3: Transform data (hook method)
        auto transformed_data = transform_data(data);
        std::cout << "Transformed to " << transformed_data.size() << " records" << std::endl;
        
        // Step 4: Process data (abstract method)
        auto processed_data = process_implementation(transformed_data);
        
        // Step 5: Write output
        write_data(output_file, processed_data);
        std::cout << "Output written to: " << output_file << std::endl;
        
        // Step 6: Cleanup (hook method)
        cleanup();
        
        std::cout << "=== Data Processing Complete ===" << std::endl;
    }

protected:
    // Concrete methods - common implementation
    std::vector<std::string> read_data(const std::string& filename) {
        std::vector<std::string> data;
        std::ifstream file(filename);
        std::string line;
        
        while (std::getline(file, line)) {
            if (!line.empty()) {
                data.push_back(line);
            }
        }
        
        return data;
    }
    
    bool validate_data(const std::vector<std::string>& data) {
        if (data.empty()) {
            std::cout << "Error: Input data is empty" << std::endl;
            return false;
        }
        
        for (const auto& record : data) {
            if (record.find("ERROR") != std::string::npos) {
                std::cout << "Error: Invalid record found: " << record << std::endl;
                return false;
            }
        }
        
        return true;
    }
    
    void write_data(const std::string& filename, const std::vector<std::string>& data) {
        std::ofstream file(filename);
        for (const auto& record : data) {
            file << record << "\n";
        }
    }
    
    // Hook method - subclasses can override but don't have to
    virtual std::vector<std::string> transform_data(const std::vector<std::string>& data) {
        std::cout << "Using default transformation (identity)" << std::endl;
        return data; // Default: no transformation
    }
    
    virtual void cleanup() {
        std::cout << "Performing default cleanup" << std::endl;
    }
    
    // Abstract method - must be implemented by subclasses
    virtual std::vector<std::string> process_implementation(const std::vector<std::string>& data) = 0;
};

// Concrete Implementations
class CSVProcessor : public DataProcessor {
protected:
    std::vector<std::string> transform_data(const std::vector<std::string>& data) override {
        std::cout << "Transforming CSV data: parsing and cleaning" << std::endl;
        std::vector<std::string> transformed;
        
        for (const auto& line : data) {
            // Simple CSV parsing - remove extra spaces
            std::string cleaned;
            bool in_quotes = false;
            
            for (char c : line) {
                if (c == '"') {
                    in_quotes = !in_quotes;
                } else if (c == ' ' && !in_quotes) {
                    continue; // Remove spaces outside quotes
                }
                cleaned += c;
            }
            
            transformed.push_back(cleaned);
        }
        
        return transformed;
    }
    
    std::vector<std::string> process_implementation(const std::vector<std::string>& data) override {
        std::cout << "Processing CSV data: calculating statistics" << std::endl;
        std::vector<std::string> results;
        
        int total_records = data.size();
        int total_fields = 0;
        std::vector<int> field_counts;
        
        for (const auto& line : data) {
            int field_count = 1; // Start with 1 for first field
            for (char c : line) {
                if (c == ',') field_count++;
            }
            field_counts.push_back(field_count);
            total_fields += field_count;
        }
        
        double avg_fields = static_cast<double>(total_fields) / total_records;
        
        results.push_back("CSV Processing Results:");
        results.push_back("Total Records: " + std::to_string(total_records));
        results.push_back("Total Fields: " + std::to_string(total_fields));
        results.push_back("Average Fields per Record: " + std::to_string(avg_fields));
        
        return results;
    }
    
    void cleanup() override {
        std::cout << "CSV Processor: Cleaning up temporary files" << std::endl;
    }
};

class JSONProcessor : public DataProcessor {
protected:
    std::vector<std::string> transform_data(const std::vector<std::string>& data) override {
        std::cout << "Transforming JSON data: validating structure" << std::endl;
        std::vector<std::string> transformed;
        
        for (const auto& line : data) {
            // Simple JSON validation and formatting
            std::string formatted = line;
            
            // Remove extra whitespace
            formatted.erase(std::remove_if(formatted.begin(), formatted.end(), 
                          [](unsigned char c) { return std::isspace(c); }), 
                          formatted.end());
            
            // Ensure proper JSON structure
            if (!formatted.empty() && formatted[0] == '{' && formatted.back() == '}') {
                transformed.push_back(formatted);
            }
        }
        
        return transformed;
    }
    
    std::vector<std::string> process_implementation(const std::vector<std::string>& data) override {
        std::cout << "Processing JSON data: extracting key information" << std::endl;
        std::vector<std::string> results;
        
        int total_objects = data.size();
        int total_keys = 0;
        
        for (const auto& json_str : data) {
            int key_count = 0;
            for (size_t i = 0; i < json_str.length() - 1; ++i) {
                if (json_str[i] == '"' && json_str[i+1] == ':') {
                    key_count++;
                }
            }
            total_keys += key_count;
        }
        
        results.push_back("JSON Processing Results:");
        results.push_back("Total Objects: " + std::to_string(total_objects));
        results.push_back("Total Keys: " + std::to_string(total_keys));
        results.push_back("Average Keys per Object: " + 
                         std::to_string(static_cast<double>(total_keys) / total_objects));
        
        return results;
    }
};

class LogProcessor : public DataProcessor {
protected:
    std::vector<std::string> transform_data(const std::vector<std::string>& data) override {
        std::cout << "Transforming log data: filtering and parsing" << std::endl;
        std::vector<std::string> transformed;
        
        for (const auto& line : data) {
            // Filter out debug messages and parse timestamps
            if (line.find("DEBUG") == std::string::npos) {
                // Extract timestamp and message
                size_t timestamp_end = line.find(']');
                if (timestamp_end != std::string::npos) {
                    std::string cleaned = line.substr(0, timestamp_end + 1) + 
                                         " | " + line.substr(timestamp_end + 1);
                    transformed.push_back(cleaned);
                } else {
                    transformed.push_back(line);
                }
            }
        }
        
        return transformed;
    }
    
    std::vector<std::string> process_implementation(const std::vector<std::string>& data) override {
        std::cout << "Processing log data: analyzing patterns" << std::endl;
        std::vector<std::string> results;
        
        int error_count = 0;
        int warning_count = 0;
        int info_count = 0;
        
        for (const auto& line : data) {
            if (line.find("ERROR") != std::string::npos) {
                error_count++;
            } else if (line.find("WARNING") != std::string::npos) {
                warning_count++;
            } else if (line.find("INFO") != std::string::npos) {
                info_count++;
            }
        }
        
        results.push_back("Log Analysis Results:");
        results.push_back("Total Log Entries: " + std::to_string(data.size()));
        results.push_back("ERROR Count: " + std::to_string(error_count));
        results.push_back("WARNING Count: " + std::to_string(warning_count));
        results.push_back("INFO Count: " + std::to_string(info_count));
        results.push_back("Error Rate: " + 
                         std::to_string(static_cast<double>(error_count) / data.size() * 100) + "%");
        
        return results;
    }
    
    void cleanup() override {
        std::cout << "Log Processor: Archiving processed logs" << std::endl;
    }
};

// Demo function
void dataProcessingDemo() {
    std::cout << "=== Template Method Pattern - Data Processing Pipeline ===\n" << std::endl;
    
    // Create sample data files
    std::ofstream csv_file("data.csv");
    csv_file << "Name,Age,City\n";
    csv_file << "John,25,New York\n";
    csv_file << "Alice,30,London\n";
    csv_file << "Bob,35,Tokyo\n";
    csv_file.close();
    
    std::ofstream json_file("data.json");
    json_file << "{\"name\":\"John\",\"age\":25,\"city\":\"New York\"}\n";
    json_file << "{\"name\":\"Alice\",\"age\":30,\"city\":\"London\"}\n";
    json_file << "{\"name\":\"Bob\",\"age\":35,\"city\":\"Tokyo\"}\n";
    json_file.close();
    
    std::ofstream log_file("app.log");
    log_file << "[2023-10-01 10:00:00] INFO Application started\n";
    log_file << "[2023-10-01 10:01:00] DEBUG Loading configuration\n";
    log_file << "[2023-10-01 10:02:00] WARNING Low memory\n";
    log_file << "[2023-10-01 10:03:00] ERROR Database connection failed\n";
    log_file << "[2023-10-01 10:04:00] INFO Retrying connection\n";
    log_file.close();
    
    // Process different data types
    std::cout << "--- Processing CSV Data ---" << std::endl;
    CSVProcessor csv_processor;
    csv_processor.process_data("data.csv", "csv_results.txt");
    
    std::cout << "\n--- Processing JSON Data ---" << std::endl;
    JSONProcessor json_processor;
    json_processor.process_data("data.json", "json_results.txt");
    
    std::cout << "\n--- Processing Log Data ---" << std::endl;
    LogProcessor log_processor;
    log_processor.process_data("app.log", "log_results.txt");
}

int main() {
    dataProcessingDemo();
    return 0;
}
```

#### Game Engine Framework

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <thread>
#include <chrono>
#include <random>

// Abstract Game Template
class Game {
public:
    virtual ~Game() = default;
    
    // Template Method - The main game loop
    void run() {
        std::cout << "🎮 Starting " << get_game_name() << std::endl;
        
        initialize();
        
        while (!is_game_over()) {
            process_input();
            update();
            render();
            
            // Frame rate control
            std::this_thread::sleep_for(std::chrono::milliseconds(16)); // ~60 FPS
            current_frame++;
        }
        
        show_results();
        cleanup();
        
        std::cout << "🎮 " << get_game_name() << " finished!" << std::endl;
    }

protected:
    int current_frame = 0;
    int score = 0;
    bool game_running = true;
    
    // Concrete methods
    void initialize() {
        std::cout << "🔄 Initializing game..." << std::endl;
        load_assets();
        setup_level();
        std::cout << "✅ Game initialized successfully" << std::endl;
    }
    
    void cleanup() {
        std::cout << "🧹 Cleaning up game resources..." << std::endl;
        unload_assets();
        std::cout << "✅ Cleanup completed" << std::endl;
    }
    
    // Hook methods with default implementations
    virtual void load_assets() {
        std::cout << "📦 Loading default assets..." << std::endl;
    }
    
    virtual void unload_assets() {
        std::cout << "🗑️ Unloading default assets..." << std::endl;
    }
    
    virtual void setup_level() {
        std::cout << "🏗️ Setting up default level..." << std::endl;
    }
    
    virtual void show_results() {
        std::cout << "🏆 Final Score: " << score << std::endl;
        std::cout << "📊 Frames played: " << current_frame << std::endl;
    }
    
    // Abstract methods - must be implemented by subclasses
    virtual std::string get_game_name() const = 0;
    virtual void process_input() = 0;
    virtual void update() = 0;
    virtual void render() = 0;
    virtual bool is_game_over() = 0;
};

// Concrete Game: Space Shooter
class SpaceShooter : public Game {
private:
    int player_health = 100;
    int enemy_count = 5;
    std::mt19937 rng;
    
public:
    SpaceShooter() : rng(std::random_device{}()) {}
    
protected:
    std::string get_game_name() const override {
        return "Galaxy Defender";
    }
    
    void load_assets() override {
        std::cout << "🚀 Loading spaceship textures..." << std::endl;
        std::cout << "💥 Loading explosion sounds..." << std::endl;
        std::cout << "🎵 Loading background music..." << std::endl;
    }
    
    void setup_level() override {
        std::cout << "🌌 Generating asteroid field..." << std::endl;
        std::cout << "👾 Spawning enemy fleet..." << std::endl;
        enemy_count = 10;
        player_health = 100;
        score = 0;
    }
    
    void process_input() override {
        std::uniform_int_distribution<int> action_dist(1, 4);
        int action = action_dist(rng);
        
        switch (action) {
            case 1:
                std::cout << "⬆️ Player moves forward" << std::endl;
                break;
            case 2:
                std::cout << "💥 Player fires laser" << std::endl;
                enemy_count--;
                score += 100;
                break;
            case 3:
                std::cout.println("🛡️ Player activates shield" << std::endl;
                break;
            case 4:
                std::cout << "💨 Player dodges" << std::endl;
                break;
        }
    }
    
    void update() override {
        // Simulate game logic
        std::uniform_int_distribution<int> event_dist(1, 3);
        int event = event_dist(rng);
        
        switch (event) {
            case 1:
                if (enemy_count > 0) {
                    std::cout << "👾 Enemy attacks!" << std::endl;
                    player_health -= 10;
                }
                break;
            case 2:
                if (current_frame % 30 == 0 && enemy_count < 15) {
                    std::cout << "🆕 Enemy reinforcement arrived!" << std::endl;
                    enemy_count += 2;
                }
                break;
            case 3:
                if (current_frame % 60 == 0) {
                    std::cout << "⭐ Collected power-up!" << std::endl;
                    score += 50;
                }
                break;
        }
        
        // Update game state
        if (enemy_count <= 0) {
            std::cout << "✅ All enemies destroyed!" << std::endl;
            score += 500;
            enemy_count = 8; // Respawn enemies
        }
    }
    
    void render() override {
        std::cout << "🎮 Frame " << current_frame 
                  << " | Health: " << player_health 
                  << " | Enemies: " << enemy_count 
                  << " | Score: " << score << std::endl;
    }
    
    bool is_game_over() override {
        if (player_health <= 0) {
            std::cout << "💀 Player destroyed! Game Over." << std::endl;
            return true;
        }
        
        if (current_frame >= 300) { // 5 seconds at 60 FPS
            std::cout << "⏰ Time's up!" << std::endl;
            return true;
        }
        
        if (score >= 2000) {
            std::cout << "🎉 Victory! Maximum score achieved!" << std::endl;
            return true;
        }
        
        return false;
    }
    
    void show_results() override {
        Game::show_results();
        std::cout << "❤️ Final Health: " << player_health << std::endl;
        std::cout << "👾 Enemies Remaining: " << enemy_count << std::endl;
        
        if (score >= 1500) {
            std::cout << "🏅 Rank: ACE PILOT" << std::endl;
        } else if (score >= 1000) {
            std::cout << "🥈 Rank: VETERAN" << std::endl;
        } else {
            std::cout << "🥉 Rank: ROOKIE" << std::endl;
        }
    }
};

// Concrete Game: Puzzle Game
class PuzzleGame : public Game {
private:
    int level = 1;
    int pieces_solved = 0;
    int total_pieces = 10;
    
public:
    std::string get_game_name() const override {
        return "Mind Bender Puzzles";
    }
    
    void load_assets() override {
        std::cout << "🧩 Loading puzzle textures..." << std::endl;
        std::cout << "🔊 Loading sound effects..." << std::endl;
        std::cout << "📚 Loading puzzle database..." << std::endl;
    }
    
    void setup_level() override {
        std::cout << "🎯 Setting up Level " << level << "..." << std::endl;
        pieces_solved = 0;
        total_pieces = 8 + (level * 2);
        score = 0;
    }
    
    void process_input() override {
        // Simulate player solving puzzles
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dis(1, 3);
        
        int action = dis(gen);
        
        switch (action) {
            case 1:
                std::cout << "🧠 Player analyzes puzzle..." << std::endl;
                break;
            case 2:
                std::cout << "✍️ Player makes a move..." << std::endl;
                pieces_solved++;
                score += level * 10;
                break;
            case 3:
                std::cout << "💡 Player uses hint..." << std::endl;
                score -= 5;
                break;
        }
    }
    
    void update() override {
        // Check if level completed
        if (pieces_solved >= total_pieces) {
            std::cout << "✅ Level " << level << " completed!" << std::endl;
            score += level * 100;
            level++;
            pieces_solved = 0;
            total_pieces = 8 + (level * 2);
            
            if (level > 3) {
                game_running = false;
            }
        }
        
        // Random events
        if (current_frame % 25 == 0) {
            std::cout << "🌟 Bonus time! Extra points!" << std::endl;
            score += 15;
        }
    }
    
    void render() override {
        std::cout << "🧩 Level " << level 
                  << " | Solved: " << pieces_solved << "/" << total_pieces
                  << " | Score: " << score << std::endl;
    }
    
    bool is_game_over() override {
        return !game_running || current_frame >= 200;
    }
    
    void show_results() override {
        std::cout << "🎊 PUZZLE GAME RESULTS 🎊" << std::endl;
        std::cout << "Final Level: " << level << std::endl;
        std::cout << "Total Score: " << score << std::endl;
        std::cout << "Puzzles Solved: " << (level - 1) * 10 + pieces_solved << std::endl;
        
        if (score >= 500) {
            std::cout << "🏆 Master Puzzle Solver!" << std::endl;
        } else if (score >= 300) {
            std::cout << "🥈 Advanced Puzzler" << std::endl;
        } else {
            std::cout << "🥉 Puzzle Enthusiast" << std::endl;
        }
    }
};

// Demo function
void gameEngineDemo() {
    std::cout << "=== Template Method Pattern - Game Engine Framework ===\n" << std::endl;
    
    std::cout << "--- Running Space Shooter Game ---" << std::endl;
    SpaceShooter shooter;
    shooter.run();
    
    std::cout << "\n--- Running Puzzle Game ---" << std::endl;
    PuzzleGame puzzle;
    puzzle.run();
}

int main() {
    gameEngineDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Function pointer types for the template methods
typedef void (*CompileFunction)(void* context);
typedef void (*OptimizeFunction)(void* context);
typedef void (*GenerateCodeFunction)(void* context);
typedef void (*WriteOutputFunction)(void* context, const char* filename);

// Compiler Context Structure
typedef struct {
    char source_code[1024];
    char intermediate_code[1024];
    char optimized_code[1024];
    char final_output[1024];
    int optimization_level;
    CompileFunction compile;
    OptimizeFunction optimize;
    GenerateCodeFunction generate_code;
    WriteOutputFunction write_output;
} Compiler;

// Template Method - The compilation process
void compile_template(Compiler* compiler, const char* source, const char* output_file) {
    printf("🚀 Starting compilation process...\n");
    
    // Step 1: Store source code
    strcpy(compiler->source_code, source);
    printf("📝 Source code loaded (%lu characters)\n", strlen(source));
    
    // Step 2: Compile to intermediate representation
    compiler->compile(compiler);
    printf("🔧 Generated intermediate code\n");
    
    // Step 3: Optimize code
    compiler->optimize(compiler);
    printf("⚡ Applied optimizations\n");
    
    // Step 4: Generate final code
    compiler->generate_code(compiler);
    printf("🎯 Generated final code\n");
    
    // Step 5: Write output
    compiler->write_output(compiler, output_file);
    printf("💾 Output written to: %s\n", output_file);
    
    printf("✅ Compilation completed successfully!\n");
}

// C Compiler Implementation
void c_compile(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->intermediate_code, "C_IR: %s", compiler->source_code);
    printf("   - Parsing C syntax\n");
    printf("   - Type checking\n");
    printf("   - Generating C intermediate representation\n");
}

void c_optimize(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->optimized_code, "OPTIMIZED_C: %s [Level:%d]", 
            compiler->intermediate_code, compiler->optimization_level);
    
    printf("   - Inlining functions\n");
    printf("   - Dead code elimination\n");
    printf("   - Loop optimization\n");
    
    if (compiler->optimization_level > 1) {
        printf("   - Advanced: Vectorization\n");
        printf("   - Advanced: Link-time optimization\n");
    }
}

void c_generate_code(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->final_output, "EXECUTABLE: %s -> x86_64 machine code", 
            compiler->optimized_code);
    printf("   - Generating x86 assembly\n");
    printf("   - Allocating registers\n");
    printf("   - Resolving symbols\n");
}

void c_write_output(void* context, const char* filename) {
    Compiler* compiler = (Compiler*)context;
    printf("   - Creating object file: %s.o\n", filename);
    printf("   - Linking with C runtime\n");
    printf("   - Generating executable: %s\n", filename);
}

Compiler create_c_compiler(int optimization_level) {
    Compiler compiler;
    compiler.optimization_level = optimization_level;
    compiler.compile = c_compile;
    compiler.optimize = c_optimize;
    compiler.generate_code = c_generate_code;
    compiler.write_output = c_write_output;
    return compiler;
}

// Python Compiler Implementation
void python_compile(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->intermediate_code, "PYTHON_BYTECODE: %s", compiler->source_code);
    printf("   - Parsing Python syntax\n");
    printf("   - Dynamic type analysis\n");
    printf("   - Generating Python bytecode\n");
}

void python_optimize(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->optimized_code, "OPTIMIZED_PYTHON: %s [Peephole:%d]", 
            compiler->intermediate_code, compiler->optimization_level);
    
    printf("   - Constant folding\n");
    printf("   - Peephole optimization\n");
    
    if (compiler->optimization_level > 1) {
        printf("   - Advanced: JIT compilation ready\n");
    }
}

void python_generate_code(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->final_output, "PYC: %s -> Python bytecode file", 
            compiler->optimized_code);
    printf("   - Serializing bytecode\n");
    printf("   - Adding metadata\n");
}

void python_write_output(void* context, const char* filename) {
    Compiler* compiler = (Compiler*)context;
    printf("   - Creating bytecode file: %s.pyc\n", filename);
    printf("   - Adding magic number and timestamp\n");
}

Compiler create_python_compiler(int optimization_level) {
    Compiler compiler;
    compiler.optimization_level = optimization_level;
    compiler.compile = python_compile;
    compiler.optimize = python_optimize;
    compiler.generate_code = python_generate_code;
    compiler.write_output = python_write_output;
    return compiler;
}

// TypeScript Compiler Implementation
void typescript_compile(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->intermediate_code, "TS_AST: %s", compiler->source_code);
    printf("   - Parsing TypeScript syntax\n");
    printf("   - Type checking with TypeScript\n");
    printf("   - Generating Abstract Syntax Tree\n");
}

void typescript_optimize(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->optimized_code, "OPTIMIZED_TS: %s [StripTypes:%d]", 
            compiler->intermediate_code, compiler->optimization_level);
    
    printf("   - Type stripping\n");
    printf("   - Tree shaking\n");
    printf("   - Minification\n");
    
    if (compiler->optimization_level > 1) {
        printf("   - Advanced: Module bundling\n");
    }
}

void typescript_generate_code(void* context) {
    Compiler* compiler = (Compiler*)context;
    sprintf(compiler->final_output, "JS: %s -> JavaScript ES6", 
            compiler->optimized_code);
    printf("   - Transpiling to JavaScript\n");
    printf("   - Adding polyfills if needed\n");
}

void typescript_write_output(void* context, const char* filename) {
    Compiler* compiler = (Compiler*)context;
    printf("   - Creating JavaScript file: %s.js\n", filename);
    printf("   - Generating source maps\n");
    printf("   - Bundle analysis\n");
}

Compiler create_typescript_compiler(int optimization_level) {
    Compiler compiler;
    compiler.optimization_level = optimization_level;
    compiler.compile = typescript_compile;
    compiler.optimize = typescript_optimize;
    compiler.generate_code = typescript_generate_code;
    compiler.write_output = typescript_write_output;
    return compiler;
}

// Demo function
void compilerDemo() {
    printf("=== Template Method Pattern - Compiler Framework ===\n\n");
    
    // Sample source codes
    char c_source[] = "int main() { printf(\\\"Hello, World!\\\"); return 0; }";
    char python_source[] = "def hello(): print(\\\"Hello, World!\\\")";
    char typescript_source[] = "class Greeter { message: string; constructor(m: string) { this.message = m; } greet() { console.log(this.message); } }";
    
    printf("--- Compiling C Program ---\n");
    Compiler c_compiler = create_c_compiler(2);
    compile_template(&c_compiler, c_source, "hello_c");
    
    printf("\n--- Compiling Python Script ---\n");
    Compiler py_compiler = create_python_compiler(1);
    compile_template(&py_compiler, python_source, "hello_py");
    
    printf("\n--- Compiling TypeScript Code ---\n");
    Compiler ts_compiler = create_typescript_compiler(3);
    compile_template(&ts_compiler, typescript_source, "hello_ts");
    
    // Display final results
    printf("\n=== Compilation Results ===\n");
    printf("C Compiler Output: %s\n", c_compiler.final_output);
    printf("Python Compiler Output: %s\n", py_compiler.final_output);
    printf("TypeScript Compiler Output: %s\n", ts_compiler.final_output);
}

int main() {
    compilerDemo();
    return 0;
}
```

### Python Implementation

#### Web Framework Request Handling

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from datetime import datetime
import json
import hashlib
import time

class HTTPRequest:
    def __init__(self, method: str, path: str, headers: Dict[str, str], body: str = ""):
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
        self.timestamp = datetime.now()

class HTTPResponse:
    def __init__(self, status_code: int, body: str = "", headers: Dict[str, str] = None):
        self.status_code = status_code
        self.body = body
        self.headers = headers or {}
        self.timestamp = datetime.now()

# Abstract Request Handler Template
class RequestHandler(ABC):
    def handle_request(self, request: HTTPRequest) -> HTTPResponse:
        """Template method defining the request handling pipeline"""
        print(f"🔧 Handling {request.method} {request.path}")
        
        # Step 1: Authenticate request
        if not self.authenticate(request):
            return HTTPResponse(401, "Unauthorized")
        
        # Step 2: Validate request
        validation_result = self.validate_request(request)
        if not validation_result["valid"]:
            return HTTPResponse(400, validation_result["message"])
        
        # Step 3: Authorize request
        if not self.authorize(request):
            return HTTPResponse(403, "Forbidden")
        
        # Step 4: Process business logic
        try:
            result = self.process_request(request)
        except Exception as e:
            return self.handle_error(request, e)
        
        # Step 5: Format response
        response = self.format_response(result)
        
        # Step 6: Log request
        self.log_request(request, response)
        
        print(f"✅ Request handled successfully")
        return response
    
    # Concrete methods with default implementation
    def authenticate(self, request: HTTPRequest) -> bool:
        """Default authentication - check for API key"""
        api_key = request.headers.get('X-API-Key')
        if not api_key:
            print("❌ Authentication failed: No API key")
            return False
        
        # Simple validation - in real world, check against database
        if len(api_key) >= 10:
            print("🔑 Authentication successful")
            return True
        else:
            print("❌ Authentication failed: Invalid API key")
            return False
    
    def validate_request(self, request: HTTPRequest) -> Dict[str, Any]:
        """Default validation"""
        validations = {
            "valid": True,
            "message": ""
        }
        
        # Check required headers
        required_headers = ['User-Agent', 'Content-Type']
        for header in required_headers:
            if header not in request.headers:
                validations["valid"] = False
                validations["message"] = f"Missing required header: {header}"
                break
        
        # Validate HTTP method
        allowed_methods = ['GET', 'POST', 'PUT', 'DELETE']
        if request.method not in allowed_methods:
            validations["valid"] = False
            validations["message"] = f"Method {request.method} not allowed"
        
        if validations["valid"]:
            print("✅ Request validation passed")
        else:
            print(f"❌ Request validation failed: {validations['message']}")
        
        return validations
    
    def authorize(self, request: HTTPRequest) -> bool:
        """Default authorization - check if path is accessible"""
        restricted_paths = ['/admin', '/system']
        if any(request.path.startswith(path) for path in restricted_paths):
            print("❌ Authorization failed: Access to restricted path")
            return False
        
        print("✅ Authorization granted")
        return True
    
    def format_response(self, result: Any) -> HTTPResponse:
        """Default response formatting"""
        if isinstance(result, dict):
            body = json.dumps(result)
            headers = {'Content-Type': 'application/json'}
        else:
            body = str(result)
            headers = {'Content-Type': 'text/plain'}
        
        headers['X-Request-ID'] = hashlib.md5(str(time.time()).encode()).hexdigest()[:8]
        
        return HTTPResponse(200, body, headers)
    
    def handle_error(self, request: HTTPRequest, error: Exception) -> HTTPResponse:
        """Default error handling"""
        print(f"🚨 Error processing request: {error}")
        error_response = {
            "error": type(error).__name__,
            "message": str(error),
            "path": request.path,
            "timestamp": datetime.now().isoformat()
        }
        return HTTPResponse(500, json.dumps(error_response))
    
    def log_request(self, request: HTTPRequest, response: HTTPResponse) -> None:
        """Default request logging"""
        log_entry = {
            'timestamp': request.timestamp.isoformat(),
            'method': request.method,
            'path': request.path,
            'status_code': response.status_code,
            'response_time': (response.timestamp - request.timestamp).total_seconds()
        }
        print(f"📝 Request logged: {log_entry}")
    
    # Abstract method - must be implemented by subclasses
    @abstractmethod
    def process_request(self, request: HTTPRequest) -> Any:
        pass

# Concrete Handler: User API
class UserAPIHandler(RequestHandler):
    def __init__(self):
        self.users = {
            1: {"id": 1, "name": "Alice", "email": "alice@example.com"},
            2: {"id": 2, "name": "Bob", "email": "bob@example.com"}
        }
    
    def process_request(self, request: HTTPRequest) -> Any:
        """Process user-related requests"""
        if request.method == 'GET' and request.path == '/users':
            return list(self.users.values())
        
        elif request.method == 'GET' and request.path.startswith('/users/'):
            user_id = int(request.path.split('/')[-1])
            if user_id in self.users:
                return self.users[user_id]
            else:
                raise ValueError(f"User {user_id} not found")
        
        elif request.method == 'POST' and request.path == '/users':
            user_data = json.loads(request.body)
            new_id = max(self.users.keys()) + 1
            user_data['id'] = new_id
            self.users[new_id] = user_data
            return {"id": new_id, "message": "User created successfully"}
        
        elif request.method == 'PUT' and request.path.startswith('/users/'):
            user_id = int(request.path.split('/')[-1])
            if user_id in self.users:
                user_data = json.loads(request.body)
                self.users[user_id].update(user_data)
                return {"message": f"User {user_id} updated successfully"}
            else:
                raise ValueError(f"User {user_id} not found")
        
        elif request.method == 'DELETE' and request.path.startswith('/users/'):
            user_id = int(request.path.split('/')[-1])
            if user_id in self.users:
                del self.users[user_id]
                return {"message": f"User {user_id} deleted successfully"}
            else:
                raise ValueError(f"User {user_id} not found")
        
        else:
            raise ValueError(f"Unsupported operation: {request.method} {request.path}")

# Concrete Handler: Product API
class ProductAPIHandler(RequestHandler):
    def __init__(self):
        self.products = {
            1: {"id": 1, "name": "Laptop", "price": 999.99, "stock": 10},
            2: {"id": 2, "name": "Mouse", "price": 29.99, "stock": 50}
        }
        self.orders = []
    
    def process_request(self, request: HTTPRequest) -> Any:
        """Process product and order requests"""
        if request.method == 'GET' and request.path == '/products':
            return list(self.products.values())
        
        elif request.method == 'GET' and request.path.startswith('/products/'):
            product_id = int(request.path.split('/')[-1])
            if product_id in self.products:
                return self.products[product_id]
            else:
                raise ValueError(f"Product {product_id} not found")
        
        elif request.method == 'POST' and request.path == '/orders':
            order_data = json.loads(request.body)
            product_id = order_data.get('product_id')
            quantity = order_data.get('quantity', 1)
            
            if product_id not in self.products:
                raise ValueError(f"Product {product_id} not found")
            
            product = self.products[product_id]
            if product['stock'] < quantity:
                raise ValueError(f"Insufficient stock for {product['name']}")
            
            # Create order
            order = {
                'id': len(self.orders) + 1,
                'product_id': product_id,
                'quantity': quantity,
                'total_price': product['price'] * quantity,
                'status': 'confirmed',
                'timestamp': datetime.now().isoformat()
            }
            self.orders.append(order)
            
            # Update stock
            product['stock'] -= quantity
            
            return order
        
        elif request.method == 'GET' and request.path == '/orders':
            return self.orders
        
        else:
            raise ValueError(f"Unsupported operation: {request.method} {request.path}")

# Concrete Handler: Analytics API with custom behavior
class AnalyticsAPIHandler(RequestHandler):
    def __init__(self):
        self.analytics_data = {}
    
    def authenticate(self, request: HTTPRequest) -> bool:
        """Override authentication for analytics - require admin role"""
        api_key = request.headers.get('X-API-Key')
        user_role = request.headers.get('X-User-Role', 'user')
        
        if not api_key or user_role != 'admin':
            print("❌ Analytics access requires admin role")
            return False
        
        print("🔑 Admin authentication successful")
        return True
    
    def process_request(self, request: HTTPRequest) -> Any:
        """Process analytics requests"""
        if request.method == 'GET' and request.path == '/analytics/summary':
            return {
                "total_requests": len(self.analytics_data),
                "endpoints": list(set(data.get('endpoint', '') for data in self.analytics_data.values())),
                "timestamp": datetime.now().isoformat()
            }
        
        elif request.method == 'POST' and request.path == '/analytics/event':
            event_data = json.loads(request.body)
            event_id = hashlib.md5(str(event_data).encode()).hexdigest()
            self.analytics_data[event_id] = {
                **event_data,
                "timestamp": datetime.now().isoformat()
            }
            return {"event_id": event_id, "status": "recorded"}
        
        elif request.method == 'GET' and request.path.startswith('/analytics/events'):
            return list(self.analytics_data.values())
        
        else:
            raise ValueError(f"Unsupported operation: {request.method} {request.path}")
    
    def log_request(self, request: HTTPRequest, response: HTTPResponse) -> None:
        """Enhanced logging for analytics"""
        super().log_request(request, response)
        
        # Additional analytics logging
        analytics_event = {
            'endpoint': request.path,
            'method': request.method,
            'status_code': response.status_code,
            'user_agent': request.headers.get('User-Agent', 'Unknown'),
            'timestamp': datetime.now().isoformat()
        }
        
        event_id = hashlib.md5(str(analytics_event).encode()).hexdigest()
        self.analytics_data[event_id] = analytics_event
        
        print(f"📊 Analytics event recorded: {analytics_event}")

# Web Server Simulation
class WebServer:
    def __init__(self):
        self.handlers = {
            '/users': UserAPIHandler(),
            '/products': ProductAPIHandler(),
            '/analytics': AnalyticsAPIHandler()
        }
    
    def handle_request(self, method: str, path: str, headers: Dict[str, str], body: str = "") -> HTTPResponse:
        """Route request to appropriate handler"""
        # Find matching handler based on path prefix
        handler = None
        for prefix, h in self.handlers.items():
            if path.startswith(prefix):
                handler = h
                break
        
        if not handler:
            return HTTPResponse(404, f"No handler for path: {path}")
        
        request = HTTPRequest(method, path, headers, body)
        return handler.handle_request(request)

# Demo function
def webFrameworkDemo():
    print("=== Template Method Pattern - Web Framework ===\n")
    
    server = WebServer()
    
    # Test headers
    user_headers = {
        'User-Agent': 'DemoClient/1.0',
        'Content-Type': 'application/json',
        'X-API-Key': 'secret_user_key_12345'
    }
    
    admin_headers = {
        'User-Agent': 'AdminClient/1.0',
        'Content-Type': 'application/json',
        'X-API-Key': 'secret_admin_key_12345',
        'X-User-Role': 'admin'
    }
    
    print("--- Testing User API ---")
    response = server.handle_request('GET', '/users', user_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    response = server.handle_request('GET', '/users/1', user_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Testing Product API ---")
    response = server.handle_request('GET', '/products', user_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    order_data = json.dumps({'product_id': 1, 'quantity': 2})
    response = server.handle_request('POST', '/orders', user_headers, order_data)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Testing Analytics API (as regular user - should fail) ---")
    response = server.handle_request('GET', '/analytics/summary', user_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Testing Analytics API (as admin) ---")
    response = server.handle_request('GET', '/analytics/summary', admin_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    analytics_event = json.dumps({'event_type': 'page_view', 'page': '/home'})
    response = server.handle_request('POST', '/analytics/event', admin_headers, analytics_event)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Testing Error Cases ---")
    # Invalid API key
    invalid_headers = user_headers.copy()
    invalid_headers['X-API-Key'] = 'short'
    response = server.handle_request('GET', '/users', invalid_headers)
    print(f"Invalid API Key Response: {response.status_code} - {response.body}\n")
    
    # Missing header
    missing_headers = user_headers.copy()
    del missing_headers['User-Agent']
    response = server.handle_request('GET', '/users', missing_headers)
    print(f"Missing Header Response: {response.status_code} - {response.body}\n")

if __name__ == "__main__":
    webFrameworkDemo()
```

#### Test Framework

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Callable
from datetime import datetime
import time
import inspect

class TestResult:
    def __init__(self, test_name: str):
        self.test_name = test_name
        self.passed = False
        self.error_message = ""
        self.execution_time = 0.0
        self.timestamp = datetime.now()
    
    def __str__(self):
        status = "✅ PASS" if self.passed else "❌ FAIL"
        return f"{status} {self.test_name} ({self.execution_time:.3f}s)"

# Abstract Test Case Template
class TestCase(ABC):
    def __init__(self, test_name: str):
        self.test_name = test_name
        self.setup_called = False
        self.teardown_called = False
    
    def run(self) -> TestResult:
        """Template method defining the test execution flow"""
        result = TestResult(self.test_name)
        start_time = time.time()
        
        try:
            print(f"\n🧪 Running test: {self.test_name}")
            
            # Test lifecycle
            self.setup()
            self.setup_called = True
            
            self.execute_test()
            
            self.teardown()
            self.teardown_called = True
            
            result.passed = True
            print(f"✅ Test {self.test_name} passed")
            
        except AssertionError as e:
            result.error_message = f"Assertion failed: {e}"
            print(f"❌ Test {self.test_name} failed: {e}")
            
        except Exception as e:
            result.error_message = f"Unexpected error: {e}"
            print(f"💥 Test {self.test_name} crashed: {e}")
            
            # Ensure teardown is called even if test fails
            if self.setup_called and not self.teardown_called:
                try:
                    self.teardown()
                except Exception as teardown_error:
                    print(f"⚠️  Teardown also failed: {teardown_error}")
        
        finally:
            result.execution_time = time.time() - start_time
        
        return result
    
    # Hook methods with default implementations
    def setup(self) -> None:
        """Setup method - can be overridden by subclasses"""
        print(f"   ⚙️  Default setup for {self.test_name}")
    
    def teardown(self) -> None:
        """Teardown method - can be overridden by subclasses"""
        print(f"   🧹 Default teardown for {self.test_name}")
    
    # Abstract method - must be implemented by subclasses
    @abstractmethod
    def execute_test(self) -> None:
        """The actual test logic - to be implemented by subclasses"""
        pass

# Concrete Test Cases
class UnitTest(TestCase):
    def __init__(self, test_name: str, test_function: Callable):
        super().__init__(test_name)
        self.test_function = test_function
        self.test_data = None
    
    def setup(self) -> None:
        """Unit test specific setup"""
        print(f"   🔬 Unit test setup: {self.test_name}")
        # Initialize test data
        self.test_data = {"value": 42, "items": [1, 2, 3]}
    
    def execute_test(self) -> None:
        """Execute the unit test function"""
        # Inject test data if function accepts it
        sig = inspect.signature(self.test_function)
        if 'test_data' in sig.parameters:
            self.test_function(test_data=self.test_data)
        else:
            self.test_function()
    
    def teardown(self) -> None:
        """Unit test specific teardown"""
        print(f"   🗑️  Unit test teardown: {self.test_name}")
        self.test_data = None

class IntegrationTest(TestCase):
    def __init__(self, test_name: str, components: List[str]):
        super().__init__(test_name)
        self.components = components
        self.connections = {}
    
    def setup(self) -> None:
        """Integration test setup - connect components"""
        print(f"   🔗 Integration test setup: {self.test_name}")
        print(f"   Connecting components: {', '.join(self.components)}")
        
        # Simulate component connections
        for component in self.components:
            self.connections[component] = f"connected_{component}"
            print(f"   ✅ {component} connected")
        
        time.sleep(0.1)  # Simulate connection time
    
    def execute_test(self) -> None:
        """Execute integration test"""
        print(f"   🧩 Testing component integration")
        
        # Test data flow between components
        test_data = "integration_data"
        current_component = self.components[0]
        
        for next_component in self.components[1:]:
            print(f"   📤 {current_component} -> 📥 {next_component}")
            # Simulate data transfer
            assert self.connections[current_component] and self.connections[next_component]
            current_component = next_component
            time.sleep(0.05)
        
        print(f"   ✅ Data flowed through all components successfully")
    
    def teardown(self) -> None:
        """Integration test teardown - disconnect components"""
        print(f"   🔌 Integration test teardown: {self.test_name}")
        
        for component in self.components:
            print(f"   🔓 {component} disconnected")
            self.connections.pop(component, None)
        
        time.sleep(0.1)  # Simulate disconnection time

class PerformanceTest(TestCase):
    def __init__(self, test_name: str, operation: Callable, iterations: int = 1000):
        super().__init__(test_name)
        self.operation = operation
        self.iterations = iterations
        self.performance_data = []
    
    def setup(self) -> None:
        """Performance test setup"""
        print(f"   ⚡ Performance test setup: {self.test_name}")
        print(f"   Iterations: {self.iterations}")
        self.performance_data.clear()
    
    def execute_test(self) -> None:
        """Execute performance test"""
        print(f"   🏃 Running performance test...")
        
        start_time = time.time()
        
        for i in range(self.iterations):
            iteration_start = time.time()
            self.operation()
            iteration_time = time.time() - iteration_start
            self.performance_data.append(iteration_time)
        
        total_time = time.time() - start_time
        avg_time = total_time / self.iterations
        max_time = max(self.performance_data)
        min_time = min(self.performance_data)
        
        print(f"   📊 Performance Results:")
        print(f"     Total time: {total_time:.3f}s")
        print(f"     Average: {avg_time * 1000:.2f}ms")
        print(f"     Min: {min_time * 1000:.2f}ms")
        print(f"     Max: {max_time * 1000:.2f}ms")
        
        # Performance assertions
        assert avg_time < 0.01, f"Performance degraded: {avg_time * 1000:.2f}ms average"
        assert max_time < 0.05, f"Spike detected: {max_time * 1000:.2f}ms maximum"
    
    def teardown(self) -> None:
        """Performance test teardown"""
        print(f"   📈 Performance test teardown: {self.test_name}")
        # Could save performance data to file here

# Test Runner
class TestRunner:
    def __init__(self):
        self.test_cases: List[TestCase] = []
        self.results: List[TestResult] = []
    
    def add_test(self, test_case: TestCase) -> None:
        """Add a test case to the runner"""
        self.test_cases.append(test_case)
    
    def run_all_tests(self) -> None:
        """Run all test cases and report results"""
        print("🚀 Starting test execution")
        print("=" * 50)
        
        for test_case in self.test_cases:
            result = test_case.run()
            self.results.append(result)
        
        self._generate_report()
    
    def _generate_report(self) -> None:
        """Generate test execution report"""
        print("\n" + "=" * 50)
        print("📊 TEST EXECUTION REPORT")
        print("=" * 50)
        
        passed_tests = [r for r in self.results if r.passed]
        failed_tests = [r for r in self.results if not r.passed]
        
        total_time = sum(r.execution_time for r in self.results)
        
        print(f"Total Tests: {len(self.results)}")
        print(f"Passed: {len(passed_tests)}")
        print(f"Failed: {len(failed_tests)}")
        print(f"Total Execution Time: {total_time:.3f}s")
        print(f"Success Rate: {len(passed_tests)/len(self.results)*100:.1f}%")
        
        if passed_tests:
            print(f"\n✅ PASSED TESTS:")
            for result in passed_tests:
                print(f"  {result}")
        
        if failed_tests:
            print(f"\n❌ FAILED TESTS:")
            for result in failed_tests:
                print(f"  {result}")
                if result.error_message:
                    print(f"    Error: {result.error_message}")

# Demo test functions
def test_addition():
    """Simple unit test for addition"""
    assert 1 + 1 == 2, "Basic addition failed"
    assert 2 + 2 == 4, "Another addition failed"

def test_list_operations(test_data=None):
    """Unit test for list operations"""
    items = test_data["items"] if test_data else [1, 2, 3]
    items.append(4)
    assert len(items) == 4, "List append failed"
    assert items[-1] == 4, "Last element incorrect"

def test_string_operations():
    """Unit test for string operations"""
    text = "hello"
    assert text.upper() == "HELLO", "String upper failed"
    assert len(text) == 5, "String length incorrect"

def expensive_operation():
    """Simulate an expensive operation for performance testing"""
    time.sleep(0.001)  # 1ms operation
    sum(range(1000))  # Some computation

# Demo function
def testFrameworkDemo():
    print("=== Template Method Pattern - Test Framework ===\n")
    
    runner = TestRunner()
    
    # Add unit tests
    runner.add_test(UnitTest("test_addition", test_addition))
    runner.add_test(UnitTest("test_list_operations", test_list_operations))
    runner.add_test(UnitTest("test_string_operations", test_string_operations))
    
    # Add integration test
    runner.add_test(IntegrationTest("web_service_integration", 
                                   ["database", "api_gateway", "user_service", "auth_service"]))
    
    # Add performance test
    runner.add_test(PerformanceTest("expensive_operation_performance", 
                                   expensive_operation, iterations=500))
    
    # Run all tests
    runner.run_all_tests()

if __name__ == "__main__":
    testFrameworkDemo()
```

## Advantages and Disadvantages

### Advantages

- **Code Reuse**: Promotes code reuse through inheritance
- **Algorithm Consistency**: Ensures algorithm structure remains consistent
- **Hollywood Principle**: Parent class controls the flow, subclasses implement details
- **Eliminates Code Duplication**: Common code is in base class
- **Easy to Extend**: New implementations only need to override specific steps

### Disadvantages

- **Inheritance Limitations**: Requires inheritance, which can be restrictive
- **Liskov Substitution**: Must be careful with subclass behavior
- **Rigid Structure**: Algorithm structure is fixed in template method
- **Overhead**: May create too many small classes for simple variations

## Best Practices

1. **Use for Algorithms with Fixed Structure**: When you have algorithms with invariant steps
2. **Minimize Abstract Methods**: Keep the number of abstract methods small and focused
3. **Provide Sensible Defaults**: Use hook methods with default implementations when possible
4. **Document the Template**: Clearly document the algorithm flow and expected behavior
5. **Consider Strategy Pattern**: For more flexibility, consider Strategy pattern instead

## Template Method vs Other Patterns

- **vs Strategy**: Template Method uses inheritance, Strategy uses composition
- **vs Factory Method**: Factory Method is a specialization of Template Method
- **vs Observer**: Template Method defines algorithm, Observer handles notifications
- **vs Command**: Template Method defines algorithm structure, Command encapsulates requests

The Template Method pattern is widely used in frameworks, libraries, and any situation where you want to define the skeleton of an algorithm while allowing subclasses to provide specific implementations for certain steps.
