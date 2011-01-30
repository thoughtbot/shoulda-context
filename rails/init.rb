if RAILS_ENV == 'test'
  require "shoulda/context"
  Shoulda.autoload_macros RAILS_ROOT, File.join("vendor", "{plugins,gems}", "*")
end
