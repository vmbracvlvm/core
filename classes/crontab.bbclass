# -*- mode:python; -*-
#
# OE-lite class for handling crontab files
#

addtask install_crontab after do_install before do_fixup

require conf/crontab.conf

RDEPENDS_${PN}:>USE_crontab = "crond"

do_install_crontab[dirs] = "${D}"

python do_install_crontab () {
    import os

    if not d.get('USE_crontab'):
	return

    options = ((d.get('RECIPE_FLAGS') or "").split() +
               (d.get('CLASS_FLAGS') or "").split())
    ddir = d.get('D')
    bb.note('ddir=%s'%ddir)
    crontabdir = d.get('crontabdir')
    crontabdir = '%s%s'%(ddir, crontabdir)
    bb.note('crontabdir=%s'%crontabdir)
    srcdir = d.get('SRCDIR')

    for option in options:

	if not option.endswith('_crontab'):
	    continue

	when = d.get('USE_'+option)
	if not when:
	    continue

	name = option[0:-len('_crontab')]

	crontab_file = bb.data.getVar('CRONTAB_FILE_'+name, d, True)
	if not crontab_file:
	    crontab_file = os.path.join(srcdir, name + '.crontab')

	crontab_user = bb.data.getVar('CRONTAB_USER_'+name, d, True) or 'root'

        out_filename = os.path.join(crontabdir, crontab_user +'.'+ name)

        bb.note('crontabdir=%s'%crontabdir)
	if not os.path.exists(crontabdir):
	    os.makedirs(crontabdir, mode=0755)

        with open(out_filename, 'w') as out_file:
	    with open(crontab_file) as in_file:
                for line in in_file.readlines():
                    out_file.write(when +' '+ line)
        os.chmod(out_filename, 0644)
}
