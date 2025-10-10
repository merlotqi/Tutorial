# Chain of Responsibility Pattern

## Introduction

The Chain of Responsibility Pattern is a behavioral design pattern that allows passing requests along a chain of handlers. Upon receiving a request, each handler decides either to process the request or to pass it to the next handler in the chain.

### Key Characteristics

- **Request Passing**: Requests are passed along a chain of handlers
- **Loose Coupling**: Senders don't know which handler will process the request
- **Dynamic Chain**: Handlers can be added or removed at runtime
- **Multiple Handlers**: Multiple handlers get a chance to process the request

### Use Cases

- Event handling systems
- Logging frameworks
- Approval workflows
- Exception handling
- Middleware in web frameworks
- Input validation chains

## Implementation Examples

### C++ Implementation

#### Logging System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <sstream>
#include <vector>
#include <ctime>

// Log Levels
enum class LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    CRITICAL
};

// Convert log level to string
std::string logLevelToString(LogLevel level) {
    switch (level) {
        case LogLevel::DEBUG: return "DEBUG";
        case LogLevel::INFO: return "INFO";
        case LogLevel::WARNING: return "WARNING";
        case LogLevel::ERROR: return "ERROR";
        case LogLevel::CRITICAL: return "CRITICAL";
        default: return "UNKNOWN";
    }
}

// Log Message
struct LogMessage {
    LogLevel level;
    std::string message;
    std::string timestamp;
    std::string source;
    
    LogMessage(LogLevel lvl, const std::string& msg, const std::string& src = "")
        : level(lvl), message(msg), source(src) {
        // Generate timestamp
        std::time_t now = std::time(nullptr);
        timestamp = std::ctime(&now);
        timestamp.pop_back(); // Remove newline
    }
    
    std::string toString() const {
        std::ostringstream oss;
        oss << "[" << timestamp << "] "
            << "[" << logLevelToString(level) << "] "
            << (source.empty() ? "" : "[" + source + "] ")
            << message;
        return oss.str();
    }
};

// Handler Interface
class LogHandler {
protected:
    std::unique_ptr<LogHandler> nextHandler;
    LogLevel processingLevel;

public:
    explicit LogHandler(LogLevel level) : processingLevel(level) {}
    virtual ~LogHandler() = default;
    
    void setNext(std::unique_ptr<LogHandler> next) {
        nextHandler = std::move(next);
    }
    
    virtual void handle(const LogMessage& message) {
        if (shouldHandle(message.level)) {
            process(message);
        }
        
        if (nextHandler) {
            nextHandler->handle(message);
        }
    }
    
    virtual bool shouldHandle(LogLevel level) const {
        return level >= processingLevel;
    }
    
    virtual void process(const LogMessage& message) = 0;
};

// Concrete Handlers
class ConsoleHandler : public LogHandler {
public:
    ConsoleHandler(LogLevel level = LogLevel::DEBUG) : LogHandler(level) {}
    
    void process(const LogMessage& message) override {
        std::cout << "📝 CONSOLE: " << message.toString() << std::endl;
    }
};

class FileHandler : public LogHandler {
private:
    std::string filename;
    
public:
    FileHandler(const std::string& file, LogLevel level = LogLevel::INFO) 
        : LogHandler(level), filename(file) {}
    
    void process(const LogMessage& message) override {
        // In real implementation, would write to file
        std::cout << "💾 FILE [" << filename << "]: " << message.toString() << std::endl;
    }
};

class EmailHandler : public LogHandler {
private:
    std::string recipient;
    
public:
    EmailHandler(const std::string& email, LogLevel level = LogLevel::ERROR) 
        : LogHandler(level), recipient(email) {}
    
    void process(const LogMessage& message) override {
        std::cout << "📧 EMAIL to " << recipient << ": " << message.toString() << std::endl;
    }
};

class DatabaseHandler : public LogHandler {
private:
    std::string connectionString;
    
public:
    DatabaseHandler(const std::string& connStr, LogLevel level = LogLevel::WARNING) 
        : LogHandler(level), connectionString(connStr) {}
    
    void process(const LogMessage& message) override {
        std::cout << "🗄️ DATABASE [" << connectionString << "]: " << message.toString() << std::endl;
    }
};

class CriticalAlertHandler : public LogHandler {
public:
    CriticalAlertHandler(LogLevel level = LogLevel::CRITICAL) : LogHandler(level) {}
    
    void process(const LogMessage& message) override {
        std::cout << "🚨 CRITICAL ALERT: " << message.toString() << std::endl;
        // In real implementation, would trigger alerts (SMS, PagerDuty, etc.)
        triggerAlerts();
    }
    
private:
    void triggerAlerts() {
        std::cout << "🔔 Triggering SMS alerts..." << std::endl;
        std::cout << "📱 Triggering mobile push notifications..." << std::endl;
        std::cout << "📟 Triggering pager alerts..." << std::endl;
    }
};

// Logging System that uses Chain of Responsibility
class LoggingSystem {
private:
    std::unique_ptr<LogHandler> chainHead;

public:
    LoggingSystem() {
        buildChain();
    }
    
    void log(LogLevel level, const std::string& message, const std::string& source = "") {
        LogMessage logMsg(level, message, source);
        if (chainHead) {
            chainHead->handle(logMsg);
        }
    }
    
    // Convenience methods
    void debug(const std::string& message, const std::string& source = "") {
        log(LogLevel::DEBUG, message, source);
    }
    
    void info(const std::string& message, const std::string& source = "") {
        log(LogLevel::INFO, message, source);
    }
    
    void warning(const std::string& message, const std::string& source = "") {
        log(LogLevel::WARNING, message, source);
    }
    
    void error(const std::string& message, const std::string& source = "") {
        log(LogLevel::ERROR, message, source);
    }
    
