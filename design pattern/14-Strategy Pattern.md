# Strategy Pattern

## Introduction

The Strategy pattern is a behavioral design pattern that enables selecting an algorithm's behavior at runtime. It defines a family of algorithms, encapsulates each one, and makes them interchangeable.

### Key Characteristics

- **Algorithm Encapsulation**: Each algorithm is encapsulated in its own class
- **Interchangeability**: Strategies can be swapped at runtime
- **Eliminates Conditionals**: Replaces complex conditional logic with strategy objects
- **Open/Closed Principle**: New strategies can be added without modifying existing code

### Use Cases

- When you need different variants of an algorithm
- When you have multiple similar classes that only differ in their behavior
- To avoid exposing complex, algorithm-specific data structures
- When a class has multiple conditional statements for different behaviors

## Implementation Examples

### C++ Implementation

#### Payment Strategy Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>

// Strategy interface
class PaymentStrategy {
public:
    virtual ~PaymentStrategy() = default;
    virtual void pay(double amount) = 0;
    virtual std::string get_name() const = 0;
};

// Concrete Strategies
class CreditCardPayment : public PaymentStrategy {
private:
    std::string card_number;
    std::string expiry_date;
    std::string cvv;

public:
    CreditCardPayment(const std::string& card_num, const std::string& expiry, const std::string& cvv_code)
        : card_number(card_num), expiry_date(expiry), cvv(cvv_code) {}
    
    void pay(double amount) override {
        std::cout << "Processing credit card payment of $" << amount << std::endl;
        std::cout << "Card: " << mask_card_number(card_number) << std::endl;
        std::cout << "Payment successful!" << std::endl;
    }
    
    std::string get_name() const override {
        return "Credit Card";
    }

private:
    std::string mask_card_number(const std::string& card_num) {
        if (card_num.length() <= 4) return card_num;
        return "****-****-****-" + card_num.substr(card_num.length() - 4);
    }
};

class PayPalPayment : public PaymentStrategy {
private:
    std::string email;

public:
    PayPalPayment(const std::string& user_email) : email(user_email) {}
    
    void pay(double amount) override {
        std::cout << "Processing PayPal payment of $" << amount << std::endl;
        std::cout << "Email: " << email << std::endl;
        std::cout << "Redirecting to PayPal... Payment completed!" << std::endl;
    }
    
    std::string get_name() const override {
        return "PayPal";
    }
};

class CryptoPayment : public PaymentStrategy {
private:
    std::string wallet_address;
    std::string cryptocurrency;

public:
    CryptoPayment(const std::string& wallet, const std::string& crypto = "Bitcoin")
        : wallet_address(wallet), cryptocurrency(crypto) {}
    
    void pay(double amount) override {
        std::cout << "Processing " << cryptocurrency << " payment of $" << amount << std::endl;
        std::cout << "Wallet: " << mask_wallet_address(wallet_address) << std::endl;
        std::cout << "Transaction confirmed on blockchain!" << std::endl;
    }
    
    std::string get_name() const override {
        return cryptocurrency;
    }

private:
    std::string mask_wallet_address(const std::string& wallet) {
        if (wallet.length() <= 8) return wallet;
        return wallet.substr(0, 4) + "..." + wallet.substr(wallet.length() - 4);
    }
};

class BankTransferPayment : public PaymentStrategy {
private:
    std::string account_number;
    std::string routing_number;

public:
    BankTransferPayment(const std::string& account, const std::string& routing)
        : account_number(account), routing_number(routing) {}
    
    void pay(double amount) override {
        std::cout << "Processing bank transfer of $" << amount << std::endl;
        std::cout << "Account: " << mask_account_number(account_number) << std::endl;
        std::cout << "Transfer initiated. Will complete in 1-2 business days." << std::endl;
    }
    
    std::string get_name() const override {
        return "Bank Transfer";
    }

private:
    std::string mask_account_number(const std::string& account) {
        if (account.length() <= 4) return account;
        return "***" + account.substr(account.length() - 4);
    }
};

// Context
class PaymentProcessor {
private:
    std::unique_ptr<PaymentStrategy> strategy;
    double total_amount;

public:
    PaymentProcessor() : total_amount(0.0) {}
    
    void set_payment_strategy(std::unique_ptr<PaymentStrategy> payment_strategy) {
        strategy = std::move(payment_strategy);
        std::cout << "Payment method set to: " << strategy->get_name() << std::endl;
    }
    
    void add_to_cart(double amount) {
        total_amount += amount;
        std::cout << "Added $" << amount << " to cart. Total: $" << total_amount << std::endl;
    }
    
    void process_payment() {
        if (!strategy) {
            std::cout << "Error: No payment method selected!" << std::endl;
            return;
        }
        
        if (total_amount <= 0) {
            std::cout << "Error: Cart is empty!" << std::endl;
            return;
        }
        
        std::cout << "\n=== Processing Payment ===" << std::endl;
        strategy->pay(total_amount);
        total_amount = 0.0; // Reset cart after payment
    }
    
    void display_available_methods() const {
        std::cout << "\nAvailable Payment Methods:" << std::endl;
        std::cout << "1. Credit Card" << std::endl;
        std::cout << "2. PayPal" << std::endl;
        std::cout << "3. Cryptocurrency" << std::endl;
        std::cout << "4. Bank Transfer" << std::endl;
    }
};

