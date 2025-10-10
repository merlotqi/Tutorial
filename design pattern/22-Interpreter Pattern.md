# Interpreter Pattern

## Introduction

The Interpreter Pattern is a behavioral design pattern that defines a grammatical representation for a language and provides an interpreter to interpret sentences in that language. It's used to define a language's grammar and provide an interpreter to evaluate expressions in the language.

### Key Characteristics

- **Grammar Definition**: Defines a grammar for a simple language
- **Expression Evaluation**: Provides way to evaluate language expressions
- **Abstract Syntax Tree**: Uses abstract syntax tree to represent expressions
- **Extensible**: Easy to extend with new expressions

### Use Cases

- SQL parsing and interpretation
- Regular expression engines
- Mathematical expression evaluators
- Domain Specific Languages (DSLs)
- Configuration file parsers
- Rule engines

## Implementation Examples

### C++ Implementation

#### Mathematical Expression Evaluator

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>
#include <sstream>
#include <cmath>
#include <stdexcept>

// Abstract Expression
class Expression {
public:
    virtual ~Expression() = default;
    virtual double interpret() = 0;
    virtual std::string toString() const = 0;
};

// Terminal Expressions
class Number : public Expression {
private:
    double value;

public:
    Number(double val) : value(val) {}
    
    double interpret() override {
        return value;
    }
    
    std::string toString() const override {
        return std::to_string(value);
    }
};

class Variable : public Expression {
private:
    std::string name;
    std::unordered_map<std::string, double>& context;

public:
    Variable(const std::string& varName, std::unordered_map<std::string, double>& ctx)
        : name(varName), context(ctx) {}
    
    double interpret() override {
        if (context.find(name) != context.end()) {
            return context[name];
        }
        throw std::runtime_error("Undefined variable: " + name);
    }
    
    std::string toString() const override {
        return name;
    }
};

// Non-terminal Expressions
class AddExpression : public Expression {
private:
    std::shared_ptr<Expression> left;
    std::shared_ptr<Expression> right;

public:
    AddExpression(std::shared_ptr<Expression> l, std::shared_ptr<Expression> r)
        : left(l), right(r) {}
    
    double interpret() override {
        return left->interpret() + right->interpret();
    }
    
    std::string toString() const override {
        return "(" + left->toString() + " + " + right->toString() + ")";
    }
};

class SubtractExpression : public Expression {
private:
    std::shared_ptr<Expression> left;
    std::shared_ptr<Expression> right;

public:
    SubtractExpression(std::shared_ptr<Expression> l, std::shared_ptr<Expression> r)
        : left(l), right(r) {}
    
    double interpret() override {
        return left->interpret() - right->interpret();
    }
    
    std::string toString() const override {
        return "(" + left->toString() + " - " + right->toString() + ")";
    }
};

class MultiplyExpression : public Expression {
private:
    std::shared_ptr<Expression> left;
    std::shared_ptr<Expression> right;

public:
    MultiplyExpression(std::shared_ptr<Expression> l, std::shared_ptr<Expression> r)
        : left(l), right(r) {}
    
    double interpret() override {
        return left->interpret() * right->interpret();
    }
    
    std::string toString() const override {
        return "(" + left->toString() + " * " + right->toString() + ")";
    }
};

class DivideExpression : public Expression {
private:
    std::shared_ptr<Expression> left;
    std::shared_ptr<Expression> right;

public:
    DivideExpression(std::shared_ptr<Expression> l, std::shared_ptr<Expression> r)
        : left(l), right(r) {}
    
    double interpret() override {
        double divisor = right->interpret();
        if (divisor == 0) {
            throw std::runtime_error("Division by zero");
        }
        return left->interpret() / divisor;
    }
    
    std::string toString() const override {
        return "(" + left->toString() + " / " + right->toString() + ")";
    }
};

class PowerExpression : public Expression {
private:
    std::shared_ptr<Expression> base;
    std::shared_ptr<Expression> exponent;

public:
    PowerExpression(std::shared_ptr<Expression> b, std::shared_ptr<Expression> e)
        : base(b), exponent(e) {}
    
    double interpret() override {
        return std::pow(base->interpret(), exponent->interpret());
    }
    
    std::string toString() const override {
        return "(" + base->toString() + " ^ " + exponent->toString() + ")";
    }
};

// Function Expressions
class SinExpression : public Expression {
private:
    std::shared_ptr<Expression> argument;

public:
    SinExpression(std::shared_ptr<Expression> arg) : argument(arg) {}
    
    double interpret() override {
        return std::sin(argument->interpret());
    }
    
    std::string toString() const override {
        return "sin(" + argument->toString() + ")";
    }
};

class CosExpression : public Expression {
private:
    std::shared_ptr<Expression> argument;

public:
    CosExpression(std::shared_ptr<Expression> arg) : argument(arg) {}
    
    double interpret() override {
        return std::cos(argument->interpret());
    }
    
    std::string toString() const override {
        return "cos(" + argument->toString() + ")";
    }
};

class SqrtExpression : public Expression {
private:
    std::shared_ptr<Expression> argument;

public:
    SqrtExpression(std::shared_ptr<Expression> arg) : argument(arg) {}
    
    double interpret() override {
        double value = argument->interpret();
        if (value < 0) {
            throw std::runtime_error("Square root of negative number");
        }
        return std::sqrt(value);
    }
    
    std::string toString() const override {
        return "sqrt(" + argument->toString() + ")";
    }
};

// Parser for mathematical expressions
class ExpressionParser {
private:
    std::string expression;
    size_t position;
    std::unordered_map<std::string, double>& context;

    void skipWhitespace() {
        while (position < expression.length() && std::isspace(expression[position])) {
            position++;
        }
    }

    char peek() {
        skipWhitespace();
        if (position < expression.length()) {
            return expression[position];
        }
        return '\0';
    }

    char consume() {
        skipWhitespace();
        if (position < expression.length()) {
            return expression[position++];
        }
        return '\0';
    }

    std::shared_ptr<Expression> parsePrimary() {
        skipWhitespace();
        
        if (peek() == '(') {
            consume(); // '('
            auto expr = parseExpression();
            if (consume() != ')') {
                throw std::runtime_error("Expected ')'");
            }
            return expr;
        }
        
        if (std::isdigit(peek()) || peek() == '.') {
            return parseNumber();
        }
        
        if (std::isalpha(peek())) {
            std::string identifier = parseIdentifier();
            
            // Check if it's a function
            if (peek() == '(') {
                return parseFunction(identifier);
            }
            
            // It's a variable
            return std::make_shared<Variable>(identifier, context);
        }
        
        throw std::runtime_error("Unexpected character: " + std::string(1, peek()));
    }

    std::shared_ptr<Expression> parseNumber() {
        std::string numberStr;
        while (position < expression.length() && 
               (std::isdigit(expression[position]) || expression[position] == '.')) {
            numberStr += expression[position++];
        }
        return std::make_shared<Number>(std::stod(numberStr));
    }

    std::string parseIdentifier() {
        std::string identifier;
        while (position < expression.length() && 
               (std::isalnum(expression[position]) || expression[position] == '_')) {
            identifier += expression[position++];
        }
        return identifier;
    }

    std::shared_ptr<Expression> parseFunction(const std::string& funcName) {
        consume(); // '('
        auto argument = parseExpression();
        if (consume() != ')') {
            throw std::runtime_error("Expected ')' after function argument");
        }
        
        if (funcName == "sin") {
            return std::make_shared<SinExpression>(argument);
        } else if (funcName == "cos") {
            return std::make_shared<CosExpression>(argument);
        } else if (funcName == "sqrt") {
            return std::make_shared<SqrtExpression>(argument);
        } else {
            throw std::runtime_error("Unknown function: " + funcName);
        }
    }