    void critical(const std::string& message, const std::string& source = "") {
        log(LogLevel::CRITICAL, message, source);
    }

private:
    void buildChain() {
        // Build the chain: Console -> File -> Database -> Email -> Critical Alert
        auto consoleHandler = std::make_unique<ConsoleHandler>(LogLevel::DEBUG);
        auto fileHandler = std::make_unique<FileHandler>("app.log", LogLevel::INFO);
        auto dbHandler = std::make_unique<DatabaseHandler>("server=localhost;db=logs", LogLevel::WARNING);
        auto emailHandler = std::make_unique<EmailHandler>("admin@company.com", LogLevel::ERROR);
        auto criticalHandler = std::make_unique<CriticalAlertHandler>(LogLevel::CRITICAL);
        
        // Build the chain
        consoleHandler->setNext(std::move(fileHandler));
        consoleHandler->setNext(std::move(dbHandler));
        consoleHandler->setNext(std::move(emailHandler));
        consoleHandler->setNext(std::move(criticalHandler));
        
        chainHead = std::move(consoleHandler);
    }
};

// Demo function
void loggingSystemDemo() {
    std::cout << "=== Chain of Responsibility Pattern - Logging System ===\n" << std::endl;
    
    LoggingSystem logger;
    
    std::cout << "--- Testing Different Log Levels ---" << std::endl;
    logger.debug("This is a debug message", "UserService");
    logger.info("Application started successfully", "System");
    logger.warning("Database connection is slow", "Database");
    logger.error("Failed to process user request", "API");
    logger.critical("System out of memory! Shutting down...", "Kernel");
    
    std::cout << "\n--- Testing Chain Behavior ---" << std::endl;
    std::cout << "Note how each handler processes messages based on its log level threshold" << std::endl;
}

