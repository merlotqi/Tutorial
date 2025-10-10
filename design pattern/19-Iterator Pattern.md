# Iterator Pattern

## Introduction

The Iterator Pattern is a behavioral design pattern that provides a way to access the elements of an aggregate object sequentially without exposing its underlying representation. It decouples the traversal algorithms from the aggregate objects.

### Key Characteristics

- **Sequential Access**: Provides uniform way to traverse different collections
- **Encapsulation**: Hides the internal structure of the collection
- **Multiple Iteration**: Supports multiple simultaneous traversals
- **Polymorphic Iteration**: Enables polymorphic iteration over different collections

### Use Cases

- Collections and data structures
- Database query results
- File system traversal
- Tree and graph traversal
- Paginated API responses
- Stream processing

## Implementation Examples

### C++ Implementation

#### Custom Collection Framework

```cpp
#include <iostream>
#include <memory>
#include <vector>
#include <list>
#include <stdexcept>
#include <algorithm>

// Iterator Interface
template<typename T>
class Iterator {
public:
    virtual ~Iterator() = default;
    virtual bool has_next() const = 0;
    virtual T next() = 0;
    virtual void reset() = 0;
};

// Aggregate Interface
template<typename T>
class Iterable {
public:
    virtual ~Iterable() = default;
    virtual std::unique_ptr<Iterator<T>> create_iterator() = 0;
    virtual size_t size() const = 0;
};

// Concrete Iterator for Vector
template<typename T>
class VectorIterator : public Iterator<T> {
private:
    const std::vector<T>& collection;
    size_t current_index;

public:
    VectorIterator(const std::vector<T>& coll) 
        : collection(coll), current_index(0) {}

    bool has_next() const override {
        return current_index < collection.size();
    }

    T next() override {
        if (!has_next()) {
            throw std::out_of_range("No more elements");
        }
        return collection[current_index++];
    }

    void reset() override {
        current_index = 0;
    }
};

// Concrete Iterator for List with filtering capability
template<typename T, typename Predicate>
class FilteredListIterator : public Iterator<T> {
private:
    const std::list<T>& collection;
    typename std::list<T>::const_iterator current;
    Predicate predicate;

public:
    FilteredListIterator(const std::list<T>& coll, Predicate pred = Predicate{})
        : collection(coll), current(collection.begin()), predicate(pred) {
        advance_to_valid();
    }

    bool has_next() const override {
        return current != collection.end();
    }

    T next() override {
        if (!has_next()) {
            throw std::out_of_range("No more elements");
        }
        T value = *current;
        ++current;
        advance_to_valid();
        return value;
    }

    void reset() override {
        current = collection.begin();
        advance_to_valid();
    }

private:
    void advance_to_valid() {
        while (current != collection.end() && !predicate(*current)) {
            ++current;
        }
    }
};

// Custom Array Collection
template<typename T, size_t N>
class FixedArray : public Iterable<T> {
private:
    T data[N];
    size_t count;

public:
    FixedArray() : count(0) {}

    void add(const T& item) {
        if (count < N) {
            data[count++] = item;
        } else {
            throw std::out_of_range("Array is full");
        }
    }

    T& operator[](size_t index) {
        if (index >= count) {
            throw std::out_of_range("Index out of bounds");
        }
        return data[index];
    }

    const T& operator[](size_t index) const {
        if (index >= count) {
            throw std::out_of_range("Index out of bounds");
        }
        return data[index];
    }

    size_t size() const override {
        return count;
    }

    std::unique_ptr<Iterator<T>> create_iterator() override {
        return std::make_unique<VectorIterator<T>>(std::vector<T>(data, data + count));
    }
};

// Binary Search Tree with Iterator
template<typename T>
class BSTIterator : public Iterator<T> {
private:
    struct Node {
        T data;
        std::unique_ptr<Node> left;
        std::unique_ptr<Node> right;
        Node(const T& value) : data(value) {}
    };

    const std::unique_ptr<Node>& root;
    std::vector<Node*> stack;

    void push_left(Node* node) {
        while (node) {
            stack.push_back(node);
            node = node->left.get();
        }
    }

public:
    BSTIterator(const std::unique_ptr<Node>& root_node) : root(root_node) {
        reset();
    }

    bool has_next() const override {
        return !stack.empty();
    }

    T next() override {
        if (!has_next()) {
            throw std::out_of_range("No more elements");
        }
        
        Node* current = stack.back();
        stack.pop_back();
        
        if (current->right) {
            push_left(current->right.get());
        }
        
        return current->data;
    }

    void reset() override {
        stack.clear();
        if (root) {
            push_left(root.get());
        }
    }
};

template<typename T>
class BinarySearchTree : public Iterable<T> {
private:
    struct Node {
        T data;
        std::unique_ptr<Node> left;
        std::unique_ptr<Node> right;
        Node(const T& value) : data(value) {}
    };

    std::unique_ptr<Node> root;
    size_t element_count;

    void insert(std::unique_ptr<Node>& node, const T& value) {
        if (!node) {
            node = std::make_unique<Node>(value);
            element_count++;
        } else if (value < node->data) {
            insert(node->left, value);
        } else if (value > node->data) {
            insert(node->right, value);
        }
    }

public:
    BinarySearchTree() : element_count(0) {}

    void insert(const T& value) {
        insert(root, value);
    }

    size_t size() const override {
        return element_count;
    }

    std::unique_ptr<Iterator<T>> create_iterator() override {
        return std::make_unique<BSTIterator<T>>(root);
    }
};

// Range Iterator for numeric sequences
class RangeIterator : public Iterator<int> {
private:
    int current;
    int end;
    int step;

public:
    RangeIterator(int start, int end_val, int step_size = 1)
        : current(start), end(end_val), step(step_size) {}

    bool has_next() const override {
        return step > 0 ? current < end : current > end;
    }

    int next() override {
        if (!has_next()) {
            throw std::out_of_range("No more elements");
        }
        int value = current;
        current += step;
        return value;
    }

    void reset() override {
        // Cannot reset without storing original start
        throw std::runtime_error("RangeIterator does not support reset");
    }
};

// Demo function
void collectionFrameworkDemo() {
    std::cout << "=== Iterator Pattern - Custom Collection Framework ===\n" << std::endl;

    // Test FixedArray
    std::cout << "--- FixedArray Iteration ---" << std::endl;
    FixedArray<int, 5> array;
    array.add(10);
    array.add(20);
    array.add(30);
    array.add(40);
    array.add(50);

    auto array_iter = array.create_iterator();
    while (array_iter->has_next()) {
        std::cout << array_iter->next() << " ";
    }
    std::cout << std::endl;

    // Test Binary Search Tree
    std::cout << "\n--- Binary Search Tree Iteration ---" << std::endl;
    BinarySearchTree<int> bst;
    bst.insert(50);
    bst.insert(30);
    bst.insert(70);
    bst.insert(20);
    bst.insert(40);
    bst.insert(60);
    bst.insert(80);

    auto bst_iter = bst.create_iterator();
    while (bst_iter->has_next()) {
        std::cout << bst_iter->next() << " ";
    }
    std::cout << std::endl;

    // Test List with Filtered Iterator
    std::cout << "\n--- Filtered List Iteration ---" << std::endl;
    std::list<int> numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Even numbers only
    auto is_even = [](int n) { return n % 2 == 0; };
    auto filtered_iter = std::make_unique<FilteredListIterator<int, decltype(is_even)>>(numbers, is_even);
    
    while (filtered_iter->has_next()) {
        std::cout << filtered_iter->next() << " ";
    }
    std::cout << std::endl;

    // Test Range Iterator
    std::cout << "\n--- Range Iterator ---" << std::endl;
    RangeIterator range_iter(1, 10, 2);
    while (range_iter.has_next()) {
        std::cout << range_iter.next() << " ";
    }
    std::cout << std::endl;

    // Polymorphic iteration
    std::cout << "\n--- Polymorphic Iteration ---" << std::endl;
    std::vector<std::unique_ptr<Iterable<int>>> collections;
    
    auto array_ptr = std::make_unique<FixedArray<int, 5>>();
    array_ptr->add(100);
    array_ptr->add(200);
    array_ptr->add(300);
    collections.push_back(std::move(array_ptr));
    
    auto bst_ptr = std::make_unique<BinarySearchTree<int>>();
    bst_ptr->insert(150);
    bst_ptr->insert(250);
    bst_ptr->insert(350);
    collections.push_back(std::move(bst_ptr));
    
    for (const auto& collection : collections) {
        auto iter = collection->create_iterator();
        std::cout << "Collection (size: " << collection->size() << "): ";
        while (iter->has_next()) {
            std::cout << iter->next() << " ";
        }
        std::cout << std::endl;
    }
}

int main() {
    collectionFrameworkDemo();
    return 0;
}
```