    std::shared_ptr<Expression> parsePower() {
        auto left = parsePrimary();
        
        while (peek() == '^') {
            consume(); // '^'
            auto right = parsePrimary();
            left = std::make_shared<PowerExpression>(left, right);
        }
        
        return left;
    }

    std::shared_ptr<Expression> parseTerm() {
        auto left = parsePower();
        
        while (true) {
            if (peek() == '*') {
                consume(); // '*'
                auto right = parsePower();
                left = std::make_shared<MultiplyExpression>(left, right);
            } else if (peek() == '/') {
                consume(); // '/'
                auto right = parsePower();
                left = std::make_shared<DivideExpression>(left, right);
            } else {
                break;
            }
        }
        
        return left;
    }

    std::shared_ptr<Expression> parseExpression() {
        auto left = parseTerm();
        
        while (true) {
            if (peek() == '+') {
                consume(); // '+'
                auto right = parseTerm();
                left = std::make_shared<AddExpression>(left, right);
            } else if (peek() == '-') {
                consume(); // '-'
                auto right = parseTerm();
                left = std::make_shared<SubtractExpression>(left, right);
            } else {
                break;
            }
        }
        
        return left;
    }

public:
    ExpressionParser(const std::string& expr, std::unordered_map<std::string, double>& ctx)
        : expression(expr), position(0), context(ctx) {}
    
    std::shared_ptr<Expression> parse() {
        auto result = parseExpression();
        if (position < expression.length()) {
            throw std::runtime_error("Unexpected characters at end of expression");
        }
        return result;
    }
};

// Mathematical Expression Evaluator
class MathEvaluator {
private:
    std::unordered_map<std::string, double> context;

public:
    void setVariable(const std::string& name, double value) {
        context[name] = value;
    }
    
    double evaluate(const std::string& expression) {
        try {
            ExpressionParser parser(expression, context);
            auto expr = parser.parse();
            std::cout << "Expression: " << expr->toString() << std::endl;
            return expr->interpret();
        } catch (const std::exception& e) {
            std::cout << "Error: " << e.what() << std::endl;
            throw;
        }
    }
};

// Demo function
void mathExpressionDemo() {
    std::cout << "=== Interpreter Pattern - Mathematical Expression Evaluator ===\n" << std::endl;
    
    MathEvaluator evaluator;
    
    // Set some variables
    evaluator.setVariable("x", 5.0);
    evaluator.setVariable("y", 3.0);
    evaluator.setVariable("pi", 3.14159);
    
    // Test expressions
    std::vector<std::string> expressions = {
        "2 + 3",
        "x + y",
        "x * y - 2",
        "(x + y) * 2",
        "x ^ y",
        "sin(pi / 2)",
        "cos(0)",
        "sqrt(16)",
        "2 * x + 3 * y - 1",
        "sin(pi) + cos(0)"
    };
    
    for (const auto& expr : expressions) {
        try {
            std::cout << "Evaluating: " << expr << std::endl;
            double result = evaluator.evaluate(expr);
            std::cout << "Result: " << result << "\n" << std::endl;
        } catch (const std::exception& e) {
            std::cout << "Failed to evaluate: " << expr << "\n" << std::endl;
        }
    }
}

