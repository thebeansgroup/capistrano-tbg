unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/tbg/git_tag requires Capistrano 2"
end

Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :git do
      desc 'Create a git tag'
      task :generate_tag do
        p "git tag"
      end
    end
  end
end