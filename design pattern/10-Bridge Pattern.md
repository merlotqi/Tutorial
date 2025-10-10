# Bridge Pattern

## Introduction

The Bridge pattern is a structural design pattern that separates abstraction from implementation so that both can vary independently. It decouples an abstraction from its implementation, allowing the two to evolve independently without binding them at compile time.

### Key Characteristics

- **Decoupling**: Separates abstraction and implementation hierarchies
- **Independent Evolution**: Both abstraction and implementation can be extended independently
- **Composition over Inheritance**: Uses composition to bridge abstraction and implementation
- **Multiple Dimensions**: Handles multiple orthogonal classifications efficiently

### Use Cases

- When you want to avoid permanent binding between abstraction and implementation
- When both abstractions and implementations should be extensible via subclassing
- When changes in implementation should not affect clients
- When you have multiple orthogonal dimensions in your class hierarchy
- When you want to share implementations among multiple objects

## Implementation Examples

### C++ Implementation

#### Basic Bridge Pattern - Device and Remote Control

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>

// Implementation interface
class Device {
public:
    virtual ~Device() = default;
    virtual bool isEnabled() const = 0;
    virtual void enable() = 0;
    virtual void disable() = 0;
    virtual int getVolume() const = 0;
    virtual void setVolume(int percent) = 0;
    virtual int getChannel() const = 0;
    virtual void setChannel(int channel) = 0;
    virtual void printStatus() const = 0;
};

// Concrete Implementations
class TV : public Device {
private:
    bool on;
    int volume;
    int channel;
    std::string name;

public:
    TV(const std::string& name) : on(false), volume(50), channel(1), name(name) {}
    
    bool isEnabled() const override {
        return on;
    }
    
    void enable() override {
        on = true;
        std::cout << name << " TV is now ON" << std::endl;
    }
    
    void disable() override {
        on = false;
        std::cout << name << " TV is now OFF" << std::endl;
    }
    
    int getVolume() const override {
        return volume;
    }
    
    void setVolume(int percent) override {
        if (percent >= 0 && percent <= 100) {
            volume = percent;
            std::cout << name << " TV volume set to " << volume << "%" << std::endl;
        }
    }
    
    int getChannel() const override {
        return channel;
    }
    
    void setChannel(int channel) override {
        if (channel >= 1 && channel <= 999) {
            this->channel = channel;
            std::cout << name << " TV channel set to " << channel << std::endl;
        }
    }
    
    void printStatus() const override {
        std::cout << "------------------------------------" << std::endl;
        std::cout << "| " << name << " TV Status" << std::endl;
        std::cout << "| Power: " << (on ? "ON" : "OFF") << std::endl;
        std::cout << "| Volume: " << volume << "%" << std::endl;
        std::cout << "| Channel: " << channel << std::endl;
        std::cout << "------------------------------------" << std::endl;
    }
};

class Radio : public Device {
private:
    bool on;
    int volume;
    int channel;
    double frequency;

public:
    Radio() : on(false), volume(30), channel(1), frequency(88.5) {}
    
    bool isEnabled() const override {
        return on;
    }
    
    void enable() override {
        on = true;
        std::cout << "Radio is now ON" << std::endl;
    }
    
    void disable() override {
        on = false;
        std::cout << "Radio is now OFF" << std::endl;
    }
    
    int getVolume() const override {
        return volume;
    }
    
    void setVolume(int percent) override {
        if (percent >= 0 && percent <= 100) {
            volume = percent;
            std::cout << "Radio volume set to " << volume << "%" << std::endl;
        }
    }
    
    int getChannel() const override {
        return channel;
    }
    
    void setChannel(int channel) override {
        if (channel >= 1 && channel <= 200) {
            this->channel = channel;
            this->frequency = 88.5 + (channel - 1) * 0.1;
            std::cout << "Radio tuned to " << frequency << " MHz" << std::endl;
        }
    }
    
    void printStatus() const override {
        std::cout << "------------------------------------" << std::endl;
        std::cout << "| Radio Status" << std::endl;
        std::cout << "| Power: " << (on ? "ON" : "OFF") << std::endl;
        std::cout << "| Volume: " << volume << "%" << std::endl;
        std::cout << "| Frequency: " << frequency << " MHz" << std::endl;
        std::cout << "| Channel: " << channel << std::endl;
        std::cout << "------------------------------------" << std::endl;
    }
};

// Abstraction
class RemoteControl {
protected:
    std::unique_ptr<Device> device;

public:
    RemoteControl(std::unique_ptr<Device> device) : device(std::move(device)) {}
    virtual ~RemoteControl() = default;
    
    virtual void togglePower() {
        if (device->isEnabled()) {
            device->disable();
        } else {
            device->enable();
        }
    }
    
    virtual void volumeDown() {
        device->setVolume(device->getVolume() - 10);
    }
    
    virtual void volumeUp() {
        device->setVolume(device->getVolume() + 10);
    }
    
    virtual void channelDown() {
        device->setChannel(device->getChannel() - 1);
    }
    
    virtual void channelUp() {
        device->setChannel(device->getChannel() + 1);
    }
    
    void printDeviceStatus() {
        device->printStatus();
    }
};

// Refined Abstractions
class AdvancedRemoteControl : public RemoteControl {
public:
    AdvancedRemoteControl(std::unique_ptr<Device> device) 
        : RemoteControl(std::move(device)) {}
    
    void mute() {
        device->setVolume(0);
        std::cout << "Device muted" << std::endl;
    }
    
    void setChannel(int channel) {
        device->setChannel(channel);
    }
    
    void recordScene() {
        std::cout << "Scene recorded for later viewing" << std::endl;
    }
};

class VoiceRemoteControl : public RemoteControl {
public:
    VoiceRemoteControl(std::unique_ptr<Device> device) 
        : RemoteControl(std::move(device)) {}
    
    void voiceCommand(const std::string& command) {
        std::cout << "Processing voice command: " << command << std::endl;
        
        if (command == "turn on") {
            device->enable();
        } else if (command == "turn off") {
            device->disable();
        } else if (command == "volume up") {
            volumeUp();
        } else if (command == "volume down") {
            volumeDown();
        } else if (command.find("channel") != std::string::npos) {
            // Simple channel number extraction
            try {
                int channel = std::stoi(command.substr(command.find_last_of(' ') + 1));
                device->setChannel(channel);
            } catch (...) {
                std::cout << "Could not understand channel number" << std::endl;
            }
        } else {
            std::cout << "Command not recognized" << std::endl;
        }
    }
};