#### File System Traversal

```cpp
#include <iostream>
#include <memory>
#include <vector>
#include <string>
#include <stack>
#include <queue>
#include <algorithm>
#include <memory>

// File System Entity Base Class
class FileSystemEntity {
public:
    virtual ~FileSystemEntity() = default;
    virtual const std::string& get_name() const = 0;
    virtual void print(int indent = 0) const = 0;
};

// File Class
class File : public FileSystemEntity {
private:
    std::string name;
    size_t size;
    std::string extension;

public:
    File(const std::string& file_name, size_t file_size = 0)
        : name(file_name), size(file_size) {
        size_t dot_pos = name.find_last_of('.');
        extension = (dot_pos != std::string::npos) ? name.substr(dot_pos + 1) : "";
    }

    const std::string& get_name() const override {
        return name;
    }

    size_t get_size() const {
        return size;
    }

    const std::string& get_extension() const {
        return extension;
    }

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') 
                  << "📄 " << name << " (" << size << " bytes)" << std::endl;
    }
};

// Directory Class
class Directory : public FileSystemEntity {
private:
    std::string name;
    std::vector<std::shared_ptr<FileSystemEntity>> children;

public:
    Directory(const std::string& dir_name) : name(dir_name) {}

    const std::string& get_name() const override {
        return name;
    }

    void add_child(std::shared_ptr<FileSystemEntity> child) {
        children.push_back(child);
    }

    const std::vector<std::shared_ptr<FileSystemEntity>>& get_children() const {
        return children;
    }

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') 
                  << "📁 " << name << "/" << std::endl;
        for (const auto& child : children) {
            child->print(indent + 2);
        }
    }
};

// File System Iterator Interface
class FileSystemIterator {
public:
    virtual ~FileSystemIterator() = default;
    virtual bool has_next() const = 0;
    virtual std::shared_ptr<FileSystemEntity> next() = 0;
    virtual void reset() = 0;
};

// Depth-First Iterator
class DepthFirstIterator : public FileSystemIterator {
private:
    std::stack<std::shared_ptr<FileSystemEntity>> stack;

public:
    DepthFirstIterator(std::shared_ptr<FileSystemEntity> root) {
        reset();
        if (root) {
            stack.push(root);
        }
    }

    bool has_next() const override {
        return !stack.empty();
    }

    std::shared_ptr<FileSystemEntity> next() override {
        if (!has_next()) {
            return nullptr;
        }

        auto current = stack.top();
        stack.pop();

        // If it's a directory, push its children in reverse order
        if (auto dir = std::dynamic_pointer_cast<Directory>(current)) {
            const auto& children = dir->get_children();
            for (auto it = children.rbegin(); it != children.rend(); ++it) {
                stack.push(*it);
            }
        }

        return current;
    }

    void reset() override {
        while (!stack.empty()) stack.pop();
    }
};

// Breadth-First Iterator
class BreadthFirstIterator : public FileSystemIterator {
private:
    std::queue<std::shared_ptr<FileSystemEntity>> queue;

public:
    BreadthFirstIterator(std::shared_ptr<FileSystemEntity> root) {
        reset();
        if (root) {
            queue.push(root);
        }
    }

    bool has_next() const override {
        return !queue.empty();
    }

    std::shared_ptr<FileSystemEntity> next() override {
        if (!has_next()) {
            return nullptr;
        }

        auto current = queue.front();
        queue.pop();

        // If it's a directory, enqueue its children
        if (auto dir = std::dynamic_pointer_cast<Directory>(current)) {
            for (const auto& child : dir->get_children()) {
                queue.push(child);
            }
        }

        return current;
    }

    void reset() override {
        while (!queue.empty()) queue.pop();
    }
};

// File Type Filter Iterator
class FileTypeFilterIterator : public FileSystemIterator {
private:
    std::unique_ptr<FileSystemIterator> base_iterator;
    std::string target_extension;

public:
    FileTypeFilterIterator(std::unique_ptr<FileSystemIterator> iterator, 
                          const std::string& extension)
        : base_iterator(std::move(iterator)), target_extension(extension) {
        advance_to_valid();
    }

    bool has_next() const override {
        return base_iterator->has_next();
    }

    std::shared_ptr<FileSystemEntity> next() override {
        if (!has_next()) {
            return nullptr;
        }

        auto current = base_iterator->next();
        advance_to_valid();
        return current;
    }

    void reset() override {
        base_iterator->reset();
        advance_to_valid();
    }

private:
    void advance_to_valid() {
        while (base_iterator->has_next()) {
            auto next_entity = base_iterator->next();
            if (auto file = std::dynamic_pointer_cast<File>(next_entity)) {
                if (file->get_extension() == target_extension) {
                    // Put it back and return
                    base_iterator->reset(); // Simplified - in real implementation would need different approach
                    return;
                }
            }
        }
    }
};

// File System with Iterable Interface
class FileSystem : public FileSystemEntity {
private:
    std::shared_ptr<Directory> root;

public:
    FileSystem() {
        root = std::make_shared<Directory>("root");
        
        // Build sample file system
        auto docs = std::make_shared<Directory>("Documents");
        auto pics = std::make_shared<Directory>("Pictures");
        auto music = std::make_shared<Directory>("Music");
        
        docs->add_child(std::make_shared<File>("report.pdf", 1024));
        docs->add_child(std::make_shared<File>("notes.txt", 512));
        docs->add_child(std::make_shared<File>("budget.xlsx", 2048));
        
        pics->add_child(std::make_shared<File>("vacation.jpg", 3072));
        pics->add_child(std::make_shared<File>("family.png", 4096));
        pics->add_child(std::make_shared<File>("screenshot.bmp", 1024));
        
        music->add_child(std::make_shared<File>("song1.mp3", 5120));
        music->add_child(std::make_shared<File>("song2.wav", 10240));
        music->add_child(std::make_shared<File>("playlist.m3u", 256));
        
        auto projects = std::make_shared<Directory>("Projects");
        auto project1 = std::make_shared<Directory>("WebApp");
        project1->add_child(std::make_shared<File>("index.html", 1024));
        project1->add_child(std::make_shared<File>("style.css", 2048));
        project1->add_child(std::make_shared<File>("app.js", 3072));
        projects->add_child(project1);
        
        root->add_child(docs);
        root->add_child(pics);
        root->add_child(music);
        root->add_child(projects);
    }

    const std::string& get_name() const override {
        return root->get_name();
    }

    void print(int indent = 0) const override {
        root->print(indent);
    }

    std::unique_ptr<FileSystemIterator> create_dfs_iterator() {
        return std::make_unique<DepthFirstIterator>(root);
    }

    std::unique_ptr<FileSystemIterator> create_bfs_iterator() {
        return std::make_unique<BreadthFirstIterator>(root);
    }

    std::unique_ptr<FileSystemIterator> create_file_type_iterator(const std::string& extension) {
        auto base_iter = create_dfs_iterator();
        return std::make_unique<FileTypeFilterIterator>(std::move(base_iter), extension);
    }
};

// Demo function
void fileSystemDemo() {
    std::cout << "=== Iterator Pattern - File System Traversal ===\n" << std::endl;

    FileSystem fs;
    
    std::cout << "--- File System Structure ---" << std::endl;
    fs.print();

    std::cout << "\n--- Depth-First Traversal ---" << std::endl;
    auto dfs_iter = fs.create_dfs_iterator();
    while (dfs_iter->has_next()) {
        auto entity = dfs_iter->next();
        entity->print(2);
    }

    std::cout << "\n--- Breadth-First Traversal ---" << std::endl;
    auto bfs_iter = fs.create_bfs_iterator();
    while (bfs_iter->has_next()) {
        auto entity = bfs_iter->next();
        entity->print(2);
    }

    std::cout << "\n--- Filtered Traversal (PDF files only) ---" << std::endl;
    auto pdf_iter = fs.create_file_type_iterator("pdf");
    while (pdf_iter->has_next()) {
        auto entity = pdf_iter->next();
        entity->print(2);
    }

    std::cout << "\n--- Filtered Traversal (Image files) ---" << std::endl;
    auto image_iter = fs.create_file_type_iterator("jpg");
    while (image_iter->has_next()) {
        auto entity = image_iter->next();
        entity->print(2);
    }
    
    auto png_iter = fs.create_file_type_iterator("png");
    while (png_iter->has_next()) {
        auto entity = png_iter->next();
        entity->print(2);
    }
}

int main() {
    fileSystemDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Simple String Collection Iterator
typedef struct {
    char** data;
    int size;
    int current;
} StringIterator;

StringIterator* string_iterator_create(char** strings, int count) {
    StringIterator* iter = malloc(sizeof(StringIterator));
    iter->data = strings;
    iter->size = count;
    iter->current = 0;
    return iter;
}

bool string_iterator_has_next(StringIterator* iter) {
    return iter->current < iter->size;
}

char* string_iterator_next(StringIterator* iter) {
    if (!string_iterator_has_next(iter)) {
        return NULL;
    }
    return iter->data[iter->current++];
}

void string_iterator_reset(StringIterator* iter) {
    iter->current = 0;
}

void string_iterator_destroy(StringIterator* iter) {
    free(iter);
}

// Number Range Iterator
typedef struct {
    int start;
    int end;
    int step;
    int current;
} RangeIterator;

RangeIterator* range_iterator_create(int start, int end, int step) {
    RangeIterator* iter = malloc(sizeof(RangeIterator));
    iter->start = start;
    iter->end = end;
    iter->step = step;
    iter->current = start;
    return iter;
}

bool range_iterator_has_next(RangeIterator* iter) {
    return iter->step > 0 ? iter->current < iter->end : iter->current > iter->end;
}

int range_iterator_next(RangeIterator* iter) {
    if (!range_iterator_has_next(iter)) {
        return -1; // Error value
    }
    int value = iter->current;
    iter->current += iter->step;
    return value;
}

void range_iterator_reset(RangeIterator* iter) {
    iter->current = iter->start;
}

void range_iterator_destroy(RangeIterator* iter) {
    free(iter);
}

// Filtered Iterator
typedef bool (*FilterFunction)(int);

typedef struct {
    int* data;
    int size;
    int current;
    FilterFunction filter;
} FilteredIterator;

FilteredIterator* filtered_iterator_create(int* numbers, int count, FilterFunction filter) {
    FilteredIterator* iter = malloc(sizeof(FilteredIterator));
    iter->data = numbers;
    iter->size = count;
    iter->current = 0;
    iter->filter = filter;
    return iter;
}

bool filtered_iterator_has_next(FilteredIterator* iter) {
    // Find next valid element
    int temp_current = iter->current;
    while (temp_current < iter->size) {
        if (iter->filter(iter->data[temp_current])) {
            return true;
        }
        temp_current++;
    }
    return false;
}

int filtered_iterator_next(FilteredIterator* iter) {
    while (iter->current < iter->size) {
        int value = iter->data[iter->current++];
        if (iter->filter(value)) {
            return value;
        }
    }
    return -1; // Error value
}

void filtered_iterator_reset(FilteredIterator* iter) {
    iter->current = 0;
}

void filtered_iterator_destroy(FilteredIterator* iter) {
    free(iter);
}

// Filter functions
bool is_even(int n) {
    return n % 2 == 0;
}

bool is_positive(int n) {
    return n > 0;
}

bool is_prime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    
    for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) {
            return false;
        }
    }
    return true;
}

// Demo function
void cIteratorDemo() {
    printf("=== Iterator Pattern - C Implementation ===\n\n");
    
    // String Iterator Demo
    printf("--- String Iterator ---\n");
    char* fruits[] = {"Apple", "Banana", "Cherry", "Date", "Elderberry"};
    StringIterator* str_iter = string_iterator_create(fruits, 5);
    
    while (string_iterator_has_next(str_iter)) {
        printf("%s ", string_iterator_next(str_iter));
    }
    printf("\n");
    
    string_iterator_reset(str_iter);
    printf("After reset: ");
    while (string_iterator_has_next(str_iter)) {
        printf("%s ", string_iterator_next(str_iter));
    }
    printf("\n");
    
    string_iterator_destroy(str_iter);
    
    // Range Iterator Demo
    printf("\n--- Range Iterator ---\n");
    RangeIterator* range_iter = range_iterator_create(1, 10, 1);
    
    printf("Range 1-10: ");
    while (range_iterator_has_next(range_iter)) {
        printf("%d ", range_iterator_next(range_iter));
    }
    printf("\n");
    
    range_iterator_reset(range_iter);
    printf("After reset: ");
    while (range_iterator_has_next(range_iter)) {
        printf("%d ", range_iterator_next(range_iter));
    }
    printf("\n");
    
    range_iterator_destroy(range_iter);
    
    // Step range
    RangeIterator* step_iter = range_iterator_create(0, 20, 3);
    printf("Range 0-20 step 3: ");
    while (range_iterator_has_next(step_iter)) {
        printf("%d ", range_iterator_next(step_iter));
    }
    printf("\n");
    range_iterator_destroy(step_iter);
    
    // Filtered Iterator Demo
    printf("\n--- Filtered Iterator ---\n");
    int numbers[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
    int num_count = sizeof(numbers) / sizeof(numbers[0]);
    
    // Even numbers
    FilteredIterator* even_iter = filtered_iterator_create(numbers, num_count, is_even);
    printf("Even numbers: ");
    while (filtered_iterator_has_next(even_iter)) {
        printf("%d ", filtered_iterator_next(even_iter));
    }
    printf("\n");
    filtered_iterator_destroy(even_iter);
    
    // Prime numbers
    FilteredIterator* prime_iter = filtered_iterator_create(numbers, num_count, is_prime);
    printf("Prime numbers: ");
    while (filtered_iterator_has_next(prime_iter)) {
        printf("%d ", filtered_iterator_next(prime_iter));
    }
    printf("\n");
    filtered_iterator_destroy(prime_iter);
    
    // Combined demo with negative numbers
    printf("\n--- Complex Filtering ---\n");
    int mixed_numbers[] = {-5, -2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int mixed_count = sizeof(mixed_numbers) / sizeof(mixed_numbers[0]);
    
    // Positive even numbers
    bool positive_even(int n) {
        return n > 0 && n % 2 == 0;
    }
    
    FilteredIterator* pos_even_iter = filtered_iterator_create(mixed_numbers, mixed_count, positive_even);
    printf("Positive even numbers: ");
    while (filtered_iterator_has_next(pos_even_iter)) {
        printf("%d ", filtered_iterator_next(pos_even_iter));
    }
    printf("\n");
    filtered_iterator_destroy(pos_even_iter);
}

int main() {
    cIteratorDemo();
    return 0;
}
```

