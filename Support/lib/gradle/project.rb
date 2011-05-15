require "find"

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/process"
require ENV["TM_SUPPORT_PATH"] + "/lib/ui"
require ENV["TM_SUPPORT_PATH"] + "/lib/escape"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/htmloutput"
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/event'

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/gradle/prefs'

require 'find'
require "shellwords"

module Gradle
  class Project
    
    class Module 
      attr_reader :project, :path, :prefix, :prefs
      
      def initialize(project, path)
        @project = project
        @path = path
        @prefs = Prefs.new(path)
        
        if path == project.path
          @prefix = ""
        else
          @prefix = (path[project.path.length + 1..-1].sub "/", ":") + ":"
        end
      end
      
      def prefix_task(task) 
        @prefix + task
      end
      
      def test_single(file = ENV['TM_SELECTED_FILE'])
        run("test", @project.test_single_arg(file))
      end
      
      def prompt_for_command_and_run
        previous = @prefs.get("prev_prompt")
        command = TextMate::UI.request_string(
          :title => "GradleMate", 
          :prompt => "Enter a gradle command" + (@prefix.empty? ? ' (for root module):' : " (for “#{@prefix[0..-2]}”):"), 
          :default => previous
        )
        
        if command.nil?
          puts "Command cancelled"
          false
        else
          @prefs.set("prev_prompt", command) unless command.nil?
          run_string(command)
          true
        end
      end

      def run_string(command)
        run(*Shellwords.shellwords(command))
      end
      
      def run(*args)
        prefixed_args = args.collect { |a| a[0..0] == "-" ? a : prefix_task(a) }
        @project.run(prefixed_args)
      end
    end
    
    attr_reader :path, :prefs
    
    def initialize(path = nil)
      @path = path || ENV['TM_PROJECT_DIRECTORY']
      @prefs = Prefs.new(@path)
      
      assert_is_gradle_project
    end

    def most_local_module(file = ENV['TM_SELECTED_FILE'])
      if file.nil?
        puts "No file selection"
        exit 1
      elsif !File.file? file
        puts "#{file} is not a file"
        exit 1
      end
      
      parent = File.expand_path("#{file}/..")
      while parent != @path do
        if File.exists? "#{parent}/build.gradle"
          return Module.new(self, parent)
        end
        parent = File.expand_path("#{parent}/..")
      end
      
      return Module.new(self, @path)
    end
    
    def test_single_arg(file = ENV['TM_SELECTED_FILE']) 
      if file.nil?
        puts "No file selection"
        exit 1
      end
      
      clazz = File.basename(file, File.extname(file))
      "-Dtest.single=#{clazz}"
    end
    
    def test_single(file = ENV['TM_SELECTED_FILE'])
      run("test", test_single_arg(file))
    end
    
    def run_previous_command
      previous = @prefs.get("previous_command")
      if previous.nil?
        puts "No previous command for this project"
        exit 1
      end
      
      run(previous)
    end
    
    def prompt_for_command_and_run
      previous = @prefs.get("prev_prompt")
      command = TextMate::UI.request_string(:title => "GradleMate", :prompt => "Enter a gradle command:", :default => previous)
      if command.nil?
        puts "Command cancelled"
        false
      else
        @prefs.set("prev_prompt", command) unless command.nil?
        run_string(command)
        true
      end
    end
    
    def run_string(command)
      run(*Shellwords.shellwords(command))
    end
    
    def run(*args)
      @prefs.set("previous_command", args)
      Dir.chdir(@path) do
        TextMate::HTMLOutput.show(:window_title => "GradleMate", :page_title => "GradleMate", :sub_title => @path) do |io|
          cmd = ["./gradlew"] + args
          io << "<strong>#{htmlize(cmd.join(' '))}</strong><br/>"
          io << "<pre>"
          
          TextMate::Process.run(cmd) do |str, type|
            str.chomp!
            str = "<span style=\"#{type == :err ? 'color: red' : ''}\">#{htmlize(str)}</span>"

            # Link individual test failures to their xml report files
            if str =~ /Test (.*) FAILED/
              testname = $1
              testfile = path_to_test_result(testname)
              unless testfile.nil?
                str.sub! /Test (.*) FAILED/, "Test <a href=\"javascript:TextMate.system('open \\\\'txmt://open/?url=file://#{testfile}\\\\'')\">\\1</a> FAILED"
              end
            end

            # Italicise the task names
            str.sub! /(<.+?>)(:(?:.+:?)+)/, "\\1<span style='font-style: italic'>\\2</span>"
            
            # Link compile error messages to the source
            str.sub! /^(.+?)(\/(?:.+\/)+.+\..+):\s?(\d+)(.+)$/, "\\1<a href=\"javascript:TextMate.system('open \\\\'txmt://open/?url=file://\\2&line=\\3\\\\'')\">\\2:\\3</a>\\4"

            # Link test failures to the html report
            str.sub! /^(.+Cause: There were failing tests. See the report at )((?:\/.+)+)\.(.+)$/, "\\1<a href=\"javascript:TextMate.system('open \\\\'\\2/index.html\\\\'')\">\\2</a>.\\3"

            # Colorise the UP-TO-DATE suffix
            str.sub! /UP-TO-DATE/, "<span style='color: yellow'>UP-TO-DATE</span>"

            # Colorise the build status
            str.sub! /BUILD SUCCESSFUL/, "<span style='color: green'>BUILD SUCCESSFUL</span>"
            str.sub! /BUILD FAILED/, "<span style='color: red'>BUILD FAILED</span>"
            
            io << str + "\n"
          end
          io << "</pre>"
        end
        
        TextMate.event("info.build.complete.gradle", "Gradle Command Complete", $? == 0 ? "Command Succeeded" : "Command Failed")
      end
    end
    
    private 
    
    def assert_is_gradle_project
      unless File::exists?("#{@path}/gradlew")
        puts "#{@path} does not appear to be a Gradle project, no “gradlew” script found"
        exit 1
      end
    end
    
    def path_to_test_result(clazz) 
      Find.find(@path) do |path|
        base = File.basename(path)
        if FileTest.directory?(path)
          if base[0] == ?. or path =~ /build\/(?!test-results$)/
            Find.prune
          else
            next
          end
        else
          return path if base == "TEST-#{clazz}.xml"
        end
      end
      
      nil
    end
    
  end  
end