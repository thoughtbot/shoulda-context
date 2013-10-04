module Shoulda
  class Railtie < Rails::Railtie
    initializer "Shoulda.autoload_macros" do
      if Rails.env.test?
        Shoulda.autoload_macros Rails.root, File.join("vendor", "{plugins,gems}", "*")
      end
    end
  end
end
