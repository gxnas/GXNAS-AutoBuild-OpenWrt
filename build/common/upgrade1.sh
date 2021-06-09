#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Functions

GET_TARGET_INFO() {
        TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
        TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
	Compile_Date="$(date +%Y%m%d%H%M)"
	case "${TARGET_PROFILE}" in
	x86-64)
		if [ `grep -c "CONFIG_TARGET_IMAGES_GZIP=y" ${Home}/.config` -eq '1' ]; then
			Firmware_sfxo="img.gz"
		else
			Firmware_sfxo="img"
		fi
	;;
	esac
	case "${REPO_BRANCH}" in
	"master")
		COMP1="coolsnowwolf-18.06"
		COMP2="lede"
		ZUOZHE="Lean's"
		if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
			Up_Firmware="openwrt-x86-64-generic-squashfs-combined.${Firmware_sfxo}"
			EFI_Up_Firmware="openwrt-x86-64-generic-squashfs-combined-efi.${Firmware_sfxo}"
			Firmware_sfx="${Firmware_sfxo}"
		elif [[ "${TARGET_PROFILE}" == "phicomm-k3" ]]; then
			Up_Firmware="openwrt-bcm53xx-generic-phicomm-k3-squashfs.trx"
			Firmware_sfx="trx"
		elif [[ "${TARGET_PROFILE}" =~ (d-team_newifi-d2|phicomm_k2p|phicomm_k2p-32m) ]]; then
			Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
			Firmware_sfx="bin"
		else
			Up_Firmware="${Updete_firmware}"
			Firmware_sfx="${Extension}"
		fi
	;;
	"19.07") 
		COMP1="openwrt-19.07"
		COMP2="lienol"
		ZUOZHE="Lienol's"
		if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
			Up_Firmware="openwrt-x86-64-combined-squashfs.${Firmware_sfxo}"
			EFI_Up_Firmware="openwrt-x86-64-combined-squashfs-efi.${Firmware_sfxo}"
			Firmware_sfx="${Firmware_sfxo}"
		elif [[ "${TARGET_PROFILE}" == "phicomm-k3" ]]; then
			Up_Firmware="openwrt-bcm53xx-phicomm-k3-squashfs.trx"
			Firmware_sfx="trx"
		elif [[ "${TARGET_PROFILE}" =~ (d-team_newifi-d2|k2p) ]]; then
			Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
			Firmware_sfx="bin"
		else
			Up_Firmware="${Updete_firmware}"
			Firmware_sfx="${Extension}"
		fi
	;;
	"openwrt-18.06")
		COMP1="immortalwrt-18.06"
		COMP2="project"
		ZUOZHE="ctcgfw"
		if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
			Up_Firmware="immortalwrt-x86-64-combined-squashfs.${Firmware_sfxo}"
			EFI_Up_Firmware="immortalwrt-x86-64-uefi-gpt-squashfs.${Firmware_sfxo}"
			Firmware_sfx="${Firmware_sfxo}"
		elif [[ "${TARGET_PROFILE}" == "phicomm-k3" ]]; then
			Up_Firmware="immortalwrt-bcm53xx-phicomm-k3-squashfs.trx"
			Firmware_sfx="trx"
		elif [[ "${TARGET_PROFILE}" =~ (d-team_newifi-d2|phicomm_k2p) ]]; then
			Up_Firmware="immortalwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
			Firmware_sfx="bin"
		else
			Up_Firmware="${Updete_firmware}"
			Firmware_sfx="${Extension}"
		fi
	;;
	"openwrt-21.02")
		COMP1="ctcgfw-21.02"
		COMP2="Spirit"
		ZUOZHE="ctcgfw"
		if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
			Up_Firmware="immortalwrt-x86-64-generic-squashfs-combined.${Firmware_sfxo}"
			EFI_Up_Firmware="immortalwrt-x86-64-generic-squashfs-combined-efi.${Firmware_sfxo}"
			Firmware_sfx="${Firmware_sfxo}"
		elif [[ "${TARGET_PROFILE}" == "phicomm-k3" ]]; then
			Up_Firmware="immortalwrt-bcm53xx-phicomm-k3-squashfs.trx"
			Firmware_sfx="trx"
		elif [[ "${TARGET_PROFILE}" =~ (d-team_newifi-d2|phicomm_k2p) ]]; then
			Up_Firmware="immortalwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
			Firmware_sfx="bin"
		else
			Up_Firmware="${Updete_firmware}"
			Firmware_sfx="${Extension}"
		fi
	;;
	esac
	if [[ ${REGULAR_UPDATE} == "true" ]]; then
		AutoUpdate_Version=$(awk 'NR==6' package/base-files/files/bin/AutoUpdate.sh | awk -F '[="]+' '/Version/{print $2}')
		[[ -z "${AutoUpdate_Version}" ]] && AutoUpdate_Version="Unknown"
	fi
	Github_Release="${Github}/releases/download/AutoUpdate"
	Github_Tags="https://api.github.com/repos/${Apidz}/releases/tags/AutoUpdate"
	XiaZai="${Apidz}/releases/download/AutoUpdate"
	Github_UP_RELEASE="${Github}/releases/AutoUpdate"
	In_Firmware_Info="package/base-files/files/etc/openwrt_info"
	Openwrt_Version="${COMP2}-${TARGET_PROFILE}-${Compile_Date}"
}

