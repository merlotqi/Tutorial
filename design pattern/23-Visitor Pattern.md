# Visitor Pattern

## Introduction

The Visitor Pattern is a behavioral design pattern that allows you to separate algorithms from the objects on which they operate. It lets you define new operations without changing the classes of the elements on which they operate.

### Key Characteristics

- **Double Dispatch**: Uses double dispatch to execute the correct method based on both visitor and element types
- **Separation of Concerns**: Separates data structures from algorithms
- **Extensible**: Easy to add new operations without modifying existing classes
- **Open/Closed Principle**: Classes are open for extension but closed for modification

### Use Cases

- Document export systems (PDF, HTML, XML)
- Compiler operations (type checking, code generation, optimization)
- UI component rendering
- Insurance policy calculation engines
- Shopping cart price calculations
- Report generation systems

## Implementation Examples

### C++ Implementation

#### Document Export System

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <sstream>

// Forward declarations
class TextElement;
class ImageElement;
class TableElement;

// Visitor interface
class DocumentVisitor {
public:
    virtual ~DocumentVisitor() = default;
    virtual void visitText(TextElement* element) = 0;
    virtual void visitImage(ImageElement* element) = 0;
    virtual void visitTable(TableElement* element) = 0;
};

// Element interface
class DocumentElement {
public:
    virtual ~DocumentElement() = default;
    virtual void accept(DocumentVisitor* visitor) = 0;
    virtual std::string getName() const = 0;
};

// Concrete element classes
class TextElement : public DocumentElement {
private:
    std::string content;
    std::string font;
    int fontSize;

public:
    TextElement(const std::string& text, const std::string& fontStyle = "Arial", int size = 12)
        : content(text), font(fontStyle), fontSize(size) {}
    
    void accept(DocumentVisitor* visitor) override {
        visitor->visitText(this);
    }
    
    std::string getName() const override {
        return "TextElement";
    }
    
    const std::string& getContent() const { return content; }
    const std::string& getFont() const { return font; }
    int getFontSize() const { return fontSize; }
};

class ImageElement : public DocumentElement {
private:
    std::string imagePath;
    int width;
    int height;
    std::string format;

public:
    ImageElement(const std::string& path, int w, int h, const std::string& imgFormat = "JPEG")
        : imagePath(path), width(w), height(h), format(imgFormat) {}
    
    void accept(DocumentVisitor* visitor) override {
        visitor->visitImage(this);
    }
    
    std::string getName() const override {
        return "ImageElement";
    }
    
    const std::string& getImagePath() const { return imagePath; }
    int getWidth() const { return width; }
    int getHeight() const { return height; }
    const std::string& getFormat() const { return format; }
};

class TableElement : public DocumentElement {
private:
    std::vector<std::vector<std::string>> data;
    std::string title;

public:
    TableElement(const std::string& tableTitle, 
                 const std::vector<std::vector<std::string>>& tableData)
        : title(tableTitle), data(tableData) {}
    
    void accept(DocumentVisitor* visitor) override {
        visitor->visitTable(this);
    }
    
    std::string getName() const override {
        return "TableElement";
    }
    
    const std::string& getTitle() const { return title; }
    const std::vector<std::vector<std::string>>& getData() const { return data; }
    int getRowCount() const { return data.size(); }
    int getColumnCount() const { return data.empty() ? 0 : data[0].size(); }
};

// Concrete visitors
class HTMLExportVisitor : public DocumentVisitor {
private:
    std::stringstream htmlContent;

public:
    void visitText(TextElement* element) override {
        htmlContent << "<p style=\"font-family: " << element->getFont() 
                   << "; font-size: " << element->getFontSize() << "px;\">"
                   << element->getContent() << "</p>\n";
    }
    
    void visitImage(ImageElement* element) override {
        htmlContent << "<img src=\"" << element->getImagePath() 
                   << "\" width=\"" << element->getWidth() 
                   << "\" height=\"" << element->getHeight() 
                   << "\" alt=\"Image\">\n";
    }
    
    void visitTable(TableElement* element) override {
        htmlContent << "<h3>" << element->getTitle() << "</h3>\n";
        htmlContent << "<table border=\"1\">\n";
        
        for (const auto& row : element->getData()) {
            htmlContent << "  <tr>\n";
            for (const auto& cell : row) {
                htmlContent << "    <td>" << cell << "</td>\n";
            }
            htmlContent << "  </tr>\n";
        }
        
        htmlContent << "</table>\n";
    }
    
    std::string getHTML() const {
        return "<html>\n<body>\n" + htmlContent.str() + "</body>\n</html>";
    }
};

class PDFExportVisitor : public DocumentVisitor {
private:
    std::stringstream pdfContent;

public:
    void visitText(TextElement* element) override {
        pdfContent << "PDF Text: [" << element->getFont() << ", " 
                  << element->getFontSize() << "pt] " 
                  << element->getContent() << "\n";
    }
    