### Python Implementation

#### Database Result Set Iterator

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, Iterator as TypingIterator
from datetime import datetime
import time

# Database Record模拟
class DatabaseRecord:
    def __init__(self, data: Dict[str, Any]):
        self.data = data
        self.timestamp = datetime.now()
    
    def __getitem__(self, key: str) -> Any:
        return self.data.get(key)
    
    def __str__(self) -> str:
        return f"Record({self.data})"
    
    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)

# 数据库结果集迭代器接口
class ResultSetIterator(ABC):
    @abstractmethod
    def has_next(self) -> bool: ...
    
    @abstractmethod
    def next(self) -> DatabaseRecord: ...
    
    @abstractmethod
    def reset(self) -> None: ...
    
    @abstractmethod
    def close(self) -> None: ...

# 具体迭代器实现
class SimpleResultSetIterator(ResultSetIterator):
    def __init__(self, records: List[DatabaseRecord]):
        self.records = records
        self.current_index = 0
        self.is_closed = False
    
    def has_next(self) -> bool:
        if self.is_closed:
            return False
        return self.current_index < len(self.records)
    
    def next(self) -> DatabaseRecord:
        if not self.has_next():
            raise StopIteration("No more records")
        
        record = self.records[self.current_index]
        self.current_index += 1
        return record
    
    def reset(self) -> None:
        self.current_index = 0
    
    def close(self) -> None:
        self.is_closed = True
        self.records.clear()

