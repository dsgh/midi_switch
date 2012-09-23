require "unimidi"
require "midi-eye"
require "logger"

module MidiSwitch
  class MidiConnection
    attr_accessor :output
    attr_accessor :input
    attr_accessor :listener
    attr_accessor :ready_to_change
    attr_accessor :queued_program
    
    def log
      @log ||= Logger.new(STDOUT)
    end
    
    def initialize
      self.ready_to_change = true
      self.listener = MIDIEye::Listener.new(input).tap do |listener|
        listener.listen_for(:class => [MIDIMessage::NoteOn, MIDIMessage::NoteOff]) do |event|
          @notes ||= {}
          if event[:message].is_a?(MIDIMessage::NoteOn)
            @notes[event[:message].note] ||= true
          elsif event[:message].is_a?(MIDIMessage::NoteOff)
            @notes.delete(event[:message].note)
          end
          if @notes.empty?
            self.ready_to_change = true
          else
            self.ready_to_change = false
          end
        end
      end
      listener.run(:background => true)
    end
    
    def close
      listener.join
      log.debug "listener closed"
    end
    
    def update(program)
      if ready_to_change
        change_program!(program)
      else
        self.queued_program = program
      end
    end
    
    private
    
    def ready_to_change=(value)
      @ready_to_change = !!value
      if ready_to_change && queued_program
        change_program!(queued_program)
        self.queued_program = nil
      end
    end
    
    def change_program!(program)
      log.debug "0xc0 #{program}"
      if output
        output.open do |output|
          # in jruby, we have to pass a third argument, even though it's not used. TODO: send pull request to midi-jruby
          output.puts(0xc0, program, 0)
        end
      end
    end
    
    def output
      UniMIDI::Output.first
    end
    
    def input
      UniMIDI::Input.first
    end
  end
end