    void visitImage(ImageElement* element) override {
        pdfContent << "PDF Image: " << element->getImagePath() 
                  << " (" << element->getWidth() << "x" << element->getHeight() 
                  << ", " << element->getFormat() << ")\n";
    }
    
    void visitTable(TableElement* element) override {
        pdfContent << "PDF Table: " << element->getTitle() << "\n";
        pdfContent << "Columns: " << element->getColumnCount() 
                  << ", Rows: " << element->getRowCount() << "\n";
        
        for (const auto& row : element->getData()) {
            for (const auto& cell : row) {
                pdfContent << cell << " | ";
            }
            pdfContent << "\n";
        }
    }
    
    std::string getPDFContent() const {
        return "PDF Document:\n" + pdfContent.str();
    }
};

class PlainTextVisitor : public DocumentVisitor {
private:
    std::stringstream textContent;

public:
    void visitText(TextElement* element) override {
        textContent << "Text: " << element->getContent() << "\n";
    }
    
    void visitImage(ImageElement* element) override {
        textContent << "[Image: " << element->getImagePath() << "]\n";
    }
    
    void visitTable(TableElement* element) override {
        textContent << "Table: " << element->getTitle() << "\n";
        for (const auto& row : element->getData()) {
            for (const auto& cell : row) {
                textContent << cell << "\t";
            }
            textContent << "\n";
        }
    }
    
    std::string getTextContent() const {
        return textContent.str();
    }
};

// Document class that contains elements
class Document {
private:
    std::vector<std::unique_ptr<DocumentElement>> elements;

public:
    void addElement(std::unique_ptr<DocumentElement> element) {
        elements.push_back(std::move(element));
    }
    
    void accept(DocumentVisitor* visitor) {
        for (auto& element : elements) {
            element->accept(visitor);
        }
    }
    
    size_t getElementCount() const {
        return elements.size();
    }
};

// Demo function
void documentExportDemo() {
    std::cout << "=== Visitor Pattern - Document Export System ===\n" << std::endl;
    
    // Create a document with various elements
    Document doc;
    
    doc.addElement(std::make_unique<TextElement>("Welcome to our Annual Report", "Times New Roman", 16));
    doc.addElement(std::make_unique<TextElement>("This report contains important financial data.", "Arial", 12));
    doc.addElement(std::make_unique<ImageElement>("chart.png", 800, 600, "PNG"));
    
    std::vector<std::vector<std::string>> tableData = {
        {"Q1", "Q2", "Q3", "Q4"},
        {"$100K", "$150K", "$200K", "$180K"},
        {"$80K", "$120K", "$160K", "$140K"}
    };
    doc.addElement(std::make_unique<TableElement>("Financial Summary", tableData));
    
    doc.addElement(std::make_unique<TextElement>("Conclusion: Strong growth observed in Q3.", "Arial", 12));
    
    std::cout << "Document created with " << doc.getElementCount() << " elements.\n" << std::endl;
    
    // Export to different formats using visitors
    HTMLExportVisitor htmlVisitor;
    PDFExportVisitor pdfVisitor;
    PlainTextVisitor textVisitor;
    
    std::cout << "1. HTML Export:\n";
    std::cout << "----------------\n";
    doc.accept(&htmlVisitor);
    std::cout << htmlVisitor.getHTML() << std::endl;
    
    std::cout << "2. PDF Export:\n";
    std::cout << "----------------\n";
    doc.accept(&pdfVisitor);
    std::cout << pdfVisitor.getPDFContent() << std::endl;
    
    std::cout << "3. Plain Text Export:\n";
    std::cout << "----------------------\n";
    doc.accept(&textVisitor);
    std::cout << textVisitor.getTextContent() << std::endl;
}