int main() {
    loggingSystemDemo();
    return 0;
}
```

#### Approval Workflow System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <cmath>

// Expense Request
class ExpenseRequest {
private:
    std::string id;
    std::string employee;
    std::string description;
    double amount;
    std::string status;
    std::string approvedBy;

public:
    ExpenseRequest(const std::string& emp, const std::string& desc, double amt)
        : employee(emp), description(desc), amount(amt), status("Pending") {
        // Generate simple ID
        static int counter = 1;
        id = "EXP-" + std::to_string(counter++);
    }
    
    // Getters
    const std::string& getId() const { return id; }
    const std::string& getEmployee() const { return employee; }
    const std::string& getDescription() const { return description; }
    double getAmount() const { return amount; }
    const std::string& getStatus() const { return status; }
    const std::string& getApprovedBy() const { return approvedBy; }
    
    // Setters
    void setStatus(const std::string& newStatus) { status = newStatus; }
    void setApprovedBy(const std::string& approver) { approvedBy = approver; }
    
    void display() const {
        std::cout << "💰 Expense #" << id << std::endl;
        std::cout << "   Employee: " << employee << std::endl;
        std::cout << "   Description: " << description << std::endl;
        std::cout << "   Amount: $" << amount << std::endl;
        std::cout << "   Status: " << status << std::endl;
        if (!approvedBy.empty()) {
            std::cout << "   Approved By: " << approvedBy << std::endl;
        }
    }
};

// Approval Handler Interface
class ApprovalHandler {
protected:
    std::unique_ptr<ApprovalHandler> nextHandler;
    std::string approverName;
    double approvalLimit;

public:
    ApprovalHandler(const std::string& name, double limit) 
        : approverName(name), approvalLimit(limit) {}
    
    virtual ~ApprovalHandler() = default;
    
    void setNext(std::unique_ptr<ApprovalHandler> next) {
        nextHandler = std::move(next);
    }
    
    virtual void processRequest(std::shared_ptr<ExpenseRequest> request) {
        if (canApprove(request)) {
            if (approve(request)) {
                std::cout << "✅ " << approverName << " approved expense #" 
                          << request->getId() << " ($" << request->getAmount() << ")" << std::endl;
                request->setStatus("Approved");
                request->setApprovedBy(approverName);
                return; // Stop the chain
            }
        }
        
        if (nextHandler) {
            std::cout << "↪️  " << approverName << " forwarding to next approver" << std::endl;
            nextHandler->processRequest(request);
        } else {
            std::cout << "❌ No one can approve expense #" << request->getId() 
                      << ". Request rejected." << std::endl;
            request->setStatus("Rejected");
        }
    }
    
    virtual bool canApprove(std::shared_ptr<ExpenseRequest> request) const {
        return request->getAmount() <= approvalLimit;
    }
    
    virtual bool approve(std::shared_ptr<ExpenseRequest> request) {
        // In real system, might have additional logic here
        return true;
    }
};

// Concrete Handlers
class TeamLeadHandler : public ApprovalHandler {
public:
    TeamLeadHandler(const std::string& name) : ApprovalHandler(name, 1000.0) {}
    
    bool approve(std::shared_ptr<ExpenseRequest> request) override {
        // Team lead might have additional checks
        if (request->getDescription().find("entertainment") != std::string::npos) {
            std::cout << "⚠️  Team lead requires manager approval for entertainment expenses" << std::endl;
            return false;
        }
        return true;
    }
};

class ManagerHandler : public ApprovalHandler {
public:
    ManagerHandler(const std::string& name) : ApprovalHandler(name, 5000.0) {}
    
    bool approve(std::shared_ptr<ExpenseRequest> request) override {
        // Manager might check for budget compliance
        if (request->getAmount() > 3000 && request->getDescription().find("travel") != std::string::npos) {
            std::cout << "📋 Manager requires director approval for large travel expenses" << std::endl;
            return false;
        }
        return true;
    }
};

class DirectorHandler : public ApprovalHandler {
public:
    DirectorHandler(const std::string& name) : ApprovalHandler(name, 25000.0) {}
    
    bool approve(std::shared_ptr<ExpenseRequest> request) override {
        // Director might require additional documentation for large amounts
        if (request->getAmount() > 10000) {
            std::cout << "📄 Director requires additional documentation for expenses over $10,000" << std::endl;
            // In real system, would wait for documentation
            return true; // Assume documentation is provided
        }
        return true;
    }
};

class VPHandler : public ApprovalHandler {
public:
    VPHandler(const std::string& name) : ApprovalHandler(name, 100000.0) {}
    
    bool approve(std::shared_ptr<ExpenseRequest> request) override {
        // VP might require business justification
        std::cout << "💼 VP reviewing business justification for large expense" << std::endl;
        return true;
    }
};

class CEOHandler : public ApprovalHandler {
public:
    CEOHandler(const std::string& name) : ApprovalHandler(name, 500000.0) {}
    
    bool approve(std::shared_ptr<ExpenseRequest> request) override {
        // CEO approval for very large expenses
        std::cout << "👑 CEO personally approving major company expense" << std::endl;
        return true;
    }
};

// Expense Approval System
class ExpenseApprovalSystem {
private:
    std::unique_ptr<ApprovalHandler> approvalChain;

public:
    ExpenseApprovalSystem() {
        buildApprovalChain();
    }
    
    void submitExpense(std::shared_ptr<ExpenseRequest> request) {
        std::cout << "\n📤 Submitting expense for approval:" << std::endl;
        request->display();
        std::cout << "\n🔄 Processing approval chain..." << std::endl;
        
        approvalChain->processRequest(request);
        
        std::cout << "\n📋 Final Result:" << std::endl;
        request->display();
    }

private:
    void buildApprovalChain() {
        // Build the approval chain
        auto teamLead = std::make_unique<TeamLeadHandler>("Sarah Chen (Team Lead)");
        auto manager = std::make_unique<ManagerHandler>("Mike Johnson (Manager)");
        auto director = std::make_unique<DirectorHandler>("Lisa Wang (Director)");
        auto vp = std::make_unique<VPHandler>("Robert Brown (VP)");
        auto ceo = std::make_unique<CEOHandler>("Jennifer Smith (CEO)");
        
        // Build the chain
        teamLead->setNext(std::move(manager));
        teamLead->setNext(std::move(director));
        teamLead->setNext(std::move(vp));
        teamLead->setNext(std::move(ceo));
        
        approvalChain = std::move(teamLead);
    }
};

// Demo function
void approvalWorkflowDemo() {
    std::cout << "=== Chain of Responsibility Pattern - Approval Workflow ===\n" << std::endl;
    
    ExpenseApprovalSystem approvalSystem;
    
    std::cout << "--- Test Case 1: Small Expense (Team Lead Approval) ---" << std::endl;
    auto expense1 = std::make_shared<ExpenseRequest>("John Doe", "Office supplies", 250.0);
    approvalSystem.submitExpense(expense1);
    
    std::cout << "\n--- Test Case 2: Medium Expense (Manager Approval) ---" << std::endl;
    auto expense2 = std::make_shared<ExpenseRequest>("Jane Smith", "Team lunch", 800.0);
    approvalSystem.submitExpense(expense2);
    
    std::cout << "\n--- Test Case 3: Large Expense (Director Approval) ---" << std::endl;
    auto expense3 = std::make_shared<ExpenseRequest>("Bob Wilson", "Conference travel", 4500.0);
    approvalSystem.submitExpense(expense3);
    
    std::cout << "\n--- Test Case 4: Entertainment Expense (Special Handling) ---" << std::endl;
    auto expense4 = std::make_shared<ExpenseRequest>("Alice Brown", "Client entertainment", 600.0);
    approvalSystem.submitExpense(expense4);
    
    std::cout << "\n--- Test Case 5: Very Large Expense (VP/CEO Approval) ---" << std::endl;
    auto expense5 = std::make_shared<ExpenseRequest>("David Lee", "New server equipment", 35000.0);
    approvalSystem.submitExpense(expense5);
    
    std::cout << "\n--- Test Case 6: Massive Expense (CEO Approval) ---" << std::endl;
    auto expense6 = std::make_shared<ExpenseRequest>("CEO Office", "Company acquisition", 250000.0);
    approvalSystem.submitExpense(expense6);
}

int main() {
    approvalWorkflowDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Authentication Request
typedef struct {
    char username[50];
    char password[50];
    char ip_address[16];
    char user_agent[100];
    bool is_authenticated;
    char failure_reason[100];
} AuthRequest;

// Authentication Handler Interface
typedef struct AuthHandler AuthHandler;
typedef void (*AuthFunction)(AuthHandler*, AuthRequest*);

struct AuthHandler {
    AuthFunction authenticate;
    AuthHandler* next;
    char handler_name[50];
};

// Concrete Handlers
void rate_limit_authenticate(AuthHandler* handler, AuthRequest* request) {
    printf("🔒 Rate Limiter checking request from %s\n", request->ip_address);
    
    // Simulate rate limiting check
    if (strcmp(request->ip_address, "192.168.1.100") == 0) {
        strcpy(request->failure_reason, "Rate limit exceeded");
        printf("❌ Rate limit exceeded for IP: %s\n", request->ip_address);
        return;
    }
    
    printf("✅ Rate limit check passed\n");
    
    // Pass to next handler
    if (handler->next != NULL) {
        handler->next->authenticate(handler->next, request);
    }
}

void ip_whitelist_authenticate(AuthHandler* handler, AuthRequest* request) {
    printf("🌐 IP Whitelist checking %s\n", request->ip_address);
    
    // Simulate IP whitelist check
    const char* allowed_ips[] = {"192.168.1.1", "192.168.1.2", "192.168.1.3", NULL};
    bool ip_allowed = false;
    
    for (int i = 0; allowed_ips[i] != NULL; i++) {
        if (strcmp(request->ip_address, allowed_ips[i]) == 0) {
            ip_allowed = true;
            break;
        }
    }
    
    if (!ip_allowed) {
        strcpy(request->failure_reason, "IP address not in whitelist");
        printf("❌ IP %s not in whitelist\n", request->ip_address);
        return;
    }
    
    printf("✅ IP whitelist check passed\n");
    
    // Pass to next handler
    if (handler->next != NULL) {
        handler->next->authenticate(handler->next, request);
    }
}

void credential_authenticate(AuthHandler* handler, AuthRequest* request) {
    printf("🔑 Credential validation for user: %s\n", request->username);
    
    // Simulate credential validation
    if (strcmp(request->username, "admin") == 0 && strcmp(request->password, "admin123") == 0) {
        printf("✅ Admin credentials valid\n");
    } else if (strcmp(request->username, "user") == 0 && strcmp(request->password, "user123") == 0) {
        printf("✅ User credentials valid\n");
    } else if (strcmp(request->username, "guest") == 0 && strcmp(request->password, "guest") == 0) {
        printf("✅ Guest credentials valid\n");
    } else {
        strcpy(request->failure_reason, "Invalid username or password");
        printf("❌ Invalid credentials for user: %s\n", request->username);
        return;
    }
    
    printf("✅ Credential validation passed\n");
    
    // Pass to next handler
    if (handler->next != NULL) {
        handler->next->authenticate(handler->next, request);
    }
}

void two_factor_authenticate(AuthHandler* handler, AuthRequest* request) {
    printf("📱 Two-factor authentication for user: %s\n", request->username);
    
    // Simulate 2FA check - only required for admin
    if (strcmp(request->username, "admin") == 0) {
        printf("⚠️  Admin requires two-factor authentication\n");
        // In real system, would verify 2FA code
        bool two_factor_valid = true; // Assume valid for demo
        
        if (!two_factor_valid) {
            strcpy(request->failure_reason, "Two-factor authentication failed");
            printf("❌ 2FA failed for admin\n");
            return;
        }
        printf("✅ 2FA passed for admin\n");
    } else {
        printf("ℹ️  2FA not required for this user\n");
    }
    
    printf("✅ Two-factor authentication passed\n");
    
    // Pass to next handler
    if (handler->next != NULL) {
        handler->next->authenticate(handler->next, request);
    } else {
        // If we reached the end of chain, authentication is successful
        request->is_authenticated = true;
        printf("🎉 Authentication successful for user: %s\n", request->username);
    }
}

// Handler creation functions
AuthHandler* create_rate_limit_handler() {
    AuthHandler* handler = malloc(sizeof(AuthHandler));
    strcpy(handler->handler_name, "RateLimiter");
    handler->authenticate = rate_limit_authenticate;
    handler->next = NULL;
    return handler;
}

AuthHandler* create_ip_whitelist_handler() {
    AuthHandler* handler = malloc(sizeof(AuthHandler));
    strcpy(handler->handler_name, "IPWhitelist");
    handler->authenticate = ip_whitelist_authenticate;
    handler->next = NULL;
    return handler;
}

AuthHandler* create_credential_handler() {
    AuthHandler* handler = malloc(sizeof(AuthHandler));
    strcpy(handler->handler_name, "CredentialValidator");
    handler->authenticate = credential_authenticate;
    handler->next = NULL;
    return handler;
}

AuthHandler* create_two_factor_handler() {
    AuthHandler* handler = malloc(sizeof(AuthHandler));
    strcpy(handler->handler_name, "TwoFactorAuth");
    handler->authenticate = two_factor_authenticate;
    handler->next = NULL;
    return handler;
}

// Authentication system
typedef struct {
    AuthHandler* chain_head;
} AuthenticationSystem;

void init_authentication_system(AuthenticationSystem* system) {
    // Create handlers
    AuthHandler* rate_limiter = create_rate_limit_handler();
    AuthHandler* ip_whitelist = create_ip_whitelist_handler();
    AuthHandler* credential_validator = create_credential_handler();
    AuthHandler* two_factor = create_two_factor_handler();
    
    // Build the chain
    rate_limiter->next = ip_whitelist;
    ip_whitelist->next = credential_validator;
    credential_validator->next = two_factor;
    
    system->chain_head = rate_limiter;
}

void authenticate_user(AuthenticationSystem* system, AuthRequest* request) {
    printf("\n🔐 Starting authentication process for user: %s\n", request->username);
    printf("IP: %s, User-Agent: %s\n", request->ip_address, request->user_agent);
    
    // Initialize request
    request->is_authenticated = false;
    request->failure_reason[0] = '\0';
    
    // Start the chain
    if (system->chain_head != NULL) {
        system->chain_head->authenticate(system->chain_head, request);
    }
    
    // Display result
    if (request->is_authenticated) {
        printf("🎊 FINAL RESULT: Authentication SUCCESS\n");
    } else {
        printf("💥 FINAL RESULT: Authentication FAILED - %s\n", request->failure_reason);
    }
}

void free_authentication_system(AuthenticationSystem* system) {
    AuthHandler* current = system->chain_head;
    while (current != NULL) {
        AuthHandler* next = current->next;
        free(current);
        current = next;
    }
}

// Demo function
void authenticationDemo() {
    printf("=== Chain of Responsibility Pattern - Authentication System ===\n\n");
    
    AuthenticationSystem auth_system;
    init_authentication_system(&auth_system);
    
    // Test case 1: Successful user authentication
    printf("--- Test 1: Valid User Login ---\n");
    AuthRequest request1 = {
        .username = "user",
        .password = "user123",
        .ip_address = "192.168.1.1",
        .user_agent = "Chrome/91.0"
    };
    authenticate_user(&auth_system, &request1);
    
    // Test case 2: Successful admin authentication
    printf("\n--- Test 2: Valid Admin Login ---\n");
    AuthRequest request2 = {
        .username = "admin",
        .password = "admin123",
        .ip_address = "192.168.1.2",
        .user_agent = "Firefox/89.0"
    };
    authenticate_user(&auth_system, &request2);
    
    // Test case 3: Rate limited IP
    printf("\n--- Test 3: Rate Limited IP ---\n");
    AuthRequest request3 = {
        .username = "user",
        .password = "user123",
        .ip_address = "192.168.1.100",
        .user_agent = "Safari/14.0"
    };
    authenticate_user(&auth_system, &request3);
    
    // Test case 4: IP not in whitelist
    printf("\n--- Test 4: IP Not in Whitelist ---\n");
    AuthRequest request4 = {
        .username = "user",
        .password = "user123",
        .ip_address = "10.0.0.1",
        .user_agent = "Edge/91.0"
    };
    authenticate_user(&auth_system, &request4);
    
    // Test case 5: Invalid credentials
    printf("\n--- Test 5: Invalid Credentials ---\n");
    AuthRequest request5 = {
        .username = "hacker",
        .password = "password",
        .ip_address = "192.168.1.1",
        .user_agent = "Chrome/91.0"
    };
    authenticate_user(&auth_system, &request5);
    
    // Cleanup
    free_authentication_system(&auth_system);
}

int main() {
    authenticationDemo();
    return 0;
}
```

