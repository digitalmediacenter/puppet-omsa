require 'spec_helper'

describe 'omsa' do
  let(:facts) {{
    :operatingsystem => 'sles',
    :operatingsystemrelease => '11.3',
  }}
  it do
    should contain_class('omsa::repo')

    should contain_package('srvadmin-all').with({
      :ensure => 'present',
    }).that_requires('Class[omsa::repo]')

    should contain_service('dataeng').with({
      :ensure => 'running',
    }).that_requires('Package[srvadmin-all]')

    should contain_service('dsm_om_connsvc').with({
      :ensure => 'running',
    }).that_requires('Package[srvadmin-all]')
  end
end
