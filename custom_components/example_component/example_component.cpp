#include "example_component.h"
#include "esphome/core/log.h"

namespace esphome {
namespace example_component {

static const char *const TAG = "example_component";

void ExampleComponent::setup() {
  ESP_LOGCONFIG(TAG, "Setting up Example Component...");
}

void ExampleComponent::loop() {
  uint32_t now = millis();
  if (now - this->last_update_ > 1000) {
    this->last_update_ = now;
  }
}

void ExampleComponent::dump_config() {
  ESP_LOGCONFIG(TAG, "Example Component:");
}

}
}