// Usage example
int main() {
    std::cout << "=== Bridge Pattern - Remote Control System ===" << std::endl;
    
    // Basic remote with TV
    std::cout << "\n1. Basic Remote with TV:" << std::endl;
    auto basicRemote = std::make_unique<RemoteControl>(std::make_unique<TV>("Living Room"));
    basicRemote->togglePower();
    basicRemote->volumeUp();
    basicRemote->channelUp();
    basicRemote->printDeviceStatus();
    
    // Advanced remote with Radio
    std::cout << "\n2. Advanced Remote with Radio:" << std::endl;
    auto advancedRemote = std::make_unique<AdvancedRemoteControl>(std::make_unique<Radio>());
    advancedRemote->togglePower();
    advancedRemote->setChannel(105);
    advancedRemote->mute();
    advancedRemote->recordScene();
    advancedRemote->printDeviceStatus();
    
    // Voice remote with TV
    std::cout << "\n3. Voice Remote with TV:" << std::endl;
    auto voiceRemote = std::make_unique<VoiceRemoteControl>(std::make_unique<TV>("Bedroom"));
    voiceRemote->voiceCommand("turn on");
    voiceRemote->voiceCommand("volume up");
    voiceRemote->voiceCommand("channel 5");
    voiceRemote->voiceCommand("turn off");
    voiceRemote->printDeviceStatus();
    
    // Same remote type with different devices
    std::cout << "\n4. Same Remote Type with Different Devices:" << std::endl;
    std::vector<std::unique_ptr<RemoteControl>> remotes;
    remotes.push_back(std::make_unique<AdvancedRemoteControl>(std::make_unique<TV>("Kitchen")));
    remotes.push_back(std::make_unique<AdvancedRemoteControl>(std::make_unique<Radio>()));
    
    for (auto& remote : remotes) {
        remote->togglePower();
        remote->volumeUp();
        remote->printDeviceStatus();
    }
    
    return 0;
}
```

#### Shape and Renderer Bridge Example

```cpp
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <cmath>

// Implementation interface - Renderer
class Renderer {
public:
    virtual ~Renderer() = default;
    virtual void renderCircle(float x, float y, float radius) = 0;
    virtual void renderRectangle(float x, float y, float width, float height) = 0;
    virtual void renderTriangle(float x1, float y1, float x2, float y2, float x3, float y3) = 0;
    virtual std::string getName() const = 0;
};

// Concrete Implementations - Different rendering methods
class VectorRenderer : public Renderer {
public:
    void renderCircle(float x, float y, float radius) override {
        std::cout << "Drawing a vector circle at (" << x << ", " << y 
                  << ") with radius " << radius << std::endl;
    }
    
    void renderRectangle(float x, float y, float width, float height) override {
        std::cout << "Drawing a vector rectangle at (" << x << ", " << y 
                  << ") with size " << width << "x" << height << std::endl;
    }
    
    void renderTriangle(float x1, float y1, float x2, float y2, float x3, float y3) override {
        std::cout << "Drawing a vector triangle with points (" 
                  << x1 << ", " << y1 << "), (" << x2 << ", " << y2 
                  << "), (" << x3 << ", " << y3 << ")" << std::endl;
    }
    
    std::string getName() const override {
        return "Vector Renderer";
    }
};

class RasterRenderer : public Renderer {
public:
    void renderCircle(float x, float y, float radius) override {
        std::cout << "Rasterizing a circle at (" << x << ", " << y 
                  << ") with radius " << radius << " pixels" << std::endl;
    }
    
    void renderRectangle(float x, float y, float width, float height) override {
        std::cout << "Rasterizing a rectangle at (" << x << ", " << y 
                  << ") with size " << width << "x" << height << " pixels" << std::endl;
    }
    
    void renderTriangle(float x1, float y1, float x2, float y2, float x3, float y3) override {
        std::cout << "Rasterizing a triangle with points (" 
                  << x1 << ", " << y1 << "), (" << x2 << ", " << y2 
                  << "), (" << x3 << ", " << y3 << ") pixels" << std::endl;
    }
    
    std::string getName() const override {
        return "Raster Renderer";
    }
};

class OpenGLRenderer : public Renderer {
public:
    void renderCircle(float x, float y, float radius) override {
        std::cout << "OpenGL: Rendering circle (VAO) at (" << x << ", " << y 
                  << ") with radius " << radius << std::endl;
    }
    
    void renderRectangle(float x, float y, float width, float height) override {
        std::cout << "OpenGL: Rendering rectangle (VBO) at (" << x << ", " << y 
                  << ") with size " << width << "x" << height << std::endl;
    }
    
    void renderTriangle(float x1, float y1, float x2, float y2, float x3, float y3) override {
        std::cout << "OpenGL: Rendering triangle (EBO) with vertices (" 
                  << x1 << ", " << y1 << "), (" << x2 << ", " << y2 
                  << "), (" << x3 << ", " << y3 << ")" << std::endl;
    }
    
    std::string getName() const override {
        return "OpenGL Renderer";
    }
};

// Abstraction - Shape
class Shape {
protected:
    std::unique_ptr<Renderer> renderer;
    float x, y;

public:
    Shape(std::unique_ptr<Renderer> renderer, float x = 0, float y = 0) 
        : renderer(std::move(renderer)), x(x), y(y) {}
    virtual ~Shape() = default;
    
    virtual void draw() = 0;
    virtual void resize(float factor) = 0;
    virtual void move(float newX, float newY) {
        x = newX;
        y = newY;
    }
    
    virtual std::string getName() const = 0;
    
    void printInfo() const {
        std::cout << getName() << " at (" << x << ", " << y 
                  << ") using " << renderer->getName() << std::endl;
    }
};

// Refined Abstractions - Different shapes
class Circle : public Shape {
private:
    float radius;

public:
    Circle(std::unique_ptr<Renderer> renderer, float x, float y, float radius) 
        : Shape(std::move(renderer), x, y), radius(radius) {}
    
    void draw() override {
        std::cout << "Drawing Circle: ";
        renderer->renderCircle(x, y, radius);
    }
    
    void resize(float factor) override {
        radius *= factor;
        std::cout << "Circle resized to radius " << radius << std::endl;
    }
    
    std::string getName() const override {
        return "Circle";
    }
    
    float getArea() const {
        return M_PI * radius * radius;
    }
};

class Rectangle : public Shape {
private:
    float width, height;

public:
    Rectangle(std::unique_ptr<Renderer> renderer, float x, float y, float width, float height) 
        : Shape(std::move(renderer), x, y), width(width), height(height) {}
    
    void draw() override {
        std::cout << "Drawing Rectangle: ";
        renderer->renderRectangle(x, y, width, height);
    }
    
    void resize(float factor) override {
        width *= factor;
        height *= factor;
        std::cout << "Rectangle resized to " << width << "x" << height << std::endl;
    }
    