int main() {
    documentExportDemo();
    return 0;
}
```

#### Insurance Policy Calculator

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <map>
#include <iomanip>

// Forward declarations
class LifeInsurance;
class HealthInsurance;
class AutoInsurance;
class PropertyInsurance;

// Visitor interface
class InsuranceVisitor {
public:
    virtual ~InsuranceVisitor() = default;
    virtual void visitLifeInsurance(LifeInsurance* insurance) = 0;
    virtual void visitHealthInsurance(HealthInsurance* insurance) = 0;
    virtual void visitAutoInsurance(AutoInsurance* insurance) = 0;
    virtual void visitPropertyInsurance(PropertyInsurance* insurance) = 0;
};

// Insurance policy interface
class InsurancePolicy {
public:
    virtual ~InsurancePolicy() = default;
    virtual void accept(InsuranceVisitor* visitor) = 0;
    virtual std::string getPolicyNumber() const = 0;
    virtual double getBasePremium() const = 0;
};

// Concrete policy classes
class LifeInsurance : public InsurancePolicy {
private:
    std::string policyNumber;
    double coverageAmount;
    int insuredAge;
    std::string healthStatus;
    double basePremium;

public:
    LifeInsurance(const std::string& policyNo, double coverage, int age, 
                  const std::string& health, double basePrem = 1000.0)
        : policyNumber(policyNo), coverageAmount(coverage), insuredAge(age),
          healthStatus(health), basePremium(basePrem) {}
    
    void accept(InsuranceVisitor* visitor) override {
        visitor->visitLifeInsurance(this);
    }
    
    std::string getPolicyNumber() const override { return policyNumber; }
    double getBasePremium() const override { return basePremium; }
    
    double getCoverageAmount() const { return coverageAmount; }
    int getInsuredAge() const { return insuredAge; }
    const std::string& getHealthStatus() const { return healthStatus; }
};

class HealthInsurance : public InsurancePolicy {
private:
    std::string policyNumber;
    int coveredPeople;
    std::string planType; // "Basic", "Standard", "Premium"
    bool hasDental;
    bool hasVision;
    double basePremium;

public:
    HealthInsurance(const std::string& policyNo, int people, const std::string& plan,
                    bool dental, bool vision, double basePrem = 500.0)
        : policyNumber(policyNo), coveredPeople(people), planType(plan),
          hasDental(dental), hasVision(vision), basePremium(basePrem) {}
    
    void accept(InsuranceVisitor* visitor) override {
        visitor->visitHealthInsurance(this);
    }
    
    std::string getPolicyNumber() const override { return policyNumber; }
    double getBasePremium() const override { return basePremium; }
    
    int getCoveredPeople() const { return coveredPeople; }
    const std::string& getPlanType() const { return planType; }
    bool getHasDental() const { return hasDental; }
    bool getHasVision() const { return hasVision; }
};

class AutoInsurance : public InsurancePolicy {
private:
    std::string policyNumber;
    std::string vehicleType;
    int driverAge;
    int drivingExperience;
    bool hasAccidents;
    double basePremium;

public:
    AutoInsurance(const std::string& policyNo, const std::string& vehicle, 
                  int age, int experience, bool accidents, double basePrem = 800.0)
        : policyNumber(policyNo), vehicleType(vehicle), driverAge(age),
          drivingExperience(experience), hasAccidents(accidents), basePremium(basePrem) {}
    
    void accept(InsuranceVisitor* visitor) override {
        visitor->visitAutoInsurance(this);
    }
    
    std::string getPolicyNumber() const override { return policyNumber; }
    double getBasePremium() const override { return basePremium; }
    
    const std::string& getVehicleType() const { return vehicleType; }
    int getDriverAge() const { return driverAge; }
    int getDrivingExperience() const { return drivingExperience; }
    bool getHasAccidents() const { return hasAccidents; }
};

class PropertyInsurance : public InsurancePolicy {
private:
    std::string policyNumber;
    std::string propertyType; // "House", "Apartment", "Commercial"
    double propertyValue;
    std::string location;
    bool hasFloodCoverage;
    double basePremium;

public:
    PropertyInsurance(const std::string& policyNo, const std::string& type,
                      double value, const std::string& loc, bool flood, double basePrem = 1200.0)
        : policyNumber(policyNo), propertyType(type), propertyValue(value),
          location(loc), hasFloodCoverage(flood), basePremium(basePrem) {}
    
    void accept(InsuranceVisitor* visitor) override {
        visitor->visitPropertyInsurance(this);
    }
    
    std::string getPolicyNumber() const override { return policyNumber; }
    double getBasePremium() const override { return basePremium; }
    
    const std::string& getPropertyType() const { return propertyType; }
    double getPropertyValue() const { return propertyValue; }
    const std::string& getLocation() const { return location; }
    bool getHasFloodCoverage() const { return hasFloodCoverage; }
};

// Concrete visitors
class PremiumCalculator : public InsuranceVisitor {
private:
    double totalPremium;
    std::map<std::string, double> policyPremiums;

public:
    PremiumCalculator() : totalPremium(0.0) {}
    
    void visitLifeInsurance(LifeInsurance* insurance) override {
        double premium = insurance->getBasePremium();
        
        // Age factor
        if (insurance->getInsuredAge() > 50) {
            premium *= 1.5;
        }
        
        // Health factor
        if (insurance->getHealthStatus() == "Poor") {
            premium *= 2.0;
        } else if (insurance->getHealthStatus() == "Excellent") {
            premium *= 0.8;
        }
        
        // Coverage amount factor
        premium *= (insurance->getCoverageAmount() / 100000.0);
        
        policyPremiums[insurance->getPolicyNumber()] = premium;
        totalPremium += premium;
        
        std::cout << "Life Insurance Premium: $" << std::fixed << std::setprecision(2) 
                  << premium << " (Policy: " << insurance->getPolicyNumber() << ")\n";
    }
    
    void visitHealthInsurance(HealthInsurance* insurance) override {
        double premium = insurance->getBasePremium();
        
        // People count
        premium *= insurance->getCoveredPeople();
        
        // Plan type
        if (insurance->getPlanType() == "Premium") {
            premium *= 1.5;
        } else if (insurance->getPlanType() == "Basic") {
            premium *= 0.7;
        }
        
        // Additional coverage
        if (insurance->getHasDental()) premium += 50;
        if (insurance->getHasVision()) premium += 30;
        
        policyPremiums[insurance->getPolicyNumber()] = premium;
        totalPremium += premium;
        
        std::cout << "Health Insurance Premium: $" << std::fixed << std::setprecision(2) 
                  << premium << " (Policy: " << insurance->getPolicyNumber() << ")\n";
    }
    
    void visitAutoInsurance(AutoInsurance* insurance) override {
        double premium = insurance->getBasePremium();
        
        // Driver age and experience
        if (insurance->getDriverAge() < 25) {
            premium *= 1.8;
        } else if (insurance->getDriverAge() > 65) {
            premium *= 1.3;
        }
        
        if (insurance->getDrivingExperience() < 3) {
            premium *= 1.5;
        }
        
        // Accident history
        if (insurance->getHasAccidents()) {
            premium *= 1.6;
        }
        
        // Vehicle type
        if (insurance->getVehicleType() == "Sports") {
            premium *= 1.4;
        } else if (insurance->getVehicleType() == "SUV") {
            premium *= 1.2;
        }
        
        policyPremiums[insurance->getPolicyNumber()] = premium;
        totalPremium += premium;
        
        std::cout << "Auto Insurance Premium: $" << std::fixed << std::setprecision(2) 
                  << premium << " (Policy: " << insurance->getPolicyNumber() << ")\n";
    }
    
    void visitPropertyInsurance(PropertyInsurance* insurance) override {
        double premium = insurance->getBasePremium();
        
        // Property value factor
        premium *= (insurance->getPropertyValue() / 500000.0);
        
        // Location risk
        if (insurance->getLocation() == "High Risk") {
            premium *= 1.8;
        } else if (insurance->getLocation() == "Low Risk") {
            premium *= 0.8;
        }
        
        // Additional coverage
        if (insurance->getHasFloodCoverage()) {
            premium += 200;
        }
        
        policyPremiums[insurance->getPolicyNumber()] = premium;
        totalPremium += premium;
        
        std::cout << "Property Insurance Premium: $" << std::fixed << std::setprecision(2) 
                  << premium << " (Policy: " << insurance->getPolicyNumber() << ")\n";
    }
    
    double getTotalPremium() const { return totalPremium; }
    const std::map<std::string, double>& getPolicyPremiums() const { return policyPremiums; }
};

class RiskAssessor : public InsuranceVisitor {
private:
    double totalRiskScore;
    std::map<std::string, std::string> riskAssessments;

public:
    RiskAssessor() : totalRiskScore(0.0) {}
    
    void visitLifeInsurance(LifeInsurance* insurance) override {
        double riskScore = 5.0; // Base risk
        
        if (insurance->getHealthStatus() == "Poor") riskScore += 3.0;
        if (insurance->getInsuredAge() > 60) riskScore += 2.0;
        
        std::string assessment = riskScore > 7.0 ? "High Risk" : 
                                riskScore > 5.0 ? "Medium Risk" : "Low Risk";
        
        riskAssessments[insurance->getPolicyNumber()] = assessment;
        totalRiskScore += riskScore;
        
        std::cout << "Life Insurance Risk: " << assessment << " (Score: " << riskScore 
                  << ") for Policy: " << insurance->getPolicyNumber() << "\n";
    }
    
    void visitHealthInsurance(HealthInsurance* insurance) override {
        double riskScore = 4.0; // Base risk
        
        if (insurance->getPlanType() == "Premium") riskScore -= 1.0;
        if (insurance->getCoveredPeople() > 4) riskScore += 1.0;
        
        std::string assessment = riskScore > 5.0 ? "High Risk" : 
                                riskScore > 3.0 ? "Medium Risk" : "Low Risk";
        
        riskAssessments[insurance->getPolicyNumber()] = assessment;
        totalRiskScore += riskScore;
        
        std::cout << "Health Insurance Risk: " << assessment << " (Score: " << riskScore 
                  << ") for Policy: " << insurance->getPolicyNumber() << "\n";
    }
    
    void visitAutoInsurance(AutoInsurance* insurance) override {
        double riskScore = 6.0; // Base risk (auto is generally higher risk)
        
        if (insurance->getDriverAge() < 25) riskScore += 2.0;
        if (insurance->getHasAccidents()) riskScore += 3.0;
        if (insurance->getDrivingExperience() < 2) riskScore += 2.0;
        
        std::string assessment = riskScore > 8.0 ? "High Risk" : 
                                riskScore > 6.0 ? "Medium Risk" : "Low Risk";
        
        riskAssessments[insurance->getPolicyNumber()] = assessment;
        totalRiskScore += riskScore;
        
        std::cout << "Auto Insurance Risk: " << assessment << " (Score: " << riskScore 
                  << ") for Policy: " << insurance->getPolicyNumber() << "\n";
    }
    
    void visitPropertyInsurance(PropertyInsurance* insurance) override {
        double riskScore = 4.0; // Base risk
        
        if (insurance->getLocation() == "High Risk") riskScore += 3.0;
        if (insurance->getHasFloodCoverage()) riskScore -= 1.0;
        
        std::string assessment = riskScore > 6.0 ? "High Risk" : 
                                riskScore > 4.0 ? "Medium Risk" : "Low Risk";
        
        riskAssessments[insurance->getPolicyNumber()] = assessment;
        totalRiskScore += riskScore;
        
        std::cout << "Property Insurance Risk: " << assessment << " (Score: " << riskScore 
                  << ") for Policy: " << insurance->getPolicyNumber() << "\n";
    }
    
    double getAverageRiskScore() const { 
        return riskAssessments.empty() ? 0.0 : totalRiskScore / riskAssessments.size(); 
    }
    const std::map<std::string, std::string>& getRiskAssessments() const { return riskAssessments; }
};

class PolicyValidator : public InsuranceVisitor {
private:
    std::vector<std::string> validationErrors;

public:
    void visitLifeInsurance(LifeInsurance* insurance) override {
        if (insurance->getCoverageAmount() < 10000) {
            validationErrors.push_back("Life insurance coverage too low for policy: " + 
                                     insurance->getPolicyNumber());
        }
        if (insurance->getInsuredAge() > 80) {
            validationErrors.push_back("Insured age too high for policy: " + 
                                     insurance->getPolicyNumber());
        }
        std::cout << "Validated Life Insurance: " << insurance->getPolicyNumber() << " ✓\n";
    }
    
    void visitHealthInsurance(HealthInsurance* insurance) override {
        if (insurance->getCoveredPeople() > 10) {
            validationErrors.push_back("Too many people covered in policy: " + 
                                     insurance->getPolicyNumber());
        }
        std::cout << "Validated Health Insurance: " << insurance->getPolicyNumber() << " ✓\n";
    }
    
    void visitAutoInsurance(AutoInsurance* insurance) override {
        if (insurance->getDriverAge() < 18) {
            validationErrors.push_back("Driver too young for policy: " + 
                                     insurance->getPolicyNumber());
        }
        std::cout << "Validated Auto Insurance: " << insurance->getPolicyNumber() << " ✓\n";
    }
    
    void visitPropertyInsurance(PropertyInsurance* insurance) override {
        if (insurance->getPropertyValue() <= 0) {
            validationErrors.push_back("Invalid property value for policy: " + 
                                     insurance->getPolicyNumber());
        }
        std::cout << "Validated Property Insurance: " << insurance->getPolicyNumber() << " ✓\n";
    }
    
    const std::vector<std::string>& getValidationErrors() const { return validationErrors; }
    bool isValid() const { return validationErrors.empty(); }
};

// Insurance portfolio
class InsurancePortfolio {
private:
    std::vector<std::unique_ptr<InsurancePolicy>> policies;

public:
    void addPolicy(std::unique_ptr<InsurancePolicy> policy) {
        policies.push_back(std::move(policy));
    }
    
    void accept(InsuranceVisitor* visitor) {
        for (auto& policy : policies) {
            policy->accept(visitor);
        }
    }
    
    size_t getPolicyCount() const {
        return policies.size();
    }
};

// Demo function
void insuranceCalculatorDemo() {
    std::cout << "=== Visitor Pattern - Insurance Calculator ===\n" << std::endl;
    
    // Create insurance portfolio
    InsurancePortfolio portfolio;
    
    portfolio.addPolicy(std::make_unique<LifeInsurance>("LIFE-001", 500000, 45, "Good"));
    portfolio.addPolicy(std::make_unique<HealthInsurance>("HEALTH-001", 3, "Premium", true, true));
    portfolio.addPolicy(std::make_unique<AutoInsurance>("AUTO-001", "Sedan", 35, 10, false));
    portfolio.addPolicy(std::make_unique<PropertyInsurance>("PROP-001", "House", 350000, "Medium Risk", true));
    portfolio.addPolicy(std::make_unique<LifeInsurance>("LIFE-002", 1000000, 28, "Excellent"));
    
    std::cout << "Portfolio created with " << portfolio.getPolicyCount() << " policies.\n" << std::endl;
    
    // Calculate premiums
    std::cout << "1. PREMIUM CALCULATION:\n";
    std::cout << "=======================\n";
    PremiumCalculator premiumCalc;
    portfolio.accept(&premiumCalc);
    std::cout << "\nTotal Portfolio Premium: $" << std::fixed << std::setprecision(2) 
              << premiumCalc.getTotalPremium() << "\n" << std::endl;
    
    // Assess risks
    std::cout << "2. RISK ASSESSMENT:\n";
    std::cout << "===================\n";
    RiskAssessor riskAssessor;
    portfolio.accept(&riskAssessor);
    std::cout << "\nAverage Risk Score: " << riskAssessor.getAverageRiskScore() << "\n" << std::endl;
    
    // Validate policies
    std::cout << "3. POLICY VALIDATION:\n";
    std::cout << "=====================\n";
    PolicyValidator validator;
    portfolio.accept(&validator);
    
    if (validator.isValid()) {
        std::cout << "\nAll policies are valid! ✓\n";
    } else {
        std::cout << "\nValidation Errors:\n";
        for (const auto& error : validator.getValidationErrors()) {
            std::cout << "  - " << error << "\n";
        }
    }
}

int main() {
    insuranceCalculatorDemo();
    return 0;
}
```