int main() {
    mathExpressionDemo();
    return 0;
}
```

#### SQL WHERE Clause Interpreter

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>

// Database Record
struct Record {
    std::unordered_map<std::string, std::string> fields;
    
    Record(std::initializer_list<std::pair<std::string, std::string>> init) {
        for (const auto& pair : init) {
            fields[pair.first] = pair.second;
        }
    }
    
    std::string getField(const std::string& fieldName) const {
        auto it = fields.find(fieldName);
        if (it != fields.end()) {
            return it->second;
        }
        return "";
    }
};

// Abstract Expression for SQL Conditions
class SQLExpression {
public:
    virtual ~SQLExpression() = default;
    virtual bool evaluate(const Record& record) const = 0;
    virtual std::string toString() const = 0;
};

// Terminal Expressions
class FieldExpression : public SQLExpression {
private:
    std::string fieldName;

public:
    FieldExpression(const std::string& field) : fieldName(field) {}
    
    bool evaluate(const Record& record) const override {
        return !record.getField(fieldName).empty();
    }
    
    std::string toString() const override {
        return fieldName;
    }
};

class ConstantExpression : public SQLExpression {
private:
    std::string value;

public:
    ConstantExpression(const std::string& val) : value(val) {}
    
    bool evaluate(const Record& record) const override {
        return true; // Constants always exist
    }
    
    std::string toString() const override {
        return "'" + value + "'";
    }
    
    const std::string& getValue() const { return value; }
};

// Comparison Expressions
class EqualsExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    EqualsExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        auto leftField = std::dynamic_pointer_cast<FieldExpression>(left);
        auto rightConst = std::dynamic_pointer_cast<ConstantExpression>(right);
        
        if (leftField && rightConst) {
            return record.getField(leftField->toString()) == rightConst->getValue();
        }
        return false;
    }
    
    std::string toString() const override {
        return left->toString() + " = " + right->toString();
    }
};

class NotEqualsExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    NotEqualsExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        auto leftField = std::dynamic_pointer_cast<FieldExpression>(left);
        auto rightConst = std::dynamic_pointer_cast<ConstantExpression>(right);
        
        if (leftField && rightConst) {
            return record.getField(leftField->toString()) != rightConst->getValue();
        }
        return false;
    }
    
    std::string toString() const override {
        return left->toString() + " != " + right->toString();
    }
};

class GreaterThanExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    GreaterThanExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        auto leftField = std::dynamic_pointer_cast<FieldExpression>(left);
        auto rightConst = std::dynamic_pointer_cast<ConstantExpression>(right);
        
        if (leftField && rightConst) {
            return record.getField(leftField->toString()) > rightConst->getValue();
        }
        return false;
    }
    
    std::string toString() const override {
        return left->toString() + " > " + right->toString();
    }
};

class LessThanExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    LessThanExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        auto leftField = std::dynamic_pointer_cast<FieldExpression>(left);
        auto rightConst = std::dynamic_pointer_cast<ConstantExpression>(right);
        
        if (leftField && rightConst) {
            return record.getField(leftField->toString()) < rightConst->getValue();
        }
        return false;
    }
    
    std::string toString() const override {
        return left->toString() + " < " + right->toString();
    }
};

class LikeExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    LikeExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        auto leftField = std::dynamic_pointer_cast<FieldExpression>(left);
        auto rightConst = std::dynamic_pointer_cast<ConstantExpression>(right);
        
        if (leftField && rightConst) {
            std::string fieldValue = record.getField(leftField->toString());
            std::string pattern = rightConst->getValue();
            
            // Simple LIKE implementation (supports % wildcard)
            if (pattern.find('%') == std::string::npos) {
                return fieldValue == pattern;
            }
            
            // Convert SQL LIKE pattern to simpler matching
            if (pattern.front() == '%' && pattern.back() == '%') {
                std::string search = pattern.substr(1, pattern.length() - 2);
                return fieldValue.find(search) != std::string::npos;
            } else if (pattern.front() == '%') {
                std::string search = pattern.substr(1);
                return fieldValue.size() >= search.size() && 
                       fieldValue.substr(fieldValue.size() - search.size()) == search;
            } else if (pattern.back() == '%') {
                std::string search = pattern.substr(0, pattern.length() - 1);
                return fieldValue.size() >= search.size() && 
                       fieldValue.substr(0, search.size()) == search;
            }
        }
        return false;
    }
    
    std::string toString() const override {
        return left->toString() + " LIKE " + right->toString();
    }
};

// Logical Expressions
class AndExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    AndExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        return left->evaluate(record) && right->evaluate(record);
    }
    
    std::string toString() const override {
        return "(" + left->toString() + " AND " + right->toString() + ")";
    }
};

class OrExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> left;
    std::shared_ptr<SQLExpression> right;

public:
    OrExpression(std::shared_ptr<SQLExpression> l, std::shared_ptr<SQLExpression> r)
        : left(l), right(r) {}
    
    bool evaluate(const Record& record) const override {
        return left->evaluate(record) || right->evaluate(record);
    }
    
    std::string toString() const override {
        return "(" + left->toString() + " OR " + right->toString() + ")";
    }
};

class NotExpression : public SQLExpression {
private:
    std::shared_ptr<SQLExpression> expression;

public:
    NotExpression(std::shared_ptr<SQLExpression> expr) : expression(expr) {}
    
    bool evaluate(const Record& record) const override {
        return !expression->evaluate(record);
    }
    
    std::string toString() const override {
        return "NOT " + expression->toString();
    }
};

// SQL WHERE Clause Parser (Simplified)
class SQLWhereParser {
private:
    std::string condition;
    size_t position;
    
    void skipWhitespace() {
        while (position < condition.length() && std::isspace(condition[position])) {
            position++;
        }
    }
    
    char peek() {
        skipWhitespace();
        if (position < condition.length()) {
            return condition[position];
        }
        return '\0';
    }
    
    char consume() {
        skipWhitespace();
        if (position < condition.length()) {
            return condition[position++];
        }
        return '\0';
    }
    
    std::string parseIdentifier() {
        std::string identifier;
        while (position < condition.length() && 
               (std::isalnum(condition[position]) || condition[position] == '_')) {
            identifier += condition[position++];
        }
        return identifier;
    }
    
    std::string parseStringLiteral() {
        if (consume() != '\'') {
            throw std::runtime_error("Expected string literal");
        }
        
        std::string literal;
        while (position < condition.length() && condition[position] != '\'') {
            literal += condition[position++];
        }
        
        if (consume() != '\'') {
            throw std::runtime_error("Unclosed string literal");
        }
        
        return literal;
    }
    
    std::shared_ptr<SQLExpression> parsePrimary() {
        skipWhitespace();
        
        if (peek() == '(') {
            consume(); // '('
            auto expr = parseExpression();
            if (consume() != ')') {
                throw std::runtime_error("Expected ')'");
            }
            return expr;
        }
        
        if (peek() == 'N' || peek() == 'n') {
            std::string keyword = parseIdentifier();
            if (keyword == "NOT" || keyword == "not") {
                auto expr = parsePrimary();
                return std::make_shared<NotExpression>(expr);
            }
            // If not NOT, treat as identifier
            return std::make_shared<FieldExpression>(keyword);
        }
        
        if (std::isalpha(peek())) {
            std::string identifier = parseIdentifier();
            return std::make_shared<FieldExpression>(identifier);
        }
        
        if (peek() == '\'') {
            std::string literal = parseStringLiteral();
            return std::make_shared<ConstantExpression>(literal);
        }
        
        throw std::runtime_error("Unexpected character in condition");
    }
    
    std::shared_ptr<SQLExpression> parseComparison() {
        auto left = parsePrimary();
        skipWhitespace();
        
        // Check for comparison operators
        if (position < condition.length() - 1) {
            std::string op;
            op += peek();
            if (std::string("=!<>").find(peek()) != std::string::npos) {
                op += consume();
                if (op == "=") {
                    auto right = parsePrimary();
                    return std::make_shared<EqualsExpression>(left, right);
                } else if (op == "!=" || op == "<>") {
                    auto right = parsePrimary();
                    return std::make_shared<NotEqualsExpression>(left, right);
                } else if (op == ">") {
                    auto right = parsePrimary();
                    return std::make_shared<GreaterThanExpression>(left, right);
                } else if (op == "<") {
                    auto right = parsePrimary();
                    return std::make_shared<LessThanExpression>(left, right);
                }
            } else if (peek() == 'L' || peek() == 'l') {
                std::string keyword = parseIdentifier();
                if (keyword == "LIKE" || keyword == "like") {
                    auto right = parsePrimary();
                    return std::make_shared<LikeExpression>(left, right);
                }
            }
        }
        
        return left;
    }
    
    std::shared_ptr<SQLExpression> parseAnd() {
        auto left = parseComparison();
        
        while (true) {
            skipWhitespace();
            if (position < condition.length() - 2 && 
                (condition[position] == 'A' || condition[position] == 'a')) {
                std::string keyword = parseIdentifier();
                if (keyword == "AND" || keyword == "and") {
                    auto right = parseComparison();
                    left = std::make_shared<AndExpression>(left, right);
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        
        return left;
    }
    
    std::shared_ptr<SQLExpression> parseExpression() {
        auto left = parseAnd();
        
        while (true) {
            skipWhitespace();
            if (position < condition.length() - 1 && 
                (condition[position] == 'O' || condition[position] == 'o')) {
                std::string keyword = parseIdentifier();
                if (keyword == "OR" || keyword == "or") {
                    auto right = parseAnd();
                    left = std::make_shared<OrExpression>(left, right);
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        
        return left;
    }

public:
    SQLWhereParser(const std::string& cond) : condition(cond), position(0) {}
    
    std::shared_ptr<SQLExpression> parse() {
        auto result = parseExpression();
        if (position < condition.length()) {
            throw std::runtime_error("Unexpected characters at end of condition");
        }
        return result;
    }
};

// Database Query Engine
class SimpleDatabase {
private:
    std::vector<Record> records;

public:
    void addRecord(const Record& record) {
        records.push_back(record);
    }
    
    std::vector<Record> query(const std::string& whereCondition) {
        std::vector<Record> results;
        
        try {
            SQLWhereParser parser(whereCondition);
            auto whereExpr = parser.parse();
            
            std::cout << "WHERE clause: " << whereExpr->toString() << std::endl;
            
            for (const auto& record : records) {
                if (whereExpr->evaluate(record)) {
                    results.push_back(record);
                }
            }
        } catch (const std::exception& e) {
            std::cout << "Query error: " << e.what() << std::endl;
        }
        
        return results;
    }
    
    void displayRecords(const std::vector<Record>& recordsToDisplay) {
        if (recordsToDisplay.empty()) {
            std::cout << "No records found." << std::endl;
            return;
        }
        
        for (size_t i = 0; i < recordsToDisplay.size(); ++i) {
            std::cout << "Record " << (i + 1) << ": ";
            for (const auto& field : recordsToDisplay[i].fields) {
                std::cout << field.first << "='" << field.second << "' ";
            }
            std::cout << std::endl;
        }
    }
};

// Demo function
void sqlWhereDemo() {
    std::cout << "=== Interpreter Pattern - SQL WHERE Clause Interpreter ===\n" << std::endl;
    
    SimpleDatabase db;
    
    // Add sample records
    db.addRecord(Record{{"id", "1"}, {"name", "John"}, {"age", "25"}, {"city", "New York"}});
    db.addRecord(Record{{"id", "2"}, {"name", "Alice"}, {"age", "30"}, {"city", "London"}});
    db.addRecord(Record{{"id", "3"}, {"name", "Bob"}, {"age", "25"}, {"city", "Paris"}});
    db.addRecord(Record{{"id", "4"}, {"name", "Charlie"}, {"age", "35"}, {"city", "New York"}});
    db.addRecord(Record{{"id", "5"}, {"name", "Diana"}, {"age", "28"}, {"city", "Tokyo"}});
    
    // Test queries
    std::vector<std::string> queries = {
        "age = '25'",
        "city = 'New York'",
        "age > '28'",
        "name LIKE 'A%'",
        "city = 'New York' AND age > '26'",
        "city = 'London' OR city = 'Paris'",
        "NOT city = 'New York'",
        "age != '25' AND name LIKE '%a%'"
    };
    
    for (const auto& query : queries) {
        std::cout << "\nQuery: WHERE " << query << std::endl;
        auto results = db.query(query);
        db.displayRecords(results);
        std::cout << "Found " << results.size() << " records" << std::endl;
    }
}

int main() {
    sqlWhereDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

// Boolean Expression Types
typedef enum {
    EXP_TRUE,
    EXP_FALSE,
    EXP_VAR,
    EXP_AND,
    EXP_OR,
    EXP_NOT
} ExpType;

// Boolean Expression Structure
typedef struct BooleanExp BooleanExp;
struct BooleanExp {
    ExpType type;
    char* variable;  // For EXP_VAR
    BooleanExp* left;  // For AND, OR
    BooleanExp* right; // For AND, OR
    BooleanExp* operand; // For NOT
};

// Context for variable values
typedef struct {
    char** variables;
    bool* values;
    int count;
} Context;

// Expression creation functions
BooleanExp* create_true() {
    BooleanExp* exp = malloc(sizeof(BooleanExp));
    exp->type = EXP_TRUE;
    exp->variable = NULL;
    exp->left = exp->right = exp->operand = NULL;
    return exp;
}

BooleanExp* create_false() {
    BooleanExp* exp = malloc(sizeof(BooleanExp));
    exp->type = EXP_FALSE;
    exp->variable = NULL;
    exp->left = exp->right = exp->operand = NULL;
    return exp;
}

BooleanExp* create_variable(const char* var) {
    BooleanExp* exp = malloc(sizeof(BooleanExp));
    exp->type = EXP_VAR;
    exp->variable = strdup(var);
    exp->left = exp->right = exp->operand = NULL;
    return exp;
}

BooleanExp* create_and(BooleanExp* left, BooleanExp* right) {
    BooleanExp* exp = malloc(sizeof(BooleanExp));
    exp->type = EXP_AND;
    exp->variable = NULL;
    exp->left = left;
    exp->right = right;
    exp->operand = NULL;
    return exp;
}

BooleanExp* create_or(BooleanExp* left, BooleanExp* right) {
    BooleanExp* exp = malloc(sizeof(BooleanExp));
    exp->type = EXP_OR;
    exp->variable = NULL;
    exp->left = left;
    exp->right = right;
    exp->operand = NULL;
    return exp;
}

BooleanExp* create_not(BooleanExp* operand) {
    BooleanExp* exp = malloc(sizeof(BooleanExp));
    exp->type = EXP_NOT;
    exp->variable = NULL;
    exp->left = exp->right = NULL;
    exp->operand = operand;
    return exp;
}

// Evaluation function
bool evaluate(BooleanExp* exp, Context* context) {
    switch (exp->type) {
        case EXP_TRUE:
            return true;
        case EXP_FALSE:
            return false;
        case EXP_VAR:
            for (int i = 0; i < context->count; i++) {
                if (strcmp(exp->variable, context->variables[i]) == 0) {
                    return context->values[i];
                }
            }
            return false; // Variable not found
        case EXP_AND:
            return evaluate(exp->left, context) && evaluate(exp->right, context);
        case EXP_OR:
            return evaluate(exp->left, context) || evaluate(exp->right, context);
        case EXP_NOT:
            return !evaluate(exp->operand, context);
        default:
            return false;
    }
}

// Expression printing
void print_expression(BooleanExp* exp) {
    switch (exp->type) {
        case EXP_TRUE:
            printf("TRUE");
            break;
        case EXP_FALSE:
            printf("FALSE");
            break;
        case EXP_VAR:
            printf("%s", exp->variable);
            break;
        case EXP_AND:
            printf("(");
            print_expression(exp->left);
            printf(" AND ");
            print_expression(exp->right);
            printf(")");
            break;
        case EXP_OR:
            printf("(");
            print_expression(exp->left);
            printf(" OR ");
            print_expression(exp->right);
            printf(")");
            break;
        case EXP_NOT:
            printf("NOT ");
            print_expression(exp->operand);
            break;
    }
}

// Free expression memory
void free_expression(BooleanExp* exp) {
    if (exp == NULL) return;
    
    switch (exp->type) {
        case EXP_VAR:
            free(exp->variable);
            break;
        case EXP_AND:
        case EXP_OR:
            free_expression(exp->left);
            free_expression(exp->right);
            break;
        case EXP_NOT:
            free_expression(exp->operand);
            break;
        default:
            break;
    }
    free(exp);
}

// Simple Parser for Boolean Expressions
BooleanExp* parse_expression(const char** input);

void skip_whitespace(const char** input) {
    while (**input && isspace(**input)) {
        (*input)++;
    }
}

char* parse_identifier(const char** input) {
    skip_whitespace(input);
    
    const char* start = *input;
    while (**input && (isalnum(**input) || **input == '_')) {
        (*input)++;
    }
    
    if (*input == start) return NULL;
    
    size_t length = *input - start;
    char* identifier = malloc(length + 1);
    strncpy(identifier, start, length);
    identifier[length] = '\0';
    
    return identifier;
}

BooleanExp* parse_primary(const char** input) {
    skip_whitespace(input);
    
    if (**input == '(') {
        (*input)++; // Skip '('
        BooleanExp* exp = parse_expression(input);
        skip_whitespace(input);
        if (**input == ')') {
            (*input)++; // Skip ')'
        }
        return exp;
    }
    
    if (strncmp(*input, "TRUE", 4) == 0) {
        *input += 4;
        return create_true();
    }
    
    if (strncmp(*input, "FALSE", 5) == 0) {
        *input += 5;
        return create_false();
    }
    
    if (strncmp(*input, "NOT", 3) == 0) {
        *input += 3;
        skip_whitespace(input);
        BooleanExp* operand = parse_primary(input);
        return create_not(operand);
    }
    
    char* identifier = parse_identifier(input);
    if (identifier) {
        return create_variable(identifier);
    }
    
    return create_false(); // Default for parsing errors
}

BooleanExp* parse_and(const char** input) {
    BooleanExp* left = parse_primary(input);
    
    while (true) {
        skip_whitespace(input);
        if (strncmp(*input, "AND", 3) == 0) {
            *input += 3;
            skip_whitespace(input);
            BooleanExp* right = parse_primary(input);
            left = create_and(left, right);
        } else {
            break;
        }
    }
    
    return left;
}

BooleanExp* parse_expression(const char** input) {
    BooleanExp* left = parse_and(input);
    
    while (true) {
        skip_whitespace(input);
        if (strncmp(*input, "OR", 2) == 0) {
            *input += 2;
            skip_whitespace(input);
            BooleanExp* right = parse_and(input);
            left = create_or(left, right);
        } else {
            break;
        }
    }
    
    return left;
}

BooleanExp* parse_boolean_expression(const char* input) {
    return parse_expression(&input);
}

// Context management
void init_context(Context* context) {
    context->variables = NULL;
    context->values = NULL;
    context->count = 0;
}

void set_variable(Context* context, const char* variable, bool value) {
    // Check if variable already exists
    for (int i = 0; i < context->count; i++) {
        if (strcmp(context->variables[i], variable) == 0) {
            context->values[i] = value;
            return;
        }
    }
    
    // Add new variable
    context->count++;
    context->variables = realloc(context->variables, sizeof(char*) * context->count);
    context->values = realloc(context->values, sizeof(bool) * context->count);
    
    context->variables[context->count - 1] = strdup(variable);
    context->values[context->count - 1] = value;
}

void free_context(Context* context) {
    for (int i = 0; i < context->count; i++) {
        free(context->variables[i]);
    }
    free(context->variables);
    free(context->values);
}

// Demo function
void booleanExpressionDemo() {
    printf("=== Interpreter Pattern - Boolean Expression Evaluator ===\n\n");
    
    Context context;
    init_context(&context);
    
    // Set some variable values
    set_variable(&context, "A", true);
    set_variable(&context, "B", false);
    set_variable(&context, "C", true);
    set_variable(&context, "D", false);
    
    // Test expressions
    const char* expressions[] = {
        "A AND B",
        "A OR B",
        "NOT A",
        "A AND B OR C",
        "A AND (B OR C)",
        "NOT A AND B",
        "A AND NOT B",
        "TRUE AND A",
        "FALSE OR A",
        "(A OR B) AND (C OR D)",
        "A AND B AND C AND D",
        "A OR B OR C OR D"
    };
    
    int num_expressions = sizeof(expressions) / sizeof(expressions[0]);
    
    for (int i = 0; i < num_expressions; i++) {
        printf("Expression %d: %s\n", i + 1, expressions[i]);
        
        BooleanExp* exp = parse_boolean_expression(expressions[i]);
        printf("Parsed: ");
        print_expression(exp);
        printf("\n");
        
        bool result = evaluate(exp, &context);
        printf("Result: %s\n\n", result ? "TRUE" : "FALSE");
        
        free_expression(exp);
    }
    
    free_context(&context);
}

int main() {
    booleanExpressionDemo();
    return 0;
}
```

