module MidiSwitch
  class Cli
    attr_accessor :core
    
    def initialize
      self.core = MidiSwitch::Core.new
    end
    
    def run
      $terminal_state = `stty -g -f /dev/tty`
      `stty -f /dev/tty raw -echo cbreak`
      at_exit do
        core.close
        `stty -f /dev/tty #{$terminal_state}`
      end
      Signal.trap("INT") { exit }
      
      puts "Press q for exit; h,l to change programs and j,k to change songs"
      while "q"[0].ord != (cmd = STDIN.getc)
        case cmd
        when "l"[0].ord, " "[0].ord
          core.next_program
        when "h"[0].ord
          core.previous_program
        when "j"[0].ord
          next_song
        when "k"[0].ord
          previous_song
        end
      end
      puts "Quitting..."
    end
    
    private
    
    def next_song
      core.next_song
      song_changed_cb
    end
    
    def previous_song
      core.previous_song
      song_changed_cb
    end
    
    def song_changed_cb
      puts "Current song: #{core.current_song}"
    end
  end
end
