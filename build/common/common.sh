#!/bin/bash
# https://github.com/281677160/build-openwrt
# common Module by 28677160
# matrix.target=${Modelfile}

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31m";;
	g) export Color="\e[32m";;
	b) export Color="\e[34m";;
	y) export Color="\e[33m";;
	z) export Color="\e[35m";;
	l) export Color="\e[36m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}


################################################################################################################
# LEDE源码通用diy.sh文件
################################################################################################################
Diy_lede() {

find . -name 'luci-app-netdata' -o -name 'luci-theme-argon' -o -name 'k3screenctrl' | xargs -i rm -rf {}

sed -i 's/iptables -t nat/# iptables -t nat/g' "${ZZZ}"

sed -i '/IMAGES_GZIP/d' "${PATH1}/${CONFIG_FILE}" > /dev/null 2>&1
echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${PATH1}/${CONFIG_FILE}"

git clone https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh > /dev/null 2>&1" package/base-files/files/etc/rc.local
}


################################################################################################################
# LIENOL源码通用diy.sh文件
################################################################################################################
Diy_lienol() {

find . -name 'luci-app-netdata' -o -name 'luci-theme-argon' | xargs -i rm -rf {}

git clone https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

curl -fsSL https://raw.githubusercontent.com/281677160/AdGuardHome/main/luci-app-adguardhome/root/etc/config/AdGuardHome.yaml > package/diy/luci-app-adguardhome/root/etc/config/AdGuardHome.yaml
curl -fsSL https://raw.githubusercontent.com/281677160/AdGuardHome/main/luci-app-adguardhome/po/zh-cn/AdGuardHome.po > package/diy/luci-app-adguardhome/po/zh-cn/AdGuardHome.po

rm -rf feeds/packages/libs/libcap
svn co https://github.com/coolsnowwolf/packages/trunk/libs/libcap feeds/packages/libs/libcap > /dev/null 2>&1
sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += luci-app-passwall/g' target/linux/x86/Makefile
sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh > /dev/null 2>&1" package/base-files/files/etc/rc.local
}


################################################################################################################
# 天灵源码18.06分支diy.sh文件
################################################################################################################
Diy_1806() {

find . -name 'luci-theme-argonv3' -o -name 'luci-app-argon-config' -o -name 'luci-theme-argon'  | xargs -i rm -rf {}
find . -name 'luci-theme-argonv2' -o -name 'luci-app-timecontrol' | xargs -i rm -rf {}

sed -i "/exit 0/i\sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release" ${ZZZ}
sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh > /dev/null 2>&1" package/base-files/files/etc/rc.local
}


################################################################################################################
# 天灵源码21.02分支diy.sh文件
################################################################################################################
Diy_2102() {

find . -name 'luci-app-argon-config' -o -name 'luci-theme-argon'  | xargs -i rm -rf {}

sed -i "/exit 0/i\sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release" "${ZZZ}"
sed -i "/exit 0/i\chmod +x /etc/webweb.sh && source /etc/webweb.sh > /dev/null 2>&1" package/base-files/files/etc/rc.local
}