### Python Implementation

#### Middleware Pipeline

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, Callable
from datetime import datetime
import json
import time

# HTTP Request and Response classes
class HTTPRequest:
    def __init__(self, method: str, path: str, headers: Dict[str, str], body: str = ""):
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
        self.timestamp = datetime.now()
        self.user: Optional[Dict[str, Any]] = None
        self.metadata: Dict[str, Any] = {}

class HTTPResponse:
    def __init__(self, status_code: int = 200, body: str = "", headers: Dict[str, str] = None):
        self.status_code = status_code
        self.body = body
        self.headers = headers or {}
        self.timestamp = datetime.now()

# Middleware Handler Interface
class Middleware(ABC):
    def __init__(self):
        self.next_middleware: Optional[Middleware] = None
    
    def set_next(self, middleware: 'Middleware') -> 'Middleware':
        self.next_middleware = middleware
        return middleware
    
    @abstractmethod
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        """
        Handle the request/response.
        Return True to continue the chain, False to stop.
        """
        pass
    
    def _call_next(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        """Call the next middleware in the chain"""
        if self.next_middleware:
            return self.next_middleware.handle(request, response)
        return True

# Concrete Middleware Implementations
class LoggingMiddleware(Middleware):
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        print(f"📝 [{request.timestamp}] {request.method} {request.path}")
        print(f"    Headers: {json.dumps(request.headers, indent=4)}")
        if request.body:
            print(f"    Body: {request.body[:100]}...")
        
        # Record start time for performance measurement
        request.metadata['start_time'] = time.time()
        
        # Continue the chain
        continue_chain = self._call_next(request, response)
        
        # Log response
        duration = time.time() - request.metadata['start_time']
        print(f"📝 Response: {response.status_code} (took {duration:.3f}s)")
        
        return continue_chain

class AuthenticationMiddleware(Middleware):
    def __init__(self, api_keys: Dict[str, str]):
        super().__init__()
        self.api_keys = api_keys
    
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        print("🔐 Authenticating request...")
        
        api_key = request.headers.get('X-API-Key')
        if not api_key:
            response.status_code = 401
            response.body = json.dumps({"error": "API key required"})
            return False
        
        user_id = self.api_keys.get(api_key)
        if not user_id:
            response.status_code = 401
            response.body = json.dumps({"error": "Invalid API key"})
            return False
        
        # Add user information to request
        request.user = {"id": user_id, "api_key": api_key}
        print(f"✅ Authenticated as user: {user_id}")
        
        return self._call_next(request, response)

class AuthorizationMiddleware(Middleware):
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        if not request.user:
            response.status_code = 401
            response.body = json.dumps({"error": "Authentication required"})
            return False
        
        print("🔒 Checking authorization...")
        
        user_id = request.user['id']
        
        # Simple role-based authorization
        if request.path.startswith('/admin/') and not user_id.startswith('admin'):
            response.status_code = 403
            response.body = json.dumps({"error": "Admin access required"})
            return False
        
        # Check resource ownership for user-specific endpoints
        if request.path.startswith('/users/') and '/profile' in request.path:
            path_user_id = request.path.split('/')[2]
            if path_user_id != user_id and not user_id.startswith('admin'):
                response.status_code = 403
                response.body = json.dumps({"error": "Access denied"})
                return False
        
        print("✅ Authorization passed")
        return self._call_next(request, response)

class RateLimitingMiddleware(Middleware):
    def __init__(self, requests_per_minute: int = 60):
        super().__init__()
        self.requests_per_minute = requests_per_minute
        self.request_counts: Dict[str, list] = {}
    
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        if not request.user:
            return self._call_next(request, response)
        
        user_id = request.user['id']
        current_time = time.time()
        
        # Clean old requests (older than 1 minute)
        if user_id in self.request_counts:
            self.request_counts[user_id] = [
                req_time for req_time in self.request_counts[user_id]
                if current_time - req_time < 60
            ]
        
        # Initialize if needed
        if user_id not in self.request_counts:
            self.request_counts[user_id] = []
        
        # Check rate limit
        if len(self.request_counts[user_id]) >= self.requests_per_minute:
            response.status_code = 429
            response.body = json.dumps({
                "error": "Rate limit exceeded",
                "limit": self.requests_per_minute,
                "retry_after": 60
            })
            print(f"🚫 Rate limit exceeded for user: {user_id}")
            return False
        
        # Add current request
        self.request_counts[user_id].append(current_time)
        print(f"📊 Rate limit: {len(self.request_counts[user_id])}/{self.requests_per_minute} requests")
        
        return self._call_next(request, response)

class CachingMiddleware(Middleware):
    def __init__(self):
        super().__init__()
        self.cache: Dict[str, tuple] = {}  # key: (timestamp, response_data)
    
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        # Only cache GET requests
        if request.method != 'GET':
            return self._call_next(request, response)
        
        cache_key = f"{request.method}:{request.path}"
        
        # Check cache
        if cache_key in self.cache:
            cache_time, cached_response = self.cache[cache_key]
            if time.time() - cache_time < 300:  # 5 minute cache
                print(f"💾 Serving from cache: {cache_key}")
                response.status_code = cached_response['status_code']
                response.body = cached_response['body']
                response.headers = cached_response['headers']
                response.headers['X-Cache'] = 'HIT'
                return False  # Stop chain, served from cache
        
        print("💾 Cache miss, processing request...")
        
        # Continue chain and cache the result
        continue_chain = self._call_next(request, response)
        
        # Cache successful GET responses
        if request.method == 'GET' and response.status_code == 200:
            self.cache[cache_key] = (
                time.time(),
                {
                    'status_code': response.status_code,
                    'body': response.body,
                    'headers': response.headers
                }
            )
            response.headers['X-Cache'] = 'MISS'
            print(f"💾 Cached response for: {cache_key}")
        
        return continue_chain

class CompressionMiddleware(Middleware):
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        # Process request first
        continue_chain = self._call_next(request, response)
        
        # Compress response if large and client supports it
        accept_encoding = request.headers.get('Accept-Encoding', '')
        response_size = len(response.body) if response.body else 0
        
        if 'gzip' in accept_encoding and response_size > 1024:
            print(f"🗜️ Compressing response ({response_size} bytes)")
            # In real implementation, would actually compress the content
            response.headers['Content-Encoding'] = 'gzip'
            response.headers['X-Original-Size'] = str(response_size)
            response.headers['X-Compressed-Size'] = str(response_size // 2)  # Simulated
        
        return continue_chain

# Request Handler (end of chain)
class RequestHandler:
    def handle(self, request: HTTPRequest, response: HTTPResponse) -> bool:
        print(f"🎯 Handling request: {request.method} {request.path}")
        
        # Simple routing
        if request.path == '/api/users/me':
            response.body = json.dumps({
                "user_id": request.user['id'],
                "message": "Hello user!",
                "timestamp": datetime.now().isoformat()
            })
        elif request.path == '/api/admin/stats':
            response.body = json.dumps({
                "total_users": 1000,
                "active_sessions": 42,
                "server_time": datetime.now().isoformat()
            })
        elif request.path == '/api/public/info':
            response.body = json.dumps({
                "service": "API Server",
                "version": "1.0.0",
                "status": "operational"
            })
        else:
            response.status_code = 404
            response.body = json.dumps({"error": "Endpoint not found"})
        
        return True

# Web Server using Middleware Chain
class WebServer:
    def __init__(self):
        self.middleware_chain: Optional[Middleware] = None
        self.request_handler = RequestHandler()
        self._build_middleware_chain()
    
    def _build_middleware_chain(self):
        # Configure API keys
        api_keys = {
            "user123key": "user123",
            "admin456key": "admin456",
            "guest789key": "guest789"
        }
        
        # Create middleware
        logging_mw = LoggingMiddleware()
        auth_mw = AuthenticationMiddleware(api_keys)
        authz_mw = AuthorizationMiddleware()
        rate_limit_mw = RateLimitingMiddleware(requests_per_minute=10)
        cache_mw = CachingMiddleware()
        compression_mw = CompressionMiddleware()
        
        # Build the chain
        logging_mw.set_next(auth_mw).set_next(authz_mw).set_next(rate_limit_mw).set_next(cache_mw).set_next(compression_mw)
        
        self.middleware_chain = logging_mw
    
    def handle_request(self, method: str, path: str, headers: Dict[str, str], body: str = "") -> HTTPResponse:
        request = HTTPRequest(method, path, headers, body)
        response = HTTPResponse()
        
        # Start the middleware chain
        if self.middleware_chain:
            self.middleware_chain.handle(request, response)
        
        # If chain completed without being stopped, call the final handler
        if response.status_code == 200 and not response.body:
            self.request_handler.handle(request, response)
        
        return response

# Demo function
def middlewarePipelineDemo():
    print("=== Chain of Responsibility Pattern - Middleware Pipeline ===\n")
    
    server = WebServer()
    
    # Test headers
    user_headers = {
        'X-API-Key': 'user123key',
        'Accept-Encoding': 'gzip',
        'User-Agent': 'DemoClient/1.0'
    }
    
    admin_headers = {
        'X-API-Key': 'admin456key',
        'User-Agent': 'AdminClient/1.0'
    }
    
    invalid_headers = {
        'X-API-Key': 'invalidkey',
        'User-Agent': 'HackerBot/1.0'
    }
    
    print("--- Test 1: User Accessing Their Profile ---")
    response = server.handle_request('GET', '/api/users/me', user_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Test 2: Admin Accessing Stats ---")
    response = server.handle_request('GET', '/api/admin/stats', admin_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Test 3: Unauthenticated Access ---")
    response = server.handle_request('GET', '/api/users/me', {})
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Test 4: Invalid API Key ---")
    response = server.handle_request('GET', '/api/users/me', invalid_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Test 5: User Trying to Access Admin Area ---")
    response = server.handle_request('GET', '/api/admin/stats', user_headers)
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Test 6: Public Endpoint (No Auth Required) ---")
    response = server.handle_request('GET', '/api/public/info', {})
    print(f"Response: {response.status_code} - {response.body}\n")
    
    print("--- Test 7: Caching Behavior ---")
    print("First request (should cache):")
    response1 = server.handle_request('GET', '/api/users/me', user_headers)
    print(f"Response: {response1.status_code} - X-Cache: {response1.headers.get('X-Cache', 'None')}\n")
    
    print("Second request (should be cached):")
    response2 = server.handle_request('GET', '/api/users/me', user_headers)
    print(f"Response: {response2.status_code} - X-Cache: {response2.headers.get('X-Cache', 'None')}\n")

if __name__ == "__main__":
    middlewarePipelineDemo()
```

#### Support Ticket System

```python
from abc import ABC, abstractmethod
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
import uuid

class TicketPriority(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"
    CRITICAL = "critical"

class TicketType(Enum):
    BILLING = "billing"
    TECHNICAL = "technical"
    SALES = "sales"
    GENERAL = "general"
    FEEDBACK = "feedback"

class SupportTicket:
    def __init__(self, customer_id: str, customer_name: str, issue: str, 
                 priority: TicketPriority, ticket_type: TicketType):
        self.ticket_id = str(uuid.uuid4())[:8]
        self.customer_id = customer_id
        self.customer_name = customer_name
        self.issue = issue
        self.priority = priority
        self.ticket_type = ticket_type
        self.created_at = datetime.now()
        self.assigned_agent: Optional[str] = None
        self.status = "new"
        self.resolution: Optional[str] = None
        self.history: List[Dict[str, Any]] = []
        
        self._add_history("Ticket created")
    
    def _add_history(self, event: str, agent: str = "System"):
        self.history.append({
            'timestamp': datetime.now(),
            'event': event,
            'agent': agent
        })
    
    def assign(self, agent: str):
        self.assigned_agent = agent
        self._add_history(f"Assigned to {agent}", "System")
    
    def resolve(self, resolution: str, agent: str):
        self.resolution = resolution
        self.status = "resolved"
        self._add_history(f"Resolved: {resolution}", agent)
    
    def __str__(self):
        return f"Ticket #{self.ticket_id} - {self.priority.value} - {self.ticket_type.value}"

# Support Handler Interface
class SupportHandler(ABC):
    def __init__(self):
        self.next_handler: Optional['SupportHandler'] = None
    
    def set_next(self, handler: 'SupportHandler') -> 'SupportHandler':
        self.next_handler = handler
        return handler
    
    @abstractmethod
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        """
        Handle the support ticket.
        Return True if handled, False to pass to next handler.
        """
        pass
    
    def _pass_to_next(self, ticket: SupportTicket) -> bool:
        """Pass the ticket to the next handler in the chain"""
        if self.next_handler:
            return self.next_handler.handle_ticket(ticket)
        return False

# Concrete Handlers
class AutoResponderHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        print("🤖 Auto-responder processing ticket...")
        
        # Auto-respond to certain ticket types
        auto_responses = {
            TicketType.FEEDBACK: "Thank you for your feedback! We'll review it carefully.",
            TicketType.GENERAL: "Thank you for contacting support. We'll get back to you soon.",
        }
        
        if ticket.ticket_type in auto_responses:
            print(f"✅ Auto-responded to {ticket.ticket_type.value} ticket")
            ticket._add_history(f"Auto-responded: {auto_responses[ticket.ticket_type]}")
            return True
        
        return self._pass_to_next(ticket)

class KnowledgeBaseHandler(SupportHandler):
    def __init__(self):
        super().__init__()
        self.solutions = {
            "password reset": "You can reset your password using the 'Forgot Password' link on the login page.",
            "billing issue": "Please check our billing FAQ or contact our billing department.",
            "login problem": "Try clearing your browser cache or using a different browser.",
            "service down": "We're aware of the issue and working on a fix. Check our status page for updates."
        }
    
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        print("📚 Checking knowledge base...")
        
        issue_lower = ticket.issue.lower()
        
        for keyword, solution in self.solutions.items():
            if keyword in issue_lower:
                print(f"✅ Found solution in knowledge base for: {keyword}")
                ticket._add_history(f"Knowledge base solution provided: {solution}")
                ticket.resolve(f"Auto-resolved via knowledge base: {solution}", "KnowledgeBase")
                return True
        
        return self._pass_to_next(ticket)

class BillingSpecialistHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        if ticket.ticket_type != TicketType.BILLING:
            return self._pass_to_next(ticket)
        
        print("💳 Billing specialist processing ticket...")
        
        # Billing specialists handle all billing tickets
        if ticket.priority in [TicketPriority.LOW, TicketPriority.MEDIUM]:
            ticket.assign("Billing_Agent_1")
            print("✅ Assigned to billing agent")
        else:
            ticket.assign("Senior_Billing_Agent")
            print("✅ Assigned to senior billing agent")
        
        ticket._add_history("Handled by billing specialist")
        return True

class TechnicalSpecialistHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        if ticket.ticket_type != TicketType.TECHNICAL:
            return self._pass_to_next(ticket)
        
        print("🔧 Technical specialist processing ticket...")
        
        # Route based on priority and complexity
        if "urgent" in ticket.issue.lower() or ticket.priority in [TicketPriority.URGENT, TicketPriority.CRITICAL]:
            ticket.assign("Senior_Tech_Support")
            print("✅ Assigned to senior technical support (urgent)")
        elif "complex" in ticket.issue.lower() or "advanced" in ticket.issue.lower():
            ticket.assign("Technical_Specialist")
            print("✅ Assigned to technical specialist")
        else:
            ticket.assign("Tech_Support_1")
            print("✅ Assigned to general technical support")
        
        ticket._add_history("Handled by technical specialist")
        return True

class SalesSupportHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        if ticket.ticket_type != TicketType.SALES:
            return self._pass_to_next(ticket)
        
        print("💰 Sales support processing ticket...")
        
        # Sales handles all sales inquiries
        ticket.assign("Sales_Representative")
        ticket._add_history("Handled by sales support")
        print("✅ Assigned to sales representative")
        return True

class EscalationManagerHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        print("👨‍💼 Escalation manager reviewing ticket...")
        
        # Escalate high priority tickets
        if ticket.priority in [TicketPriority.URGENT, TicketPriority.CRITICAL]:
            ticket.assign("Senior_Manager")
            print("🚨 Escalated to senior manager")
            ticket._add_history("Escalated to senior manager")
            return True
        
        # Handle VIP customers
        if ticket.customer_id.startswith("VIP"):
            ticket.assign("VIP_Support")
            print("⭐ VIP customer - assigned to VIP support")
            ticket._add_history("Assigned to VIP support (VIP customer)")
            return True
        
        return self._pass_to_next(ticket)

class GeneralSupportHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        print("👥 General support handling ticket...")
        
        # General support handles everything else
        if not ticket.assigned_agent:
            ticket.assign("General_Support_Agent")
            print("✅ Assigned to general support agent")
        
        ticket._add_history("Handled by general support")
        return True

class UnhandledTicketHandler(SupportHandler):
    def handle_ticket(self, ticket: SupportTicket) -> bool:
        print("❓ Ticket could not be handled by any specialist")
        ticket.assign("Support_Manager")
        ticket._add_history("Escalated to support manager (unhandled)")
        return True

# Support Ticket System
class SupportTicketSystem:
    def __init__(self):
        self.handler_chain: Optional[SupportHandler] = None
        self._build_handler_chain()
    
    def _build_handler_chain(self):
        # Create all handlers
        auto_responder = AutoResponderHandler()
        knowledge_base = KnowledgeBaseHandler()
        billing_specialist = BillingSpecialistHandler()
        technical_specialist = TechnicalSpecialistHandler()
        sales_support = SalesSupportHandler()
        escalation_manager = EscalationManagerHandler()
        general_support = GeneralSupportHandler()
        unhandled_handler = UnhandledTicketHandler()
        
        # Build the chain
        auto_responder.set_next(knowledge_base) \
                     .set_next(billing_specialist) \
                     .set_next(technical_specialist) \
                     .set_next(sales_support) \
                     .set_next(escalation_manager) \
                     .set_next(general_support) \
                     .set_next(unhandled_handler)
        
        self.handler_chain = auto_responder
    
    def submit_ticket(self, customer_id: str, customer_name: str, issue: str, 
                     priority: TicketPriority, ticket_type: TicketType) -> SupportTicket:
        ticket = SupportTicket(customer_id, customer_name, issue, priority, ticket_type)
        
        print(f"\n🎫 New Support Ticket: {ticket}")
        print(f"   Customer: {customer_name} ({customer_id})")
        print(f"   Issue: {issue}")
        print(f"   Type: {ticket_type.value}, Priority: {priority.value}")
        
        # Process through handler chain
        if self.handler_chain:
            self.handler_chain.handle_ticket(ticket)
        
        print(f"📋 Final Assignment: {ticket.assigned_agent}")
        return ticket
    
    def display_ticket_info(self, ticket: SupportTicket):
        print(f"\n=== Ticket #{ticket.ticket_id} ===")
        print(f"Customer: {ticket.customer_name}")
        print(f"Status: {ticket.status}")
        print(f"Assigned to: {ticket.assigned_agent}")
        print(f"Priority: {ticket.priority.value}")
        print(f"Type: {ticket.ticket_type.value}")
        print(f"Created: {ticket.created_at}")
        
        if ticket.resolution:
            print(f"Resolution: {ticket.resolution}")
        
        print(f"\nHistory:")
        for event in ticket.history:
            print(f"  {event['timestamp'].strftime('%H:%M:%S')} - {event['event']}")

# Demo function
def supportSystemDemo():
    print("=== Chain of Responsibility Pattern - Support Ticket System ===\n")
    
    support_system = SupportTicketSystem()
    
    print("--- Test 1: Technical Issue ---")
    ticket1 = support_system.submit_ticket(
        "USER001", "John Doe", 
        "I can't login to my account, getting error message",
        TicketPriority.HIGH, TicketType.TECHNICAL
    )
    support_system.display_ticket_info(ticket1)
    
    print("\n--- Test 2: Billing Question ---")
    ticket2 = support_system.submit_ticket(
        "USER002", "Jane Smith",
        "I was charged twice for my subscription this month",
        TicketPriority.MEDIUM, TicketType.BILLING
    )
    support_system.display_ticket_info(ticket2)
    
    print("\n--- Test 3: Sales Inquiry ---")
    ticket3 = support_system.submit_ticket(
        "USER003", "Bob Wilson",
        "I'm interested in your enterprise plan, can you send me pricing?",
        TicketPriority.LOW, TicketType.SALES
    )
    support_system.display_ticket_info(ticket3)
    
    print("\n--- Test 4: Feedback ---")
    ticket4 = support_system.submit_ticket(
        "USER004", "Alice Brown",
        "I love your product! Here are some suggestions for improvement",
        TicketPriority.LOW, TicketType.FEEDBACK
    )
    support_system.display_ticket_info(ticket4)
    
    print("\n--- Test 5: VIP Customer ---")
    ticket5 = support_system.submit_ticket(
        "VIP001", "VIP Customer",
        "I need help with advanced configuration",
        TicketPriority.MEDIUM, TicketType.TECHNICAL
    )
    support_system.display_ticket_info(ticket5)
    
    print("\n--- Test 6: Critical System Issue ---")
    ticket6 = support_system.submit_ticket(
        "USER005", "System Admin",
        "Production system is down, urgent help needed!",
        TicketPriority.CRITICAL, TicketType.TECHNICAL
    )
    support_system.display_ticket_info(ticket6)
    
    print("\n--- Test 7: Knowledge Base Resolution ---")
    ticket7 = support_system.submit_ticket(
        "USER006", "New User",
        "How do I reset my password? I forgot it",
        TicketPriority.LOW, TicketType.TECHNICAL
    )
    support_system.display_ticket_info(ticket7)

if __name__ == "__main__":
    supportSystemDemo()
```

## Advantages and Disadvantages

### Advantages

- **Loose Coupling**: Senders don't know which handler will process the request
- **Flexibility**: Handlers can be added or removed dynamically
- **Single Responsibility**: Each handler has a single specific responsibility
- **Dynamic Processing**: The chain can be configured at runtime

### Disadvantages

- **No Guarantee**: There's no guarantee that a request will be handled
- **Performance**: Can impact performance if the chain is too long
- **Debugging**: Can be difficult to debug and trace through the chain
- **Complexity**: May add unnecessary complexity for simple processing

## Best Practices

1. **Keep Handlers Focused**: Each handler should have a single, well-defined responsibility
2. **Set Reasonable Chain Length**: Avoid creating chains that are too long
3. **Provide Fallback**: Always have a default handler at the end of the chain
4. **Monitor Performance**: Be aware of the performance impact of long chains
5. **Use for Appropriate Scenarios**: Use when multiple objects should handle a request independently

## Chain of Responsibility vs Other Patterns

- **vs Decorator**: Chain of Responsibility passes requests along a chain, Decorator adds responsibilities dynamically
- **vs Command**: Chain of Responsibility handles requests through a chain, Command encapsulates requests as objects
- **vs Strategy**: Chain of Responsibility uses multiple handlers, Strategy uses different algorithms
- **vs Observer**: Chain of Responsibility processes requests sequentially, Observer notifies all observers simultaneously

The Chain of Responsibility pattern is particularly useful in scenarios where multiple objects should have the opportunity to handle a request, and you want to decouple the sender from the receiver. It's widely used in event handling systems, middleware pipelines, and approval workflows.
