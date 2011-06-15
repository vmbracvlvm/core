# -*- mode:python; -*-

require conf/meta.conf

BINCONFIG_GLOB += "${bindir}/*-config"

FILES_${PN}-dev += "${bindir}/*-config ${binconfigmetadir}"

BINCONFIG_FIXUP_STRIP_DIRS  = "${TARGET_SYSROOT} ${D} ${B} ${S}"

FIXUP_FUNCS += "binconfig_fixup"

binconfig_fixup[dirs] = "${D}"
python binconfig_fixup () {

    metadir = bb.data.getVar('binconfigmetadir', d, True).lstrip("/")
    metafile = bb.data.getVar('binconfigfilelist', d, True).lstrip("/")
    bb.utils.mkdirhier(metadir)

    import glob
    binconfig_files = []
    for pattern in bb.data.getVar('BINCONFIG_GLOB', d, True).split():
        binconfig_files += glob.glob(pattern.lstrip("/"))

    with open(metafile, "w") as output_file:
        output_file.write("\n".join(binconfig_files) + "\n")

    strip_dirs = set()
    for strip_dir in d.getVar("BINCONFIG_FIXUP_STRIP_DIRS", True).split():
        strip_dirs.add(strip_dir)
        strip_dirs.add(os.path.realpath(strip_dir))

    import re
    for filename in binconfig_files:
        with open(filename, "r") as input_file:
            binconfig_file = input_file.read()
        for strip_dirs in strip_dirs:
            binconfig_file = re.sub(r"--sysroot=%s(/\S+)"%(strip_dirs),
                                    r"--sysroot=\g<1>", binconfig_file)
            binconfig_file = re.sub(r"--sysroot=%s\s*"%(strip_dirs),
                                    r"", binconfig_file)
            binconfig_file = re.sub(r"-isystem %s"%(strip_dirs),
                                    r"-isystem ", binconfig_file)
            binconfig_file = re.sub(r"-I%s"%(strip_dirs),
                                    r"-I", binconfig_file)
            binconfig_file = re.sub(r"-iquote%s"%(strip_dirs),
                                    r"-iquote", binconfig_file)
            binconfig_file = re.sub(r"-L%s"%(strip_dirs),
                                    r"-L", binconfig_file)
            binconfig_file = re.sub(r"=%s"%(strip_dirs),
                                    r"=", binconfig_file)
        with open(filename, "w") as output_file:
            output_file.write(binconfig_file)
}