### Python Implementation

#### Compiler Operations

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from dataclasses import dataclass
from enum import Enum

class NodeType(Enum):
    PROGRAM = "Program"
    VARIABLE_DECLARATION = "VariableDeclaration"
    FUNCTION_DECLARATION = "FunctionDeclaration"
    ASSIGNMENT = "Assignment"
    BINARY_OPERATION = "BinaryOperation"
    IF_STATEMENT = "IfStatement"
    WHILE_LOOP = "WhileLoop"

# AST Node interface
class ASTNode(ABC):
    @abstractmethod
    def accept(self, visitor: 'ASTVisitor') -> Any: ...

# Concrete AST Nodes
@dataclass
class ProgramNode(ASTNode):
    statements: List[ASTNode]
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_program(self)

@dataclass
class VariableDeclarationNode(ASTNode):
    name: str
    var_type: str
    initial_value: ASTNode = None
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_variable_declaration(self)

@dataclass
class FunctionDeclarationNode(ASTNode):
    name: str
    parameters: List[tuple]
    return_type: str
    body: List[ASTNode]
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_function_declaration(self)

@dataclass
class AssignmentNode(ASTNode):
    variable: str
    value: ASTNode
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_assignment(self)

@dataclass
class BinaryOperationNode(ASTNode):
    left: ASTNode
    operator: str
    right: ASTNode
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_binary_operation(self)

