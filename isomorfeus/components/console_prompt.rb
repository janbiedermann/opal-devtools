class ConsolePrompt < React::Component::Base
  prop :point, default: -1
  prop :value, default: ''
  prop :label, default: '> '
  prop :argument, default: nil

  ref :child_cursor

  component_did_mount do
    blink
  end

  component_did_update do |_prev_props, _prev_state, _snapshot|
    blink
  end

  def update_semaphore
    @update_semaphore ||= 0
  end

  def semaphore_incr
    @update_semaphore ||= 0
    @update_semaphore += 1
  end

  def semaphore_decr
    @update_semaphore ||= 0
    @update_semaphore -= 1
  end

  def blink
    # Blink cursor when idle
    if ref(:child_cursor).JS[:current]
      if update_semaphore == 0
        ref(:child_cursor).JS[:current].JS[:className] = "react-console-cursor"
      end
      semaphore_incr
      %x{
        window.setTimeout( () => {
          #{semaphore_decr}
          if(#{update_semaphore} == 0 && #{ref(:child_cursor)}.current) {
            #{ref(:child_cursor)}.current.className = "react-console-cursor react-console-cursor-idle";
          }
        }, 1000);
      }
    end
  end

  def render_value
    return props.value if props.point < 0
    if props.point == props.value.length
       SPAN "#{props.value}"
       SPAN({ref: ref(:child_cursor), key: 'cursor', class_name: "react-console-cursor"}, "\u00A0")
    else
       SPAN props.value[0...(props.point)]
       SPAN({ref: ref(:child_cursor), key: 'cursor', class_name: "react-console-cursor"}, props.value[props.point...(props.point+1)])
       SPAN props.value[(props.point+1)..-1]
    end
  end

  render do
    label = props.label
    if props.argument
      idx = label.rindex("\n")
      if idx >= 0
        label = label[0...(idx+1)]
      else
        label = ''
      end
    end
    DIV(class_name: "react-console-prompt-box") do
      SPAN(class_name: "react-console-prompt-label") { label }
			SPAN(class_name: "react-console-prompt-argument") { props.argument }
      SPAN(class_name: "react-console-prompt") { render_value }
    end
  end
end
