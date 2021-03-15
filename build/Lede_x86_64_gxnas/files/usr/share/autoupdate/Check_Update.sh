#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001

rm -f /tmp/cloud_version
if [ ! -f /bin/AutoUpdate.sh ];then
	echo "未检测到 /bin/AutoUpdate.sh" > /tmp/cloud_version
	exit
fi
CURRENT_DEVICE="$(awk 'NR==3' /etc/openwrt_info)"
Firmware_COMP1="$(awk 'NR==5' /etc/openwrt_info)"
Firmware_COMP2="$(awk 'NR==6' /etc/openwrt_info)"
[[ -z "${CURRENT_DEVICE}" ]] && CURRENT_DEVICE="$(jsonfilter -e '@.model.id' < "/etc/board.json" | tr ',' '_')"
Github="$(awk 'NR==2' /etc/openwrt_info)"
[[ -z "${Github}" ]] && exit
Author="${Github##*com/}"
Github_Tags="https://api.github.com/repos/${Author}/releases/tags/Lede_x86_64_gxnas"
wget -q ${Github_Tags} -O - > /tmp/Github_Tags
Firmware_Type="$(awk 'NR==4' /etc/openwrt_info)"
case ${CURRENT_DEVICE} in
x86-64)
	if [ -d /sys/firmware/efi ];then
		Firmware_SFX="-UEFI.${Firmware_Type}"
		BOOT_Type="-UEFI"
	else
		Firmware_SFX="-Legacy.${Firmware_Type}"
		BOOT_Type="-Legacy"
	fi
;;
*)
	Firmware_SFX=".${Firmware_Type}"
	BOOT_Type=""
;;
esac
Cloud_Ver="$(cat /tmp/Github_Tags | egrep -o "${Firmware_COMP1}-${Firmware_COMP2}-${CURRENT_DEVICE}-[0-9]+.*?[0-9]+${Firmware_SFX}" | awk 'END {print}' | egrep -o '[a-zA-Z0-9_-]+.*?[0-9]+')"
Cloud_Version="${Cloud_Ver#*${Firmware_COMP1}-}"
CURRENT_Version="$(awk 'NR==1' /etc/openwrt_info)"
if [[ ! -z "${Cloud_Version}" ]];then
	if [[ "${CURRENT_Version}" == "${Cloud_Version}" ]];then
		Checked_Type="已是最新"
	else
		Checked_Type="可更新"
	fi
	echo "${Cloud_Version}${BOOT_Type} [${Checked_Type}]" > /tmp/cloud_version
else
	echo "当前网络不佳或云端固件已删除" > /tmp/cloud_version
fi
exit
