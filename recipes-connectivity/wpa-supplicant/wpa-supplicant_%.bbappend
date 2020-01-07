FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append += " \
	file://wpa_supplicant.conf-uhf \
	file://wpa_supplicant.conf-sample \
	"

do_install_append() {
	rm -rf ${D}${sysconfdir}/wpa_supplicant.conf
	install -m 600 ${WORKDIR}/wpa_supplicant.conf-uhf ${D}${sysconfdir}/wpa_supplicant.conf
	install -m 600 ${WORKDIR}/wpa_supplicant.conf-sample ${D}${sysconfdir}/wpa_supplicant.conf-sample
}
