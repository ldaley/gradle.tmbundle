#!/usr/bin/env ruby
puts ARGV[0]
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/gradle/project'

Gradle::Project.new.open_test_result(ARGV[0])