### Python Implementation

#### Rule Engine

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, List, Union
from datetime import datetime, timedelta
import re

# Context for rule evaluation
class RuleContext:
    def __init__(self, data: Dict[str, Any]):
        self.data = data
        self.timestamp = datetime.now()
    
    def get_value(self, key: str, default: Any = None) -> Any:
        """Get value from context data with dot notation support"""
        keys = key.split('.')
        value = self.data
        
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        
        return value
    
    def __str__(self):
        return f"RuleContext({self.data})"

# Abstract Expression
class RuleExpression(ABC):
    @abstractmethod
    def evaluate(self, context: RuleContext) -> bool: ...
    
    @abstractmethod
    def __str__(self) -> str: ...

# Terminal Expressions
class TrueExpression(RuleExpression):
    def evaluate(self, context: RuleContext) -> bool:
        return True
    
    def __str__(self) -> str:
        return "TRUE"

class FalseExpression(RuleExpression):
    def evaluate(self, context: RuleContext) -> bool:
        return False
    
    def __str__(self) -> str:
        return "FALSE"

class FieldExpression(RuleExpression):
    def __init__(self, field_name: str):
        self.field_name = field_name
    
    def evaluate(self, context: RuleContext) -> bool:
        value = context.get_value(self.field_name)
        return bool(value)
    
    def __str__(self) -> str:
        return self.field_name

