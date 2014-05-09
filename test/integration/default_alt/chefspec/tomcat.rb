require 'default_alt'

RSpec.configure do |c|
end

describe 'jdemo::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs tomcat' do
    expect(chef_run).to install_package('tomcat')
  end
end