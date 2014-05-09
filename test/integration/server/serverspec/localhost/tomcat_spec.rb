require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe package('openjdk-7-jdk') do
  it { should be_installed }
end

describe package('tomcat6') do
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