class ConstantExpression(RuleExpression):
    def __init__(self, value: Any):
        self.value = value
    
    def evaluate(self, context: RuleContext) -> bool:
        return bool(self.value)
    
    def __str__(self) -> str:
        return f"'{self.value}'"

# Comparison Expressions
class EqualsExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        left_val = self._get_value(self.left, context)
        right_val = self._get_value(self.right, context)
        return left_val == right_val
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} = {self.right})"

class GreaterThanExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        left_val = self._get_value(self.left, context)
        right_val = self._get_value(self.right, context)
        
        try:
            return float(left_val) > float(right_val)
        except (ValueError, TypeError):
            return str(left_val) > str(right_val)
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} > {self.right})"

class LessThanExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        left_val = self._get_value(self.left, context)
        right_val = self._get_value(self.right, context)
        
        try:
            return float(left_val) < float(right_val)
        except (ValueError, TypeError):
            return str(left_val) < str(right_val)
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} < {self.right})"

class ContainsExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        left_val = str(self._get_value(self.left, context))
        right_val = str(self._get_value(self.right, context))
        return right_val in left_val
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} contains {self.right})"

class RegexExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        left_val = str(self._get_value(self.left, context))
        right_val = str(self._get_value(self.right, context))
        
        try:
            return bool(re.search(right_val, left_val))
        except re.error:
            return False
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} matches {self.right})"

# Logical Expressions
class AndExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        return self.left.evaluate(context) and self.right.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} AND {self.right})"

class OrExpression(RuleExpression):
    def __init__(self, left: RuleExpression, right: RuleExpression):
        self.left = left
        self.right = right
    
    def evaluate(self, context: RuleContext) -> bool:
        return self.left.evaluate(context) or self.right.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.left} OR {self.right})"

class NotExpression(RuleExpression):
    def __init__(self, operand: RuleExpression):
        self.operand = operand
    
    def evaluate(self, context: RuleContext) -> bool:
        return not self.operand.evaluate(context)
    
    def __str__(self) -> str:
        return f"NOT {self.operand}"

# Date Expressions
class DateBeforeExpression(RuleExpression):
    def __init__(self, date_field: RuleExpression, target_date: RuleExpression):
        self.date_field = date_field
        self.target_date = target_date
    
    def evaluate(self, context: RuleContext) -> bool:
        date_str = str(self._get_value(self.date_field, context))
        target_str = str(self._get_value(self.target_date, context))
        
        try:
            date_val = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            target_val = datetime.fromisoformat(target_str.replace('Z', '+00:00'))
            return date_val < target_val
        except (ValueError, TypeError):
            return False
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.date_field} before {self.target_date})"

class DateAfterExpression(RuleExpression):
    def __init__(self, date_field: RuleExpression, target_date: RuleExpression):
        self.date_field = date_field
        self.target_date = target_date
    
    def evaluate(self, context: RuleContext) -> bool:
        date_str = str(self._get_value(self.date_field, context))
        target_str = str(self._get_value(self.target_date, context))
        
        try:
            date_val = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            target_val = datetime.fromisoformat(target_str.replace('Z', '+00:00'))
            return date_val > target_val
        except (ValueError, TypeError):
            return False
    
    def _get_value(self, expr: RuleExpression, context: RuleContext) -> Any:
        if isinstance(expr, FieldExpression):
            return context.get_value(expr.field_name)
        elif isinstance(expr, ConstantExpression):
            return expr.value
        else:
            return expr.evaluate(context)
    
    def __str__(self) -> str:
        return f"({self.date_field} after {self.target_date})"

