require 'spec_helper'

describe 'omsa::repo' do
  context "on ubuntu" do
    let(:facts) {{
      :operatingsystem => 'ubuntu',
      :lsbdistrelease => '12.04',
      :lsbdistid => 'ubuntu',
    }}
    it do
      should contain_apt__source('osma').with({
        :location    => 'http://linux.dell.com/repo/community/ubuntu',
        :release     => 'precise',
        :repos       => 'openmanage',
        :key         => '1285491434D8786F',
        :key_server  => 'pool.sks-keyservers.net',
        :include_src => false,
      })
    end
  end

  context "on sles" do
    let(:facts) {{
      :operatingsystem => 'sles',
      :operatingsystemrelease => '11.0',
    }}
    it do
      should contain_exec('add-rpm-gpg-key-dell').with({
        :command => 'wget -q -O /tmp/RPM-GPG-KEY-dell http://linux.dell.com/repo/hardware/latest/RPM-GPG-KEY-dell; rpm --import /tmp/RPM-GPG-KEY-dell',
        :unless  => 'rpm -q gpg-pubkey-23b66a9d',
      })

      should contain_exec('add-rpm-gpg-key-libsmbios').with({
        :command =>  'wget -q -O /tmp/RPM-GPG-KEY-libsmbios http://linux.dell.com/repo/hardware/latest/RPM-GPG-KEY-libsmbios; rpm --import /tmp/RPM-GPG-KEY-libsmbios',
        :unless  =>  'rpm -q gpg-pubkey-5e3d7775',
      })

      should contain_zypprepo('dell-omsa-hwindep').with({
        :type => 'rpm-md',
        :baseurl => 'http://linux.dell.com/repo/hardware/latest/platform_independent/suse11_64/',
        :enabled => 1,
        :autorefresh => 0,
      })

      should contain_file('/etc/zypp/repos.d/dell-omsa-hw.repo').with({
        :ensure  =>  'present',
        :replace =>  false,
        :owner   =>  'root',
        :group   =>  'root',
        :mode    =>  '0644',
      })

      should contain_exec('replace-system-dev-id').with({
        :command =>  '/usr/sbin/getSystemId | grep \'^System ID:\' | cut -d: -f2 | tr A-Z a-z | perl -p -i -e \'s/\s*//\' > /tmp/sysdevid;
                         sed -i "s/#DEVID#/$(cat /tmp/sysdevid)/g" /etc/zypp/repos.d/dell-omsa-hw.repo',
        :onlyif  =>  'grep -q "#DEVID#" /etc/zypp/repos.d/dell-omsa-hw.repo',
      })

      should contain_package('yum-dellsysid').with_ensure('present')
      should contain_package('libsmbios2').with_ensure('present')
    end
  end
end
