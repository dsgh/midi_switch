require "observer"

module MidiSwitch
  class Core
    include Observable
    
    attr_accessor :songs
    attr_accessor :current_song_index
    attr_accessor :current_program_index
    attr_accessor :midi_connection
    
    def initialize
      self.midi_connection = MidiConnection.new
      self.songs = hardcoded_songs
      add_observer(midi_connection)
      self.current_song_index = 0
    end
    
    def close
      midi_connection.close
    end
    
    def current_song_index=(song_index)
      if song_index >= 0 && song_index < songs.length
        @current_song_index = song_index
        self.current_program_index = 0
      end
    end
    
    def current_song
      songs[current_song_index]
    end
    
    def current_program
      current_song.programs[current_program_index]
    end
    
    def current_program_index=(program_index)
      if program_index >= 0 && program_index < current_song.programs.length
        @current_program_index = program_index
        changed
        notify_observers(current_program)
      end
    end
    
    def next_program
      self.current_program_index += 1
    end
    
    def previous_program
      self.current_program_index -= 1
    end
    
    def next_song
      self.current_song_index += 1
    end
    
    def previous_song
      self.current_song_index -= 1
    end
    
    private
    
    # Microkorg XL Factory settings:
    #   0 A11 SYNBRASS
    #  13 A26 AC PIANO
    #  45 A66 ORGAN
    #  68 B15 SOLINSTR
    #  77 B26 MW ORGAN
    #  93 B46 PHASE EP
    # 125 B86 DEEPBELL
    def hardcoded_songs
      [
        Song.new("Maroon 5 - This love", [13, 68, 13, 68, 13, 45, 68, 13]),
        Song.new("Ben l'oncle soul - Seven nation army", [68, 13, 0, 68, 13, 0, 68]),
        Song.new("Ornatos Violeta - Para de olhar para mim", [77, 125, 93, 77])
      ]
    end
    
  end
end