    std::string getName() const override {
        return "Rectangle";
    }
    
    float getArea() const {
        return width * height;
    }
};

class Triangle : public Shape {
private:
    float x2, y2, x3, y3;

public:
    Triangle(std::unique_ptr<Renderer> renderer, 
             float x1, float y1, float x2, float y2, float x3, float y3) 
        : Shape(std::move(renderer), x1, y1), x2(x2), y2(y2), x3(x3), y3(y3) {}
    
    void draw() override {
        std::cout << "Drawing Triangle: ";
        renderer->renderTriangle(x, y, x2, y2, x3, y3);
    }
    
    void resize(float factor) override {
        x2 = x + (x2 - x) * factor;
        y2 = y + (y2 - y) * factor;
        x3 = x + (x3 - x) * factor;
        y3 = y + (y3 - y) * factor;
        std::cout << "Triangle resized by factor " << factor << std::endl;
    }
    
    void move(float newX, float newY) override {
        float dx = newX - x;
        float dy = newY - y;
        Shape::move(newX, newY);
        x2 += dx;
        y2 += dy;
        x3 += dx;
        y3 += dy;
    }
    
    std::string getName() const override {
        return "Triangle";
    }
};

// Usage example
void shapeRenderingDemo() {
    std::cout << "=== Bridge Pattern - Shape Rendering System ===" << std::endl;
    
    // Different shapes with different renderers
    std::vector<std::unique_ptr<Shape>> shapes;
    
    // Circle with Vector renderer
    shapes.push_back(std::make_unique<Circle>(
        std::make_unique<VectorRenderer>(), 10, 20, 5
    ));
    
    // Circle with Raster renderer
    shapes.push_back(std::make_unique<Circle>(
        std::make_unique<RasterRenderer>(), 50, 60, 8
    ));
    
    // Rectangle with OpenGL renderer
    shapes.push_back(std::make_unique<Rectangle>(
        std::make_unique<OpenGLRenderer>(), 30, 40, 15, 10
    ));
    
    // Triangle with Vector renderer
    shapes.push_back(std::make_unique<Triangle>(
        std::make_unique<VectorRenderer>(), 5, 5, 15, 5, 10, 15
    ));
    
    // Draw all shapes
    std::cout << "\nDrawing all shapes:" << std::endl;
    for (auto& shape : shapes) {
        shape->printInfo();
        shape->draw();
    }
    
    // Resize and move shapes
    std::cout << "\nModifying shapes:" << std::endl;
    shapes[0]->resize(2.0f);  // Enlarge first circle
    shapes[1]->move(100, 100); // Move second circle
    shapes[2]->resize(0.5f);  // Shrink rectangle
    
    // Redraw modified shapes
    std::cout << "\nRedrawing modified shapes:" << std::endl;
    for (auto& shape : shapes) {
        shape->printInfo();
        shape->draw();
    }
    
    // Demonstrate same shape with different renderers
    std::cout << "\nSame Circle with Different Renderers:" << std::endl;
    auto circle1 = std::make_unique<Circle>(std::make_unique<VectorRenderer>(), 0, 0, 10);
    auto circle2 = std::make_unique<Circle>(std::make_unique<RasterRenderer>(), 0, 0, 10);
    auto circle3 = std::make_unique<Circle>(std::make_unique<OpenGLRenderer>(), 0, 0, 10);
    
    circle1->draw();
    circle2->draw();
    circle3->draw();
}