class PaginatedResultSetIterator(ResultSetIterator):
    def __init__(self, page_size: int = 10):
        self.page_size = page_size
        self.current_page = 0
        self.current_index = 0
        self.current_page_data: List[DatabaseRecord] = []
        self.is_closed = False
        self.total_records = 100  # 模拟总记录数
    
    def _fetch_page(self, page: int) -> List[DatabaseRecord]:
        """模拟从数据库获取分页数据"""
        if self.is_closed:
            return []
        
        start = page * self.page_size
        end = min(start + self.page_size, self.total_records)
        
        if start >= self.total_records:
            return []
        
        # 模拟数据库查询延迟
        time.sleep(0.1)
        
        records = []
        for i in range(start, end):
            records.append(DatabaseRecord({
                'id': i + 1,
                'name': f'User_{i + 1}',
                'email': f'user_{i + 1}@example.com',
                'age': (i % 50) + 18,
                'created_at': datetime.now()
            }))
        
        print(f"📄 Fetched page {page + 1} ({len(records)} records)")
        return records
    
    def has_next(self) -> bool:
        if self.is_closed:
            return False
        
        # 如果当前页还有记录
        if self.current_index < len(self.current_page_data):
            return True
        
        # 尝试获取下一页
        next_page = self.current_page + 1
        next_page_data = self._fetch_page(next_page)
        
        if next_page_data:
            self.current_page = next_page
            self.current_page_data = next_page_data
            self.current_index = 0
            return True
        
        return False
    
    def next(self) -> DatabaseRecord:
        if not self.has_next():
            raise StopIteration("No more records")
        
        record = self.current_page_data[self.current_index]
        self.current_index += 1
        return record
    
    def reset(self) -> None:
        self.current_page = 0
        self.current_index = 0
        self.current_page_data = self._fetch_page(0)
    
    def close(self) -> None:
        self.is_closed = True
        self.current_page_data.clear()

