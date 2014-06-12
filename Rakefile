require "rspec/core/rake_task"

RootDir = File.expand_path(File.dirname(__FILE__))

task :default => :spec

desc "Run RSpec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-r ./spec/spec_helper", "--format progress"]
  t.verbose = false
end

desc "Run RSpec tests & generate test coverage report"
RSpec::Core::RakeTask.new(:spec_cov) do |t|
  t.rspec_opts = ["-r ./spec/spec_cov", "-r ./spec/spec_helper", "--format progress"]
  t.verbose = false
end

desc "Generate & open test coverage report"
task :coverage => :spec_cov do
  system "open coverage/index.html"
end

task "coverage/" => :coverage

desc "Cleanup generated files and stuff"
task :clean do
  rm_rf "#{RootDir}/coverage/"
  rm_rf "#{RootDir}/doc/"
  Dir.glob("./**/*.class").each do |f|
    rm f
  end
end


LOC_EXCLUDE = []
def count_loc(dir, exclude_files = LOC_EXCLUDE)
  source_files = Dir.glob("#{dir}/**/*") - exclude_files
  source_files.reject!{ |f| File.directory?(f) }
  `wc -l #{source_files.join(" ")}`.split("\n").last.split("total").first.to_i
end

desc "Show LOC"
task :loc do
  source_dirs = ["lib", "spec"]
  total = 0
  source_dirs.each do |d|
    lines = count_loc(d)
    total += lines
    printf("%5s : %i\n", d, lines)
  end
  total = "total : #{total}"
  puts "-" * total.size
  puts total
end
