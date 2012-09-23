# bundle exec rbenv exec jruby -J-XstartOnFirstThread lib/swt/swt_app.rb

module MidiSwitch
  module Swt
    class SwtApp < SwtBase
      attr_accessor :core
      attr_accessor :song_label
      attr_accessor :previous_program_label
      attr_accessor :current_program_label
      attr_accessor :next_program_label
      
      def initialize
        super do |shell|
          build_ui(shell)
        end
        self.core = MidiSwitch::Core.new
        song_changed_cb
        program_changed_cb
      end
      
      def next_program
        core.next_program
        program_changed_cb
      end
      
      def previous_program
        core.previous_program
        program_changed_cb
      end
      
      def next_song
        core.previous_song
        song_changed_cb
      end
      
      def previous_song
        core.next_song
        song_changed_cb
      end
      
      private
      
      def build_ui(shell)
        fill_layout = ::Swt::Layout::FillLayout.new
        fill_layout.type = ::Swt::SWT::VERTICAL
        shell.set_layout(fill_layout)
        
        self.song_label = ::Swt::Widgets::Label.new(shell, ::Swt::SWT::CENTER)
        
        bottom_composite = ::Swt::Widgets::Composite.new(shell, ::Swt::SWT::NO_RADIO_GROUP)
        
        self.previous_program_label = ::Swt::Widgets::Label.new(bottom_composite, ::Swt::SWT::CENTER)
        
        self.current_program_label = ::Swt::Widgets::Label.new(bottom_composite, ::Swt::SWT::CENTER)
        font_data = self.current_program_label.font.font_data[0]
        font_data.set_height(40)
        current_program_label.setFont(::Swt::Graphics::Font.new(display, font_data))
        
        self.next_program_label = ::Swt::Widgets::Label.new(bottom_composite, ::Swt::SWT::CENTER)
        
        bottom_composite.pack
      end
      
      def song_changed_cb
        song_label.set_text(core.current_song.name)
      end
      
      def program_changed_cb
        previous_program_label.set_text(previous_program_text)
        current_program_label.set_text(core.current_program.to_s)
        next_program_label.set_text(next_program_text)
      end
      
      def previous_program_text
        index = core.current_program_index - 1
        if index >= 0
          core.current_song.programs[index].to_s
        else
          ""
        end
      end
      
      def next_program_text
        index = core.current_program_index + 1
        if index < core.current_song.programs.length - 1
          core.current_song.programs[index].to_s
        else
          ""
        end
      end
    end
  end
end