class FilteredResultSetIterator(ResultSetIterator):
    def __init__(self, base_iterator: ResultSetIterator, filter_func):
        self.base_iterator = base_iterator
        self.filter_func = filter_func
        self.next_record: Optional[DatabaseRecord] = None
        self._advance_to_next_valid()
    
    def _advance_to_next_valid(self) -> None:
        """前进到下一个满足过滤条件的记录"""
        self.next_record = None
        while self.base_iterator.has_next():
            record = self.base_iterator.next()
            if self.filter_func(record):
                self.next_record = record
                break
    
    def has_next(self) -> bool:
        return self.next_record is not None
    
    def next(self) -> DatabaseRecord:
        if not self.has_next():
            raise StopIteration("No more records")
        
        current_record = self.next_record
        self._advance_to_next_valid()
        return current_record
    
    def reset(self) -> None:
        self.base_iterator.reset()
        self._advance_to_next_valid()
    
    def close(self) -> None:
        self.base_iterator.close()
        self.next_record = None

# 数据库连接模拟
class DatabaseConnection:
    def __init__(self):
        self.is_connected = True
    
    def execute_query(self, query: str) -> ResultSetIterator:
        """执行查询并返回结果集迭代器"""
        if not self.is_connected:
            raise ConnectionError("Database not connected")
        
        print(f"🔍 Executing query: {query}")
        
        # 基于查询类型返回不同的迭代器
        if "LIMIT" in query.upper():
            page_size = 10
            if "LIMIT" in query:
                limit_part = query.split("LIMIT")[1].strip().split()[0]
                page_size = int(limit_part)
            return PaginatedResultSetIterator(page_size)
        else:
            # 返回简单迭代器
            records = [
                DatabaseRecord({'id': 1, 'name': 'Alice', 'age': 25}),
                DatabaseRecord({'id': 2, 'name': 'Bob', 'age': 30}),
                DatabaseRecord({'id': 3, 'name': 'Charlie', 'age': 35}),
            ]
            return SimpleResultSetIterator(records)
    
    def close(self):
        self.is_connected = False
        print("🔒 Database connection closed")