# Rule Parser
class RuleParser:
    def __init__(self):
        self.operators = {
            'AND': (10, 'left'),
            'OR': (5, 'left'),
            '=': (20, 'left'),
            '>': (20, 'left'),
            '<': (20, 'left'),
            'contains': (20, 'left'),
            'matches': (20, 'left'),
            'before': (20, 'left'),
            'after': (20, 'left'),
            'NOT': (25, 'right')
        }
    
    def parse(self, rule_string: str) -> RuleExpression:
        """Parse a rule string into an expression tree"""
        tokens = self._tokenize(rule_string)
        return self._parse_expression(tokens)
    
    def _tokenize(self, rule_string: str) -> List[str]:
        """Convert rule string to tokens"""
        # Simple tokenization - in real implementation would be more sophisticated
        tokens = []
        current_token = ""
        
        for char in rule_string:
            if char.isspace():
                if current_token:
                    tokens.append(current_token)
                    current_token = ""
            elif char in '()':
                if current_token:
                    tokens.append(current_token)
                    current_token = ""
                tokens.append(char)
            else:
                current_token += char
        
        if current_token:
            tokens.append(current_token)
        
        return tokens
    
    def _parse_expression(self, tokens: List[str]) -> RuleExpression:
        """Parse tokens into expression tree using shunting yard algorithm"""
        output = []
        operators = []
        
        for token in tokens:
            if token == '(':
                operators.append(token)
            elif token == ')':
                while operators and operators[-1] != '(':
                    output.append(operators.pop())
                if operators and operators[-1] == '(':
                    operators.pop()
            elif token in self.operators:
                while (operators and operators[-1] != '(' and
                       self.operators[token][0] <= self.operators[operators[-1]][0]):
                    output.append(operators.pop())
                operators.append(token)
            else:
                # Handle field names and constants
                if token.startswith("'") and token.endswith("'"):
                    output.append(ConstantExpression(token[1:-1]))
                elif token.isdigit():
                    output.append(ConstantExpression(int(token)))
                elif token.replace('.', '').isdigit():
                    output.append(ConstantExpression(float(token)))
                else:
                    output.append(FieldExpression(token))
        
        while operators:
            output.append(operators.pop())
        
        return self._build_expression_tree(output)
    
    def _build_expression_tree(self, rpn_tokens: List[Any]) -> RuleExpression:
        """Build expression tree from Reverse Polish Notation tokens"""
        stack = []
        
        for token in rpn_tokens:
            if isinstance(token, RuleExpression):
                stack.append(token)
            elif token in self.operators:
                if token == 'NOT':
                    operand = stack.pop()
                    stack.append(NotExpression(operand))
                else:
                    right = stack.pop()
                    left = stack.pop()
                    
                    if token == 'AND':
                        stack.append(AndExpression(left, right))
                    elif token == 'OR':
                        stack.append(OrExpression(left, right))
                    elif token == '=':
                        stack.append(EqualsExpression(left, right))
                    elif token == '>':
                        stack.append(GreaterThanExpression(left, right))
                    elif token == '<':
                        stack.append(LessThanExpression(left, right))
                    elif token == 'contains':
                        stack.append(ContainsExpression(left, right))
                    elif token == 'matches':
                        stack.append(RegexExpression(left, right))
                    elif token == 'before':
                        stack.append(DateBeforeExpression(left, right))
                    elif token == 'after':
                        stack.append(DateAfterExpression(left, right))
        
        return stack[0] if stack else FalseExpression()

# Rule Engine
class RuleEngine:
    def __init__(self):
        self.parser = RuleParser()
        self.rules: Dict[str, RuleExpression] = {}
    
    def add_rule(self, name: str, rule_expression: str):
        """Add a rule to the engine"""
        try:
            self.rules[name] = self.parser.parse(rule_expression)
            print(f"✅ Rule '{name}' added: {self.rules[name]}")
        except Exception as e:
            print(f"❌ Failed to parse rule '{name}': {e}")
    
    def evaluate_rule(self, rule_name: str, context: RuleContext) -> bool:
        """Evaluate a rule against context"""
        if rule_name not in self.rules:
            raise ValueError(f"Rule '{rule_name}' not found")
        
        rule = self.rules[rule_name]
        result = rule.evaluate(context)
        
        print(f"🔍 Evaluating rule '{rule_name}': {rule}")
        print(f"   Context: {context.data}")
        print(f"   Result: {result}")
        
        return result
    
    def evaluate_all(self, context: RuleContext) -> Dict[str, bool]:
        """Evaluate all rules against context"""
        results = {}
        for rule_name in self.rules:
            results[rule_name] = self.evaluate_rule(rule_name, context)
        return results

# Demo function
def ruleEngineDemo():
    print("=== Interpreter Pattern - Rule Engine ===\n")
    
    engine = RuleEngine()
    
    # Define business rules
    rules = {
        "is_vip_customer": "customer_type = 'vip' AND total_purchases > 1000",
        "needs_approval": "order_amount > 5000 OR risk_score > 0.8",
        "free_shipping_eligible": "order_amount > 50 AND customer_type = 'premium'",
        "high_value_order": "order_amount > 10000",
        "suspicious_activity": "login_attempts > 5 AND last_login_country != registration_country",
        "expired_document": "document_expiry_date before '2024-01-01'",
        "valid_email": "email matches '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'",
        "complex_rule": "(customer_type = 'vip' AND order_amount > 500) OR (loyalty_years > 5 AND order_amount > 200)"
    }
    
    # Add rules to engine
    for name, expression in rules.items():
        engine.add_rule(name, expression)
    
    # Test contexts
    test_contexts = [
        # VIP customer with high purchase
        RuleContext({
            "customer_type": "vip",
            "total_purchases": 1500,
            "order_amount": 6000,
            "risk_score": 0.3,
            "login_attempts": 2,
            "last_login_country": "US",
            "registration_country": "US",
            "document_expiry_date": "2024-12-31",
            "email": "john@example.com",
            "loyalty_years": 3
        }),
        
        # New customer with suspicious activity
        RuleContext({
            "customer_type": "regular",
            "total_purchases": 100,
            "order_amount": 300,
            "risk_score": 0.9,
            "login_attempts": 8,
            "last_login_country": "RU",
            "registration_country": "US",
            "document_expiry_date": "2023-06-15",
            "email": "invalid-email",
            "loyalty_years": 0
        }),
        
        # Premium customer eligible for free shipping
        RuleContext({
            "customer_type": "premium",
            "total_purchases": 800,
            "order_amount": 75,
            "risk_score": 0.2,
            "login_attempts": 1,
            "last_login_country": "US",
            "registration_country": "US",
            "document_expiry_date": "2024-06-01",
            "email": "alice@company.com",
            "loyalty_years": 2
        })
    ]
    
    # Evaluate rules for each context
    for i, context in enumerate(test_contexts, 1):
        print(f"\n{'='*50}")
        print(f"Test Case {i}: {context}")
        print(f"{'='*50}")
        
        results = engine.evaluate_all(context)
        
        print(f"\n📊 Results for Test Case {i}:")
        for rule_name, result in results.items():
            status = "✅ PASS" if result else "❌ FAIL"
            print(f"  {rule_name}: {status}")
    
    # Test individual rule evaluation
    print(f"\n{'='*50}")
    print("Individual Rule Testing")
    print(f"{'='*50}")
    
    custom_context = RuleContext({
        "customer_type": "vip",
        "order_amount": 600,
        "loyalty_years": 6
    })
    
    engine.evaluate_rule("complex_rule", custom_context)

if __name__ == "__main__":
    ruleEngineDemo()