int main() {
    shapeRenderingDemo();
    return 0;
}
```

### C Implementation

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Implementation interface - MessageSender
typedef struct MessageSender {
    void (*send)(struct MessageSender* self, const char* message, const char* recipient);
    void (*connect)(struct MessageSender* self);
    void (*disconnect)(struct MessageSender* self);
    char* (*get_type)(struct MessageSender* self);
} MessageSender;

// Concrete Implementations
typedef struct {
    MessageSender base;
    char* server_url;
} EmailSender;

void email_send(MessageSender* self, const char* message, const char* recipient) {
    EmailSender* email = (EmailSender*)self;
    printf("EmailSender: Sending email to %s\n", recipient);
    printf("  Server: %s\n", email->server_url);
    printf("  Message: %s\n", message);
}

void email_connect(MessageSender* self) {
    printf("EmailSender: Connecting to SMTP server...\n");
}

void email_disconnect(MessageSender* self) {
    printf("EmailSender: Disconnecting from SMTP server...\n");
}

char* email_get_type(MessageSender* self) {
    return "Email";
}

EmailSender* create_email_sender(const char* server_url) {
    EmailSender* email = malloc(sizeof(EmailSender));
    email->base.send = email_send;
    email->base.connect = email_connect;
    email->base.disconnect = email_disconnect;
    email->base.get_type = email_get_type;
    email->server_url = strdup(server_url);
    return email;
}

void destroy_email_sender(EmailSender* email) {
    free(email->server_url);
    free(email);
}

typedef struct {
    MessageSender base;
    char* api_key;
} SMSSender;

void sms_send(MessageSender* self, const char* message, const char* recipient) {
    SMSSender* sms = (SMSSender*)self;
    printf("SMSSender: Sending SMS to %s\n", recipient);
    printf("  API Key: %s\n", sms->api_key);
    printf("  Message: %s\n", message);
}

void sms_connect(MessageSender* self) {
    printf("SMSSender: Connecting to SMS gateway...\n");
}

void sms_disconnect(MessageSender* self) {
    printf("SMSSender: Disconnecting from SMS gateway...\n");
}

char* sms_get_type(MessageSender* self) {
    return "SMS";
}

SMSSender* create_sms_sender(const char* api_key) {
    SMSSender* sms = malloc(sizeof(SMSSender));
    sms->base.send = sms_send;
    sms->base.connect = sms_connect;
    sms->base.disconnect = sms_disconnect;
    sms->base.get_type = sms_get_type;
    sms->api_key = strdup(api_key);
    return sms;
}

void destroy_sms_sender(SMSSender* sms) {
    free(sms->api_key);
    free(sms);
}

typedef struct {
    MessageSender base;
    char* webhook_url;
} SlackSender;

void slack_send(MessageSender* self, const char* message, const char* recipient) {
    SlackSender* slack = (SlackSender*)self;
    printf("SlackSender: Sending message to channel %s\n", recipient);
    printf("  Webhook: %s\n", slack->webhook_url);
    printf("  Message: %s\n", message);
}

void slack_connect(MessageSender* self) {
    printf("SlackSender: Connecting to Slack API...\n");
}

void slack_disconnect(MessageSender* self) {
    printf("SlackSender: Disconnecting from Slack API...\n");
}

char* slack_get_type(MessageSender* self) {
    return "Slack";
}

SlackSender* create_slack_sender(const char* webhook_url) {
    SlackSender* slack = malloc(sizeof(SlackSender));
    slack->base.send = slack_send;
    slack->base.connect = slack_connect;
    slack->base.disconnect = slack_disconnect;
    slack->base.get_type = slack_get_type;
    slack->webhook_url = strdup(webhook_url);
    return slack;
}

void destroy_slack_sender(SlackSender* slack) {
    free(slack->webhook_url);
    free(slack);
}

// Abstraction - Message
typedef struct Message {
    MessageSender* sender;
    char* content;
    char* recipient;
    
    void (*send)(struct Message* self);
    void (*set_content)(struct Message* self, const char* content);
    void (*set_recipient)(struct Message* self, const char* recipient);
    char* (*get_info)(struct Message* self);
} Message;

void message_send(Message* self) {
    printf("Message: Preparing to send...\n");
    self->sender->connect(self->sender);
    self->sender->send(self->sender, self->content, self->recipient);
    self->sender->disconnect(self->sender);
}

void message_set_content(Message* self, const char* content) {
    free(self->content);
    self->content = strdup(content);
}

void message_set_recipient(Message* self, const char* recipient) {
    free(self->recipient);
    self->recipient = strdup(recipient);
}

char* message_get_info(Message* self) {
    char* info = malloc(256);
    sprintf(info, "Message [%s] to %s via %s", 
            self->content, self->recipient, self->sender->get_type(self->sender));
    return info;
}

// Refined Abstractions
typedef struct {
    Message base;
    int priority;
    char* subject;
} UrgentMessage;

void urgent_message_send(Message* self) {
    UrgentMessage* urgent = (UrgentMessage*)self;
    printf("URGENT (Priority %d): ", urgent->priority);
    message_send(self);
}

char* urgent_message_get_info(Message* self) {
    UrgentMessage* urgent = (UrgentMessage*)self;
    char* base_info = message_get_info(self);
    char* info = malloc(strlen(base_info) + 50);
    sprintf(info, "URGENT %d - %s - %s", urgent->priority, urgent->subject, base_info);
    free(base_info);
    return info;
}

UrgentMessage* create_urgent_message(MessageSender* sender, int priority, const char* subject) {
    UrgentMessage* urgent = malloc(sizeof(UrgentMessage));
    urgent->base.sender = sender;
    urgent->base.content = strdup("");
    urgent->base.recipient = strdup("");
    urgent->base.send = urgent_message_send;
    urgent->base.set_content = message_set_content;
    urgent->base.set_recipient = message_set_recipient;
    urgent->base.get_info = urgent_message_get_info;
    urgent->priority = priority;
    urgent->subject = strdup(subject);
    return urgent;
}

void destroy_urgent_message(UrgentMessage* urgent) {
    free(urgent->base.content);
    free(urgent->base.recipient);
    free(urgent->subject);
    free(urgent);
}

typedef struct {
    Message base;
    char* template_name;
    int retry_count;
} TemplateMessage;

void template_message_send(Message* self) {
    TemplateMessage* template_msg = (TemplateMessage*)self;
    printf("Template '%s': ", template_msg->template_name);
    
    for (int i = 0; i <= template_msg->retry_count; i++) {
        printf("Attempt %d: ", i + 1);
        message_send(self);
        if (i < template_msg->retry_count) {
            printf("  Retrying...\n");
        }
    }
}

char* template_message_get_info(Message* self) {
    TemplateMessage* template_msg = (TemplateMessage*)self;
    char* base_info = message_get_info(self);
    char* info = malloc(strlen(base_info) + 100);
    sprintf(info, "Template[%s] (Retries: %d) - %s", 
            template_msg->template_name, template_msg->retry_count, base_info);
    free(base_info);
    return info;
}

TemplateMessage* create_template_message(MessageSender* sender, const char* template_name, int retry_count) {
    TemplateMessage* template_msg = malloc(sizeof(TemplateMessage));
    template_msg->base.sender = sender;
    template_msg->base.content = strdup("");
    template_msg->base.recipient = strdup("");
    template_msg->base.send = template_message_send;
    template_msg->base.set_content = message_set_content;
    template_msg->base.set_recipient = message_set_recipient;
    template_msg->base.get_info = template_message_get_info;
    template_msg->template_name = strdup(template_name);
    template_msg->retry_count = retry_count;
    return template_msg;
}

void destroy_template_message(TemplateMessage* template_msg) {
    free(template_msg->base.content);
    free(template_msg->base.recipient);
    free(template_msg->template_name);
    free(template_msg);
}

// Demo function
void message_system_demo() {
    printf("=== Bridge Pattern - Message System ===\n\n");
    
    // Create different senders (implementations)
    EmailSender* email_sender = create_email_sender("smtp.example.com");
    SMSSender* sms_sender = create_sms_sender("abc123-api-key");
    SlackSender* slack_sender = create_slack_sender("https://hooks.slack.com/xxx");
    
    // Create different message types (abstractions) with different senders
    
    // Urgent email
    printf("1. Urgent Email:\n");
    UrgentMessage* urgent_email = create_urgent_message(
        (MessageSender*)email_sender, 1, "System Alert"
    );
    urgent_email->base.set_content(&urgent_email->base, "Server is down!");
    urgent_email->base.set_recipient(&urgent_email->base, "admin@company.com");
    
    char* info1 = urgent_email->base.get_info(&urgent_email->base);
    printf("Info: %s\n", info1);
    free(info1);
    
    urgent_email->base.send(&urgent_email->base);
    printf("\n");
    
    // Template SMS
    printf("2. Template SMS:\n");
    TemplateMessage* template_sms = create_template_message(
        (MessageSender*)sms_sender, "Welcome", 2
    );
    template_sms->base.set_content(&template_sms->base, "Welcome to our service!");
    template_sms->base.set_recipient(&template_sms->base, "+1234567890");
    
    char* info2 = template_sms->base.get_info(&template_sms->base);
    printf("Info: %s\n", info2);
    free(info2);
    
    template_sms->base.send(&template_sms->base);
    printf("\n");
    
    // Regular Slack message
    printf("3. Regular Slack Message:\n");
    Message* regular_slack = malloc(sizeof(Message));
    regular_slack->sender = (MessageSender*)slack_sender;
    regular_slack->content = strdup("Daily standup in 5 minutes");
    regular_slack->recipient = strdup("#general");
    regular_slack->send = message_send;
    regular_slack->set_content = message_set_content;
    regular_slack->set_recipient = message_set_recipient;
    regular_slack->get_info = message_get_info;
    
    char* info3 = regular_slack->get_info(regular_slack);
    printf("Info: %s\n", info3);
    free(info3);
    
    regular_slack->send(regular_slack);
    printf("\n");
    
    // Cleanup
    destroy_urgent_message(urgent_email);
    destroy_template_message(template_sms);
    free(regular_slack->content);
    free(regular_slack->recipient);
    free(regular_slack);
    
    destroy_email_sender(email_sender);
    destroy_sms_sender(sms_sender);
    destroy_slack_sender(slack_sender);
}

int main() {
    message_system_demo();
    return 0;
}
```

