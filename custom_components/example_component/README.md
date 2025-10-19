# Example Custom Component for ESPHome

This directory contains an example custom component structure for ESPHome.

## Structure

```
example_component/
├── __init__.py           # Component registration and config schema
├── example_component.h   # C++ header file
├── example_component.cpp # C++ implementation
├── sensor.py            # Sensor platform (optional)
└── README.md            # This file
```

## Usage in Device Config

```yaml
external_components:
  - source:
      type: local
      path: custom_components

example_component:
  id: my_example
```

## Creating Your Own Component

1. Copy this directory structure
2. Rename files and classes
3. Implement your logic in `.cpp` and `.h`
4. Define config schema in `__init__.py`
5. Add platform files (sensor.py, switch.py, etc.) as needed

## References

- [ESPHome Custom Components Guide](https://esphome.io/custom/custom_component.html)
- [Component Structure](https://esphome.io/custom/custom_component.html#custom-component-structure)
