%w(2.8 2.9).each do |version|
  appraise "mysql-#{version}" do
    gem 'mysql', "~> #{version}.0"
  end
end

# The gem will likely work with mysql2 versions before 0.4, but the tests won't
# pass because earlier versions don't support prepared statements.
%w(0.4).each do |version|
  appraise "mysql2-#{version}" do
    gem 'mysql2', "~> #{version}.0"
  end
end

%w(0.16 0.17 0.18).each do |version|
  appraise "pg-#{version}" do
    gem 'pg', "~> #{version}.0"
  end
end
