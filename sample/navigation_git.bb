SUMMARY     = "AGL Reference On Demand Navigation application."
DESCRIPTION = "This application provides the function of Navigation to AGL. "
HOMEPAGE    = "https://oss-project.tmc-tokai.jp/gitlab/AppsDev/HMI-FW-V0.9/navigation"
SECTION     = "apps"

LICENSE     = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ae6497158920d9524cf208c09cc4c984"

USERNAME = "zhou_xin"
PASSWORD = "1qaz!QAZ"

SRC_URI = "git://oss-project.tmc-tokai.jp/gitlab/AppsDev/HMI-FW-V0.9/navigation.git;protocol=http;branch=master;user=${USERNAME}:${PASSWORD}"
SRCREV  = "${AUTOREV}"

DEPENDS += " qtbase qtquickcontrols2 \
             qlibhomescreen \
             qlibwindowmanager \
             qtlocation qtaglextras \
           "

RDEPENDS_${PN} += " qtlocation \
                    flite openjtalk \
                  "

RPROVIDES_${PN} = "virtual/navigation"

inherit qmake5 aglwgt pkgconfig

S = "${WORKDIR}/git"

PATH_prepend = "${STAGING_DIR_NATIVE}${OE_QMAKE_PATH_QT_BINS}:"
