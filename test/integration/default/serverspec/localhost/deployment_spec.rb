require 'spec_helper'

# Make sure nginx is running
describe service("nginx") do
  it { should be_running }
end

# Make sure vhosts have the correct stuff
describe file("/etc/nginx/sites-enabled/static") do
  it { should be_file }
  its(:content) { should match "server_name static.theodi.org;" }
  its(:content) { should match "proxy_pass http://static;" }
end

# Make sure vhosts have correct static asset configuration
# cross-origin is disabled in this suite
describe file("/etc/nginx/sites-enabled/static") do
  it { should be_file }
  its(:content) { should match /location \~ \^\/\(assets\)\// }
  its(:content) { should match /add_header Access-Control-Allow-Origin "\*";/ }
end

# Make sure we have some code
describe file("/var/www/static/current/config.ru") do
  it { should be_file }
end

# Make sure we have environment correctly
describe file("/var/www/static/current/.env") do
  its(:content) { should match /GOVUK_APP_DOMAIN: theodi.org/ }
  its(:content) { should match /SUCH: test/ }
end

describe file("/etc/init/static-thin-1.conf") do
  its(:content) { should match /SUCH=test/ }
  its(:content) { should match /PORT=4010/ }
  its(:content) { should match /PATH=\/home\/quirkafleeg\/.rvm\/gems\/ruby-1.9.3-p[0-9]{3}@global\/bin:\/home\/quirkafleeg\/.rvm\/rubies\/ruby-1.9.3-p[0-9]{3}\/bin/}
  its(:content) { should match /bundle exec thin start/ }
end

# Make sure foreman job is running
describe service("static-thin-1") do
  it { should be_running }
end

# Check we can actually access the thing - we'll get a Rails error due
# to lack of database, but that's OK as we know Rails is running.
describe command("curl -H 'Host: static.theodi.org' http://localhost:8080/templates/www.html.erb") do
  it { should return_stdout /About the ODI/ }
end

describe command("curl -v -H 'Host: static.theodi.org' -H 'Origin: http://project.dapaas.eu' http://localhost:8080/assets/favicon.ico -o /tmp/favicon.ico") do
  it { should return_stdout /Access-Control-Allow-Origin: \*/ }
end