# Python迭代器协议适配器
class PythonIteratorAdapter:
    def __init__(self, result_set_iterator: ResultSetIterator):
        self.iterator = result_set_iterator
    
    def __iter__(self):
        return self
    
    def __next__(self) -> DatabaseRecord:
        if self.iterator.has_next():
            return self.iterator.next()
        raise StopIteration

# 使用示例
def databaseDemo():
    print("=== Iterator Pattern - Database Result Set ===\n")
    
    # 创建数据库连接
    db = DatabaseConnection()
    
    try:
        print("--- Simple Query Execution ---")
        simple_iterator = db.execute_query("SELECT * FROM users")
        
        print("Records:")
        while simple_iterator.has_next():
            record = simple_iterator.next()
            print(f"  {record}")
        
        simple_iterator.close()
        
        print("\n--- Paginated Query Execution ---")
        paginated_iterator = db.execute_query("SELECT * FROM users LIMIT 5")
        
        record_count = 0
        max_records = 15  # 限制显示的记录数
        
        while paginated_iterator.has_next() and record_count < max_records:
            record = paginated_iterator.next()
            print(f"  {record}")
            record_count += 1
        
        print(f"Displayed {record_count} records")
        paginated_iterator.close()
        
        print("\n--- Filtered Iteration ---")
        # 重新执行查询进行过滤
        base_iterator = db.execute_query("SELECT * FROM users LIMIT 5")
        
        # 过滤年龄大于25的用户
        def age_filter(record):
            return record['age'] > 25
        
        filtered_iterator = FilteredResultSetIterator(base_iterator, age_filter)
        
        print("Users older than 25:")
        while filtered_iterator.has_next():
            record = filtered_iterator.next()
            print(f"  {record['name']} (Age: {record['age']})")
        
        filtered_iterator.close()
        
        print("\n--- Python Iterator Protocol ---")
        python_iter = PythonIteratorAdapter(db.execute_query("SELECT * FROM users LIMIT 3"))
        
        print("Using Python for-loop:")
        for record in python_iter:
            print(f"  {record}")
        
    finally:
        db.close()

if __name__ == "__main__":
    databaseDemo()
```

#### Social Network Feed Iterator

```python
from abc import ABC, abstractmethod
from typing import List, Optional, Iterator as TypingIterator
from datetime import datetime, timedelta
import random
from enum import Enum

class PostType(Enum):
    TEXT = "text"
    IMAGE = "image"
    VIDEO = "video"
    LINK = "link"

