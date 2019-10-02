class Console < React::Component::Base
  COMMAND_DEFAULT = 0
  COMMAND_SEARCH = 1
  COMMAND_KILL = 2
  COMMAND_YANK = 3

  SEARCH_DIRECTION_REVERSE = 0
  SEARCH_DIRECTION_FORWARD = 1

  KEY_CODES = {
    # backspace
    8 => :backward_delete_char,
    # tab
    9 => :complete,
    # return
    13 => :accept_line,
    # esc
    27 => :prefix_meta,
    # end
    35 => :end_of_line,
    # start
    36 => :beginning_of_line,
    # left
    37 => :backward_char,
    # right
    39 => :forward_char,
    # up
    38 => :previous_history,
    # down
    40 => :next_history,
    # delete
    46 => :delete_char
  }

  CTRL_CODES = {
    # C-a
    65 => :beginning_of_line,
    # C-e
    69 => :end_of_line,
    # C-f
    70 => :forward_char,
    # C-b
    66 => :backward_char,
    # C-c
    67 => :cancel_command,
    # C-d
    68 => :delete_char, # TODO EOF
    # C-k
    75 => :kill_line,
    # C-l
    76 => :clear_screen,
    # C-p
    80 => :previous_history,
    # C-n
    78 => :next_history,
    # C-q TODO
    #81 => :quotedInsert,
    # C-r
    82 => :reverse_search_history,
    # C-s
    83 => :forward_search_history,
    # C-t TODO
    #84 => :transposeChars,
    # C-u
    85 => :backward_kill_line,
    # C-v TODO
    #86 => :quotedInsert,
    # C-y TODO
    89 => :yank,
    # C-w TODO
    #87 => :killPreviousWhitespace,
    # C-] TODO
    #221 => :characterSearch,
    # C-x TODO
    #88 => :prefixCtrlX,
    189 => :insert_question_mark
  }

  CTRL_X_CODES = {
    # TODO state
    # C-x Rubout
    8 => :backward_kill_line,
    # C-x ( TODO
    #57 => :startKbdMacro,
    # C-x ) TODO
    #48 => :endKbdMacro,
    # C-x e TODO
    #69 => :callLastKbdMacro,
    # C-x C-u TODO
    #85 => :undo,
    # C-x C-x TODO
    #88 => :exchangePointAndMark,
  }

  CTRL_SHIFT_CODES = {
    # C-_ TODO
    #189 => :undo,
    # C-@ TODO
    #50 => :setMark,
  }

  META_CODES = {
    # M-backspace
    8 => :backward_kill_word,
    # M-b
    66 => :backward_word,
    # M-d
    68 => :kill_word,
    # M-f
    70 => :forward_word,
    # M-n
    78 => :non_incremental_forward_search_history,
    # M-p
    80 => :non_incremental_reverse_search_history,
    # M-y
    89 => :yank_pop,
    # M-.
    190 => :yank_last_arg,
    # M-TAB TODO
    #9 => :tabInsert,
    # M-t TODO
    #84 => :transposeWords,
    # M-u TODO
    #85 => :upcaseWord,
    # M-l TODO
    #76 => :downcaseWord,
    # M-c TODO
    #67 => :capitalizeWord,
    # M-w TODO
    #87 => :unixWordRubout,
    # M-\ TODO
    #220 => :deleteHorizontalSpace,
    # M-0 TODO
    #48: () => this.digitArgument(0),
    # M-1 TODO
    #49: () => this.digitArgument(1),
    # M-2 TODO
    #50: () => this.digitArgument(2),
    # M-3 TODO
    #51: () => this.digitArgument(3),
    # M-4 TODO
    #52: () => this.digitArgument(4),
    # M-5 TODO
    #53: () => this.digitArgument(5),
    # M-6 TODO
    #54: () => this.digitArgument(6),
    # M-7 TODO
    #55: () => this.digitArgument(7),
    # M-8 TODO
    #56: () => this.digitArgument(8),
    # M-9 TODO
    #57: () => this.digitArgument(9),
    # M-- TODO
    #189: () => this.digitArgument('-'),
    # M-f TODO
    #71: () => this.abort,
    # M-r TODO
    #82 => :revertLine,
    # M-SPACE TODO
    #32 => :setMark,
  }

  META_SHIFT_CODES = {
    # TODO hook in
    # M-<
    188 => :beginning_of_history,
    # M->
    190 => :end_of_history,
    # M-_
    189 => :yank_last_arg,
    # M-? TODO
    #191 => :possibleCompletions,
    # M-* TODO
    #56 => :insertCompletions,
  }

  META_CTRL_CODES = {
    # M-C-y
    89 => :yank_nth_arg,
    # M-C-] TODO
    #221 => :characterSearchBackward,
    # M-C-j TODO !!!
    #74 => :viEditingMode,
  }

  prop :prompt_label, default: '> '
  prop :continue, default: proc { false }
  prop :cancel, default: proc {}

  state.focus = false
  state.accept_input = true
  state.typer = ''
  state.point = 0
  state.curr_label = '' # was next_label
  state.prompt_text = ''
  state.restore_text = ''
  state.search_text = ''
  state.search_direction = nil
  state.search_init = false
  state.log = []
  state.history = []
  state.historyn = 0
  state.kill = []
  state.killn = []
  state.argument = nil
  state.last_command = COMMAND_DEFAULT

  ref :child_container
  ref :child_focus
  ref :child_typer

  def scroll_semaphore
    @scroll_semaphore ||= 0
  end

  def scroll_semaphore_incr
    @scroll_semaphore ||= 0
    @scroll_semaphore += 1
  end

  def scroll_semaphore_decr
    @scroll_semaphore ||= 0
    @scroll_semaphore -= 1
  end

  event_handler :blur do |_|
    state.focus(false)
  end

  event_handler :key_down do |e|
    if state.accept_input
      if e.alt_key?
        if e.ctrl_key? && META_CTRL_CODES.key?(e.key_code)
          send(META_CTRL_CODES[e.key_code])
          e.prevent_default
        elsif e.shift_key? && META_SHIFT_CODES.key?(e.key_code)
          send(META_SHIFT_CODES[e.key_code])
          e.prevent_default
        elsif META_CODES.key?(e.key_code)
          send(META_CODES[e.key_code])
          e.prevent_default
        end
      elsif e.ctrl_key?
        if CTRL_CODES.key?(e.key_code)
          send(CTRL_CODES[e.key_code])
          e.prevent_default
        elsif e.key_code != 86 # allow ctrl+v for paste on windows
          e.prevent_default
        end
      elsif KEY_CODES.key?(e.key_code)
        send(KEY_CODES[e.key_code])
        e.prevent_default
      end
    elsif e.ctrl_key? && e.key_code == 67
      # if input is blocked, ctrl+c should still call cancel
      send(CTRL_CODES[e.key_code])
      e.prevent_default
    end
  end

  event_handler :paste do |e|
    insert = e.clipboard_data.get_data('text')
    if state.last_command == COMMAND_SEARCH
      set_state({ search_text: state.search_init ? insert : text_insert(insert, state.search_text), typer: ref(:child_typer).JS[:current].JS[:value] }) do
        trigger_search
      end
    else
      set_state(console_insert(insert).merge({ last_command: COMMAND_DEFAULT })) { scroll_to_bottom }
    end
    e.prevent_default
  end
  # commands

  event_handler :change do |_|
    idx = 0
    while idx < state.typer.length && idx < ref(:child_typer).JS[:current].JS[:value].JS[:length]
      idx += 1
      break if state.typer[idx] != ref(:child_typer).JS[:current].JS[:value][idx]
    end
    insert = ref(:child_typer).JS[:current].JS[:value][idx..-1]
    replace = state.typer.length - idx
    if state.last_command == COMMAND_SEARCH
      set_state({ search_text: (state.search_init ? insert : text_insert(insert, state.search_text, replace)), typer: ref(:child_typer).JS[:current].JS[:value], }) do
        trigger_search
      end
    else
      set_state(console_insert(insert, replace).merge({ typer: ref(:child_typer).JS[:current].JS[:value], last_command: COMMAND_DEFAULT })) do
        scroll_to_bottom
      end
    end
  end

  event_handler :focus do |_|
    if `window.getSelection().toString()` == ''
      ref(:child_typer).JS[:current].JS.focus()
      state.focus(true) { scroll_to_bottom }
    end
  end

  component_did_mount do
    if props.autofocus
      ref(:child_typer).JS[:current].JS.focus()
      state.focus(true)
    end
    state.curr_label(next_label) { scroll_to_bottom }
  end

  def set_busy
    state.accept_input = false
  end

  def get_safe_log
    state.log.push({label: '', command: '', message: [] }) if state.log.size < 1
    state.log
  end

  def update_last_log(*messages)
    log = get_safe_log
    index_to_replace = log[state.log.length-1].message.length > 0 ? log[state.log.length-1].message.length - 1 : 0
    log[state.log.length-1].message[index_to_replace] = { value: messages }
    state.log(log) { scroll_if_bottom }
  end

  def log(*messages)
    log = get_safe_log
    log[state.log.length-1][:message].push({value: messages})
    state.log(log) { scroll_if_bottom }
  end

  def focus
    state.focus(true) { ref(:child_typer).JS[:current].JS.focus() }
  end

  def carriage_return
    set_state({ accept_input: true, curr_label: next_label}) { scroll_if_bottom }
    focus
  end

  # Commands for Moving
  def beginning_of_line
    set_state({ point: 0, argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
  end

  def end_of_line
    set_state({ point: state.prompt_text.length, argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
  end

  def forward_char
    set_state({ point: move_point(1, nil), argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
  end

  def backward_char
    set_state({ point: move_point(-1, nil), argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
  end

  def forward_word
    set_state({ point: next_word, argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
  end

  def backward_word
    set_state({ point: previous_word, argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
  end

  # Commands for Manipulating the History
  def accept_line
    ref(:child_typer).JS[:current].JS[:value] = ""
    if props.continue.call(state.prompt_text)
      set_state(console_insert("\n", nil).merge({ typer: "", last_command: COMMAND_DEFAULT })) { scroll_to_bottom }
    else
      command = state.prompt_text
      history = state.history
      log = state.log
      history.push(command) if history.empty? || history[history.length-1] != command
      log.push({ label: state.curr_label, command: command, message: [] })
      set_state({ accept_input: false, typer: "", point: 0, prompt_text: "", restore_text: "",
                  log: log, history: history, historyn: 0, argument: nil, last_command: COMMAND_DEFAULT }) do
        scroll_to_bottom
        if props.handler
          props.handler.call(command)
        else
          carriage_return
        end
      end
    end
  end

  def previous_history
    rotate_history(-1)
  end

  def next_history
    rotate_history(1)
  end

  def end_of_history
    rotate_history(state.history.length)
  end

  def trigger_search
    if state.search_direction == SEARCH_DIRECTION_REVERSE
      reverse_search_history
    else
      forward_search_history
    end
  end

  def reverse_search_history
    if state.last_command == COMMAND_SEARCH
      set_state(search_history(SEARCH_DIRECTION_REVERSE, true).merge ({ argument: "(reverse-i-search)\\`#{state.search_text}': ",
                                                                        last_command: COMMAND_SEARCH })) { scroll_to_bottom }
    else
      set_state({ search_direction: SEARCH_DIRECTION_REVERSE, search_init: true,
                  argument: "(reverse-i-search)\\`': ", last_command: COMMAND_SEARCH }) do
        scroll_to_bottom
      end
    end
  end

  def forward_search_history
    if state.last_command == COMMAND_SEARCH
      set_state(search_history(SEARCH_DIRECTION_FORWARD, true).merge ({ argument: "(forward-i-search)\\`#{state.search_text}': ",
                                                                        last_command: COMMAND_SEARCH })) { scroll_to_bottom }
    else
      set_state({ search_direction: SEARCH_DIRECTION_FORWARD, search_init: true,
                  argument: "(forward-i-search)\\`': ", last_command: COMMAND_SEARCH }) do
        scroll_to_bottom
      end
    end
  end

  def clear_screen
    state.log([])
    focus
  end

  def non_incremental_reverse_search_history
    # TODO
  end

  def non_incremental_forward_search_history
    # TODO
  end

  def history_search_backward
    # TODO
  end

  def history_search_forward
    # TODO
  end

  def history_substring_search_backward
    # TODO
  end

  def history_substring_search_forward
    # TODO
  end

  def yank_nth_arg
    # TODO
  end

  def yank_last_arg
    # TODO
  end

  # Commands for Changing Text
  def delete_char
    if state.point < state.prompt_text.length
      set_state({ prompt_text: state.prompt_text[0...state.point] + state.prompt_text[state.point+1..-1],
                  argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
    end
  end

  def backward_delete_char
    if state.last_command == COMMAND_SEARCH
      set_state({ search_text: state.search_text[0...(state.search_text.length-1)], typer: ref(:child_typer).JS[:current].JS[:value] }) { trigger_search }
    elsif state.point > 0
      set_state({ point: move_point(-1, nil), prompt_text: state.prompt_text[0...(state.point-1)] + state.prompt_text[state.point..-1],
                  argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
    end
  end

  # Killing and Yanking
  def kill_line
    kill = state.kill
    if state.last_command == COMMAND_KILL
      kill[0] = kill[0] + state.prompt_text[state.point..-1]
    else
      kill.unshift(state.prompt_text[state.point..-1])
    end
    set_state({ prompt_text: state.prompt_text[0...state.point], kill: kill, killn: 0, argument: nil, last_command: COMMAND_KILL }) do
      scroll_to_bottom
    end
  end

  def backward_kill_line
    kill = state.kill
    if state.last_command == COMMAND_KILL
      kill[0] = state.prompt_text[0...state.point] + kill[0]
    else
      kill.unshift(state.prompt_text[0...state.point])
    end
    set_state({ point: 0, prompt_text: state.prompt_text[state.point..-1], kill: kill, killn: 0, argument: nil, last_command: COMMAND_KILL }) do
      scroll_to_bottom
    end
  end

  def kill_whole_line
    kill = state.kill
    if state.last_command == COMMAND_KILL
      kill[0] = state.prompt_text[0...state.point] + kill[0] + state.prompt_text[state.point..-1]
    else
      kill.unshift(state.prompt_text)
    end
    set_state({ point: 0, prompt_text: '', kill: kill, killn: 0, argument: nil, last_command: COMMAND_KILL }) { scroll_to_bottom }
  end

  def kill_word
    kill = state.kill
    if state.last_command == COMMAND_KILL
      kill[0] = kill[0] + state.prompt_text[state.point...next_word]
    else
      kill.unshift(state.prompt_text[state.point...next_word])
    end
    set_state({ prompt_text: state.prompt_text[0...state.point] + state.prompt_text[next_word..-1], kill: kill, killn: 0, argument: nil,
                last_command: COMMAND_KILL }) { scroll_to_bottom }
  end

  def backward_kill_word
    kill = state.kill
    if state.last_command == COMMAND_KILL
      kill[0] = state.prompt_text[previous_word...state.point] + kill[0]
    else
      kill.unshift(state.prompt_text[previous_word...state.point])
    end
    set_state({ point: previous_word, prompt_text: state.prompt_text[0...previous_word] + state.prompt_text[state.point..-1], kill: kill,
                killn: 0, argument: nil, last_command: COMMAND_KILL }) { scroll_to_bottom }
  end

  def yank
    set_state(console_insert(state.kill[state.killn], nil).merge({ last_command: COMMAND_YANK })) { scroll_to_bottom }
  end

  def yank_pop
    if state.last_command == COMMAND_YANK
      killn = rotate_ring(1, state.killn, state.kill.length, nil)
      set_state(console_insert(state.kill[killn], state.kill[state.killn].length).merge({ killn: killn, last_command: COMMAND_YANK })) do
        scroll_to_bottom
      end
    end
  end

  def complete
    if props.complete
      # Split text and find current word
      words = state.prompt_text.split(" ")
      curr = 0
      idx = words[0].length
      while(idx < state.point && curr + 1 < words.length)
        idx += words[++curr].length + 1
      end
      completions = props.complete(words, curr, state.prompt_text)
      if completions.length == 1
        # Perform completion
        words[curr] = completions[0]
        point = -1
        i = 0
        while i <= curr
          i += 1
          point += words[i].length + 1
        end
        set_state({ point: point, prompt_text: words.join(" "), argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
      elsif completions.length > 1
        # show completions
        log = state.log
        log.push({ label: state.curr_label, command: state.prompt_text, message: [{ type: "completion", value: [completions.join("\t")] }] })
        set_state({ curr_label: next_label, log: log, argument: nil, last_command: COMMAND_DEFAULT}) { scroll_to_bottom }
      end
    end
  end

  # Keyboard Macros
  # Miscellaneous
  def prefix_meta
    if state.last_command == COMMAND_SEARCH
      set_state({ argument: nil, last_command: COMMAND_DEFAULT })
    end
    # TODO Meta prefixed state
  end

  def cancel_command
    if state.accept_input # Typing command
      ref(:child_typer).JS[:current].JS[:value] = ""
      log = state.log
      log.push({ label: state.curr_label, command: state.prompt_text, message: [] })
      set_state({ typer: "", point: 0, prompt_text: "", restore_text: "", log: log, historyn: 0, argument: nil,
                  last_command: COMMAND_DEFAULT}) { scroll_to_bottom }
    else # command is executing, call handler
      props.cancel
    end
  end

  # Helper functions
  def insert_question_mark
    set_state(console_insert('?', nil))
  end

  def text_insert(insert, text, replace, point)
    replace = 0 if replace == nil
    point = text.length if point == nil
    text[0...(point - replace)] + insert + text[point..-1]
  end

  def console_insert(insert, replace)
    replace = 0 if replace == nil
    prompt_text = text_insert(insert, state.prompt_text, replace, state.point)
    { point: move_point(insert.length - replace, insert.length - replace + state.prompt_text.length),
      prompt_text: prompt_text, restore_text: prompt_text, argument: nil, last_command: COMMAND_DEFAULT }
  end

  def move_point(n, max)
    max = state.prompt_text.length if max == nil
    pos = state.point + n
    return 0 if pos < 0
    return max if pos > max
    pos
  end

  def next_word
    # Find first alphanumeric char after first non-alphanumeric char
    search = `/\W\w/.exec(#{state.prompt_text[state.point..-1]})`
    return search.index + state.point + 1 if search
    state.prompt_text.length
  end

  def previous_word
    # Find first non-alphanumeric char after first alphanumeric char in reverse
    search = `/\W\w(?!.*\W\w)/.exec(#{state.prompt_text[0...(state.point-1)]})`
    return search.index + 1 if search
    0
  end

  def rotate_ring(n, ringn, ring, circular)
    circular = true if circular == nil
    return 0 if ring == 0
    if circular
      return (ring + (ringn + n) % ring) % ring
    else
      ringn = ringn - n
    end
    return 0 if ringn < 0
    return ring if ringn >= ring
    ringn
  end

  def rotate_history(n)
    historyn = rotate_ring(n, state.historyn, state.history.length, false)
    if historyn == 0
      set_state({ point: state.restore_text.length, prompt_text: state.restore_text, historyn: historyn,
                  argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
    else
      prompt_text = state.history[state.history.length-historyn]
      set_state({ point: prompt_text.length, prompt_text: prompt_text, historyn: historyn,
                  argument: nil, last_command: COMMAND_DEFAULT }) { scroll_to_bottom }
    end
  end

  def search_history(direction, next_v)
    direction = state.search_direction if direction == nil
    next_v = false if next_v == nil
    idx = state.historyn
    inc = (direction == SEARCH_DIRECTION_REVERSE) ? 1 : -1
    idx = idx + inc if next_v
    while idx > 0 && idx <= state.history.length
      idx = idx + inc
      entry = state.history[state.history.length-idx]
      point = entry.index(state.search_text)
      if point > -1
        return { point: point, prompt_text: entry, search_direction: direction, search_init: false, historyn: idx }
      end
    end
    return { search_direction: direction, search_init: false }
  end


  # DOM management
  def scroll_if_bottom
    if scroll_semaphore > 0 ||
      ref(:child_container).JS[:current].JS[:scrollTop] == ref(:child_container).JS[:current].JS[:scrollHeight] - ref(:child_container).JS[:current].JS[:offsetHeight]
      scroll_semaphore_incr
      scroll_if_bottom_true
    else
      nil
    end
  end

  def scroll_if_bottom_true
    scroll_to_bottom
    scroll_semaphore_decr
  end

  def scroll_to_bottom
    ref(:child_container).JS[:current].JS[:scrollTop] = ref(:child_container).JS[:current].JS[:scrollHeight]
    rect = ref(:child_focus).JS[:current].JS.getBoundingClientRect()
    if rect.JS[:top] < 0 || rect.JS[:left] < 0 ||
      rect.JS[:bottom] > (`window.innerHeight` || `document.documentElement.clientHeight`) ||
      rect.JS[:right] > (`window.innerWidth` || `document.documentElement.clientWidth`)
      ref(:child_typer).JS[:current].JS.scrollIntoView(false)
    end
  end

  def next_label
    if `(typeof #{props.prompt_label} === "string")`
      props.prompt_label
    else
      props.prompt_label.call
    end
  end

  render do
    DIV(ref: ref(:child_container),
        class_name: "react-console-container " + (state.focus ? "react-console-focus" : "react-console-nofocus"),
        on_click: :focus) do
      if props.welcome_message
        DIV(class_name: "react-console-message react-console-welcome") { props.welcome_message }
      end
      i = 0
		  state.log.each do |val|
        i += 1
			  ConsolePrompt(label: val[:label], value: val[:command])
        val[:message].each do |v|
          ConsoleMessage(key: i, type: v[:type], value: v[:value])
        end
      end
      if state.accept_input
        ConsolePrompt(label: state.curr_label, value: state.prompt_text, point: state.point, argument: state.argument)
		  end
      DIV(style: { overflow: "hidden", height: 1, width: 1 }) do
	      TEXTAREA(ref: ref(:child_typer), class_name: "react-console-typer", auto_complete: "off", auto_correct: "off",
                 auto_capitalize: "off", spell_check: "false",
                 style: { outline: "none", color: "transparent", backgroundColor: "transparent",
                          border: "none", resize: "none", overflow: "hidden" },
                 on_blur: :blur, on_key_down: :key_down, on_change: :change, on_paste: :paste)
      end
			DIV(ref: ref(:child_focus)) { "\u00A0" }
    end
	end
end
