# Disable debuginfo as it causes issues with bundled gems that build libraries
%global debug_package %{nil}
%global repo_name osc-systemstatus
%global app_name systemstatus
%global with_passenger 1
%define ondemand_gems_ver %(rpm --qf "%%{version}" -q ondemand-gems)
%global gem_home %{scl_ondemand_apps_gem_home}/%{app_name}

%if 0%{?with_passenger}
%bcond_without passenger
%else
%bcond_with passenger
%endif

%define __brp_mangle_shebangs /bin/true

%{!?package_release: %define package_release 1}
%{!?git_tag: %define git_tag v%{package_version}}
%define git_tag_minus_v %(echo %{git_tag} | sed -r 's/^v//')

# Work around issue with EL6 builds
# https://stackoverflow.com/a/48801417
%if 0%{?rhel} < 7
%define __strip /opt/rh/devtoolset-6/root/usr/bin/strip
%endif

Name:     ondemand-%{app_name}
Version:  %{package_version}
Release:  %{package_release}%{?dist}
Summary:  System Status for OSC Clusters

Group:    System Environment/Daemons
License:  MIT
URL:      https://github.com/AweSim-OSC/%{repo_name}
Source0:  https://github.com/AweSim-OSC/%{repo_name}/archive/%{git_tag}.tar.gz

BuildRequires:  sqlite-devel curl make
BuildRequires:  ondemand-runtime
BuildRequires:  ondemand-ruby
BuildRequires:  ondemand-nodejs
BuildRequires:  ondemand-scldevel
BuildRequires:  ondemand-gems
Requires:       ondemand
Requires:       ondemand-gems-%{ondemand_gems_ver}

# Disable automatic dependencies as it causes issues with bundled gems and
# node.js packages used in the apps
AutoReqProv: no

%description
This app displays the current system status of available system clusters.


%prep
%setup -q -n %{repo_name}-%{git_tag_minus_v}


%build
scl enable ondemand - << \EOS
%if %{with passenger}
export PASSENGER_APP_ENV=production
export PASSENGER_BASE_URI=/pun/sys/%{app_name}
%endif
export GEM_HOME=$(pwd)/gems-build
export GEM_PATH=$(pwd)/gems-build:$GEM_PATH
bin/setup
EOS


%install
%__mkdir_p %{buildroot}%{gem_home}
%__mv ./gems-build/* %{buildroot}%{gem_home}/

%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/apps/sys/%{app_name}
%__cp -a ./. %{buildroot}%{_localstatedir}/www/ood/apps/sys/%{app_name}/
echo %{git_tag} > %{buildroot}%{_localstatedir}/www/ood/apps/sys/%{app_name}/VERSION
%if %{with passenger}
%__mkdir_p %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/sys
touch %{buildroot}%{_sharedstatedir}/ondemand-nginx/config/apps/sys/%{app_name}.conf
%__mkdir_p %{buildroot}%{_localstatedir}/www/ood/apps/sys/%{app_name}/tmp
touch %{buildroot}%{_localstatedir}/www/ood/apps/sys/%{app_name}/tmp/restart.txt
%endif


%post
%if %{with passenger}
# This NGINX app config needs to exist before it can be rebuilt
touch %{_sharedstatedir}/ondemand-nginx/config/apps/sys/%{app_name}.conf

if [ $1 -eq 1 ]; then
  # Rebuild NGINX app config and restart PUNs w/ no active connections
  /opt/ood/nginx_stage/sbin/update_nginx_stage &>/dev/null || :
fi
%endif


%postun
if [[ $1 -eq 0 ]]; then
%if %{with passenger}
  # On uninstallation restart PUNs w/ no active connections
  /opt/ood/nginx_stage/sbin/update_nginx_stage &>/dev/null || :
%endif
fi


%posttrans
%if %{with passenger}
# Restart app in case PUN wasn't restarted
touch %{_localstatedir}/www/ood/apps/sys/%{app_name}/tmp/restart.txt
%endif


%files
%defattr(-,root,root)
%{gem_home}
%{_localstatedir}/www/ood/apps/sys/%{app_name}
%{_localstatedir}/www/ood/apps/sys/%{app_name}/manifest.yml
%if %{with passenger}
%ghost %{_localstatedir}/www/ood/apps/sys/%{app_name}/tmp/restart.txt
%ghost %{_sharedstatedir}/ondemand-nginx/config/apps/sys/%{app_name}.conf
%endif

%changelog
* Sun Feb 03 2019 Trey Dockendorf <tdockendorf@osc.edu> 2.0.1-4
- Update passenger apps to use new /var/lib/ondemand-nginx paths and new
  ondemand SCL for ondemand 1.5 (tdockendorf@osc.edu)

* Wed Oct 24 2018 Morgan Rodgers <mrodgers@osc.edu> 2.0.1-3
- Bump release on systemstatus so Puppet picks up on the change
  (mrodgers@osc.edu)
- Update dependencies for systemstatus (mrodgers@osc.edu)

* Wed Oct 24 2018 Morgan Rodgers <mrodgers@osc.edu>
- Update dependencies for systemstatus (mrodgers@osc.edu)
- Update pseudofun (mrodgers@osc.edu)

* Thu Sep 13 2018 Morgan Rodgers <mrodgers@osc.edu> 2.0.1-2
- Update systemsetatus to v2.0.1 (mrodgers@osc.edu)

* Wed Sep 12 2018 Morgan Rodgers <mrodgers@osc.edu> 2.0.0-2
- Fix for change from Rails to Sinatra (mrodgers@osc.edu)
- Bump SystemStatus to v2.0.0 (mrodgers@osc.edu)

* Wed Jul 18 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.0-2
- Remove production.log (tdockendorf@osc.edu)

* Wed Mar 07 2018 Trey Dockendorf <tdockendorf@osc.edu> 1.4.0-1
- new package built with tito

