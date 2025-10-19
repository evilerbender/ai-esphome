import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import sensor
from esphome.const import (
    STATE_CLASS_MEASUREMENT,
    UNIT_EMPTY,
    ICON_EMPTY,
)
from . import example_component_ns

DEPENDENCIES = ["example_component"]

ExampleSensor = example_component_ns.class_(
    "ExampleSensor", sensor.Sensor, cg.Component
)

CONFIG_SCHEMA = sensor.sensor_schema(
    ExampleSensor,
    unit_of_measurement=UNIT_EMPTY,
    icon=ICON_EMPTY,
    accuracy_decimals=2,
    state_class=STATE_CLASS_MEASUREMENT,
).extend(cv.COMPONENT_SCHEMA)


async def to_code(config):
    var = await sensor.new_sensor(config)
    await cg.register_component(var, config)
