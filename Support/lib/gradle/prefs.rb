require "pstore"

module Gradle
  class Prefs

    @@prefs = PStore.new(File.expand_path( "~/Library/Preferences/com.macromates.textmate.gradle"))

    def self.get(key)
      @@prefs.transaction { @@prefs[key] }
    end

    def self.set(key, value)
      @@prefs.transaction { @@prefs[key] = value }
    end
    
    attr_reader :path
    
    def initialize(path)
      @path = path
    end
    
    def get(key) 
      self.class.get(getKey(key))
    end
    
    def set(key, value) 
      self.class.set(getKey(key), value)
    end
    
    private
    
    def getKey(key) 
      @path + "::" + key
    end
    
  end
end