// Usage example
void paymentSystemDemo() {
    std::cout << "=== Strategy Pattern - Payment System ===" << std::endl;
    
    PaymentProcessor processor;
    
    // Add items to cart
    processor.add_to_cart(25.99);
    processor.add_to_cart(15.50);
    processor.add_to_cart(8.75);
    
    // Demonstrate different payment strategies
    std::cout << "\n--- Credit Card Payment ---" << std::endl;
    processor.set_payment_strategy(std::make_unique<CreditCardPayment>("1234567812345678", "12/25", "123"));
    processor.process_payment();
    
    processor.add_to_cart(49.99);
    
    std::cout << "\n--- PayPal Payment ---" << std::endl;
    processor.set_payment_strategy(std::make_unique<PayPalPayment>("user@example.com"));
    processor.process_payment();
    
    processor.add_to_cart(100.00);
    
    std::cout << "\n--- Cryptocurrency Payment ---" << std::endl;
    processor.set_payment_strategy(std::make_unique<CryptoPayment>("1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"));
    processor.process_payment();
    
    processor.add_to_cart(75.25);
    
    std::cout << "\n--- Bank Transfer Payment ---" << std::endl;
    processor.set_payment_strategy(std::make_unique<BankTransferPayment>("987654321", "021000021"));
    processor.process_payment();
}

int main() {
    paymentSystemDemo();
    return 0;
}
```

#### Sorting Strategy Example

```cpp
#include <iostream>
#include <memory>
#include <vector>
#include <algorithm>
#include <string>
#include <chrono>

// Strategy interface
class SortStrategy {
public:
    virtual ~SortStrategy() = default;
    virtual void sort(std::vector<int>& data) = 0;
    virtual std::string get_name() const = 0;
    virtual void display(const std::vector<int>& data) const {
        std::cout << get_name() << " result: ";
        for (size_t i = 0; i < std::min(data.size(), size_t(10)); ++i) {
            std::cout << data[i] << " ";
        }
        if (data.size() > 10) std::cout << "...";
        std::cout << std::endl;
    }
};

// Concrete Strategies
class BubbleSort : public SortStrategy {
public:
    void sort(std::vector<int>& data) override {
        int n = data.size();
        for (int i = 0; i < n - 1; ++i) {
            for (int j = 0; j < n - i - 1; ++j) {
                if (data[j] > data[j + 1]) {
                    std::swap(data[j], data[j + 1]);
                }
            }
        }
    }
    
    std::string get_name() const override {
        return "Bubble Sort";
    }
};

class QuickSort : public SortStrategy {
public:
    void sort(std::vector<int>& data) override {
        quick_sort(data, 0, data.size() - 1);
    }
    
    std::string get_name() const override {
        return "Quick Sort";
    }

private:
    void quick_sort(std::vector<int>& data, int low, int high) {
        if (low < high) {
            int pi = partition(data, low, high);
            quick_sort(data, low, pi - 1);
            quick_sort(data, pi + 1, high);
        }
    }
    
    int partition(std::vector<int>& data, int low, int high) {
        int pivot = data[high];
        int i = low - 1;
        
        for (int j = low; j < high; ++j) {
            if (data[j] <= pivot) {
                ++i;
                std::swap(data[i], data[j]);
            }
        }
        std::swap(data[i + 1], data[high]);
        return i + 1;
    }
};

class MergeSort : public SortStrategy {
public:
    void sort(std::vector<int>& data) override {
        merge_sort(data, 0, data.size() - 1);
    }
    
    std::string get_name() const override {
        return "Merge Sort";
    }

private:
    void merge_sort(std::vector<int>& data, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;
            merge_sort(data, left, mid);
            merge_sort(data, mid + 1, right);
            merge(data, left, mid, right);
        }
    }
    
    void merge(std::vector<int>& data, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;
        
        std::vector<int> left_arr(n1), right_arr(n2);
        
        for (int i = 0; i < n1; ++i)
            left_arr[i] = data[left + i];
        for (int j = 0; j < n2; ++j)
            right_arr[j] = data[mid + 1 + j];
        
        int i = 0, j = 0, k = left;
        
        while (i < n1 && j < n2) {
            if (left_arr[i] <= right_arr[j]) {
                data[k] = left_arr[i];
                ++i;
            } else {
                data[k] = right_arr[j];
                ++j;
            }
            ++k;
        }
        
        while (i < n1) {
            data[k] = left_arr[i];
            ++i;
            ++k;
        }
        
        while (j < n2) {
            data[k] = right_arr[j];
            ++j;
            ++k;
        }
    }
};

class InsertionSort : public SortStrategy {
public:
    void sort(std::vector<int>& data) override {
        int n = data.size();
        for (int i = 1; i < n; ++i) {
            int key = data[i];
            int j = i - 1;
            
            while (j >= 0 && data[j] > key) {
                data[j + 1] = data[j];
                --j;
            }
            data[j + 1] = key;
        }
    }
    
    std::string get_name() const override {
        return "Insertion Sort";
    }
};

// Context
class Sorter {
private:
    std::unique_ptr<SortStrategy> strategy;

public:
    void set_strategy(std::unique_ptr<SortStrategy> sort_strategy) {
        strategy = std::move(sort_strategy);
    }
    
    void sort_data(std::vector<int>& data, bool show_result = true) {
        if (!strategy) {
            std::cout << "Error: No sorting strategy selected!" << std::endl;
            return;
        }
        
        if (data.empty()) {
            std::cout << "Error: Data is empty!" << std::endl;
            return;
        }
        
        std::cout << "\nSorting " << data.size() << " elements using " << strategy->get_name() << "..." << std::endl;
        
        // Measure execution time
        auto start = std::chrono::high_resolution_clock::now();
        
        strategy->sort(data);
        
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
        
        std::cout << "Sorting completed in " << duration.count() << " microseconds" << std::endl;
        
        if (show_result) {
            strategy->display(data);
        }
    }
    
    bool is_sorted(const std::vector<int>& data) const {
        return std::is_sorted(data.begin(), data.end());
    }
};

