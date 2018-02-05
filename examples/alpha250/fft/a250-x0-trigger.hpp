/// (c) Koheron

#ifndef __A250_X0_TRIGGER_HPP__
#define __A250_X0_TRIGGER_HPP__

#include <context.hpp>
#include <array>

class A250_X0_Trigger
{
  public:
    A250_X0_Trigger(Context& ctx)
    : i2c(ctx.i2c.get("i2c-1"))
    {}

    int32_t set_threshold(float voltage) {
        constexpr float vref = 2.5; // V
        constexpr uint32_t i2c_address = 0b0101111;

        uint8_t value = voltage * 255 / vref;

        std::array<uint8_t, 2> buff {0b00010000, value};
        return i2c.write(i2c_address, buff);
    }

  private:
    I2cDev& i2c;
};

#endif // __A250_X0_TRIGGER_HPP__