### Python Implementation

#### Notification System Bridge Pattern

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from datetime import datetime
import time

# Implementation Interface - NotificationSender
class NotificationSender(ABC):
    @abstractmethod
    def send(self, message: str, recipient: str) -> bool: ...
    
    @abstractmethod
    def get_type(self) -> str: ...
    
    @abstractmethod
    def connect(self) -> bool: ...
    
    @abstractmethod
    def disconnect(self) -> None: ...

# Concrete Implementations
class EmailSender(NotificationSender):
    def __init__(self, smtp_server: str, port: int = 587):
        self.smtp_server = smtp_server
        self.port = port
        self._connected = False
    
    def connect(self) -> bool:
        print(f"EmailSender: Connecting to {self.smtp_server}:{self.port}")
        self._connected = True
        return True
    
    def disconnect(self) -> None:
        print("EmailSender: Disconnecting from SMTP server")
        self._connected = False
    
    def send(self, message: str, recipient: str) -> bool:
        if not self._connected:
            self.connect()
        
        print(f"EmailSender: Sending email to {recipient}")
        print(f"  Server: {self.smtp_server}:{self.port}")
        print(f"  Message: {message}")
        return True
    
    def get_type(self) -> str:
        return "Email"

class SMSSender(NotificationSender):
    def __init__(self, api_key: str, gateway_url: str):
        self.api_key = api_key
        self.gateway_url = gateway_url
        self._connected = False
    
    def connect(self) -> bool:
        print(f"SMSSender: Connecting to {self.gateway_url}")
        self._connected = True
        return True
    
    def disconnect(self) -> None:
        print("SMSSender: Disconnecting from SMS gateway")
        self._connected = False
    
    def send(self, message: str, recipient: str) -> bool:
        if not self._connected:
            self.connect()
        
        print(f"SMSSender: Sending SMS to {recipient}")
        print(f"  Gateway: {self.gateway_url}")
        print(f"  API Key: {self.api_key[:8]}...")
        print(f"  Message: {message}")
        return True
    
    def get_type(self) -> str:
        return "SMS"

class PushNotificationSender(NotificationSender):
    def __init__(self, service_url: str, app_id: str):
        self.service_url = service_url
        self.app_id = app_id
        self._connected = False
    
    def connect(self) -> bool:
        print(f"PushNotificationSender: Connecting to {self.service_url}")
        self._connected = True
        return True
    
    def disconnect(self) -> None:
        print("PushNotificationSender: Disconnecting from push service")
        self._connected = False
    
    def send(self, message: str, recipient: str) -> bool:
        if not self._connected:
            self.connect()
        
        print(f"PushNotificationSender: Sending push to device {recipient}")
        print(f"  Service: {self.service_url}")
        print(f"  App ID: {self.app_id}")
        print(f"  Message: {message}")
        return True
    
    def get_type(self) -> str:
        return "Push Notification"

class SlackSender(NotificationSender):
    def __init__(self, webhook_url: str, channel: str = "#general"):
        self.webhook_url = webhook_url
        self.default_channel = channel
        self._connected = False
    
    def connect(self) -> bool:
        print(f"SlackSender: Connecting to Slack webhook")
        self._connected = True
        return True
    
    def disconnect(self) -> None:
        print("SlackSender: Disconnecting from Slack")
        self._connected = False
    
    def send(self, message: str, recipient: str) -> bool:
        if not self._connected:
            self.connect()
        
        channel = recipient if recipient.startswith('#') else self.default_channel
        print(f"SlackSender: Sending message to {channel}")
        print(f"  Webhook: {self.webhook_url[:30]}...")
        print(f"  Message: {message}")
        return True
    
    def get_type(self) -> str:
        return "Slack"

# Abstraction - Notification
class Notification(ABC):
    def __init__(self, sender: NotificationSender):
        self.sender = sender
        self._sent_count = 0
    
    @abstractmethod
    def send(self, recipient: str) -> bool: ...
    
    @abstractmethod
    def get_content(self) -> str: ...
    
    def get_info(self) -> Dict[str, Any]:
        return {
            "type": self.__class__.__name__,
            "sender_type": self.sender.get_type(),
            "sent_count": self._sent_count,
            "content": self.get_content()
        }

# Refined Abstractions
class SimpleNotification(Notification):
    def __init__(self, sender: NotificationSender, title: str, message: str):
        super().__init__(sender)
        self.title = title
        self.message = message
    
    def send(self, recipient: str) -> bool:
        full_message = f"{self.title}: {self.message}"
        success = self.sender.send(full_message, recipient)
        if success:
            self._sent_count += 1
        return success
    
    def get_content(self) -> str:
        return f"{self.title}: {self.message}"

class UrgentNotification(Notification):
    def __init__(self, sender: NotificationSender, message: str, priority: int = 1):
        super().__init__(sender)
        self.message = message
        self.priority = priority
        self.timestamp = datetime.now()
    
    def send(self, recipient: str) -> bool:
        urgent_message = f"🚨 URGENT (P{self.priority}) - {self.message} - {self.timestamp.strftime('%H:%M:%S')}"
        success = self.sender.send(urgent_message, recipient)
        if success:
            self._sent_count += 1
        return success
    
    def get_content(self) -> str:
        return f"URGENT P{self.priority}: {self.message}"

class TemplateNotification(Notification):
    def __init__(self, sender: NotificationSender, template_name: str, **variables):
        super().__init__(sender)
        self.template_name = template_name
        self.variables = variables
        self._load_template()
    
    def _load_template(self):
        # In real implementation, this would load from file/database
        self.templates = {
            "welcome": "Welcome {name}! Thank you for joining {service}.",
            "alert": "ALERT: {system} is experiencing {issue}. Status: {status}",
            "reminder": "Reminder: {event} is scheduled for {time}",
            "summary": "Daily Summary: {metrics} - Generated at {timestamp}"
        }
    
    def send(self, recipient: str) -> bool:
        template = self.templates.get(self.template_name, "{message}")
        try:
            message = template.format(**self.variables)
        except KeyError as e:
            message = f"Template error: missing variable {e}"
        
        success = self.sender.send(message, recipient)
        if success:
            self._sent_count += 1
        return success
    
    def get_content(self) -> str:
        return f"Template[{self.template_name}] with {len(self.variables)} variables"