// Helper function to generate random data
std::vector<int> generate_random_data(int size, int min_val = 1, int max_val = 1000) {
    std::vector<int> data;
    data.reserve(size);
    
    for (int i = 0; i < size; ++i) {
        data.push_back(min_val + rand() % (max_val - min_val + 1));
    }
    
    return data;
}

// Usage example
void sortingDemo() {
    std::cout << "=== Strategy Pattern - Sorting Algorithms ===" << std::endl;
    
    Sorter sorter;
    const int data_size = 1000;
    
    // Generate test data
    auto test_data = generate_random_data(data_size);
    std::cout << "Generated " << data_size << " random numbers" << std::endl;
    
    // Test different sorting strategies
    std::cout << "\n--- Testing Bubble Sort ---" << std::endl;
    auto data1 = test_data; // Copy for each test
    sorter.set_strategy(std::make_unique<BubbleSort>());
    sorter.sort_data(data1);
    std::cout << "Correctly sorted: " << (sorter.is_sorted(data1) ? "Yes" : "No") << std::endl;
    
    std::cout << "\n--- Testing Quick Sort ---" << std::endl;
    auto data2 = test_data;
    sorter.set_strategy(std::make_unique<QuickSort>());
    sorter.sort_data(data2);
    std::cout << "Correctly sorted: " << (sorter.is_sorted(data2) ? "Yes" : "No") << std::endl;
    
    std::cout << "\n--- Testing Merge Sort ---" << std::endl;
    auto data3 = test_data;
    sorter.set_strategy(std::make_unique<MergeSort>());
    sorter.sort_data(data3);
    std::cout << "Correctly sorted: " << (sorter.is_sorted(data3) ? "Yes" : "No") << std::endl;
    
    std::cout << "\n--- Testing Insertion Sort ---" << std::endl;
    auto data4 = test_data;
    sorter.set_strategy(std::make_unique<InsertionSort>());
    sorter.sort_data(data4);
    std::cout << "Correctly sorted: " << (sorter.is_sorted(data4) ? "Yes" : "No") << std::endl;
    
    // Performance comparison with larger data
    std::cout << "\n=== Performance Comparison (5000 elements) ===" << std::endl;
    auto large_data = generate_random_data(5000);
    
    std::vector<std::unique_ptr<SortStrategy>> strategies;
    strategies.push_back(std::make_unique<QuickSort>());
    strategies.push_back(std::make_unique<MergeSort>());
    strategies.push_back(std::make_unique<InsertionSort>());
    strategies.push_back(std::make_unique<BubbleSort>());
    
    for (auto& strategy : strategies) {
        auto data_copy = large_data;
        sorter.set_strategy(std::move(strategy));
        sorter.sort_data(data_copy, false); // Don't show results, just timing
    }
}