@dataclass
class IfStatementNode(ASTNode):
    condition: ASTNode
    then_branch: List[ASTNode]
    else_branch: List[ASTNode] = None
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_if_statement(self)

@dataclass
class WhileLoopNode(ASTNode):
    condition: ASTNode
    body: List[ASTNode]
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_while_loop(self)

@dataclass
class LiteralNode(ASTNode):
    value: Any
    literal_type: str
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_literal(self)

@dataclass
class VariableNode(ASTNode):
    name: str
    
    def accept(self, visitor: 'ASTVisitor') -> Any:
        return visitor.visit_variable(self)

# Visitor interface
class ASTVisitor(ABC):
    @abstractmethod
    def visit_program(self, node: ProgramNode) -> Any: ...
    
    @abstractmethod
    def visit_variable_declaration(self, node: VariableDeclarationNode) -> Any: ...
    
    @abstractmethod
    def visit_function_declaration(self, node: FunctionDeclarationNode) -> Any: ...
    
    @abstractmethod
    def visit_assignment(self, node: AssignmentNode) -> Any: ...
    
    @abstractmethod
    def visit_binary_operation(self, node: BinaryOperationNode) -> Any: ...
    
    @abstractmethod
    def visit_if_statement(self, node: IfStatementNode) -> Any: ...
    
    @abstractmethod
    def visit_while_loop(self, node: WhileLoopNode) -> Any: ...
    
    @abstractmethod
    def visit_literal(self, node: LiteralNode) -> Any: ...
    
    @abstractmethod
    def visit_variable(self, node: VariableNode) -> Any: ...

