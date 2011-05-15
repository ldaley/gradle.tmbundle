require "find"

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/process"
require ENV["TM_SUPPORT_PATH"] + "/lib/ui"
require ENV["TM_SUPPORT_PATH"] + "/lib/escape"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/htmloutput"

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/gradle/prefs'

require 'find'
require "shellwords"

module Gradle
  class Project
    
    attr_reader :path, :prefs
    
    def initialize(path = nil)
      @path = path || ENV['TM_PROJECT_DIRECTORY']
      @prefs = Prefs.new(self)
      
      assert_is_gradle_project
    end

    def prompt_for_invocation_and_run
      previous = @prefs.get("prev_invocation")
      invocation = TextMate::UI.request_string(:title => "GradleMate", :prompt => "Enter a gradle invocation:", :default => previous)
      if invocation.nil?
        puts "Command cancelled"
        false
      else
        @prefs.set("prev_invocation", invocation) unless invocation.nil?
        run_string(invocation)
        true
      end
    end
    
    def run_string(command)
      run(Shellwords.shellwords(command))
    end
    
    def run(*args)
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
              Find.find(@path) do |path|
                base = File.basename(path)
                if FileTest.directory?(path)
                  if base[0] == ?. or path =~ /build\/(?!test-results$)/
                    Find.prune
                  else
                    next
                  end
                else
                  if base == "TEST-#{testname}.xml"
                    str.sub! /Test (.*) FAILED/, "Test <a href=\"javascript:TextMate.system('open \\\\'txmt://open/?url=file://#{path}\\\\'')\">\\1</a> FAILED"
                    break
                  end
                end
              end
            end

            # Link compile error messages to the source
            str.sub! /^(.+?)(\/(?:.+\/)+.+\..+):\s?(\d+)(.+)$/, "\\1<a href=\"javascript:TextMate.system('open \\\\'txmt://open/?url=file://\\2&line=\\3\\\\'')\">\\2:\\3</a>\\4"

            # Link test failures to the html report
            str.sub! /^(.+Cause: There were failing tests. See the report at )((?:\/.+)+)\.(.+)$/, "\\1<a href=\"javascript:TextMate.system('open \\\\'\\2/index.html\\\\'')\">\\2</a>.\\3"

            # Colorise the UP-TO-DATE suffix
            str.sub! /UP-TO-DATE/, "<span style='color: yellow'>UP-TO-DATE</span>"

            io << str + "\n"
          end
          io << "</pre>"
        end
      end
    end
    
    private 
    
    def assert_is_gradle_project
      unless File::exists?("gradlew")
        puts "#{@path} does not appear to be a Gradle project, no “gradlew” script found"
        exit 1
      end
    end
    
  end  
end