import oebakery
import oelite.baker
import logging
import setup
import os
import sys

description = "Build something"


def add_parser_options(parser):
    oelite.baker.add_bake_parser_options(parser)
    parser.add_option("-d", "--debug",
                      action="store_true", default=False,
                      help="Debug the OE-lite metadata")
    parser.add_option("--debug-loglines",
                      action="store", default=42, metavar="N",
                      help="Show last N lines of logfiles of failed tasks (default: 42)")
    parser.add_option("-s", "--skip-os-check",
                      action="store_true", default=False, metavar="skip_os_check",
                      help="Skip supported OS check")
    return


def parse_args(options, args):
    if options.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    else:
        logging.getLogger().setLevel(logging.INFO)

def os_check(config):
    distro, release = setup.get_host_distro()
    if distro and release:
        setup_file, supported = setup.get_setup_file(config, distro, release)
        if supported:
            return True

    if distro and release:
        print('WARNING: Host distribution (%s %s) has not been validated'%(distro, release))
    else:
        print("WARNING: Cannot determine host distribution")

    response = 'n'

    if os.isatty(sys.stdin.fileno()):
        while True:
            try:
                response = raw_input(
                    "Do you want to continue [Y/n]? ")
            except KeyboardInterrupt:
                print
                response = 'n'
            response = response.lower()
            if response == '':
                response = 'y'
            if response in ('y', 'n'):
                print
                break

    if response == 'n':
        print "Maybe another time"
        return False
    return True

def run(options, args, config):

    if not options.skip_os_check:
        if not os_check(config):
            return 1

    try:
        baker = oelite.baker.OEliteBaker(options, args, config)
    except oelite.parse.ParseError as e:
        print "\nParse error"
        e.print_details()
        print
        return "Parse error"
    return baker.bake()
