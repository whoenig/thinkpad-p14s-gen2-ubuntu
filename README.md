# Configuration of a ThinkPad P14s Gen2 to work with Ubuntu (20.04)

The Thinkpad P14s Gen2 has good specification for a mobile workstation (Up to 48 GB RAM, up to i7 i7-1165G7, NVIDIA T500 4 GB). However, it doesn't work very well out of the box when installing Ubuntu 20.04: there are issues with respect to BlueTooth, limited CPU power, and inadequate fan control.

## BIOS Settings

* Make sure you have BIOS 1.40 or newer
* In the BIOS (Enter, followed by F1 during boot), change under "Config/Power":
  * Sleep State to "Linux S3" (otherwise fan might be operating during standby)
  * Intel SpeedStep Technology to "On"


## Wifi+BlueTooth

* Update kernel to 5.14 (this will enable WiFi and BlueTooth):

```
sudo add-apt-repository ppa:tuxinvader/lts-mainline
sudo apt update
sudo apt install linux-generic-5.14
```

## Avoid Systemlog errors about i2c HID

If you get many errors when using `dmesg`, try the following:

```

sudo nano /etc/default/grub
exchange this line :
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_osi="
sudo update-grub
reboot
```

## GPU

* Install CUDA, which will also update the NVIDIA graphics driver: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_network
  * Note: in the NVIDIA settings, it is also possible to disable the GPU in favor of the Intel-integrated GPU to conserve battery. This requires a reboot

## CPU Power and Fan control

There are different modes hard-coded in the bios (see https://download.lenovo.com/pccbbs/mobiles_pdf/t14_gen2_t15_gen2_p14s_gen2_p15s_gen2_ug_linux_ug_en.pdf, p. 23):

* Press Fn+L to switch to quiet mode. (limits CPU to 7.5W)
* Press Fn+M to switch to balanced mode. (limits CPU to 10 W)
* Press Fn+H to switch to performance mode. (limits CPU to 20W)

Power limit measured using https://github.com/erpalma/throttled.

Those modes seem to not only control the power limit, but also the fan profile (max RPM and rpm-temperature curve). For example, one can disable the power limit using https://github.com/erpalma/throttled, use the Fn+L mode and the laptop will become very dangerously hot. The following avoids having to switch between the modes and handles everything automatically, depending on your system load.

### Fan Control

Compile and install the latest version:

```
git clone https://github.com/vmatare/thinkfan
cd thinkfan
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install

```

Update Configuration file:

Copy `thinkfan.yaml` to `/etc/thinkfan.yaml`

Enable fan control:

```
echo "options thinkpad_acpi fan_control=1" > /etc/modprobe.d/thinkfan.conf
modprobe thinkpad_acpi

```

Enable on start up:

```
sudo systemctl enable thinkfan.service
sudo nano /etc/modules
add the following lines at the end:
thinkpad_acpi
coretemp
```

### CPU Power

Throttled is not working properly for P14s Gen2, see https://github.com/erpalma/throttled/issues/265.
However, a static fix (originally published by academo and faustusdotbe) works well.

* Install acpi `sudo apt install acpi`
* Create a new folder, e.g., `~/sw/powerlimit`
* Copy `powerlimit.sh` and `wait-watt.sh` to `~/sw/powerlimit` and make them executable (`chmod +x`)
* Update the path in `wattage.service` and copy to `/etc/systemd/system`
* Start end enable the service on reboot

```
sudo systemctl daemon-reload
sudo systemctl start wattage.service
sudo systemctl enable wattage.service
```

## Issues

### Suspend not working

Try purging the nvidia drivers and re-installing it (potentially an older version), see https://forums.developer.nvidia.com/t/black-screen-when-resuming-systemctl-suspend-using-nvidia-driver-470-57-02-with-kernel-5-8-0-63-generic-on-gtx-970-xubuntu-20-04-lts/184644.

## Other

### Avoid Computer stall when low on memory

When running low on main memory, your system can become unresponsive to the point where you need to reboot. Even switching terminals or logging in via ssh will not work in such cases. https://github.com/rfjakob/earlyoom is a good solution, that kills a process before the system enters an unresponsive state. Install via

```
sudo apt install earlyoom
```

### Monitoring wattage, fan speed, CPU temps, GPU usage

Copy `tempwatch` to `/usr/local/bin/` and make it executable: `chmod +x /usr/local/bin/tempwatch`. Opening a new terminal and launching `tempwatch` will allow you to monitor, with a refresh rate of .5s:

- CPU freq for each thread
- Temperature for each core
- Fan speed
- Fan level
- Wattage (in mw)
- Current mode (quiet/balanced/performance)
- GPU usage
