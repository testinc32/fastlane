module FastlaneCore
  class Feature
    attr_accessor :key, :description, :env_var, :experiment
    def initialize(key:, description:, env_var:, experiment: true)
      @key = key
      @description = description
      @env_var = env_var
      @experiment = experiment
    end
  end
end