# Concrete Visitors
class TypeChecker(ASTVisitor):
    def __init__(self):
        self.symbol_table: Dict[str, str] = {}
        self.errors: List[str] = []
    
    def visit_program(self, node: ProgramNode) -> Any:
        print("🔍 Type checking program...")
        for stmt in node.statements:
            stmt.accept(self)
        
        if not self.errors:
            print("✅ Type checking completed successfully!")
        else:
            print("❌ Type checking failed with errors:")
            for error in self.errors:
                print(f"   - {error}")
        return not self.errors
    
    def visit_variable_declaration(self, node: VariableDeclarationNode) -> Any:
        print(f"📝 Checking variable declaration: {node.name}")
        
        if node.name in self.symbol_table:
            self.errors.append(f"Redeclaration of variable '{node.name}'")
            return
        
        self.symbol_table[node.name] = node.var_type
        
        if node.initial_value:
            initial_type = node.initial_value.accept(self)
            if initial_type and initial_type != node.var_type:
                self.errors.append(f"Type mismatch in '{node.name}': expected {node.var_type}, got {initial_type}")
    
    def visit_function_declaration(self, node: FunctionDeclarationNode) -> Any:
        print(f"📝 Checking function declaration: {node.name}")
        # Add function to symbol table
        func_signature = f"func({','.join(p[1] for p in node.parameters)})->{node.return_type}"
        self.symbol_table[node.name] = func_signature
        
        # Check function body
        for stmt in node.body:
            stmt.accept(self)
    
    def visit_assignment(self, node: AssignmentNode) -> Any:
        print(f"📝 Checking assignment: {node.variable}")
        
        if node.variable not in self.symbol_table:
            self.errors.append(f"Assignment to undeclared variable '{node.variable}'")
            return
        
        expected_type = self.symbol_table[node.variable]
        actual_type = node.value.accept(self)
        
        if actual_type and actual_type != expected_type:
            self.errors.append(f"Assignment type mismatch for '{node.variable}': expected {expected_type}, got {actual_type}")
    
    def visit_binary_operation(self, node: BinaryOperationNode) -> Any:
        left_type = node.left.accept(self)
        right_type = node.right.accept(self)
        
        if left_type != right_type:
            self.errors.append(f"Binary operation type mismatch: {left_type} {node.operator} {right_type}")
            return None
        
        # For simplicity, assume all binary operations return the same type as operands
        return left_type
    
    def visit_if_statement(self, node: IfStatementNode) -> Any:
        condition_type = node.condition.accept(self)
        if condition_type != "bool":
            self.errors.append(f"If condition must be boolean, got {condition_type}")
        
        for stmt in node.then_branch:
            stmt.accept(self)
        
        if node.else_branch:
            for stmt in node.else_branch:
                stmt.accept(self)
    
    def visit_while_loop(self, node: WhileLoopNode) -> Any:
        condition_type = node.condition.accept(self)
        if condition_type != "bool":
            self.errors.append(f"While condition must be boolean, got {condition_type}")
        
        for stmt in node.body:
            stmt.accept(self)
    
    def visit_literal(self, node: LiteralNode) -> Any:
        return node.literal_type
    
    def visit_variable(self, node: VariableNode) -> Any:
        if node.name not in self.symbol_table:
            self.errors.append(f"Undeclared variable '{node.name}'")
            return None
        return self.symbol_table[node.name]

