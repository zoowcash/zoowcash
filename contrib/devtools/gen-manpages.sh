#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

ZOOWCASHD=${ZOOWCASHD:-$SRCDIR/zoowcashd}
ZOOWCASHCLI=${ZOOWCASHCLI:-$SRCDIR/zoowcash-cli}
ZOOWCASHTX=${ZOOWCASHTX:-$SRCDIR/zoowcash-tx}
ZOOWCASHQT=${ZOOWCASHQT:-$SRCDIR/qt/zoowcash-qt}

[ ! -x $ZOOWCASHD ] && echo "$ZOOWCASHD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
ZCHVER=($($ZOOWCASHCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$ZOOWCASHD --version | sed -n '1!p' >> footer.h2m

for cmd in $ZOOWCASHD $ZOOWCASHCLI $ZOOWCASHTX $ZOOWCASHQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${ZCHVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${ZCHVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
