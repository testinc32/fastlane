module FastlaneCore
  class FeatureManager
    @@enabled_features = []

    def self.enabled?(key)
      feature = features.find { |feature| feature.key == key }
      return false if feature.nil?
      return @@enabled_features.include?(key) || ENV[feature.env_var]
    end

    def self.register_class_method(klass:, symbol:, default_symbol:, override_symbol:, key:)
      klass.define_singleton_method(symbol) do |*args|
        if enabled?(key)
          klass.send(override_symbol, *args)
        else
          klass.send(default_symbol, *args)
        end
      end
    end

    def self.register_instance_method(klass:, symbol:, default_symbol:, override_symbol:, key:)
      klass.send(:define_method, symbol.to_s) do |*args|
        if enabled?(key)
          self.send(override_symbol, *args)
        else
          self.send(default_symbol, *args)
        end
      end
    end

    def self.features
      [
        Feature.new(:use_ruby_git, 'Use git gem for git operations.', 'USE_RUBY_GIT_FOR_MATCH', true)
      ]
    end

    def self.enable!(key)
      @@enabled_features << key unless @@enabled_features.include?(key)
    end
  end
end