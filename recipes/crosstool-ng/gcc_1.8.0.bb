require toolchain.inc

PR = "r1"

BBCLASSEXTEND="cross sdk-cross canadian-cross"

# gcc and glibc versions should be locked down by distro
CT_CC_VERSION			 = "${GCC_VERSION}"
CT_LIBC_VERSION			 = "${GLIBC_VERSION}"

# the rest should be set here
CT_KERNEL_VERSION		?= "2.6.33.6"
CT_LIBC_GLIBC_MIN_KERNEL	?= "2.6.33.6"
CT_BINUTILS_VERSION		?= "2.20.1"
CT_GDB_VERSION			?= "7.1"
CT_GMP_VERSION			?= "4.3.2"
CT_MPFR_VERSION			?= "2.4.2"
CT_PPL_VERSION			?= "0.10.2"
CT_CLOOG_VERSION		?= "0.15.9"
CT_MPC_VERSION			?= "0.8.1"
CT_MINGWRT_VERSION		?= "3.18"
CT_W32API_VERSION		?= "3.14"
