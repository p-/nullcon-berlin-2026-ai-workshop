#include <cstddef>
#include <cstdint>

bool IsNullcon(const uint8_t *data, size_t size) {
  return size >= 6 &&
         data[0] == 'N' &&
         data[1] == 'u' &&
         data[2] == 'l' &&
         data[3] == 'l' &&
         data[4] == 'c' &&
         data[5] == 'o' &&
         data[6] == 'n';
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  IsNullcon(data, size);
  return 0;
}