class SocialMediaPost:
    def __init__(self, post_id: int, author: str, content: str, 
                 post_type: PostType, likes: int = 0, timestamp: Optional[datetime] = None):
        self.post_id = post_id
        self.author = author
        self.content = content
        self.post_type = post_type
        self.likes = likes
        self.timestamp = timestamp or datetime.now()
        self.comments: List[str] = []
    
    def add_comment(self, comment: str):
        self.comments.append(comment)
    
    def like(self):
        self.likes += 1
    
    def __str__(self):
        return f"{self.author}: {self.content[:50]}... ({self.likes} likes)"
    
    def __repr__(self):
        return f"Post({self.post_id}, {self.author}, {self.post_type.value})"

# 社交网络Feed迭代器接口
class FeedIterator(ABC):
    @abstractmethod
    def has_next(self) -> bool: ...
    
    @abstractmethod
    def next(self) -> SocialMediaPost: ...
    
    @abstractmethod
    def reset(self) -> None: ...

# 具体迭代器实现
class ChronologicalFeedIterator(FeedIterator):
    """按时间顺序显示帖子"""
    def __init__(self, posts: List[SocialMediaPost]):
        self.posts = sorted(posts, key=lambda p: p.timestamp, reverse=True)
        self.current_index = 0
    
    def has_next(self) -> bool:
        return self.current_index < len(self.posts)
    
    def next(self) -> SocialMediaPost:
        if not self.has_next():
            raise StopIteration("No more posts")
        
        post = self.posts[self.current_index]
        self.current_index += 1
        return post
    
    def reset(self) -> None:
        self.current_index = 0

class PopularityFeedIterator(FeedIterator):
    """按受欢迎程度显示帖子"""
    def __init__(self, posts: List[SocialMediaPost]):
        self.posts = sorted(posts, key=lambda p: p.likes, reverse=True)
        self.current_index = 0
    
    def has_next(self) -> bool:
        return self.current_index < len(self.posts)
    
    def next(self) -> SocialMediaPost:
        if not self.has_next():
            raise StopIteration("No more posts")
        
        post = self.posts[self.current_index]
        self.current_index += 1
        return post
    
    def reset(self) -> None:
        self.current_index = 0

class AuthorFeedIterator(FeedIterator):
    """只显示特定作者的帖子"""
    def __init__(self, posts: List[SocialMediaPost], author: str):
        self.posts = [p for p in posts if p.author == author]
        self.posts.sort(key=lambda p: p.timestamp, reverse=True)
        self.current_index = 0
    
    def has_next(self) -> bool:
        return self.current_index < len(self.posts)
    
    def next(self) -> SocialMediaPost:
        if not self.has_next():
            raise StopIteration("No more posts")
        
        post = self.posts[self.current_index]
        self.current_index += 1
        return post
    
    def reset(self) -> None:
        self.current_index = 0

class TypeFilteredFeedIterator(FeedIterator):
    """按帖子类型过滤"""
    def __init__(self, posts: List[SocialMediaPost], post_type: PostType):
        self.posts = [p for p in posts if p.post_type == post_type]
        self.posts.sort(key=lambda p: p.timestamp, reverse=True)
        self.current_index = 0
    
    def has_next(self) -> bool:
        return self.current_index < len(self.posts)
    
    def next(self) -> SocialMediaPost:
        if not self.has_next():
            raise StopIteration("No more posts")
        
        post = self.posts[self.current_index]
        self.current_index += 1
        return post
    
    def reset(self) -> None:
        self.current_index = 0

class InfiniteScrollIterator(FeedIterator):
    """无限滚动迭代器 - 模拟动态加载"""
    def __init__(self, all_posts: List[SocialMediaPost], batch_size: int = 5):
        self.all_posts = sorted(all_posts, key=lambda p: p.timestamp, reverse=True)
        self.batch_size = batch_size
        self.current_batch = 0
        self.loaded_posts: List[SocialMediaPost] = []
        self._load_next_batch()
    
    def _load_next_batch(self):
        """加载下一批帖子"""
        start = self.current_batch * self.batch_size
        end = start + self.batch_size
        
        if start < len(self.all_posts):
            batch = self.all_posts[start:end]
            self.loaded_posts.extend(batch)
            self.current_batch += 1
            print(f"📥 Loaded batch {self.current_batch} ({len(batch)} posts)")
    
    def has_next(self) -> bool:
        # 如果当前加载的帖子已经用完，尝试加载更多
        if not self.loaded_posts and self.current_batch * self.batch_size < len(self.all_posts):
            self._load_next_batch()
        
        return bool(self.loaded_posts)
    
    def next(self) -> SocialMediaPost:
        if not self.has_next():
            raise StopIteration("No more posts")
        
        return self.loaded_posts.pop(0)
    
    def reset(self) -> None:
        self.current_batch = 0
        self.loaded_posts = []
        self._load_next_batch()