int main() {
    sortingDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Strategy function pointer types
typedef void (*CompressionFunction)(const char* input_file, const char* output_file);
typedef void (*DecompressionFunction)(const char* input_file, const char* output_file);

// Strategy structure
typedef struct {
    CompressionFunction compress;
    DecompressionFunction decompress;
    char name[20];
    char extension[10];
} CompressionStrategy;

// Concrete Strategies
void zip_compress(const char* input_file, const char* output_file) {
    printf("Compressing '%s' to '%s.zip' using ZIP algorithm\n", input_file, output_file);
    printf("  - Using DEFLATE compression\n");
    printf("  - Creating archive structure\n");
    printf("  - Compression complete!\n");
}

void zip_decompress(const char* input_file, const char* output_file) {
    printf("Decompressing '%s.zip' to '%s' using ZIP algorithm\n", input_file, output_file);
    printf("  - Extracting archive structure\n");
    printf("  - Inflating compressed data\n");
    printf("  - Decompression complete!\n");
}

void rar_compress(const char* input_file, const char* output_file) {
    printf("Compressing '%s' to '%s.rar' using RAR algorithm\n", input_file, output_file);
    printf("  - Using proprietary compression method\n");
    printf("  - Creating volume headers\n");
    printf("  - Compression complete!\n");
}

void rar_decompress(const char* input_file, const char* output_file) {
    printf("Decompressing '%s.rar' to '%s' using RAR algorithm\n", input_file, output_file);
    printf("  - Reading volume headers\n");
    printf("  - Reconstructing original data\n");
    printf("  - Decompression complete!\n");
}

void gzip_compress(const char* input_file, const char* output_file) {
    printf("Compressing '%s' to '%s.gz' using GZIP algorithm\n", input_file, output_file);
    printf("  - Using LZ77 and Huffman coding\n");
    printf("  - Adding gzip header and footer\n");
    printf("  - Compression complete!\n");
}

void gzip_decompress(const char* input_file, const char* output_file) {
    printf("Decompressing '%s.gz' to '%s' using GZIP algorithm\n", input_file, output_file);
    printf("  - Reading gzip header\n");
    printf("  - Inflating compressed data\n");
    printf("  - Decompression complete!\n");
}

void bzip2_compress(const char* input_file, const char* output_file) {
    printf("Compressing '%s' to '%s.bz2' using BZIP2 algorithm\n", input_file, output_file);
    printf("  - Using Burrows-Wheeler transform\n");
    printf("  - Applying Huffman coding\n");
    printf("  - Compression complete!\n");
}

void bzip2_decompress(const char* input_file, const char* output_file) {
    printf("Decompressing '%s.bz2' to '%s' using BZIP2 algorithm\n", input_file, output_file);
    printf("  - Reverse Burrows-Wheeler transform\n");
    printf("  - Decoding Huffman codes\n");
    printf("  - Decompression complete!\n");
}

// Strategy instances
CompressionStrategy zip_strategy = {
    zip_compress,
    zip_decompress,
    "ZIP",
    ".zip"
};

CompressionStrategy rar_strategy = {
    rar_compress,
    rar_decompress,
    "RAR",
    ".rar"
};

CompressionStrategy gzip_strategy = {
    gzip_compress,
    gzip_decompress,
    "GZIP",
    ".gz"
};

CompressionStrategy bzip2_strategy = {
    bzip2_compress,
    bzip2_decompress,
    "BZIP2",
    ".bz2"
};

// Context
typedef struct {
    CompressionStrategy* strategy;
    char current_file[100];
    double compression_ratio;
} FileCompressor;

void compressor_init(FileCompressor* compressor) {
    compressor->strategy = NULL;
    compressor->current_file[0] = '\0';
    compressor->compression_ratio = 0.0;
}

void compressor_set_strategy(FileCompressor* compressor, CompressionStrategy* strategy) {
    compressor->strategy = strategy;
    printf("Compression strategy set to: %s\n", strategy->name);
}

void compressor_set_file(FileCompressor* compressor, const char* filename) {
    strcpy(compressor->current_file, filename);
    printf("Current file: %s\n", filename);
}

void compressor_compress(FileCompressor* compressor, const char* output_file) {
    if (!compressor->strategy) {
        printf("Error: No compression strategy selected!\n");
        return;
    }
    
    if (strlen(compressor->current_file) == 0) {
        printf("Error: No file selected!\n");
        return;
    }
    
    printf("\n=== Starting Compression ===\n");
    compressor->strategy->compress(compressor->current_file, output_file);
    
    // Simulate compression ratio calculation
    compressor->compression_ratio = 0.3 + ((double)rand() / RAND_MAX) * 0.5; // 30-80% ratio
    printf("Compression ratio: %.1f%%\n", compressor->compression_ratio * 100);
}

void compressor_decompress(FileCompressor* compressor, const char* output_file) {
    if (!compressor->strategy) {
        printf("Error: No compression strategy selected!\n");
        return;
    }
    
    printf("\n=== Starting Decompression ===\n");
    compressor->strategy->decompress(compressor->current_file, output_file);
}

void compressor_show_info(const FileCompressor* compressor) {
    printf("\n=== Compressor Information ===\n");
    if (compressor->strategy) {
        printf("Current strategy: %s\n", compressor->strategy->name);
        printf("File extension: %s\n", compressor->strategy->extension);
    } else {
        printf("Current strategy: None\n");
    }
    
    if (strlen(compressor->current_file) > 0) {
        printf("Current file: %s\n", compressor->current_file);
    } else {
        printf("Current file: None\n");
    }
    
    if (compressor->compression_ratio > 0) {
        printf("Last compression ratio: %.1f%%\n", compressor->compression_ratio * 100);
    }
}

// Demo function
void compressionDemo() {
    printf("=== Strategy Pattern - File Compression ===\n\n");
    
    FileCompressor compressor;
    compressor_init(&compressor);
    
    // Available strategies
    CompressionStrategy* strategies[] = {
        &zip_strategy,
        &rar_strategy,
        &gzip_strategy,
        &bzip2_strategy
    };
    int num_strategies = sizeof(strategies) / sizeof(strategies[0]);
    
    // Set a file to compress
    compressor_set_file(&compressor, "document.txt");
    
    // Demonstrate different compression strategies
    for (int i = 0; i < num_strategies; i++) {
        printf("\n--- Testing %s Compression ---\n", strategies[i]->name);
        compressor_set_strategy(&compressor, strategies[i]);
        compressor_compress(&compressor, "compressed_document");
        
        // Simulate decompression
        compressor_decompress(&compressor, "decompressed_document.txt");
    }
    
    // Show final information
    compressor_show_info(&compressor);
    
    // Benchmark different strategies
    printf("\n=== Compression Benchmark ===\n");
    const char* test_files[] = {"text_file.txt", "image.png", "database.db"};
    int num_files = sizeof(test_files) / sizeof(test_files[0]);
    
    for (int i = 0; i < num_strategies; i++) {
        printf("\n%s Performance:\n", strategies[i]->name);
        for (int j = 0; j < num_files; j++) {
            compressor_set_strategy(&compressor, strategies[i]);
            compressor_set_file(&compressor, test_files[j]);
            
            // Simulate different performance characteristics
            double speed = 0.5 + ((double)rand() / RAND_MAX) * 2.0; // 0.5-2.5 MB/s
            double ratio = 0.2 + ((double)rand() / RAND_MAX) * 0.6; // 20-80% ratio
            
            printf("  %s: Speed=%.1f MB/s, Ratio=%.1f%%\n", 
                   test_files[j], speed, ratio * 100);
        }
    }
}

int main() {
    srand((unsigned int)time(NULL)); // Seed for random numbers
    compressionDemo();
    return 0;
}
```

### Python Implementation

#### Navigation Strategy Example

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Tuple
from enum import Enum
import math
import time

class TransportMode(Enum):
    DRIVING = "driving"
    WALKING = "walking"
    BICYCLING = "bicycling"
    PUBLIC_TRANSIT = "public_transit"

# Strategy Interface
class RouteStrategy(ABC):
    @abstractmethod
    def calculate_route(self, start: Tuple[float, float], end: Tuple[float, float]) -> Dict: ...
    
    @abstractmethod
    def get_eta(self, distance: float) -> float: ...
    
    @abstractmethod
    def get_cost(self, distance: float) -> float: ...
    
    @abstractmethod
    def get_mode(self) -> TransportMode: ...

# Concrete Strategies
class DrivingStrategy(RouteStrategy):
    def calculate_route(self, start: Tuple[float, float], end: Tuple[float, float]) -> Dict:
        distance = self._calculate_distance(start, end)
        eta = self.get_eta(distance)
        
        return {
            "mode": self.get_mode(),
            "distance_km": distance,
            "eta_minutes": eta,
            "cost": self.get_cost(distance),
            "route_type": "fastest",
            "toll_roads": True,
            "highways": True
        }
    
    def get_eta(self, distance: float) -> float:
        # Assume average speed of 60 km/h in cities
        average_speed = 60
        return (distance / average_speed) * 60  # Convert to minutes
    
    def get_cost(self, distance: float) -> float:
        # Cost per km: fuel + maintenance
        cost_per_km = 0.15
        return distance * cost_per_km
    
    def get_mode(self) -> TransportMode:
        return TransportMode.DRIVING
    
    def _calculate_distance(self, start: Tuple[float, float], end: Tuple[float, float]) -> float:
        # Simplified distance calculation (Haversine would be used in real implementation)
        lat1, lon1 = start
        lat2, lon2 = end
        return math.sqrt((lat2 - lat1)**2 + (lon2 - lon1)**2) * 111  # Approx km

class WalkingStrategy(RouteStrategy):
    def calculate_route(self, start: Tuple[float, float], end: Tuple[float, float]) -> Dict:
        distance = self._calculate_distance(start, end)
        eta = self.get_eta(distance)
        
        return {
            "mode": self.get_mode(),
            "distance_km": distance,
            "eta_minutes": eta,
            "cost": self.get_cost(distance),
            "route_type": "pedestrian",
            "sidewalks": True,
            "crosswalks": True
        }
    
    def get_eta(self, distance: float) -> float:
        # Assume walking speed of 5 km/h
        walking_speed = 5
        return (distance / walking_speed) * 60  # Convert to minutes
    
    def get_cost(self, distance: float) -> float:
        return 0.0  # Walking is free!
    
    def get_mode(self) -> TransportMode:
        return TransportMode.WALKING
    
    def _calculate_distance(self, start: Tuple[float, float], end: Tuple[float, float]) -> float:
        lat1, lon1 = start
        lat2, lon2 = end
        return math.sqrt((lat2 - lat1)**2 + (lon2 - lon1)**2) * 111

class BicyclingStrategy(RouteStrategy):
    def calculate_route(self, start: Tuple[float, float], end: Tuple[float, float]) -> Dict:
        distance = self._calculate_distance(start, end)
        eta = self.get_eta(distance)
        
        return {
            "mode": self.get_mode(),
            "distance_km": distance,
            "eta_minutes": eta,
            "cost": self.get_cost(distance),
            "route_type": "bike_friendly",
            "bike_lanes": True,
            "elevation_gain": 50  # meters
        }
    
    def get_eta(self, distance: float) -> float:
        # Assume cycling speed of 15 km/h
        cycling_speed = 15
        return (distance / cycling_speed) * 60
    
    def get_cost(self, distance: float) -> float:
        # Minimal maintenance cost
        return distance * 0.02
    
    def get_mode(self) -> TransportMode:
        return TransportMode.BICYCLING
    
    def _calculate_distance(self, start: Tuple[float, float], end: Tuple[float, float]) -> float:
        lat1, lon1 = start
        lat2, lon2 = end
        return math.sqrt((lat2 - lat1)**2 + (lon2 - lon1)**2) * 111

class PublicTransitStrategy(RouteStrategy):
    def calculate_route(self, start: Tuple[float, float], end: Tuple[float, float]) -> Dict:
        distance = self._calculate_distance(start, end)
        eta = self.get_eta(distance)
        
        return {
            "mode": self.get_mode(),
            "distance_km": distance,
            "eta_minutes": eta,
            "cost": self.get_cost(distance),
            "route_type": "combined",
            "transfers": 1,
            "wait_time": 5,  # minutes
            "modes": ["bus", "metro"]
        }
    
    def get_eta(self, distance: float) -> float:
        # Public transit is slower due to stops and transfers
        base_time = (distance / 25) * 60  # 25 km/h average
        wait_time = 5  # Average wait time
        transfer_time = 3  # Time per transfer
        return base_time + wait_time + transfer_time
    
    def get_cost(self, distance: float) -> float:
        # Fixed fare plus distance-based component
        base_fare = 2.50
        distance_fare = max(0, (distance - 5)) * 0.20  # Free for first 5km
        return base_fare + distance_fare
    
    def get_mode(self) -> TransportMode:
        return TransportMode.PUBLIC_TRANSIT
    
    def _calculate_distance(self, start: Tuple[float, float], end: Tuple[float, float]) -> float:
        lat1, lon1 = start
        lat2, lon2 = end
        return math.sqrt((lat2 - lat1)**2 + (lon2 - lon1)**2) * 111

# Context
class NavigationSystem:
    def __init__(self):
        self._strategy: RouteStrategy = None
        self._current_route: Dict = None
        self.trip_history: List[Dict] = []
    
    def set_strategy(self, strategy: RouteStrategy) -> None:
        self._strategy = strategy
        print(f"Navigation mode set to: {strategy.get_mode().value}")
    
    def calculate_route(self, start: Tuple[float, float], end: Tuple[float, float]) -> Dict:
        if not self._strategy:
            raise ValueError("No navigation strategy selected!")
        
        self._current_route = self._strategy.calculate_route(start, end)
        
        # Add to trip history
        trip_record = {
            **self._current_route,
            "timestamp": time.time(),
            "start": start,
            "end": end
        }
        self.trip_history.append(trip_record)
        
        return self._current_route
    
    def display_route(self) -> None:
        if not self._current_route:
            print("No route calculated!")
            return
        
        route = self._current_route
        print(f"\n=== Route Details ===")
        print(f"Mode: {route['mode'].value.upper()}")
        print(f"Distance: {route['distance_km']:.1f} km")
        print(f"ETA: {route['eta_minutes']:.1f} minutes")
        print(f"Cost: ${route['cost']:.2f}")
        
        # Mode-specific details
        if route['mode'] == TransportMode.DRIVING:
            print(f"Route type: {route['route_type']}")
            print(f"Toll roads: {'Yes' if route['toll_roads'] else 'No'}")
        elif route['mode'] == TransportMode.WALKING:
            print(f"Pedestrian friendly: Yes")
        elif route['mode'] == TransportMode.BICYCLING:
            print(f"Bike lanes: {'Yes' if route['bike_lanes'] else 'No'}")
            print(f"Elevation gain: {route['elevation_gain']}m")
        elif route['mode'] == TransportMode.PUBLIC_TRANSIT:
            print(f"Transfers: {route['transfers']}")
            print(f"Wait time: {route['wait_time']} minutes")
    
    def compare_all_modes(self, start: Tuple[float, float], end: Tuple[float, float]) -> None:
        strategies = [
            DrivingStrategy(),
            WalkingStrategy(),
            BicyclingStrategy(),
            PublicTransitStrategy()
        ]
        
        print(f"\n=== Route Comparison ===")
        print(f"From: {start} To: {end}")
        print("\nMode           Distance  ETA      Cost     ")
        print("-" * 45)
        
        for strategy in strategies:
            route = strategy.calculate_route(start, end)
            print(f"{route['mode'].value:12} {route['distance_km']:8.1f} {route['eta_minutes']:8.1f} ${route['cost']:6.2f}")
    
    def show_trip_history(self) -> None:
        print(f"\n=== Trip History ===")
        for i, trip in enumerate(self.trip_history[-5:], 1):  # Last 5 trips
            print(f"{i}. {trip['mode'].value}: {trip['distance_km']:.1f}km, {trip['eta_minutes']:.1f}min, ${trip['cost']:.2f}")

# Demo function
def navigation_demo():
    print("=== Strategy Pattern - Navigation System ===\n")
    
    nav_system = NavigationSystem()
    
    # Define some locations (latitude, longitude)
    locations = {
        "home": (40.7128, -74.0060),  # New York
        "work": (40.7589, -73.9851),   # Times Square
        "park": (40.7829, -73.9654),   # Central Park
        "airport": (40.6413, -73.7781) # JFK Airport
    }
    
    # Test different navigation strategies
    print("--- Driving from Home to Work ---")
    nav_system.set_strategy(DrivingStrategy())
    route1 = nav_system.calculate_route(locations["home"], locations["work"])
    nav_system.display_route()
    
    print("\n--- Walking from Work to Park ---")
    nav_system.set_strategy(WalkingStrategy())
    route2 = nav_system.calculate_route(locations["work"], locations["park"])
    nav_system.display_route()
    
    print("\n--- Bicycling from Park to Home ---")
    nav_system.set_strategy(BicyclingStrategy())
    route3 = nav_system.calculate_route(locations["park"], locations["home"])
    nav_system.display_route()
    
    print("\n--- Public Transit from Home to Airport ---")
    nav_system.set_strategy(PublicTransitStrategy())
    route4 = nav_system.calculate_route(locations["home"], locations["airport"])
    nav_system.display_route()
    
    # Compare all modes for one route
    nav_system.compare_all_modes(locations["home"], locations["airport"])
    
    # Show trip history
    nav_system.show_trip_history()
    
    # Demonstrate strategy switching at runtime
    print("\n=== Dynamic Strategy Switching ===")
    current_location = locations["home"]
    destination = locations["airport"]
    
    # Start with driving
    nav_system.set_strategy(DrivingStrategy())
    route = nav_system.calculate_route(current_location, destination)
    print(f"Started with driving: {route['eta_minutes']:.1f} minutes")
    
    # Switch to public transit if there's traffic
    print("Heavy traffic detected! Switching to public transit...")
    nav_system.set_strategy(PublicTransitStrategy())
    route = nav_system.calculate_route(current_location, destination)
    print(f"Public transit: {route['eta_minutes']:.1f} minutes")

if __name__ == "__main__":
    navigation_demo()
```

#### Discount Strategy Example

```python
from abc import ABC, abstractmethod
from typing import List, Dict
from datetime import datetime, timedelta
from enum import Enum

class DiscountType(Enum):
    PERCENTAGE = "percentage"
    FIXED_AMOUNT = "fixed_amount"
    BUY_X_GET_Y = "buy_x_get_y"
    SEASONAL = "seasonal"
    MEMBERSHIP = "membership"

# Strategy Interface
class DiscountStrategy(ABC):
    @abstractmethod
    def calculate_discount(self, original_price: float, quantity: int = 1) -> float: ...
    
    @abstractmethod
    def get_discount_type(self) -> DiscountType: ...
    
    @abstractmethod
    def is_eligible(self, customer_tier: str = "standard") -> bool: ...
    
    def get_description(self) -> str:
        return f"{self.get_discount_type().value.replace('_', ' ').title()} Discount"

# Concrete Strategies
class PercentageDiscountStrategy(DiscountStrategy):
    def __init__(self, percentage: float, min_purchase: float = 0):
        self.percentage = percentage
        self.min_purchase = min_purchase
    
    def calculate_discount(self, original_price: float, quantity: int = 1) -> float:
        total_price = original_price * quantity
        if total_price < self.min_purchase:
            return 0.0
        
        discount = total_price * (self.percentage / 100)
        return min(discount, total_price)  # Ensure discount doesn't exceed total
    
    def get_discount_type(self) -> DiscountType:
        return DiscountType.PERCENTAGE
    
    def is_eligible(self, customer_tier: str = "standard") -> bool:
        return True  # Percentage discounts are available to all
    
    def get_description(self) -> str:
        return f"{self.percentage}% Off"

class FixedAmountDiscountStrategy(DiscountStrategy):
    def __init__(self, amount: float, min_purchase: float = 0):
        self.amount = amount
        self.min_purchase = min_purchase
    
    def calculate_discount(self, original_price: float, quantity: int = 1) -> float:
        total_price = original_price * quantity
        if total_price < self.min_purchase:
            return 0.0
        
        return min(self.amount, total_price)
    
    def get_discount_type(self) -> DiscountType:
        return DiscountType.FIXED_AMOUNT
    
    def is_eligible(self, customer_tier: str = "standard") -> bool:
        return True
    
    def get_description(self) -> str:
        return f"${self.amount} Off"

class BuyXGetYDiscountStrategy(DiscountStrategy):
    def __init__(self, buy_quantity: int, get_quantity: int, discount_percent: float = 100):
        self.buy_quantity = buy_quantity
        self.get_quantity = get_quantity
        self.discount_percent = discount_percent
    
    def calculate_discount(self, original_price: float, quantity: int = 1) -> float:
        if quantity < self.buy_quantity + 1:
            return 0.0
        
        # Calculate how many free/discounted items customer gets
        sets = quantity // (self.buy_quantity + self.get_quantity)
        free_items = sets * self.get_quantity
        
        # If not full sets, check for partial eligibility
        remaining = quantity % (self.buy_quantity + self.get_quantity)
        if remaining > self.buy_quantity:
            free_items += (remaining - self.buy_quantity)
        
        discount = free_items * original_price * (self.discount_percent / 100)
        return discount
    
    def get_discount_type(self) -> DiscountType:
        return DiscountType.BUY_X_GET_Y
    
    def is_eligible(self, customer_tier: str = "standard") -> bool:
        return True
    
    def get_description(self) -> str:
        return f"Buy {self.buy_quantity} Get {self.get_quantity} {self.discount_percent}% Off"

class SeasonalDiscountStrategy(DiscountStrategy):
    def __init__(self, season: str, discount_percent: float):
        self.season = season
        self.discount_percent = discount_percent
        self._set_season_dates()
    
    def _set_season_dates(self):
        self.season_dates = {
            "winter": (datetime(datetime.now().year, 12, 1), datetime(datetime.now().year, 2, 28)),
            "spring": (datetime(datetime.now().year, 3, 1), datetime(datetime.now().year, 5, 31)),
            "summer": (datetime(datetime.now().year, 6, 1), datetime(datetime.now().year, 8, 31)),
            "fall": (datetime(datetime.now().year, 9, 1), datetime(datetime.now().year, 11, 30))
        }
    
    def calculate_discount(self, original_price: float, quantity: int = 1) -> float:
        if not self._is_season_active():
            return 0.0
        
        total_price = original_price * quantity
        return total_price * (self.discount_percent / 100)
    
    def get_discount_type(self) -> DiscountType:
        return DiscountType.SEASONAL
    
    def is_eligible(self, customer_tier: str = "standard") -> bool:
        return self._is_season_active()
    
    def _is_season_active(self) -> bool:
        current_date = datetime.now()
        season_range = self.season_dates.get(self.season.lower())
        
        if not season_range:
            return False
        
        start, end = season_range
        # Handle winter spanning year end
        if start.month > end.month:
            return current_date >= start or current_date <= end
        else:
            return start <= current_date <= end
    
    def get_description(self) -> str:
        return f"{self.season.title()} Sale - {self.discount_percent}% Off"

class MembershipDiscountStrategy(DiscountStrategy):
    def __init__(self):
        self.tier_discounts = {
            "standard": 0.05,    # 5%
            "premium": 0.15,     # 15%
            "vip": 0.25,         # 25%
            "employee": 0.30     # 30%
        }
    
    def calculate_discount(self, original_price: float, quantity: int = 1, customer_tier: str = "standard") -> float:
        discount_rate = self.tier_discounts.get(customer_tier, 0.0)
        total_price = original_price * quantity
        return total_price * discount_rate
    
    def get_discount_type(self) -> DiscountType:
        return DiscountType.MEMBERSHIP
    
    def is_eligible(self, customer_tier: str = "standard") -> bool:
        return customer_tier in self.tier_discounts
    
    def get_description(self) -> str:
        return "Membership Discount"

# Context
class ShoppingCart:
    def __init__(self):
        self.items: List[Dict] = []
        self.discount_strategy: DiscountStrategy = None
        self.customer_tier: str = "standard"
    
    def add_item(self, name: str, price: float, quantity: int = 1) -> None:
        self.items.append({
            "name": name,
            "price": price,
            "quantity": quantity
        })
        print(f"Added {quantity} x {name} (${price:.2f} each)")
    
    def set_discount_strategy(self, strategy: DiscountStrategy) -> None:
        if strategy.is_eligible(self.customer_tier):
            self.discount_strategy = strategy
            print(f"Discount applied: {strategy.get_description()}")
        else:
            print("Customer not eligible for this discount")
    
    def set_customer_tier(self, tier: str) -> None:
        self.customer_tier = tier
        print(f"Customer tier set to: {tier}")
    
    def calculate_total(self) -> Dict[str, float]:
        subtotal = sum(item["price"] * item["quantity"] for item in self.items)
        
        discount = 0.0
        if self.discount_strategy:
            # Calculate discount for each item and sum them up
            for item in self.items:
                item_discount = self.discount_strategy.calculate_discount(
                    item["price"], item["quantity"], self.customer_tier
                )
                discount += item_discount
        
        total = max(0, subtotal - discount)
        
        return {
            "subtotal": subtotal,
            "discount": discount,
            "total": total,
            "items_count": len(self.items)
        }
    
    def display_receipt(self) -> None:
        totals = self.calculate_total()
        
        print("\n" + "=" * 50)
        print("                  RECEIPT")
        print("=" * 50)
        
        for item in self.items:
            print(f"{item['quantity']} x {item['name']:20} ${item['price'] * item['quantity']:7.2f}")
        
        print("-" * 50)
        print(f"Subtotal:                  ${totals['subtotal']:7.2f}")
        
        if totals['discount'] > 0:
            discount_desc = self.discount_strategy.get_description() if self.discount_strategy else "Discount"
            print(f"Discount ({discount_desc}):   -${totals['discount']:7.2f}")
        
        print(f"TOTAL:                    ${totals['total']:7.2f}")
        print("=" * 50)
    
    def clear_cart(self) -> None:
        self.items.clear()
        self.discount_strategy = None
        print("Cart cleared")

# Demo function
def ecommerce_demo():
    print("=== Strategy Pattern - E-commerce Discount System ===\n")
    
    cart = ShoppingCart()
    
    # Add items to cart
    cart.add_item("Laptop", 999.99, 1)
    cart.add_item("Mouse", 29.99, 2)
    cart.add_item("Keyboard", 79.99, 1)
    cart.add_item("Monitor", 199.99, 1)
    
    # Test different discount strategies
    print("\n--- Testing Percentage Discount (20% off) ---")
    cart.set_discount_strategy(PercentageDiscountStrategy(20, min_purchase=100))
    cart.display_receipt()
    
    print("\n--- Testing Fixed Amount Discount ($50 off) ---")
    cart.set_discount_strategy(FixedAmountDiscountStrategy(50, min_purchase=200))
    cart.display_receipt()
    
    print("\n--- Testing Buy X Get Y Discount (Buy 2 Get 1 Free) ---")
    # Add more items for this test
    cart.clear_cart()
    cart.add_item("USB Cable", 9.99, 5)  # Should get 1 free
    cart.set_discount_strategy(BuyXGetYDiscountStrategy(2, 1, 100))
    cart.display_receipt()
    
    print("\n--- Testing Seasonal Discount (Summer Sale) ---")
    cart.clear_cart()
    cart.add_item("Sunglasses", 49.99, 2)
    cart.add_item("Beach Towel", 24.99, 1)
    cart.set_discount_strategy(SeasonalDiscountStrategy("summer", 15))
    cart.display_receipt()
    
    print("\n--- Testing Membership Discount ---")
    cart.clear_cart()
    cart.add_item("Premium Headphones", 299.99, 1)
    cart.add_item("Carrying Case", 19.99, 1)
    
    # Test different customer tiers
    tiers = ["standard", "premium", "vip", "employee"]
    for tier in tiers:
        print(f"\n--- {tier.upper()} Customer ---")
        cart.set_customer_tier(tier)
        cart.set_discount_strategy(MembershipDiscountStrategy())
        cart.display_receipt()
    
    # Compare all discount strategies
    print("\n=== Discount Strategy Comparison ===")
    cart.clear_cart()
    cart.add_item("Test Product", 100.00, 3)
    
    strategies = [
        ("No Discount", None),
        ("20% Off", PercentageDiscountStrategy(20)),
        ("$25 Off", FixedAmountDiscountStrategy(25)),
        ("Buy 2 Get 1", BuyXGetYDiscountStrategy(2, 1)),
        ("Summer Sale", SeasonalDiscountStrategy("summer", 15)),
        ("Premium Member", MembershipDiscountStrategy())
    ]
    
    cart.set_customer_tier("premium")
    
    print(f"\n{'Strategy':<20} {'Subtotal':<10} {'Discount':<10} {'Total':<10}")
    print("-" * 50)
    
    for strategy_name, strategy in strategies:
        if strategy:
            cart.set_discount_strategy(strategy)
        else:
            cart.discount_strategy = None
        
        totals = cart.calculate_total()
        print(f"{strategy_name:<20} ${totals['subtotal']:<9.2f} ${totals['discount']:<9.2f} ${totals['total']:<9.2f}")

if __name__ == "__main__":
    ecommerce_demo()
```

## Advantages and Disadvantages

### Advantages

- **Eliminates Conditional Statements**: Replaces complex conditionals with strategy objects
- **Open/Closed Principle**: New strategies can be added without modifying existing code
- **Runtime Flexibility**: Algorithms can be swapped at runtime
- **Clean Separation**: Each algorithm is encapsulated in its own class
- **Testability**: Each strategy can be tested independently

### Disadvantages

- **Increased Number of Classes**: Can lead to many small strategy classes
- **Client Awareness**: Clients must understand different strategies to choose appropriately
- **Overhead**: May introduce unnecessary complexity for simple algorithms
- **Communication Overhead**: Strategies may need to share data through context

## Best Practices

1. **Use for Algorithm Families**: When you have multiple related algorithms that differ in behavior
2. **Keep Strategies Stateless**: Prefer stateless strategies to avoid side effects
3. **Consider Strategy Composition**: Combine multiple strategies for complex behaviors
4. **Use Factory Methods**: Create strategies using factory methods for complex initialization
5. **Document Strategy Differences**: Clearly document when to use each strategy

## Strategy vs Other Patterns

- **vs State**: Strategy changes behavior, State changes behavior based on internal state
- **vs Template Method**: Strategy uses composition, Template Method uses inheritance
- **vs Command**: Strategy focuses on algorithms, Command focuses on actions and undo
- **vs Bridge**: Strategy behavioral, Bridge structural

The Strategy pattern is widely used in real-world applications including payment processing, sorting algorithms, compression tools, navigation systems, and discount calculation systems. It provides excellent flexibility and maintainability when you need to support multiple variations of an algorithm.
