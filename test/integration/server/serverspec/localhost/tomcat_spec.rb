require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

# confirm the java install
describe command('java -version') do
  its(:stderr) { should match /java version \"1.7/ }
  it { should return_exit_status 0 }
end

describe package('tomcat') do
  it { should be_installed }
end

describe port(8080) do
  it { should be_listening }
end

describe file('/var/lib/tomcat6/webapps/punter.war') do
  it { should be_file }
end

describe file('/var/lib/tomcat6/webapps/punter') do
  it { should be_directory }
end