class CodeGenerator(ASTVisitor):
    def __init__(self):
        self.generated_code = []
        self.indent_level = 0
    
    def _indent(self):
        return "    " * self.indent_level
    
    def visit_program(self, node: ProgramNode) -> Any:
        self.generated_code.append("# Generated Code")
        for stmt in node.statements:
            stmt.accept(self)
        return "\n".join(self.generated_code)
    
    def visit_variable_declaration(self, node: VariableDeclarationNode) -> Any:
        if node.initial_value:
            init_code = node.initial_value.accept(self)
            code = f"{self._indent()}{node.name} = {init_code}"
        else:
            code = f"{self._indent()}{node.name} = None  # {node.var_type}"
        self.generated_code.append(code)
    
    def visit_function_declaration(self, node: FunctionDeclarationNode) -> Any:
        params = ", ".join(p[0] for p in node.parameters)
        self.generated_code.append(f"{self._indent()}def {node.name}({params}):")
        self.indent_level += 1
        for stmt in node.body:
            stmt.accept(self)
        self.indent_level -= 1
        self.generated_code.append("")
    
    def visit_assignment(self, node: AssignmentNode) -> Any:
        value_code = node.value.accept(self)
        self.generated_code.append(f"{self._indent()}{node.variable} = {value_code}")
    
    def visit_binary_operation(self, node: BinaryOperationNode) -> Any:
        left_code = node.left.accept(self)
        right_code = node.right.accept(self)
        return f"({left_code} {node.operator} {right_code})"
    
    def visit_if_statement(self, node: IfStatementNode) -> Any:
        condition_code = node.condition.accept(self)
        self.generated_code.append(f"{self._indent()}if {condition_code}:")
        self.indent_level += 1
        for stmt in node.then_branch:
            stmt.accept(self)
        self.indent_level -= 1
        
        if node.else_branch:
            self.generated_code.append(f"{self._indent()}else:")
            self.indent_level += 1
            for stmt in node.else_branch:
                stmt.accept(self)
            self.indent_level -= 1
    
    def visit_while_loop(self, node: WhileLoopNode) -> Any:
        condition_code = node.condition.accept(self)
        self.generated_code.append(f"{self._indent()}while {condition_code}:")
        self.indent_level += 1
        for stmt in node.body:
            stmt.accept(self)
        self.indent_level -= 1
    
    def visit_literal(self, node: LiteralNode) -> Any:
        return repr(node.value)
    
    def visit_variable(self, node: VariableNode) -> Any:
        return node.name