class ScheduledNotification(Notification):
    def __init__(self, sender: NotificationSender, message: str, delay_seconds: int = 0):
        super().__init__(sender)
        self.message = message
        self.delay_seconds = delay_seconds
        self.scheduled_time = datetime.now()
    
    def send(self, recipient: str) -> bool:
        if self.delay_seconds > 0:
            print(f"ScheduledNotification: Waiting {self.delay_seconds} seconds...")
            time.sleep(min(self.delay_seconds, 2))  # Cap for demo
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        full_message = f"[{timestamp}] {self.message}"
        
        success = self.sender.send(full_message, recipient)
        if success:
            self._sent_count += 1
        return success
    
    def get_content(self) -> str:
        return f"Scheduled: {self.message} (delay: {self.delay_seconds}s)"

# Notification Manager using Bridge pattern
class NotificationManager:
    def __init__(self):
        self.notifications: List[Notification] = []
    
    def add_notification(self, notification: Notification) -> None:
        self.notifications.append(notification)
    
    def send_all(self, recipient: str) -> None:
        print(f"\n=== Sending all notifications to {recipient} ===")
        for i, notification in enumerate(self.notifications, 1):
            print(f"\n{i}. Sending {notification.__class__.__name__}:")
            print(f"   Info: {notification.get_info()}")
            notification.send(recipient)
    
    def get_stats(self) -> Dict[str, Any]:
        total_sent = sum(notification._sent_count for notification in self.notifications)
        sender_types = {}
        
        for notification in self.notifications:
            sender_type = notification.sender.get_type()
            sender_types[sender_type] = sender_types.get(sender_type, 0) + notification._sent_count
        
        return {
            "total_notifications": len(self.notifications),
            "total_sent": total_sent,
            "sender_breakdown": sender_types
        }

# Demo function
def notification_system_demo():
    print("=== Bridge Pattern - Notification System ===\n")
    
    # Create different senders (implementations)
    email_sender = EmailSender("smtp.gmail.com", 587)
    sms_sender = SMSSender("abc123xyz", "https://sms-gateway.com/api")
    push_sender = PushNotificationSender("https://push-service.com", "app-12345")
    slack_sender = SlackSender("https://hooks.slack.com/services/xxx/yyy/zzz")
    
    # Create notification manager
    manager = NotificationManager()
    
    # Add different notification types (abstractions) with different senders
    
    # Simple email notification
    simple_email = SimpleNotification(
        email_sender, 
        "System Update", 
        "Your system has been updated successfully."
    )
    manager.add_notification(simple_email)
    
    # Urgent SMS notification
    urgent_sms = UrgentNotification(
        sms_sender,
        "Database connection failed",
        priority=1
    )
    manager.add_notification(urgent_sms)
    
    # Template push notification
    template_push = TemplateNotification(
        push_sender,
        "welcome",
        name="John Doe",
        service="MyApp Pro"
    )
    manager.add_notification(template_push)
    
    # Scheduled Slack notification
    scheduled_slack = ScheduledNotification(
        slack_sender,
        "Daily standup meeting starting now",
        delay_seconds=1
    )
    manager.add_notification(scheduled_slack)
    
    # Send all notifications
    manager.send_all("user@example.com")
    
    # Show statistics
    print(f"\n=== Notification Statistics ===")
    stats = manager.get_stats()
    for key, value in stats.items():
        if isinstance(value, dict):
            print(f"{key}:")
            for k, v in value.items():
                print(f"  {k}: {v}")
        else:
            print(f"{key}: {value}")
    
    # Demonstrate flexibility: same notification type with different senders
    print(f"\n=== Same Notification Type, Different Senders ===")
    welcome_message = "Welcome to our platform!"
    
    welcome_email = SimpleNotification(email_sender, "Welcome", welcome_message)
    welcome_sms = SimpleNotification(sms_sender, "Welcome", welcome_message)
    welcome_push = SimpleNotification(push_sender, "Welcome", welcome_message)
    
    welcome_notifications = [welcome_email, welcome_sms, welcome_push]
    
    for notification in welcome_notifications:
        print(f"\nSending welcome via {notification.sender.get_type()}:")
        notification.send("new_user@example.com")
        print(f"Info: {notification.get_info()}")

if __name__ == "__main__":
    notification_system_demo()