################################################################################################################
# 全部作者源码公共diy.sh文件
################################################################################################################
Diy_all() {

git clone --depth 1 -b "${REPO_BRANCH}" https://github.com/281677160/openwrt-package
cp -Rf openwrt-package/* "${Home}" && rm -rf "${Home}"/openwrt-package

cp -Rf "${PATH1}"/AutoBuild_Tools.sh package/base-files/files/bin

if [[ ${REGULAR_UPDATE} == "true" ]]; then
	git clone https://github.com/281677160/luci-app-autoupdate feeds/luci/applications/luci-app-autoupdate
	cp -Rf "${PATH1}"/AutoUpdate.sh package/base-files/files/bin
fi

}


################################################################################################################
# 判断脚本是否缺少主要文件（如果缺少settings.ini设置文件在检测脚本设置就运行错误了）
################################################################################################################
Diy_settings() {
rm -rf ${Home}/build/QUEWENJIANerros
if [ -z "$(ls -A "$PATH1/${CONFIG_FILE}" 2>/dev/null)" ]; then
	echo
	TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -z "$(ls -A "$PATH1/${DIY_PART_SH}" 2>/dev/null)" ]; then
	echo
	TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -n "$(ls -A "${Home}/build/QUEWENJIANerros" 2>/dev/null)" ]; then
rm -rf ${Home}/build/QUEWENJIANerros
exit 1
fi
rm -rf {build,README.md}
}


################################################################################################################
# 判断插件冲突
################################################################################################################
Diy_chajian() {
echo
echo "TIME b \"				插件冲突信息\"" > ${Home}/CHONGTU

if [[ `grep -c "CONFIG_PACKAGE_luci-app-docker=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-dockerman=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-app-dockerman=y/# CONFIG_PACKAGE_luci-app-dockerman is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-lib-docker=y/# CONFIG_PACKAGE_luci-lib-docker is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-docker和luci-app-dockerman，插件有冲突，已删除luci-app-dockerman\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-app-autotimeset=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-autoreboot=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-app-autoreboot=y/# CONFIG_PACKAGE_luci-app-autoreboot is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-autoreboot-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-autoreboot-zh-cn=y is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-autotimeset和luci-app-autoreboot，插件有冲突，已删除luci-app-autoreboot\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-app-advanced=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-filebrowser=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-app-filebrowser=y/# CONFIG_PACKAGE_luci-app-filebrowser is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-filebrowser-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-filebrowser-zh-cn=y is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-advanced和luci-app-filebrowser，插件有冲突，已删除luci-app-filebrowser\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon_new=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-theme-argon_new=y/# CONFIG_PACKAGE_luci-theme-argon_new is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-theme-argon和luci-theme-argon_new，插件有冲突，已删除luci-theme-argon_new\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi

fi
if [[ `grep -c "CONFIG_PACKAGE_luci-app-sfe=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-flowoffload=y" ${Home}/.config` -eq '1' ]]; then
		echo "TIME r \"提示：您同时选择了luci-app-sfe和luci-app-flowoffload，两个ACC网络加速\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
fi
if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" .config` -eq '1' ]]; then
	echo "TIME r \"请注意，您选择了ext4安装的固件格式,请认真看以下说明,避免编译错误\"" > ${Home}/EXT4
	echo "TIME g \"请在Target Images  --->里面的下面两项的数值调整\"" >> ${Home}/EXT4
	echo "TIME g \"（16）Kernel partition size (in MB)\"" >> ${Home}/EXT4
	echo "TIME g \"（160）Root filesystem partition size (in MB)\"" >> ${Home}/EXT4
	echo "TIME g \"请把（16）Kernel partition size (in MB) 设置成（30）Kernel partition size (in MB) 或者更高数值\"" >> ${Home}/EXT4
	echo "TIME g \"请把（160）Root filesystem partition size (in MB) 设置成（950）Root filesystem partition size (in MB) 或者更高数值\"" >> ${Home}/EXT4
	echo "TIME g \"（160）Root filesystem partition size (in MB) 这项设置数值请避免使用‘128’、‘256’、‘512’、‘1024’等之类的数值\"" >> ${Home}/EXT4
	echo "TIME g \"选择了ext4安装格式的固件，（160）Root filesystem partition size (in MB) 这项数值太低容易造成插件空间不足编译错误\"" >> ${Home}/EXT4
	echo "TIME g \" \"" >> ${Home}/EXT4
fi
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo "TIME z \"\"" >>CHONGTU
	echo "TIME g \"  插件冲突会导致编译失败，以上操作如非您所需，请关闭此次编译，重新开始编译，避开冲突重新选择插件\"" >>CHONGTU
	echo "TIME z \"\"" >>CHONGTU
else
	rm -rf CHONGTU
fi
}


################################################################################################################
# 为编译做最后处理
################################################################################################################
Diy_chuli() {
grep -i CONFIG_PACKAGE_luci-app .config | grep  -v \# > Plug-in
grep -i CONFIG_PACKAGE_luci-theme .config | grep  -v \# >> Plug-in
awk '$0=NR$0' Plug-in > Plug-2
sed -i '/INCLUDE/d' Plug-2 > /dev/null 2>&1
sed -i 's/CONFIG_PACKAGE_/、/g' Plug-2
sed -i 's/=y/\"/g' Plug-2
awk '{print "	" $0}' Plug-2 > Plug-in
sed -i "s/^/TIME g \"/g" Plug-in
find . -name 'LICENSE' -o -name 'README' -o -name 'README.md' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'DEVICE_NAME' | xargs -i rm -rf {}
}


################################################################################################################
# 公告
################################################################################################################
GONGGAO() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
	case $1 in
		r) export Color="\e[31;1m";;
		g) export Color="\e[32m";;
		b) export Color="\e[34m";;
		y) export Color="\e[33m";;
		z) export Color="\e[36m";;
	esac
		echo -e "\n\e[35;1m[$(date "+ 公 告 ")]\e[0m ${Color}${2}\e[0m"
	}
}

Diy_gonggao() {
GONGGAO z "《Lede_source文件的Luci版本为18.06，内核版本为5.4》"
GONGGAO g "《Lienol_source文件的Luci版本为19.07，内核版本为4.14》"
GONGGAO b "《Project_source文件的Luci版本为18.06，内核版本为4.19》"
GONGGAO y "《Spirit_source文件的Luci版本为21.02，内核版本为5.4》"
GONGGAO r "《如果编译脚本在这里就出现错误的话，意思就是不得不更新脚本了，怎么更新我会在这里写明》"
echo
echo
}

Diy_tongzhi() {
GONGGAO r "《请用复制粘贴方式来更新你的build-openwrt.yml文件至6月2号凌晨1点后的最新版》"
echo
echo
exit 1
}

################################################################################################################
# 编译信息
################################################################################################################
Diy_xinxi_Base() {
GET_TARGET_INFO
echo
TIME b "编译源码: ${CODE}"
TIME b "源码链接: ${REPO_URL}"
TIME b "源码分支: ${REPO_BRANCH}"
TIME b "源码作者: ${ZUOZHE}"
TIME b "编译机型: ${TARGET_PROFILE}"
TIME b "固件作者: ${Author}"
TIME b "仓库地址: ${Github}"
TIME b "启动编号: #${Run_number}（${CangKu}仓库第${Run_number}次启动[${Run_workflow}]工作流程）"
TIME b "编译时间: $(TZ=UTC-8 date "+%Y年%m月%d号-%H时%M分")"
TIME g "友情提示：您当前使用【${Modelfile}】文件夹编译【${TARGET_PROFILE}】固件"
echo
echo
if [[ ${UPLOAD_FIRMWARE} == "true" ]]; then
	TIME y "上传固件在github actions: 开启"
else
	TIME r "上传固件在github actions: 关闭"
fi
if [[ ${UPLOAD_CONFIG} == "true" ]]; then
	TIME y "上传[.config]配置文件: 开启"
else
	TIME r "上传[.config]配置文件: 关闭"
fi
if [[ ${UPLOAD_BIN_DIR} == "true" ]]; then
	TIME y "上传BIN文件夹(固件+IPK): 开启"
else
	TIME r "上传BIN文件夹(固件+IPK): 关闭"
fi
if [[ ${UPLOAD_COWTRANSFER} == "true" ]]; then
	TIME y "上传固件到到【奶牛快传】和【WETRANSFER】: 开启"
else
	TIME r "上传固件到到【奶牛快传】和【WETRANSFER】: 关闭"
fi
if [[ ${UPLOAD_RELEASE} == "true" ]]; then
	TIME y "发布固件: 开启"
else
	TIME r "发布固件: 关闭"
fi
if [[ ${SERVERCHAN_SCKEY} == "true" ]]; then
	TIME y "微信/电报通知: 开启"
else
	TIME r "微信/电报通知: 关闭"
fi
if [[ ${SSH_ACTIONS} == "true" ]]; then
	TIME y "SSH远程连接: 开启"
else
	TIME r "SSH远程连接: 关闭"
fi
if [[ ${SSHYC} == "true" ]]; then
	TIME y "SSH远程连接临时开关: 开启"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	TIME y "把定时自动更新插件编译进固件: 开启"
else
	TIME r "把定时自动更新插件编译进固件: 关闭"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	echo
	TIME l "定时自动更新信息"
	TIME z "插件版本: ${AutoUpdate_Version}"
	if [[ ${TARGET_PROFILE} == "x86-64" ]]; then
		TIME b "传统固件: ${Up_Firmware}"
		TIME b "UEFI固件: ${EFI_Up_Firmware}"
		TIME b "固件后缀: ${Firmware_sfx}"
	else
		TIME b "固件名称: ${Up_Firmware}"
		TIME b "固件后缀: ${Firmware_sfx}"
	fi
	TIME b "固件版本: ${Openwrt_Version}"
	TIME b "云端路径: ${Github_UP_RELEASE}"
	TIME g "《编译成功，会自动把固件发布到指定地址，然后才会生成云端路径》"
	TIME g "《普通的那个发布固件跟云端的发布路径是两码事，如果你不需要普通发布的可以不用打开发布功能》"
	TIME g "《请把“REPO_TOKEN”密匙设置好,没设置好密匙不能发布就生成不了云端地址》"
	TIME g "《只支持已自动适配固件名字跟后缀机型（x86-64、phicomm_k2p、phicomm-k3、newifi-d2），其他机型请自行适配》"
	TIME g "《x86设备需要适配传统引导的固件格式名字和UEFI引导的固件格式名字，其他设备只需要设置对应安装格式的固件名字就可以了》"
	echo
else
	echo
fi
if [ -n "$(ls -A "${Home}/EXT4" 2>/dev/null)" ]; then
	chmod -R +x ${Home}/EXT4
	source ${Home}/EXT4
	rm -rf EXT4
fi
echo
TIME z " 系统空间      类型   总数  已用  可用 使用率"
cd ../ && df -hT $PWD && cd openwrt
echo
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo
	chmod -R +x ${Home}/CHONGTU
	source ${Home}/CHONGTU
	rm -rf {CHONGTU,Chajianlibiao}
fi
if [ -n "$(ls -A "${Home}/Plug-in" 2>/dev/null)" ]; then
	echo
	TIME r "	      已选插件列表"
	chmod -R +x ${Home}/Plug-in
	source ${Home}/Plug-in
	rm -rf {Plug-in,Plug-2}
	echo
fi
}