# 社交网络Feed
class SocialMediaFeed:
    def __init__(self):
        self.posts: List[SocialMediaPost] = []
        self._generate_sample_data()
    
    def _generate_sample_data(self):
        """生成示例帖子数据"""
        authors = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
        contents = {
            PostType.TEXT: [
                "Just finished reading an amazing book!",
                "Beautiful weather today!",
                "Working on an exciting new project",
                "Life is full of surprises",
                "Learning new things every day"
            ],
            PostType.IMAGE: [
                "Check out this beautiful sunset!",
                "My new artwork is complete",
                "Vacation memories",
                "Food photography practice",
                "Nature walk photos"
            ],
            PostType.VIDEO: [
                "My latest vlog is up!",
                "Tutorial on Python programming",
                "Music cover video",
                "Travel vlog episode",
                "Cooking demonstration"
            ],
            PostType.LINK: [
                "Interesting article I found",
                "Useful resource for developers",
                "Must-read blog post",
                "Helpful tutorial link",
                "News article worth reading"
            ]
        }
        
        # 生成50个随机帖子
        for i in range(50):
            post_type = random.choice(list(PostType))
            author = random.choice(authors)
            content = random.choice(contents[post_type])
            likes = random.randint(0, 1000)
            
            # 随机时间戳（最近30天内）
            days_ago = random.randint(0, 30)
            hours_ago = random.randint(0, 23)
            timestamp = datetime.now() - timedelta(days=days_ago, hours=hours_ago)
            
            post = SocialMediaPost(
                post_id=i + 1,
                author=author,
                content=content,
                post_type=post_type,
                likes=likes,
                timestamp=timestamp
            )
            
            # 添加一些评论
            for _ in range(random.randint(0, 5)):
                post.add_comment(f"Comment {_ + 1}")
            
            self.posts.append(post)
    
    def create_chronological_feed(self) -> FeedIterator:
        return ChronologicalFeedIterator(self.posts)
    
    def create_popularity_feed(self) -> FeedIterator:
        return PopularityFeedIterator(self.posts)
    
    def create_author_feed(self, author: str) -> FeedIterator:
        return AuthorFeedIterator(self.posts, author)
    
    def create_type_filtered_feed(self, post_type: PostType) -> FeedIterator:
        return TypeFilteredFeedIterator(self.posts, post_type)
    
    def create_infinite_scroll_feed(self, batch_size: int = 5) -> FeedIterator:
        return InfiniteScrollIterator(self.posts, batch_size)

# 使用示例
def socialMediaDemo():
    print("=== Iterator Pattern - Social Media Feed ===\n")
    
    feed = SocialMediaFeed()
    
    print("--- Chronological Feed ---")
    chronological_iter = feed.create_chronological_feed()
    post_count = 0
    while chronological_iter.has_next() and post_count < 5:
        post = chronological_iter.next()
        print(f"  {post.timestamp.strftime('%Y-%m-%d %H:%M')} - {post}")
        post_count += 1
    
    print("\n--- Popularity Feed (Top 5) ---")
    popularity_iter = feed.create_popularity_feed()
    post_count = 0
    while popularity_iter.has_next() and post_count < 5:
        post = popularity_iter.next()
        print(f"  {post.likes} likes - {post}")
        post_count += 1
    
    print("\n--- Author Feed (Alice's Posts) ---")
    author_iter = feed.create_author_feed("Alice")
    post_count = 0
    while author_iter.has_next() and post_count < 5:
        post = author_iter.next()
        print(f"  {post}")
        post_count += 1
    
    print("\n--- Type Filtered Feed (Images Only) ---")
    image_iter = feed.create_type_filtered_feed(PostType.IMAGE)
    post_count = 0
    while image_iter.has_next() and post_count < 5:
        post = image_iter.next()
        print(f"  {post}")
        post_count += 1
    
    print("\n--- Infinite Scroll Feed ---")
    infinite_iter = feed.create_infinite_scroll_feed(3)
    
    # 模拟用户滚动
    for scroll in range(3):
        print(f"\nScroll {scroll + 1}:")
        post_count = 0
        while infinite_iter.has_next() and post_count < 3:
            post = infinite_iter.next()
            print(f"  {post}")
            post_count += 1
        
        if scroll < 2:  # 不是最后一次滚动
            input("Press Enter to scroll for more posts...")

if __name__ == "__main__":
    socialMediaDemo()
```

## Advantages and Disadvantages

### Advantages

- **Uniform Interface**: Provides consistent way to traverse different collections
- **Encapsulation**: Hides the internal structure of the collection
- **Multiple Iterations**: Supports multiple simultaneous traversals
- **Separation of Concerns**: Separates traversal logic from collection logic
- **Lazy Evaluation**: Can implement lazy loading for large datasets

### Disadvantages

- **Overhead**: Can add complexity for simple collections
- **Performance**: Iterator objects create additional memory overhead
- **Modification Issues**: Concurrent modification can cause problems
- **Complex Implementation**: Some data structures require complex iterator implementations

## Best Practices

1. **Use Standard Interfaces**: Implement language-standard iterator protocols when available
2. **Handle Concurrent Modification**: Consider how to handle collection modifications during iteration
3. **Resource Management**: Implement proper cleanup for iterators that hold resources
4. **Lazy Loading**: Use iterators for large datasets that can't fit in memory
5. **Immutable Iterators**: Consider making iterators immutable for thread safety

## Iterator vs Other Patterns

- **vs Visitor**: Iterator traverses elements, Visitor performs operations on elements
- **vs Composite**: Iterator works with collections, Composite works with tree structures
- **vs Factory Method**: Iterator creates traversal objects, Factory Method creates various objects
- **vs Observer**: Iterator pulls data, Observer pushes notifications

The Iterator pattern is fundamental in modern programming and is built into most programming languages through constructs like `for-each` loops. It's essential for working with collections, streams, and any data structure that needs sequential access.
