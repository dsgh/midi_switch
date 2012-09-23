require "java"
SWT_APP_NAME = "Midi Switch"
require "swt"

# monkey patch
module Swt
  module Events
    import org.eclipse.swt.events.SelectionListener
    import org.eclipse.swt.events.KeyListener
  end
  
  module Graphics
    import org.eclipse.swt.graphics.FontData
  end
end

module MidiSwitch
  module Swt
    class SwtBase
      
      def initialize
        # A Display is the connection between SWT and the native GUI. (jruby-swt-cookbook/apidocs/org/eclipse/swt/widgets/Display.html)
        display = ::Swt::Widgets::Display.get_current
        
        # A Shell is a window in SWT parlance. (jruby-swt-cookbook/apidocs/org/eclipse/swt/widgets/Shell.html)
        @shell = ::Swt::Widgets::Shell.new
        
        # A Shell must have a layout. FillLayout is the simplest.
        @shell.setLayout(::Swt::Layout::FillLayout.new)
        
        yield(@shell) if block_given?
        
        listener = ::Swt::Events::KeyListener.impl do |method, *args|
          if :keyPressed == method
            key_event = args[0]
            case key_event.keyCode
            when ::Swt::SWT::ARROW_RIGHT, ::Swt::SWT::SPACE, 'l'
              next_program
            when ::Swt::SWT::ARROW_LEFT, 'h'
              previous_program
            when ::Swt::SWT::ARROW_UP, 'j'
              previous_song
            when ::Swt::SWT::ARROW_DOWN, 'k'
              next_song
            end
          end
        end
        @shell.add_key_listener(listener)
        
        # This lays out the widgets in the Shell
        @shell.pack
        
        # And this displays the Shell
        @shell.open
      end
      
      # This is the main gui event loop
      def start
        display = ::Swt::Widgets::Display.get_current
        
        # until the window (the Shell) has been closed
        while !@shell.isDisposed
          # check for and dispatch new gui events
          display.sleep unless display.read_and_dispatch
        end
        
        display.dispose
      end
    end
  end
end

::Swt::Widgets::Display.set_app_name("Midi Switch")