```

#### Domain Specific Language (DSL) for Workflow

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, List, Callable
from datetime import datetime, timedelta
import time

# Workflow Context
class WorkflowContext:
    def __init__(self, initial_data: Dict[str, Any] = None):
        self.data = initial_data or {}
        self.variables: Dict[str, Any] = {}
        self.execution_history: List[str] = []
        self.start_time = datetime.now()
    
    def set_variable(self, name: str, value: Any):
        self.variables[name] = value
        self.add_history(f"Set variable '{name}' = {value}")
    
    def get_variable(self, name: str, default: Any = None) -> Any:
        return self.variables.get(name, default)
    
    def update_data(self, key: str, value: Any):
        self.data[key] = value
    
    def get_data(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)
    
    def add_history(self, event: str):
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.execution_history.append(f"[{timestamp}] {event}")
    
    def get_history(self) -> List[str]:
        return self.execution_history
    
    def __str__(self):
        return f"WorkflowContext(variables={self.variables}, data={self.data})"

# Workflow Expression Interface
class WorkflowExpression(ABC):
    @abstractmethod
    def execute(self, context: WorkflowContext) -> Any: ...
    
    @abstractmethod
    def __str__(self) -> str: ...

# Primitive Expressions
class AssignExpression(WorkflowExpression):
    def __init__(self, variable: str, value_expression: WorkflowExpression):
        self.variable = variable
        self.value_expression = value_expression
    
    def execute(self, context: WorkflowContext) -> Any:
        value = self.value_expression.execute(context)
        context.set_variable(self.variable, value)
        return value
    
    def __str__(self) -> str:
        return f"{self.variable} = {self.value_expression}"

class ConstantExpression(WorkflowExpression):
    def __init__(self, value: Any):
        self.value = value
    
    def execute(self, context: WorkflowContext) -> Any:
        return self.value
    
    def __str__(self) -> str:
        return f"'{self.value}'" if isinstance(self.value, str) else str(self.value)

class VariableExpression(WorkflowExpression):
    def __init__(self, variable: str):
        self.variable = variable
    
    def execute(self, context: WorkflowContext) -> Any:
        return context.get_variable(self.variable)
    
    def __str__(self) -> str:
        return self.variable

# Arithmetic Expressions
class AddExpression(WorkflowExpression):
    def __init__(self, left: WorkflowExpression, right: WorkflowExpression):
        self.left = left
        self.right = right
    
    def execute(self, context: WorkflowContext) -> Any:
        left_val = self.left.execute(context)
        right_val = self.right.execute(context)
        
        try:
            return left_val + right_val
        except TypeError:
            return str(left_val) + str(right_val)
    
    def __str__(self) -> str:
        return f"({self.left} + {self.right})"

class MultiplyExpression(WorkflowExpression):
    def __init__(self, left: WorkflowExpression, right: WorkflowExpression):
        self.left = left
        self.right = right
    
    def execute(self, context: WorkflowContext) -> Any:
        left_val = self.left.execute(context)
        right_val = self.right.execute(context)
        return left_val * right_val
    
    def __str__(self) -> str:
        return f"({self.left} * {self.right})"

# Control Flow Expressions
class IfExpression(WorkflowExpression):
    def __init__(self, condition: WorkflowExpression, 
                 then_branch: WorkflowExpression, 
                 else_branch: WorkflowExpression = None):
        self.condition = condition
        self.then_branch = then_branch
        self.else_branch = else_branch
    
    def execute(self, context: WorkflowContext) -> Any:
        condition_result = self.condition.execute(context)
        
        if condition_result:
            context.add_history(f"IF condition true, executing THEN branch")
            return self.then_branch.execute(context)
        elif self.else_branch:
            context.add_history(f"IF condition false, executing ELSE branch")
            return self.else_branch.execute(context)
        
        return None
    
    def __str__(self) -> str:
        else_str = f" ELSE {self.else_branch}" if self.else_branch else ""
        return f"IF {self.condition} THEN {self.then_branch}{else_str}"

class WhileExpression(WorkflowExpression):
    def __init__(self, condition: WorkflowExpression, body: WorkflowExpression):
        self.condition = condition
        self.body = body
    
    def execute(self, context: WorkflowContext) -> Any:
        result = None
        iteration = 0
        
        while self.condition.execute(context):
            iteration += 1
            context.add_history(f"WHILE iteration {iteration}")
            result = self.body.execute(context)
            
            # Safety limit
            if iteration > 1000:
                context.add_history("WHILE loop terminated (safety limit)")
                break
        
        context.add_history(f"WHILE loop completed after {iteration} iterations")
        return result
    
    def __str__(self) -> str:
        return f"WHILE {self.condition} DO {self.body}"

# Comparison Expressions
class EqualsExpression(WorkflowExpression):
    def __init__(self, left: WorkflowExpression, right: WorkflowExpression):
        self.left = left
        self.right = right
    
    def execute(self, context: WorkflowContext) -> Any:
        left_val = self.left.execute(context)
        right_val = self.right.execute(context)
        return left_val == right_val
    
    def __str__(self) -> str:
        return f"({self.left} == {self.right})"

class GreaterThanExpression(WorkflowExpression):
    def __init__(self, left: WorkflowExpression, right: WorkflowExpression):
        self.left = left
        self.right = right
    
    def execute(self, context: WorkflowContext) -> Any:
        left_val = self.left.execute(context)
        right_val = self.right.execute(context)
        return left_val > right_val
    
    def __str__(self) -> str:
        return f"({self.left} > {self.right})"

# Action Expressions
class LogExpression(WorkflowExpression):
    def __init__(self, message_expression: WorkflowExpression):
        self.message_expression = message_expression
    
    def execute(self, context: WorkflowContext) -> Any:
        message = self.message_expression.execute(context)
        context.add_history(f"LOG: {message}")
        print(f"📝 {message}")
        return message
    
    def __str__(self) -> str:
        return f"LOG({self.message_expression})"

class WaitExpression(WorkflowExpression):
    def __init__(self, seconds_expression: WorkflowExpression):
        self.seconds_expression = seconds_expression
    
    def execute(self, context: WorkflowContext) -> Any:
        seconds = self.seconds_expression.execute(context)
        context.add_history(f"WAIT: {seconds} seconds")
        print(f"⏰ Waiting {seconds} seconds...")
        time.sleep(seconds)
        return seconds
    
    def __str__(self) -> str:
        return f"WAIT({self.seconds_expression})"

class SequenceExpression(WorkflowExpression):
    def __init__(self, expressions: List[WorkflowExpression]):
        self.expressions = expressions
    
    def execute(self, context: WorkflowContext) -> Any:
        result = None
        for expr in self.expressions:
            result = expr.execute(context)
        return result
    
    def __str__(self) -> str:
        return ";\n".join(str(expr) for expr in self.expressions)

# Workflow DSL Parser
class WorkflowParser:
    def __init__(self):
        self.variables = set()
    
    def parse(self, workflow_script: str) -> WorkflowExpression:
        """Parse workflow DSL script into expression tree"""
        lines = [line.strip() for line in workflow_script.split(';') if line.strip()]
        expressions = []
        
        for line in lines:
            expressions.append(self._parse_line(line))
        
        return SequenceExpression(expressions) if len(expressions) > 1 else expressions[0]
    
    def _parse_line(self, line: str) -> WorkflowExpression:
        """Parse a single line of workflow DSL"""
        line = line.strip()
        
        # Assignment
        if '=' in line and not line.startswith('IF') and not line.startswith('WHILE'):
            var, expr = line.split('=', 1)
            var = var.strip()
            value_expr = self._parse_expression(expr.strip())
            return AssignExpression(var, value_expr)
        
        # IF statement
        elif line.startswith('IF'):
            return self._parse_if_statement(line)
        
        # WHILE loop
        elif line.startswith('WHILE'):
            return self._parse_while_loop(line)
        
        # LOG statement
        elif line.startswith('LOG'):
            message = line[3:].strip().strip('()')
            message_expr = self._parse_expression(message)
            return LogExpression(message_expr)
        
        # WAIT statement
        elif line.startswith('WAIT'):
            seconds = line[4:].strip().strip('()')
            seconds_expr = self._parse_expression(seconds)
            return WaitExpression(seconds_expr)
        
        else:
            # Simple expression
            return self._parse_expression(line)
    
    def _parse_if_statement(self, line: str) -> WorkflowExpression:
        """Parse IF-THEN-ELSE statement"""
        # Remove IF prefix
        content = line[2:].strip()
        
        # Find THEN
        then_index = content.upper().find('THEN')
        if then_index == -1:
            raise ValueError("IF statement must have THEN clause")
        
        condition_str = content[:then_index].strip()
        rest = content[then_index + 4:].strip()
        
        # Find ELSE
        else_index = rest.upper().find('ELSE')
        
        if else_index != -1:
            then_str = rest[:else_index].strip()
            else_str = rest[else_index + 4:].strip()
            else_expr = self._parse_line(else_str)
        else:
            then_str = rest
            else_expr = None
        
        condition_expr = self._parse_expression(condition_str)
        then_expr = self._parse_line(then_str)
        
        return IfExpression(condition_expr, then_expr, else_expr)
    
    def _parse_while_loop(self, line: str) -> WorkflowExpression:
        """Parse WHILE-DO loop"""
        # Remove WHILE prefix
        content = line[5:].strip()
        
        # Find DO
        do_index = content.upper().find('DO')
        if do_index == -1:
            raise ValueError("WHILE loop must have DO clause")
        
        condition_str = content[:do_index].strip()
        body_str = content[do_index + 2:].strip()
        
        condition_expr = self._parse_expression(condition_str)
        body_expr = self._parse_line(body_str)
        
        return WhileExpression(condition_expr, body_expr)
    
    def _parse_expression(self, expr: str) -> WorkflowExpression:
        """Parse a general expression"""
        expr = expr.strip()
        
        # Constant string
        if expr.startswith("'") and expr.endswith("'"):
            return ConstantExpression(expr[1:-1])
        
        # Constant number
        elif expr.isdigit():
            return ConstantExpression(int(expr))
        elif expr.replace('.', '').isdigit():
            return ConstantExpression(float(expr))
        
        # Arithmetic operations
        elif '+' in expr:
            left, right = expr.split('+', 1)
            return AddExpression(
                self._parse_expression(left.strip()),
                self._parse_expression(right.strip())
            )
        
        # Comparison operations
        elif '==' in expr:
            left, right = expr.split('==', 1)
            return EqualsExpression(
                self._parse_expression(left.strip()),
                self._parse_expression(right.strip())
            )
        elif '>' in expr:
            left, right = expr.split('>', 1)
            return GreaterThanExpression(
                self._parse_expression(left.strip()),
                self._parse_expression(right.strip())
            )
        
        # Variable
        else:
            return VariableExpression(expr)

# Workflow Engine
class WorkflowEngine:
    def __init__(self):
        self.parser = WorkflowParser()
    
    def execute_workflow(self, workflow_script: str, initial_data: Dict[str, Any] = None) -> WorkflowContext:
        """Execute a workflow script"""
        context = WorkflowContext(initial_data)
        
        try:
            print("🚀 Starting workflow execution...")
            workflow_expr = self.parser.parse(workflow_script)
            print(f"📋 Parsed workflow: {workflow_expr}")
            
            result = workflow_expr.execute(context)
            
            print(f"✅ Workflow completed successfully!")
            if result is not None:
                print(f"📦 Final result: {result}")
            
            return context
            
        except Exception as e:
            print(f"❌ Workflow execution failed: {e}")
            context.add_history(f"ERROR: {e}")
            return context
    
    def print_execution_history(self, context: WorkflowContext):
        """Print workflow execution history"""
        print(f"\n📜 Execution History:")
        for event in context.get_history():
            print(f"  {event}")

# Demo function
def workflowDSLDemo():
    print("=== Interpreter Pattern - Workflow DSL ===\n")
    
    engine = WorkflowEngine()
    
    # Sample workflow scripts
    workflows = {
        "Counter Workflow": """
            counter = 1;
            WHILE counter < 5 DO (
                LOG('Counter is: ' + counter);
                counter = counter + 1;
                WAIT(1)
            );
            LOG('Counter finished at: ' + counter)
        """,
        
        "Conditional Workflow": """
            temperature = 25;
            IF temperature > 30 THEN (
                LOG('It''s hot! Turning on AC');
                ac_status = 'ON'
            ) ELSE (
                LOG('Temperature is comfortable');
                ac_status = 'OFF'
            );
            LOG('AC Status: ' + ac_status)
        """,
        
        "Calculation Workflow": """
            x = 10;
            y = 5;
            sum = x + y;
            product = x * y;
            LOG('Sum: ' + sum);
            LOG('Product: ' + product);
            IF sum > product THEN (
                LOG('Sum is greater than product')
            ) ELSE (
                LOG('Product is greater than or equal to sum')
            )
        """,
        
        "Complex Workflow": """
            attempts = 0;
            success = 0;
            WHILE attempts < 3 AND success == 0 DO (
                LOG('Attempt ' + (attempts + 1));
                WAIT(2);
                IF attempts == 2 THEN (
                    success = 1;
                    LOG('Success on final attempt!')
                ) ELSE (
                    LOG('Trying again...');
                    attempts = attempts + 1
                )
            );
            LOG('Final result - Success: ' + success + ', Attempts: ' + attempts)
        """
    }
    
    # Execute each workflow
    for workflow_name, workflow_script in workflows.items():
        print(f"\n{'='*60}")
        print(f"Executing: {workflow_name}")
        print(f"{'='*60}")
        
        context = engine.execute_workflow(workflow_script)
        engine.print_execution_history(context)
        
        print(f"\n📊 Final Variables: {context.variables}")

if __name__ == "__main__":
    workflowDSLDemo()
```

