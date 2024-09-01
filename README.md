# DiskIO

<p align="center">
  <img src="https://i.imgur.com/4XEPLPP.png" alt="DiskIO Logo" width="150"/>
</p>

<p align="center">
  <strong>Measure and visualize your Mac's disk performance with ease</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#understanding-results">Understanding Results</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

DiskIO is a macOS application designed to help you measure, analyze, and visualize disk I/O performance. Whether you're a system administrator, a tech enthusiast, or simply curious about your Mac's (or even an external drive!) storage capabilities, DiskIO provides detailed insights through a variety of disk speed tests and real-time visualizations.

## Features

- 🚀 **Multiple Test Formats**: SEQ1M QD8, SEQ1M QD1, RND4K QD64, RND4K QD1
- 📊 **Real-time Visualization**: Speed gauges and interactive graphs
- 📋 **Detailed Results View**: Comprehensive table with write and read speeds
- ⚙️ **Customizable Tests**: Adjustable size, count, and units
- 💾 **Disk Selection**: Test different volumes, including external drives
- ℹ️ **Disk Information Display**: View detailed specs of selected disks

## Installation

1. Go to the [Releases](https://github.com/oct4pie/diskio/releases) page.
2. Download the latest version of DiskIO.
3. Drag the DiskIO application to your Applications folder.
4. Right-click and select "Open" to bypass Gatekeeper on first launch.

## Usage

1. **Select a Disk**: Choose the volume you want to test from the dropdown.

2. **Configure Your Test**:
   - **Test Size**: Choose from 16 MiB to 64 GiB (larger = more accurate, but slower).
   - **Test Count**: Set how many times each test should run (1-10).
   - **Unit**: Select MB/s, GB/s, KB/s, or IOPS.

3. **Run the Test**: Click "Start" and watch the real-time results.

4. **Review Results**: Analyze the speed gauges, interactive graph, and detailed table.

### 💡 Pro Tips

- Use 1 GiB+ test sizes for more accurate results (avoids caching effects).
- Run 3+ tests for consistent results.
- Choose units based on your drive:
  - MB/s for most drives
  - GB/s for fast NVMe
  - IOPS for enterprise SSDs

## Understanding Results

- **SEQ1M QD8**: Max throughput (like big file transfers)
- **SEQ1M QD1**: Single-threaded, large file operations
- **RND4K QD64**: Heavy multi-threaded performance
- **RND4K QD1**: Worst-case scenario, typical for many apps

Remember:
- Sequential > Random (usually)
- SSDs > HDDs (especially in random tests)
- Performance varies with disk health and system load

## Troubleshooting

- 🔒 **Unexpected results?** Choose larger test sizes. Close other applications.
- 🐌 **Taking too long?** Try a smaller test size.
- 🔌 **External drive not showing?** Close and reopen DiskIO.
- 🐞 **Other issues?** Check Console.app and report on our GitHub issues.

## Contributing

Feel free to submit a Pull Request or create an Issue for bugs and feature requests.

## Development

Developed in Xcode 14.0+

```bash
git clone https://github.com/oct4pie/diskio.git
cd diskio
open DiskIO.xcodeproj
```

## License

MIT License - see [LICENSE](LICENSE) for details.

---
<p align="center">
  <strong>⚠️ Disclaimer:</strong> Use responsibly. Continuous testing may affect SSD lifespan.
</p>
