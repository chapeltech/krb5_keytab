Name:           krb5keytab
Version:        0.4
Release:        1%{?dist}
Summary:        Kerberos keytab management helper
License:        MIT
URL:            https://github.com/chapeltech/krb5_keytab
Source0:        krb5_keytab-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  diffutils
BuildRequires:  libkrb5admin-perl >= 0.3
BuildRequires:  make
BuildRequires:  perl

Requires:       libkrb5admin-perl >= 0.3

%description
krb5keytab contains a privileged helper and Perl client for managing Kerberos
keytab entries.

%prep
%autosetup -n krb5_keytab-%{version}
sed -i 's/-Werror//g' suid_helper/Makefile

%build
export CFLAGS="%{optflags}"
%make_build PREFIX=%{_prefix}

%check
/bin/sh tests/smoke.sh

%install
%make_install PREFIX=%{_prefix}

%files
%license debian/copyright
%doc README
%dir %{_sysconfdir}/krb5
%config(noreplace) %{_sysconfdir}/krb5/krb5_keytab.conf
%attr(4755,root,root) %{_sbindir}/krb5_keytab
%{_libexecdir}/krb5_keytabc
%{_mandir}/man5/krb5_keytab.conf.5*
%{_mandir}/man8/krb5_keytab.8*

%changelog
* Wed Aug 05 2026 ChapelTech <packages@chapel.tech> - 0.4-1
- Add Rocky/RHEL packaging.