## Advantages and Disadvantages

### Advantages

- **Easy to Extend**: New expressions can be added easily
- **Simple Grammar Implementation**: Straightforward implementation for simple languages
- **Separation of Concerns**: Separates grammar rules from interpretation logic
- **Flexible**: Can easily change interpretation rules

### Disadvantages

- **Complex Grammars**: Not suitable for complex grammars
- **Performance Overhead**: Can be slow for large expressions
- **Maintenance**: Complex when grammar has many rules
- **Limited Scope**: Only useful for specific domain languages

## Best Practices

1. **Use for Simple Languages**: Ideal for small, well-defined domain-specific languages
2. **Keep Grammar Simple**: Avoid complex grammatical structures
3. **Use with Composite**: Often used with Composite pattern for expression trees
4. **Consider Parser Generators**: For complex languages, consider parser generators instead
5. **Test Thoroughly**: Comprehensive testing of expression evaluation

## Interpreter vs Other Patterns

- **vs Composite**: Interpreter uses Composite pattern to build syntax trees
- **vs Visitor**: Interpreter defines grammar, Visitor operates on the syntax tree
- **vs Flyweight**: Can use Flyweight for shared terminal symbols
- **vs Strategy**: Interpreter defines language, Strategy defines algorithms

The Interpreter pattern is particularly useful when you need to implement a simple language or when you need to frequently evaluate expressions in a domain-specific language. It's widely used in mathematical expression evaluators, rule engines, and domain-specific languages.
