module MidiSwitch
  class Song
    attr_accessor :name
    attr_accessor :programs
    
    def initialize(name, programs)
      self.name = name
      self.programs = programs
    end
    
    def to_s
      name
    end
  end
end
