#ifndef __ALPHA_DRIVERS_SPI_CONFIG_HPP__
#define __ALPHA_DRIVERS_SPI_CONFIG_HPP__

#include <context.hpp>

#include <mutex>

class SpiConfig {
  public:
    SpiConfig(Context& ctx)
    : adc_dac_ctl(ctx.mm.get<mem::adc_dac_ctl>())
    , adc_dac_sts(ctx.mm.get<mem::adc_dac_sts>())
    {}

    // cs_id: Index of the slave on the bus
    // nbytes: Number of bytes send per packet
    template<uint8_t cs_id, uint8_t nbytes>
    void write_reg(uint32_t data) {
        static_assert(nbytes > 0, "Empty packet");
        static_assert(nbytes <= 4, "Max. 4 bytes per packet");
        static_assert(cs_id <= 2, "Exceeds maximum number of slaves on SPI config bus");

        // Locking is required since a second thread could write to
        // registers just after the polling loop exits from the first thread
        std::lock_guard<std::mutex> lock(mtx);

        // Wait for previous write to finish
        while (adc_dac_sts.read<0>() == 0);

        constexpr uint32_t TVALID_IDX = 8;
        constexpr uint32_t cmd = (1 << TVALID_IDX) + ((nbytes - 1) << 2) + cs_id;
        adc_dac_ctl.write<4>(data);
        adc_dac_ctl.write<0>(cmd);
        adc_dac_ctl.clear_bit<0, TVALID_IDX>();
    }

  private:
    Memory<mem::adc_dac_ctl>& adc_dac_ctl;
    Memory<mem::adc_dac_sts>& adc_dac_sts;
    std::mutex mtx;
};

#endif // __ALPHA_DRIVERS_SPI_CONFIG_HPP__