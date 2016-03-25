module Spaceship
  class Portal::RequestBuilder
    attr_accessor :host

    def initialize(client)
      @client = client
      @platform = 'ios'
      @host = 'developer.apple.com'
      @root = '/services-account'
      @protocol_version = 'QH65B2'
      @path_segments = [@root, @protocol_version, 'account']

      @default_params = {teamId: @client.team_id}
    end

    #platforms
    def ios
      @platform = 'ios'
      self
    end

    def tvos
      @platform = 'ios'
      self
    end

    def watchos
      @platform = 'ios'
      self
    end

    def mac
      @platform = 'mac'
      self
    end

    #resources
    def identifiers
      @resource = 'identifiers'
      self
    end

    def certificate
      @resource = 'certificate'
      self
    end

    def device
      @resource = 'device'
      self
    end

    def profile
      @resource = 'profile'
      self
    end

    def action(endpoint)
      @action = endpoint
      self
    end

    #options
    #def collect_pages
    #end

    #executors
    def get(*args)
      action, params = extract_args(args)
      self.action(action)
      @params = @default_params.merge(params)
      @verb = :get

      self
    end

    def post(*args)
      action, params = extract_args(args)
      self.action(action)
      @params = @default_params.merge(params)
      @verb = :post

      self
    end

    def uri
      URI::HTTPS.build(host: host, path: path)
    end

    ##
    # TODO: expose Client#request
    def execute(&block)
      @client.send(:request, @verb, uri, @params, &block)
    end

    private
    def path
      raise ArgumentError.new('`platform` has not been set') unless @platform
      raise ArgumentError.new('`resource` has not been set') unless @resource
      raise ArgumentError.new('`action` has not been set') unless @action

      (@path_segments + [@platform, @resource, @action]).join('/')
    end

    def extract_args(args)
      if args.first.is_a?(String)
        action, params = args
      else
        _, params = args.first
      end
    end

  end
end
