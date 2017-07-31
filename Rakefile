# encoding: UTF-8
# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/test*.rb"]
end

namespace "javascripts" do
  task "build" do
    require "json"
    require "open3"

    def run(*args)
      puts(*args)
      stdout, stderr, exit_status = Open3.capture3(*args)
      fail stderr.strip.empty? ? stdout : stderr unless exit_status.success?
      stdout
    end

    def load_all(url)
      max = run("curl --head #{url}").match(/Link:[^\n\r]+/).to_s.scan(/page=(\d+)/).flatten.map(&:to_i).uniq.max || 1
      (1..max).reduce([]) { |ary, p| ary + JSON.parse(run("curl #{url}?page=#{p}")) }
    end

    def clone_repository(url, branch, dir)
      run "[ -d #{dir} ] || git clone --single-branch --branch #{branch} --depth 1 --no-hardlinks #{url} #{dir}"
    end

    def install_node_modules(dir)
      run "[ -d #{dir} -a ! -d #{dir}/node_modules ] && cd #{dir} && npm install --only=production --ignore-scripts || true"
    end

    def build_template_compiler(engine, engine_dir, engine_version, output_file)
      run "[ -f #{output_file} ] || (node support/browserify-#{engine}.js #{engine_dir} #{engine_version} #{output_file} &&
                                     node support/minify-#{engine}.js #{output_file})"
    end

    def build_template_runtime(engine, engine_runtime_dir, engine_version, output_file)
      run "[ -f #{output_file} ] || node support/browserify-#{engine}-runtime.js #{engine_runtime_dir} #{engine_version} #{output_file}"
    end

    tags  = load_all("https://api.github.com/repos/pugjs/pug/releases").map { |x| x.fetch("tag_name") }
    tags += load_all("https://api.github.com/repos/pugjs/pug/tags").map { |x| x.fetch("name") }
    tags.uniq.each do |tag|
      if tag.match?(/\A1/)
        version = tag
        clone_repository        "https://github.com/pugjs/pug.git", tag, "tmp/jade-#{version}"
        install_node_modules    "tmp/jade-#{version}"
        build_template_compiler :jade, "tmp/jade-#{version}", version, "vendor/jade-#{version}.min.js"
        build_template_runtime  :jade, "tmp/jade-#{version}", version, "vendor/jade-runtime-#{version}.js"

      elsif tag.match?(/\A(?:pug@|2)/)
        version = tag.gsub(/\Apug@/, "")
        clone_repository        "https://github.com/pugjs/pug.git", tag, "tmp/pug-#{version}"
        install_node_modules    "tmp/pug-#{version}"
        install_node_modules    "tmp/pug-#{version}/packages/pug"
        build_template_compiler :pug, "tmp/pug-#{version}", version, "vendor/pug-#{version}.min.js"
      end
    end

    tags = load_all("https://api.github.com/repos/pugjs/pug-runtime/tags").map { |x| x.fetch("name") }
    tags.uniq.each do |tag|
      if tag.match?(/\A2/)
        version = tag
        clone_repository        "https://github.com/pugjs/pug-runtime.git", tag, "tmp/pug-runtime-#{version}"
        build_template_runtime  :pug, "tmp/pug-runtime-#{version}", version, "vendor/pug-runtime-#{version}.js"
      end
    end
  end
end
