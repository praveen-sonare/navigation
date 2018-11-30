
DISTFILES = icon.svg config.xml \
    jtalk \
    flite

copy_icon.target = $$OUT_PWD/root/icon.svg
copy_icon.depends = $$_PRO_FILE_PWD_/icon.svg
copy_icon.commands = $(COPY_FILE) \"$$replace(copy_icon.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_icon.target, /, $$QMAKE_DIR_SEP)\"
QMAKE_EXTRA_TARGETS += copy_icon
PRE_TARGETDEPS += $$copy_icon.target

copy_config.target = $$OUT_PWD/root/config.xml
copy_config.depends = $$_PRO_FILE_PWD_/config.xml
copy_config.commands = $(COPY_FILE) \"$$replace(copy_config.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_config.target, /, $$QMAKE_DIR_SEP)\"
QMAKE_EXTRA_TARGETS += copy_config
PRE_TARGETDEPS += $$copy_config.target

copy_jtalk.target = $$OUT_PWD/root/bin/jtalk
copy_jtalk.depends = $$_PRO_FILE_PWD_/jtalk
copy_jtalk.commands = $(COPY_FILE) \"$$replace(copy_jtalk.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_jtalk.target, /, $$QMAKE_DIR_SEP)\"
QMAKE_EXTRA_TARGETS += copy_jtalk
PRE_TARGETDEPS += $$copy_jtalk.target

copy_flite.target = $$OUT_PWD/root/bin/flite
copy_flite.depends = $$_PRO_FILE_PWD_/flite
copy_flite.commands = $(COPY_FILE) \"$$replace(copy_flite.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_flite.target, /, $$QMAKE_DIR_SEP)\"
QMAKE_EXTRA_TARGETS += copy_flite
PRE_TARGETDEPS += $$copy_flite.target

wgt.target = package
wgt.commands = wgtpkg-pack -f -o navigation.wgt root

QMAKE_EXTRA_TARGETS += wgt
