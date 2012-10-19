require 'rubygems'
require 'bundler/setup'

Bundler.require

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)

# Gives us the gem:spec rake task to generate a gemspec file
Hoe.plugin :gemspec

$hoe = Hoe.spec 'eaal' do |p|
  p.developer('Peter Petermann', 'ppetermann80@googlemail.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name       = p.name
  p.extra_deps         = [
    ['hpricot', '>= 0.6'], 
    ['memcache-client','>= 1.7.1'],
    ['faraday', '>= 0.8.4']
  ]

  p.extra_dev_deps = [
    ['hoe'],
    ['hoe-gemspec']
  ]

  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
task :default => [:spec, :features]