Diy_Part1() {
	sed -i '/luci-app-autoupdate/d' .config > /dev/null 2>&1
	echo -e "\nCONFIG_PACKAGE_luci-app-autoupdate=y" >> .config
	sed -i '/luci-app-ttyd/d' .config > /dev/null 2>&1
	echo -e "\nCONFIG_PACKAGE_luci-app-ttyd=y" >> .config
}

Diy_Part2() {
	GET_TARGET_INFO
	echo "Github=${Github}" > ${In_Firmware_Info}
	echo "Author=${Author}" >> ${In_Firmware_Info}
	echo "CangKu=${CangKu}" >> ${In_Firmware_Info}
	echo "Luci_Edition=${OpenWrt_name}" >> ${In_Firmware_Info}
	echo "CURRENT_Version=${Openwrt_Version}" >> ${In_Firmware_Info}
	echo "DEFAULT_Device=${TARGET_PROFILE}" >> ${In_Firmware_Info}
	echo "Firmware_Type=${Firmware_sfx}" >> ${In_Firmware_Info}
	echo "Firmware_COMP1=${COMP1}" >> ${In_Firmware_Info}
	echo "Firmware_COMP2=${COMP2}" >> ${In_Firmware_Info}
	echo "Github_Release=${Github_Release}" >> ${In_Firmware_Info}
	echo "Github_Tags=${Github_Tags}" >> ${In_Firmware_Info}
	echo "XiaZai=${XiaZai}" >> ${In_Firmware_Info}
}

Diy_Part3() {
	GET_TARGET_INFO
	Firmware_Path="bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
	Mkdir bin/Firmware
	case "${TARGET_PROFILE}" in
	x86-64)
		cd ${Firmware_Path}
		Legacy_Firmware="${Up_Firmware}"
		EFI_Firmware="${EFI_Up_Firmware}"
		AutoBuild_Firmware="${COMP1}-${Openwrt_Version}"
		if [ -f "${Legacy_Firmware}" ];then
			_MD5=$(md5sum ${Legacy_Firmware} | cut -d ' ' -f1)
			_SHA256=$(sha256sum ${Legacy_Firmware} | cut -d ' ' -f1)
			touch ${Home}/bin/Firmware/${AutoBuild_Firmware}.detail
			echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy.detail
			cp ${Legacy_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy.${Firmware_sfx}
		fi
		if [ -f "${EFI_Firmware}" ];then
			_MD5=$(md5sum ${EFI_Firmware} | cut -d ' ' -f1)
			_SHA256=$(sha256sum ${EFI_Firmware} | cut -d ' ' -f1)
			touch ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI.detail
			echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI.detail
			cp ${EFI_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI.${Firmware_sfx}
		fi
	;;
	*)
		cd ${Home}
		Default_Firmware=""${Up_Firmware}""
		AutoBuild_Firmware="${COMP1}-${Openwrt_Version}.${Firmware_sfx}"
		AutoBuild_Detail="${COMP1}-${Openwrt_Version}.detail"
		echo "Firmware: ${AutoBuild_Firmware}"
		cp ${Firmware_Path}/*${Default_Firmware} bin/Firmware/${AutoBuild_Firmware}
		_MD5=$(md5sum bin/Firmware/${AutoBuild_Firmware} | cut -d ' ' -f1)
		_SHA256=$(sha256sum bin/Firmware/${AutoBuild_Firmware} | cut -d ' ' -f1)
		echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > bin/Firmware/${AutoBuild_Detail}
	;;
	esac
	cd ${Home}
	find ${Home}/bin/Firmware -name "*" -type f -size 0c | xargs -n 1 rm -f
}

Mkdir() {
	_DIR=${1}
	if [ ! -d "${_DIR}" ];then
		mkdir -p ${_DIR}
	fi
	unset _DIR
}

Diy_xinxi() {
	Diy_xinxi_Base
}
