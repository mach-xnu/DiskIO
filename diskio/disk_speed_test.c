#include "disk_speed_test.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>

typedef void (*SpeedUpdateCallback)(double writeSpeed, double readSpeed);

double calculate_speed(long long bytes, double seconds, const char* unit) {
    double speed = (double)bytes / seconds;
    if (strcmp(unit, "GB/s") == 0) {
        return speed / (1024 * 1024 * 1024);
    } else if (strcmp(unit, "MB/s") == 0) {
        return speed / (1024 * 1024);
    } else if (strcmp(unit, "KB/s") == 0) {
        return speed / 1024;
    } else {
        return speed;
    }
}

double calculate_iops(long long operations, double seconds) {
    return operations / seconds;
}

void perform_speed_test(const char* path, long long fileSize, const char* format, int testCount, const char* unit, double* writeSpeed, double* readSpeed, SpeedUpdateCallback callback) {
    size_t chunkSize;
    int queueDepth;

    if (strcmp(format, "SEQ1M QD8") == 0) {
        chunkSize = 1 * 1024 * 1024; // 1MB
        queueDepth = 8;
    } else if (strcmp(format, "SEQ1M QD1") == 0) {
        chunkSize = 1 * 1024 * 1024; // 1MB
        queueDepth = 1;
    } else if (strcmp(format, "RND4K QD64") == 0) {
        chunkSize = 4 * 1024; // 4KB
        queueDepth = 64;
    } else if (strcmp(format, "RND4K QD1") == 0) {
        chunkSize = 4 * 1024; // 4KB
        queueDepth = 1;
    } else {
        chunkSize = 1 * 1024 * 1024; // default to 1MB
        queueDepth = 1;
    }

    char* buffer = (char*)malloc(chunkSize);
    if (buffer == NULL) {
        perror("Memory allocation failed");
        return;
    }

    memset(buffer, 0, chunkSize);
    struct timespec start, end, lastUpdate;
    double totalWriteTime = 0.0, totalReadTime = 0.0;
    long long totalWriteOps = 0, totalReadOps = 0;
    const double updateInterval = 0.1;

    long long accumulatedWriteOps = 0;
    long long accumulatedReadOps = 0;

    // write speed test
    int fd = open(path, O_CREAT | O_WRONLY, 0666);
    if (fd == -1) {
        perror("Error opening file for writing");
        free(buffer);
        return;
    }
    for (int i = 0; i < testCount; i++) {
        lseek(fd, 0, SEEK_SET);
        clock_gettime(CLOCK_MONOTONIC, &start);
        clock_gettime(CLOCK_MONOTONIC, &lastUpdate);
        for (long long j = 0; j < fileSize; j += chunkSize) {
            if (write(fd, buffer, chunkSize) != chunkSize) {
                perror("Write error");
                close(fd);
                free(buffer);
                return;
            }
            accumulatedWriteOps++;

            clock_gettime(CLOCK_MONOTONIC, &end);
            double elapsed = (end.tv_sec - lastUpdate.tv_sec) + (end.tv_nsec - lastUpdate.tv_nsec) / 1e9;
            if (elapsed >= updateInterval) {
                if (strcmp(unit, "IOPS") == 0) {
                    double currentWriteIOPS = calculate_iops(accumulatedWriteOps, elapsed);
                    if (isfinite(currentWriteIOPS)) {
                        callback(currentWriteIOPS, 0);
                    }
                } else {
                    double currentWriteSpeed = calculate_speed(accumulatedWriteOps * chunkSize, elapsed, unit);
                    if (isfinite(currentWriteSpeed)) {
                        callback(currentWriteSpeed, 0);
                    }
                }
                lastUpdate = end;
                totalWriteOps += accumulatedWriteOps;
                accumulatedWriteOps = 0;
            }
        }
        clock_gettime(CLOCK_MONOTONIC, &end);
        totalWriteTime += (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
        totalWriteOps += accumulatedWriteOps;
        accumulatedWriteOps = 0;
    }
    close(fd);

    // read speed test
    fd = open(path, O_RDONLY);
    if (fd == -1) {
        perror("Error opening file for reading");
        free(buffer);
        return;
    }
    for (int i = 0; i < testCount; i++) {
        lseek(fd, 0, SEEK_SET);
        clock_gettime(CLOCK_MONOTONIC, &start);
        clock_gettime(CLOCK_MONOTONIC, &lastUpdate);
        for (long long j = 0; j < fileSize; j += chunkSize) {
            if (read(fd, buffer, chunkSize) != chunkSize) {
                perror("Read error");
                close(fd);
                free(buffer);
                return;
            }
            accumulatedReadOps++;

            clock_gettime(CLOCK_MONOTONIC, &end);
            double elapsed = (end.tv_sec - lastUpdate.tv_sec) + (end.tv_nsec - lastUpdate.tv_nsec) / 1e9;
            if (elapsed >= updateInterval) {
                if (strcmp(unit, "IOPS") == 0) {
                    double currentReadIOPS = calculate_iops(accumulatedReadOps, elapsed);
                    if (isfinite(currentReadIOPS)) {
                        callback(0, currentReadIOPS);
                    }
                } else {
                    double currentReadSpeed = calculate_speed(accumulatedReadOps * chunkSize, elapsed, unit);
                    if (isfinite(currentReadSpeed)) {
                        callback(0, currentReadSpeed);
                    }
                }
                lastUpdate = end;
                totalReadOps += accumulatedReadOps;
                accumulatedReadOps = 0;
            }
        }
        clock_gettime(CLOCK_MONOTONIC, &end);
        totalReadTime += (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
        totalReadOps += accumulatedReadOps;
        accumulatedReadOps = 0;
    }
    close(fd);

    // final IOPS or throughput calculation
    if (strcmp(unit, "IOPS") == 0) {
        *writeSpeed = calculate_iops(totalWriteOps, totalWriteTime);
        *readSpeed = calculate_iops(totalReadOps, totalReadTime);
    } else {
        *writeSpeed = calculate_speed(fileSize * testCount, totalWriteTime, unit);
        *readSpeed = calculate_speed(fileSize * testCount, totalReadTime, unit);
    }

    free(buffer);
    unlink(path); // clean up the test file
}