```

#### Database ORM Bridge Pattern

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional
from datetime import datetime
import json

# Implementation Interface - DatabaseDriver
class DatabaseDriver(ABC):
    @abstractmethod
    def connect(self, connection_string: str) -> bool: ...
    
    @abstractmethod
    def disconnect(self) -> None: ...
    
    @abstractmethod
    def execute_query(self, query: str, params: Dict = None) -> List[Dict]: ...
    
    @abstractmethod
    def execute_command(self, command: str, params: Dict = None) -> int: ...
    
    @abstractmethod
    def get_driver_name(self) -> str: ...

# Concrete Implementations - Different Database Drivers
class PostgreSQLDriver(DatabaseDriver):
    def __init__(self):
        self._connected = False
        self._connection_string = ""
    
    def connect(self, connection_string: str) -> bool:
        self._connection_string = connection_string
        self._connected = True
        print(f"PostgreSQLDriver: Connected to {connection_string}")
        return True
    
    def disconnect(self) -> None:
        self._connected = False
        print("PostgreSQLDriver: Disconnected")
    
    def execute_query(self, query: str, params: Dict = None) -> List[Dict]:
        if not self._connected:
            raise ConnectionError("Not connected to database")
        
        print(f"PostgreSQLDriver: Executing query: {query}")
        if params:
            print(f"  Parameters: {params}")
        
        # Simulate query execution and result
        return [
            {"id": 1, "name": "PostgreSQL Result 1", "created_at": datetime.now()},
            {"id": 2, "name": "PostgreSQL Result 2", "created_at": datetime.now()}
        ]
    
    def execute_command(self, command: str, params: Dict = None) -> int:
        if not self._connected:
            raise ConnectionError("Not connected to database")
        
        print(f"PostgreSQLDriver: Executing command: {command}")
        if params:
            print(f"  Parameters: {params}")
        
        # Simulate affected rows
        return 1
    
    def get_driver_name(self) -> str:
        return "PostgreSQL"

class MySQLDriver(DatabaseDriver):
    def __init__(self):
        self._connected = False
        self._connection_string = ""
    
    def connect(self, connection_string: str) -> bool:
        self._connection_string = connection_string
        self._connected = True
        print(f"MySQLDriver: Connected to {connection_string}")
        return True
    
    def disconnect(self) -> None:
        self._connected = False
        print("MySQLDriver: Disconnected")
    
    def execute_query(self, query: str, params: Dict = None) -> List[Dict]:
        if not self._connected:
            raise ConnectionError("Not connected to database")
        
        print(f"MySQLDriver: Executing query: {query}")
        if params:
            print(f"  Parameters: {params}")
        
        # Simulate query execution and result
        return [
            {"id": 1, "name": "MySQL Result 1", "created": datetime.now()},
            {"id": 2, "name": "MySQL Result 2", "created": datetime.now()}
        ]
    
    def execute_command(self, command: str, params: Dict = None) -> int:
        if not self._connected:
            raise ConnectionError("Not connected to database")
        
        print(f"MySQLDriver: Executing command: {command}")
        if params:
            print(f"  Parameters: {params}")
        
        # Simulate affected rows
        return 1
    
    def get_driver_name(self) -> str:
        return "MySQL"

class SQLiteDriver(DatabaseDriver):
    def __init__(self):
        self._connected = False
        self._database_file = ""
    
    def connect(self, connection_string: str) -> bool:
        self._database_file = connection_string
        self._connected = True
        print(f"SQLiteDriver: Connected to database file: {connection_string}")
        return True
    
    def disconnect(self) -> None:
        self._connected = False
        print("SQLiteDriver: Disconnected")
    
    def execute_query(self, query: str, params: Dict = None) -> List[Dict]:
        if not self._connected:
            raise ConnectionError("Not connected to database")
        
        print(f"SQLiteDriver: Executing query: {query}")
        if params:
            print(f"  Parameters: {params}")
        
        # Simulate query execution and result
        return [
            {"id": 1, "name": "SQLite Result 1", "timestamp": datetime.now()},
            {"id": 2, "name": "SQLite Result 2", "timestamp": datetime.now()}
        ]
    
    def execute_command(self, command: str, params: Dict = None) -> int:
        if not self._connected:
            raise ConnectionError("Not connected to database")
        
        print(f"SQLiteDriver: Executing command: {command}")
        if params:
            print(f"  Parameters: {params}")
        
        # Simulate affected rows
        return 1
    
    def get_driver_name(self) -> str:
        return "SQLite"

# Abstraction - Repository
class Repository(ABC):
    def __init__(self, driver: DatabaseDriver, connection_string: str):
        self.driver = driver
        self.connection_string = connection_string
        self._connected = False
    
    def connect(self) -> bool:
        self._connected = self.driver.connect(self.connection_string)
        return self._connected
    
    def disconnect(self) -> None:
        self.driver.disconnect()
        self._connected = False
    
    @abstractmethod
    def get_table_name(self) -> str: ...
    
    @abstractmethod
    def find_by_id(self, id: Any) -> Optional[Dict]: ...
    
    @abstractmethod
    def find_all(self) -> List[Dict]: ...
    
    @abstractmethod
    def save(self, entity: Dict) -> bool: ...
    
    @abstractmethod
    def delete(self, id: Any) -> bool: ...

# Refined Abstractions - Different Repository Types
class UserRepository(Repository):
    def get_table_name(self) -> str:
        return "users"
    
    def find_by_id(self, id: Any) -> Optional[Dict]:
        query = f"SELECT * FROM {self.get_table_name()} WHERE id = %(id)s"
        results = self.driver.execute_query(query, {"id": id})
        return results[0] if results else None
    
    def find_all(self) -> List[Dict]:
        query = f"SELECT * FROM {self.get_table_name()}"
        return self.driver.execute_query(query)
    
    def save(self, entity: Dict) -> bool:
        if 'id' in entity and entity['id']:
            # Update existing
            query = f"""
                UPDATE {self.get_table_name()} 
                SET name = %(name)s, email = %(email)s, updated_at = %(updated_at)s
                WHERE id = %(id)s
            """
            params = {
                "id": entity['id'],
                "name": entity['name'],
                "email": entity['email'],
                "updated_at": datetime.now()
            }
        else:
            # Insert new
            query = f"""
                INSERT INTO {self.get_table_name()} (name, email, created_at)
                VALUES (%(name)s, %(email)s, %(created_at)s)
            """
            params = {
                "name": entity['name'],
                "email": entity['email'],
                "created_at": datetime.now()
            }
        
        affected = self.driver.execute_command(query, params)
        return affected > 0
    
    def delete(self, id: Any) -> bool:
        query = f"DELETE FROM {self.get_table_name()} WHERE id = %(id)s"
        affected = self.driver.execute_command(query, {"id": id})
        return affected > 0
    
    def find_by_email(self, email: str) -> Optional[Dict]:
        query = f"SELECT * FROM {self.get_table_name()} WHERE email = %(email)s"
        results = self.driver.execute_query(query, {"email": email})
        return results[0] if results else None

class ProductRepository(Repository):
    def get_table_name(self) -> str:
        return "products"
    
    def find_by_id(self, id: Any) -> Optional[Dict]:
        query = f"SELECT * FROM {self.get_table_name()} WHERE id = %(id)s"
        results = self.driver.execute_query(query, {"id": id})
        return results[0] if results else None
    
    def find_all(self) -> List[Dict]:
        query = f"SELECT * FROM {self.get_table_name()}"
        return self.driver.execute_query(query)
    
    def save(self, entity: Dict) -> bool:
        if 'id' in entity and entity['id']:
            # Update existing
            query = f"""
                UPDATE {self.get_table_name()} 
                SET name = %(name)s, price = %(price)s, category = %(category)s
                WHERE id = %(id)s
            """
            params = {
                "id": entity['id'],
                "name": entity['name'],
                "price": entity['price'],
                "category": entity['category']
            }
        else:
            # Insert new
            query = f"""
                INSERT INTO {self.get_table_name()} (name, price, category, created_at)
                VALUES (%(name)s, %(price)s, %(category)s, %(created_at)s)
            """
            params = {
                "name": entity['name'],
                "price": entity['price'],
                "category": entity['category'],
                "created_at": datetime.now()
            }
        
        affected = self.driver.execute_command(query, params)
        return affected > 0
    
    def delete(self, id: Any) -> bool:
        query = f"DELETE FROM {self.get_table_name()} WHERE id = %(id)s"
        affected = self.driver.execute_command(query, {"id": id})
        return affected > 0
    
    def find_by_category(self, category: str) -> List[Dict]:
        query = f"SELECT * FROM {self.get_table_name()} WHERE category = %(category)s"
        return self.driver.execute_query(query, {"category": category})

class OrderRepository(Repository):
    def get_table_name(self) -> str:
        return "orders"
    
    def find_by_id(self, id: Any) -> Optional[Dict]:
        query = f"SELECT * FROM {self.get_table_name()} WHERE id = %(id)s"
        results = self.driver.execute_query(query, {"id": id})
        return results[0] if results else None
    
    def find_all(self) -> List[Dict]:
        query = f"SELECT * FROM {self.get_table_name()}"
        return self.driver.execute_query(query)
    
    def save(self, entity: Dict) -> bool:
        if 'id' in entity and entity['id']:
            # Update existing
            query = f"""
                UPDATE {self.get_table_name()} 
                SET user_id = %(user_id)s, total = %(total)s, status = %(status)s
                WHERE id = %(id)s
            """
            params = {
                "id": entity['id'],
                "user_id": entity['user_id'],
                "total": entity['total'],
                "status": entity['status']
            }
        else:
            # Insert new
            query = f"""
                INSERT INTO {self.get_table_name()} (user_id, total, status, created_at)
                VALUES (%(user_id)s, %(total)s, %(status)s, %(created_at)s)
            """
            params = {
                "user_id": entity['user_id'],
                "total": entity['total'],
                "status": entity['status'],
                "created_at": datetime.now()
            }
        
        affected = self.driver.execute_command(query, params)
        return affected > 0
    
    def delete(self, id: Any) -> bool:
        query = f"DELETE FROM {self.get_table_name()} WHERE id = %(id)s"
        affected = self.driver.execute_command(query, {"id": id})
        return affected > 0
    
    def find_by_user(self, user_id: Any) -> List[Dict]:
        query = f"SELECT * FROM {self.get_table_name()} WHERE user_id = %(user_id)s"
        return self.driver.execute_query(query, {"user_id": user_id})

# Database Manager using Bridge pattern
class DatabaseManager:
    def __init__(self):
        self.repositories: List[Repository] = []
    
    def add_repository(self, repository: Repository) -> None:
        self.repositories.append(repository)
    
    def connect_all(self) -> bool:
        print("=== Connecting to all databases ===")
        success = True
        for repo in self.repositories:
            if not repo.connect():
                success = False
                print(f"Failed to connect {repo.get_table_name()} repository")
        return success
    
    def disconnect_all(self) -> None:
        print("=== Disconnecting from all databases ===")
        for repo in self.repositories:
            repo.disconnect()
    
    def demonstrate_operations(self) -> None:
        print("\n=== Demonstrating Database Operations ===")
        for repo in self.repositories:
            print(f"\n--- {repo.__class__.__name__} ({repo.driver.get_driver_name()}) ---")
            
            # Find all
            print("Find all:")
            all_entities = repo.find_all()
            for entity in all_entities:
                print(f"  {entity}")
            
            # Save new entity
            print("Save new entity:")
            new_entity = self._create_sample_entity(repo)
            if repo.save(new_entity):
                print("  Save successful")
            
            # Find by ID
            print("Find by ID:")
            found = repo.find_by_id(1)
            if found:
                print(f"  Found: {found}")

    def _create_sample_entity(self, repo: Repository) -> Dict:
        if isinstance(repo, UserRepository):
            return {"name": "John Doe", "email": "john@example.com"}
        elif isinstance(repo, ProductRepository):
            return {"name": "Sample Product", "price": 99.99, "category": "Electronics"}
        elif isinstance(repo, OrderRepository):
            return {"user_id": 1, "total": 199.98, "status": "pending"}
        else:
            return {"name": "Sample Entity"}

# Demo function
def database_orm_demo():
    print("=== Bridge Pattern - Database ORM System ===\n")
    
    # Create different database drivers (implementations)
    postgres_driver = PostgreSQLDriver()
    mysql_driver = MySQLDriver()
    sqlite_driver = SQLiteDriver()
    
    # Create database manager
    db_manager = DatabaseManager()
    
    # Add repositories (abstractions) with different drivers
    
    # User repository with PostgreSQL
    user_repo = UserRepository(
        postgres_driver, 
        "host=localhost port=5432 dbname=myapp user=admin password=secret"
    )
    db_manager.add_repository(user_repo)
    
    # Product repository with MySQL
    product_repo = ProductRepository(
        mysql_driver,
        "host=localhost port=3306 dbname=myapp user=root password=secret"
    )
    db_manager.add_repository(product_repo)
    
    # Order repository with SQLite
    order_repo = OrderRepository(
        sqlite_driver,
        "/path/to/database.sqlite"
    )
    db_manager.add_repository(order_repo)
    
    # Connect and demonstrate operations
    if db_manager.connect_all():
        db_manager.demonstrate_operations()
        db_manager.disconnect_all()
    
    # Demonstrate same repository type with different drivers
    print(f"\n=== Same Repository Type, Different Drivers ===")
    
    user_repos = [
        UserRepository(postgres_driver, "postgres_connection_string"),
        UserRepository(mysql_driver, "mysql_connection_string"),
        UserRepository(sqlite_driver, "sqlite_connection_string")
    ]
    
    for user_repo in user_repos:
        print(f"\nUserRepository with {user_repo.driver.get_driver_name()}:")
        user_repo.connect()
        
        # Demonstrate operations
        users = user_repo.find_all()
        print(f"  Found {len(users)} users")
        
        user_repo.disconnect()

if __name__ == "__main__":
    database_orm_demo()
```

