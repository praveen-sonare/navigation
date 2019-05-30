CONFIG += ordered
TEMPLATE = subdirs
SUBDIRS = app package

equals(DEFINES, "DESKTOP"){
    SUBDIRS -= package
}

package.depends += app
