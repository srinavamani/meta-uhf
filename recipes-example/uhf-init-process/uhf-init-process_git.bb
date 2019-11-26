SUMMARY = "UHF Init Process"
DESCRIPTION = "UHF Project init process"

SECTION = "devel"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${THISDIR}/uhf-init-process/COPYING;md5=eb723b61539feef013de476e68b5c50a"

SRC_URI = "file://${THISDIR}/uhf-init-process;protocol=file \
	   file://uhf-init-process.sh \
	   file://uhf-init-process \
	   file://.aws \
	   file://uhf-download.sh \
	   file://BLE_Student_ID_Scanner \
	   file://timer \
	   "

do_install() {
         install -d ${D}/${sysconfdir}/init.d/
         install -d ${D}/${sysconfdir}/rc5.d/
         install -d ${D}/${sysconfdir}/
	 install -d ${D}/${bindir}
         cp ${WORKDIR}/uhf-init-process.sh ${D}/${sysconfdir}/
         cp -rf ${WORKDIR}/.aws ${D}/${sysconfdir}/
	 cp ${WORKDIR}/uhf-download.sh ${D}/${sysconfdir}/
	 chmod 777 ${D}/${sysconfdir}/uhf-init-process.sh
	 cp ${WORKDIR}/uhf-init-process ${D}/${sysconfdir}/init.d/
	 chmod 777 ${D}/${sysconfdir}/init.d/uhf-init-process
	 ln -s ${sysconfdir}/init.d/uhf-init-process ${D}/${sysconfdir}/rc5.d/S20uhf-init-process
	 cp -rf ${WORKDIR}/BLE_Student_ID_Scanner ${D}/${bindir}/
	 cp -rf ${WORKDIR}/timer ${D}/${bindir}/
}

