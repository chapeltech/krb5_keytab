#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
	echo "tests/smoke.sh must run as root" >&2
	exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

capture=$tmpdir/capture
output=$capture.out
cat >$capture <<EOF
#!/bin/sh
{
	pwd
	printf '<%s>\\n' "\$@"
} >$output
EOF
chmod 755 $capture

${CC:-cc} ${CFLAGS:-} \
    -DKRB5_KEYTABC_PATH=\"$capture\" \
    -o $tmpdir/krb5_keytab suid_helper/krb5_keytab.c

$tmpdir/krb5_keytab -v -L mitkrb5/1.4 -- -leading 'two words'
cat >$tmpdir/expected <<EOF
/
<-u>
<root>
<-L>
<mitkrb5/1.4>
<-v>
<-->
<-leading>
<two words>
EOF
diff -u $tmpdir/expected $output

$tmpdir/krb5_keytab -c -g
printf '%s\n' '<-?>' >$tmpdir/expected
tail -n 1 $output >$tmpdir/actual
diff -u $tmpdir/expected $tmpdir/actual

test "$(sed -n '1p' scripts/krb5_keytabc)" = '#!/usr/bin/perl'
if grep -q '@@KRB5_KEYTAB_CONF@@' scripts/krb5_keytabc; then
	echo "krb5_keytabc contains an unsubstituted configuration path" >&2
	exit 1
fi
