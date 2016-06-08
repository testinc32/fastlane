# would go somewhere else
module Beta
  def self.register_class_method(cls, symbol, default_symbol, override_symbol, environment_variable_name)
    cls.define_singleton_method(symbol) do |*args|
      if ENV[environment_variable_name]
        cls.send(override_symbol, *args)
      else
        cls.send(default_symbol, *args)
      end
    end
  end

  def self.register_instance_method(cls, symbol, default_symbol, override_symbol, environment_variable_name)
    cls.send(:define_method, symbol.to_s) do |*args|
      if ENV[environment_variable_name]
        self.send(override_symbol, *args)
      else
        self.send(default_symbol, *args)
      end
    end
  end
end


module Match
  class GitHelper
    Beta.register_class_method(self, :run_clone, :run_clone_command_executor, :run_clone_ruby_git, 'USE_RUBY_GIT_FOR_MATCH')
    Beta.register_class_method(self, :run_commit_changes, :run_commit_changes_command_executor, :run_commit_changes_ruby_git, 'USE_RUBY_GIT_FOR_MATCH')
    Beta.register_class_method(self, :run_checkout_branch, :run_checkout_branch_command_executor, :run_checkout_branch_ruby_git, 'USE_RUBY_GIT_FOR_MATCH')

    def self.run_clone_command_executor(dir, shallow_clone, git_url)
      command = "git clone '#{git_url}' '#{@dir}'"
      command << " --depth 1" if shallow_clone

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: $verbose,
                                      print_command: $verbose)
    end

    def self.run_clone_ruby_git(dir, shallow_clone, git_url)
      opts = {path: @dir}
      opts[:depth] = 1 if shallow_clone
      Git.clone(git_url, ".", opts)
    end

    def self.clone(git_url, shallow_clone, manual_password: nil, skip_docs: false, branch: "master")
      return @dir if @dir

      @dir = Dir.mktmpdir

      UI.message "Cloning remote git repo..."
      self.run_clone(@dir, shallow_clone, git_url)

      UI.user_error!("Error cloning repo, make sure you have access to it '#{git_url}'") unless File.directory?(@dir)

      checkout_branch(branch) unless branch == "master"

      if !Helper.test? and GitHelper.match_version(@dir).nil? and manual_password.nil? and File.exist?(File.join(@dir, "README.md"))
        UI.important "Migrating to new match..."
        ChangePassword.update(params: { git_url: git_url,
                                    git_branch: branch,
                                 shallow_clone: shallow_clone },
                                          from: "",
                                            to: Encrypt.new.password(git_url))
        return self.clone(git_url, shallow_clone)
      end

      copy_readme(@dir) unless skip_docs
      Encrypt.new.decrypt_repo(path: @dir, git_url: git_url, manual_password: manual_password)

      return @dir
    end

    def self.generate_commit_message(params)
      # 'Automatic commit via fastlane'
      [
        "[fastlane]",
        "Updated",
        params[:app_identifier],
        "for",
        params[:type].to_s
      ].join(" ")
    end

    def self.match_version(workspace)
      path = File.join(workspace, "match_version.txt")
      if File.exist?(path)
        Gem::Version.new(File.read(path))
      end
    end

    def self.run_commit_changes_command_executor(path, message, git_url, branch)
      Dir.chdir(path) do
        return false if `git status`.include?("nothing to commit")

        Encrypt.new.encrypt_repo(path: path, git_url: git_url)
        File.write("match_version.txt", Match::VERSION) # unencrypted

        commands = []
        commands << "git add -A"
        commands << "git commit -m #{message.shellescape}"
        commands << "git push origin #{branch.shellescape}"

        UI.message "Pushing changes to remote git repo..."

        commands.each do |command|
          FastlaneCore::CommandExecutor.execute(command: command,
                                              print_all: $verbose,
                                          print_command: $verbose)
        end
      end
      true
    end

    def self.run_commit_changes_ruby_git(path, message, git_url, branch)
      git = Git.open(path)

      # Avoid calling git.status if no branch exists
      return false unless git.current_branch.nil? or git.status.any?

      Encrypt.new.encrypt_repo(path: path, git_url: git_url)
      File.write(File.join(path, "match_version.txt"), Match::VERSION) # unencrypted

      UI.message "Pushing changes to remote git repo..."
      git.add(all: true)
      git.commit("message")
      git.push(:origin, branch)

      true
    end

    def self.commit_changes(path, message, git_url, branch = "master")
      return unless self.run_commit_changes(path, message, git_url, branch)

      FileUtils.rm_rf(path)
      @dir = nil
    end

    def self.clear_changes
      return unless @dir

      FileUtils.rm_rf(@dir)
      UI.success "🔒  Successfully encrypted certificates repo" # so the user is happy
      @dir = nil
    end

    def self.run_checkout_branch_command_executor(branch)
      commands = []
      if branch_exists?(branch)
        # Checkout the branch if it already exists
        commands << "git checkout #{branch.shellescape}"
      else
        # If a new branch is being created, we create it as an 'orphan' to not inherit changes from the master branch.
        commands << "git checkout --orphan #{branch.shellescape}"
        # We also need to reset the working directory to not transfer any uncommitted changes to the new branch.
        commands << "git reset --hard"
      end

      UI.message "Checking out branch #{branch}..."

      Dir.chdir(@dir) do
        commands.each do |command|
          FastlaneCore::CommandExecutor.execute(command: command,
                                                print_all: $verbose,
                                                print_command: $verbose)
        end
      end
    end

    def self.run_checkout_branch_ruby_git(branch)
      git = Git.open(@dir)
      return if git.current_branch == branch

      UI.message "Checking out branch #{branch}..."
      if git.is_branch?(branch)
        git.checkout(branch)
      else
        git.checkout(["--orphan", branch])
        # Add empty commit to avoid an Exception when calling git.status
        git.commit("initial commit", allow_empty: true)
      end

      UI.message "Cleaning up..."
      if git.status.any?
        git.reset
        git.clean(force: true, d: true)
      end
    end

    # Create and checkout an specific branch in the git repo
    def self.checkout_branch(branch)
      return unless @dir

      run_checkout_branch(branch)
    end

    # Checks if a specific branch exists in the git repo
    def self.branch_exists?(branch)
      return unless @dir

      result = Dir.chdir(@dir) do
        FastlaneCore::CommandExecutor.execute(command: "git branch --list origin/#{branch.shellescape} --no-color -r",
                                              print_all: $verbose,
                                              print_command: $verbose)
      end
      return !result.empty?
    end

    # Copies the README.md into the git repo
    def self.copy_readme(directory)
      template = File.read("#{Helper.gem_path('match')}/lib/assets/READMETemplate.md")
      File.write(File.join(directory, "README.md"), template)
    end
  end
end
