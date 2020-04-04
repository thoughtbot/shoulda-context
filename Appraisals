appraise "rails_4_2" do
  gem "rails", "~> 4.2.0"
  gem "sprockets", "~> 3.0"
  gem "sqlite3", "~> 1.3.6"
end

appraise "rails_5_0" do
  gem "rails", "~> 5.0.0"
  gem "sprockets", "~> 3.0"
  gem "sqlite3", "~> 1.3.6"
end

appraise "rails_5_1" do
  gem "rails", "~> 5.1.0"
  gem "sprockets", "~> 3.0"
  gem "sqlite3", "~> 1.3.6"
end

appraise "rails_5_2" do
  gem "rails", "~> 5.2.0"
  gem "sprockets", "~> 3.0"
  gem "sqlite3", "~> 1.3.6"
end

if Gem::Requirement.new(">= 2.5.0").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  appraise "rails_6_0" do
    gem "rails", "~> 6.0.0"
    gem "bootsnap", ">= 1.4.2", require: false
    gem "listen", ">= 3.0.5", "< 3.2"
    gem "sqlite3", "~> 1.4"
    gem "sprockets", "~> 4.0"
    gem "webpacker", "~> 4.0"
  end
end
