SUMMARY = "Qemu automatic ptest runner"
DESCRIPTION = "Core-image-full automatic ptest runner in server"
HOMEPAGE = "http://www.timesys.com"

SECTION = "devel"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${THISDIR}/bbexample/COPYING;md5=eb723b61539feef013de476e68b5c50a"

SRC_URI = "file://${THISDIR}/bbexample;protocol=file \
	   file://ptest_automatic_runner_script.sh \
	   file://ptest_runner_test \
	   "

do_install() {
         install -d ${D}/${sysconfdir}/init.d/
         install -d ${D}/${sysconfdir}/rc5.d/
         install -d ${D}/${sysconfdir}/
         cp ${WORKDIR}/ptest_automatic_runner_script.sh ${D}/${sysconfdir}/
	 chmod 777 ${D}/${sysconfdir}/ptest_automatic_runner_script.sh
	 cp ${WORKDIR}/ptest_runner_test ${D}/${sysconfdir}/init.d/
	 chmod 777 ${D}/${sysconfdir}/init.d/ptest_runner_test
	 ln -s ${sysconfdir}/init.d/ptest_runner_test ${D}/${sysconfdir}/rc5.d/S20ptest_runner_test
}

