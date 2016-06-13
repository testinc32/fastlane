module FastlaneCore
  class FeatureManager
    class << self
      attr_accessor :enabled_features
    end
    @enabled_features = []

    def self.experiments_enabled?
      return ENV['FASTLANE_ENABLE_ALL_EXPERIMENTS']
    end

    def self.enabled?(key)
      feature = features.detect { |feat| feat.key == key }
      return false if feature.nil?
      return true if experiments_enabled? && feature.experiment == true
      return @enabled_features.include?(key) || ENV[feature.env_var]
    end

    def self.register_class_method(klass: nil, symbol: nil, default_symbol: nil, override_symbol: nil, key: nil)
      return if klass.nil? || symbol.nil? || default_symbol.nil? || override_symbol.nil? || key.nil?
      klass.define_singleton_method(symbol) do |*args|
        if enabled?(key)
          klass.send(override_symbol, *args)
        else
          klass.send(default_symbol, *args)
        end
      end
    end

    def self.register_instance_method(klass: nil, symbol: nil, default_symbol: nil, override_symbol: nil, key: nil)
      return if klass.nil? || symbol.nil? || default_symbol.nil? || override_symbol.nil? || key.nil?
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
        Feature.new(key: :use_iTMS_transporter_shell_script,
            description: 'Use iTunes Transporter shell script',
                env_var: 'FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT')
      ]
    end

    def self.enable!(key)
      @enabled_features << key unless @enabled_features.include?(key)
    end
  end
end
