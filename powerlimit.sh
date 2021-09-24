ac_adapter=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
if [ "$ac_adapter" = "on" ]; then
	echo $ac_adapter
	# MSR
	# PL1
	echo 26000000 | sudo tee /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw # 33 watt
	echo 28000000 | sudo tee /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us # 28 sec
	# PL2
	echo 26000000 | sudo tee /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw # 33 watt
	echo 2440 | sudo tee /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_time_window_us # 0.00244 sec

	# MCHBAR
	# PL1
	echo 26000000 | sudo tee /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw # 33 watt
	# ^ Only required change on a ASUS Zenbook UX430UNR
	echo 28000000 | sudo tee /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_time_window_us # 28 sec
	# PL2
	echo 26000000 | sudo tee /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_power_limit_uw # 33 watt
	echo 2440 | sudo tee /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_time_window_us # 0.00244 sec
fi