## Advantages and Disadvantages

### Advantages

- **Decoupling**: Separates abstraction from implementation completely
- **Single Responsibility**: Each class focuses on either abstraction or implementation
- **Open/Closed**: Both hierarchies can be extended independently
- **Platform Independence**: Implementation can be switched at runtime
- **Avoids Explosion**: Prevents class explosion in multi-dimensional scenarios

### Disadvantages

- **Increased Complexity**: Adds more classes and interfaces to the codebase
- **Double Indirection**: May impact performance due to additional method calls
- **Design Overhead**: Requires careful design to identify the right abstraction boundaries
- **Understanding Curve**: Can be harder for developers to understand initially

## Best Practices

1. **Identify Orthogonal Dimensions**: Look for independent variations in your domain
2. **Prefer Composition**: Use composition to bridge abstraction and implementation
3. **Design for Extensibility**: Both hierarchies should be easy to extend
4. **Keep Interfaces Clean**: Abstraction and implementation interfaces should be focused
5. **Use for Platform-Specific Code**: Ideal for cross-platform development

## Bridge vs Other Patterns

- **vs Adapter**: Bridge is designed upfront for independent evolution, Adapter makes existing classes work together
- **vs Strategy**: Bridge deals with structural relationships, Strategy deals with behavioral variations
- **vs Abstract Factory**: Bridge separates abstraction from implementation, Abstract Factory creates families of objects
- **vs Decorator**: Bridge separates interface hierarchy, Decorator adds responsibilities dynamically

The Bridge pattern is particularly useful when you have multiple orthogonal dimensions in your class hierarchy, when you want to avoid permanent binding between abstraction and implementation, or when you need to share implementations among multiple objects while keeping them decoupled.