class ASTPrinter(ASTVisitor):
    def __init__(self):
        self.output = []
        self.indent_level = 0
    
    def _indent(self):
        return "  " * self.indent_level
    
    def visit_program(self, node: ProgramNode) -> Any:
        self.output.append(f"{self._indent()}Program:")
        self.indent_level += 1
        for stmt in node.statements:
            stmt.accept(self)
        self.indent_level -= 1
        return "\n".join(self.output)
    
    def visit_variable_declaration(self, node: VariableDeclarationNode) -> Any:
        init_str = f" = {node.initial_value.accept(self)}" if node.initial_value else ""
        self.output.append(f"{self._indent()}VarDecl: {node.name}: {node.var_type}{init_str}")
    
    def visit_function_declaration(self, node: FunctionDeclarationNode) -> Any:
        params = ", ".join(f"{p[0]}: {p[1]}" for p in node.parameters)
        self.output.append(f"{self._indent()}FuncDecl: {node.name}({params}) -> {node.return_type}")
        self.indent_level += 1
        for stmt in node.body:
            stmt.accept(self)
        self.indent_level -= 1
    
    def visit_assignment(self, node: AssignmentNode) -> Any:
        value_str = node.value.accept(self)
        self.output.append(f"{self._indent()}Assignment: {node.variable} = {value_str}")
    
    def visit_binary_operation(self, node: BinaryOperationNode) -> Any:
        left_str = node.left.accept(self)
        right_str = node.right.accept(self)
        return f"({left_str} {node.operator} {right_str})"
    
    def visit_if_statement(self, node: IfStatementNode) -> Any:
        condition_str = node.condition.accept(self)
        self.output.append(f"{self._indent()}If: {condition_str}")
        self.indent_level += 1
        self.output.append(f"{self._indent()}Then:")
        self.indent_level += 1
        for stmt in node.then_branch:
            stmt.accept(self)
        self.indent_level -= 1
        
        if node.else_branch:
            self.output.append(f"{self._indent()}Else:")
            self.indent_level += 1
            for stmt in node.else_branch:
                stmt.accept(self)
            self.indent_level -= 1
        self.indent_level -= 1
    
    def visit_while_loop(self, node: WhileLoopNode) -> Any:
        condition_str = node.condition.accept(self)
        self.output.append(f"{self._indent()}While: {condition_str}")
        self.indent_level += 1
        for stmt in node.body:
            stmt.accept(self)
        self.indent_level -= 1
    
    def visit_literal(self, node: LiteralNode) -> Any:
        return f"Literal({node.value})"
    
    def visit_variable(self, node: VariableNode) -> Any:
        return f"Variable({node.name})"

def compilerOperationsDemo():
    print("=== Visitor Pattern - Compiler Operations ===\n")
    
    # Create a sample AST
    program = ProgramNode([
        VariableDeclarationNode("x", "int", LiteralNode(10, "int")),
        VariableDeclarationNode("y", "int", LiteralNode(20, "int")),
        FunctionDeclarationNode(
            "calculate",
            [("a", "int"), ("b", "int")],
            "int",
            [
                IfStatementNode(
                    BinaryOperationNode(
                        VariableNode("a"),
                        ">",
                        VariableNode("b")
                    ),
                    [AssignmentNode("result", VariableNode("a"))],
                    [AssignmentNode("result", VariableNode("b"))]
                ),
                VariableDeclarationNode("result", "int", None)
            ]
        ),
        AssignmentNode(
            "x",
            BinaryOperationNode(
                VariableNode("x"),
                "+",
                LiteralNode(5, "int")
            )
        ),
        WhileLoopNode(
            BinaryOperationNode(
                VariableNode("x"),
                "<",
                LiteralNode(100, "int")
            ),
            [
                AssignmentNode(
                    "x",
                    BinaryOperationNode(
                        VariableNode("x"),
                        "*",
                        LiteralNode(2, "int")
                    )
                )
            ]
        )
    ])
    
    # Use different visitors
    print("1. AST PRINTER:")
    print("===============")
    printer = ASTPrinter()
    print(program.accept(printer))
    
    print("\n2. TYPE CHECKER:")
    print("================")
    type_checker = TypeChecker()
    program.accept(type_checker)
    
    print("\n3. CODE GENERATOR:")
    print("==================")
    code_gen = CodeGenerator()
    generated_code = program.accept(code_gen)
    print(generated_code)

if __name__ == "__main__":
    compilerOperationsDemo()
```

## Advantages and Disadvantages

### Advantages

- **Open/Closed Principle**: New operations can be added without changing element classes
- **Separation of Concerns**: Algorithms are separated from object structures
- **Accumulating State**: Visitors can accumulate state as they traverse object structures
- **Type Safety**: Compile-time type checking for operations

### Disadvantages

- **Breaking Encapsulation**: Visitors often need access to internal details of elements
- **Complexity**: Can make the code more complex for simple object structures
- **Hard to Maintain**: Adding new element classes requires updating all visitors
- **Tight Coupling**: Visitors are tightly coupled to the element interface

## Best Practices

1. **Use When Operations Change Frequently**: When you have many unrelated operations on object structures
2. **Stable Element Hierarchy**: When the element classes are stable and don't change often
3. **Avoid for Simple Structures**: For simple object structures, direct methods might be better
4. **Use with Composite**: Often used with Composite pattern for tree structures
5. **Consider Performance**: Visitor pattern can have performance overhead due to double dispatch

## Visitor vs Other Patterns

- **vs Iterator**: Visitor performs operations on elements, Iterator traverses elements
- **vs Strategy**: Visitor changes operations, Strategy changes algorithms
- **vs Composite**: Visitor operates on Composite structures
- **vs Interpreter**: Visitor can be used to implement operations for Interpreter pattern

The Visitor pattern is particularly useful when you need to perform multiple unrelated operations on a complex object structure and want to keep these operations separate from the objects themselves.
