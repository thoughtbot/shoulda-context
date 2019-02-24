module Shoulda
  # Call `Shoulda.autoload_macros` when you want to load test macros
  # automatically in a non-Rails project (it's done automatically for Rails
  # projects).
  #
  # @param root [String] The path to your project's root directory.
  # @param dirs [String...] Directories relative to your root, which contain
  #   `shoulda_macros` directories. These can be globs.
  #
  # @example Basic usage:
  #   # File: test/test_helper.rb
  #   #
  #   # This will load everything in:
  #   # - <APP_ROOT>/test/shoulda_macros
  #   #
  #   Shoulda.autoload_macros(File.dirname(__FILE__) + '/..')
  #
  # @example Loading vendored macros:
  #   # File: test/test_helper.rb
  #   #
  #   # This will load everything in:
  #   # - <APP_ROOT>/vendor/*/shoulda_macros
  #   # - <APP_ROOT>/test/shoulda_macros
  #   #
  #   Shoulda.autoload_macros(APP_ROOT, 'vendor/*')
  #
  # @example Load macros in an app with a vendor directory laid out like Rails':
  #   # File: test/test_helper.rb
  #   #
  #   # This will load everything in:
  #   # - <APP_ROOT>/vendor/plugins/*/shoulda_macros
  #   # - <APP_ROOT>/vendor/gems/*/shoulda_macros
  #   # - <APP_ROOT>/test/shoulda_macros
  #   #
  #   Shoulda.autoload_macros(APP_ROOT, 'vendor/{plugins,gems}/*')
  #
  # @return [void]
  def self.autoload_macros(root, *dirs)
    dirs << File.join('test')
    complete_dirs = dirs.map{|d| File.join(root, d, 'shoulda_macros')}
    all_files     = complete_dirs.inject([]){ |files, dir| files + Dir[File.join(dir, '*.rb')] }
    all_files.each do |file|
      require file
    end
  end
end
