// diskio-Bridging-Header.h
typedef void (*SpeedUpdateCallback)(double writeSpeed, double readSpeed);

void perform_speed_test(const char* path, long long fileSize, const char* format, int testCount, const char* unit, double* writeSpeed, double* readSpeed, SpeedUpdateCallback callback);
