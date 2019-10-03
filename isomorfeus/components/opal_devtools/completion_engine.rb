module OpalDevtools
  # CompletionEngine for tab completes
  class CompletionEngine
    VARIABLE_DOT_COMPLETE = /(\s*([$]*\w+)\.)$/
    METHOD_COMPLETE = /(\s*([$]*\w+)\.(\w+))$/
    CONSTANT = /(\s*([A-Z]\w*))$/
    METHOD_OR_VARIABLE = /(\s*([a-z]\w*))$/
    GLOBAL = /(\s*\$(\w*))$/

    NO_MATCHES_PARAMS = [nil, []]

    def self.irb_gvars
      %x{
        let gvars = [];
        for(variable in Opal.gvars) {
          if(Opal.gvars.hasOwnProperty(variable)) {
            gvars.push([variable, Opal.gvars[variable]])
          }
        };
        return gvars;
      }
    end

    def self.irb_vars
      %x{
        let irbVars = [];
        for(variable in Opal.irb_vars) {
          if(Opal.irb_vars.hasOwnProperty(variable)) {
            irbVars.push([variable, Opal.irb_vars[variable]])
          }
        };
        return irbVars;
      }
    end

    def self.irb_varnames
      irb_vars.map { |varname, _value| varname }
    end

    def self.common_prefix(orig_text, match_index, matches)
      return match_index == 0 ? matches.first : "#{orig_text[0..match_index-1]}#{matches.first}" if matches.size == 1
      working_copy = matches.clone
      chars = common_chars_in_prefix(working_copy)
      common = chars.join
      match_index == 0 ? common : orig_text[0..match_index-1] + common
    end

    def self.common_chars_in_prefix(words)
      first_word = words.shift
      chars = []
      i = 0
      if first_word
        first_word.each_char do |char|
          if words.all? { |str| str[i] == char }
            chars << char
            i += 1
          else
            return chars
          end
        end
      end
      chars
    end

    # Shows completions for text in opal-irb
    # @param text [String] the text to try to find completions for
    # @returns [CompletionResults]
    def self.complete(text)
      index, matches = case text
                       when GLOBAL
                         global_complete(text)
                       when VARIABLE_DOT_COMPLETE
                         variable_dot_complete(text)
                       when METHOD_COMPLETE
                         method_complete(text)
                       when CONSTANT
                         constant_complete(text)
                       when METHOD_OR_VARIABLE
                         method_or_variable_complete(text)
                       else
                         NO_MATCHES_PARAMS
                       end
      prefix = common_prefix(text, index, matches)
      [text, prefix, matches]
    end

    def self.variable_dot_complete(text)
      index = text =~ VARIABLE_DOT_COMPLETE # broken in 0.7, fixed in 0.7
      whole = $1
      target_name = $2
      get_correct_methods_by_type(whole, target_name, index)
    end

    def self.get_correct_methods_by_type(whole, target_name, index)
      case target_name
      when /^[A-Z]/
        get_class_methods(whole, target_name, index)
      when /^\$/
        get_global_methods(whole, target_name, index)
      else
        get_var_methods(whole, target_name, index)
      end
    end

    def self.get_class_methods(whole, target_name, index)
      begin
        klass = Kernel.const_get(target_name)
        [whole.size + index, klass.methods]
      rescue
        NO_MATCHES_PARAMS
      end
    end

    def self.get_global_methods(whole, target_name, index)
      target_name = target_name[1..-1] # strip off leading $

      name_val_pair = irb_gvars.find { |array| array[0] == target_name }
      if name_val_pair
        methods = name_val_pair[1].methods
        return [whole.size + index, methods]
      end
      NO_MATCHES_PARAMS
    end

    def self.get_var_methods(whole, target_name, index)
      name_val_pair = irb_vars.find { |array| array[0] == target_name }
      if name_val_pair
        methods = name_val_pair[1].methods
        return [whole.size + index, methods]
      end
      NO_MATCHES_PARAMS
    end

    def self.method_complete(text)
      index = text =~ METHOD_COMPLETE # broken in 0.7, fixed in 0.7
      whole = $1
      target_name = $2
      method_fragment = $3
      get_matches_for_correct_type(whole, target_name, method_fragment, index)
    end

    def self.get_matches_for_correct_type(whole, target_name, method_fragment, index)
      case target_name
      when /^[A-Z]/
        get_class_methods_by_fragment(whole, target_name, method_fragment, index)
      when /^\$/
        get_global_methods_by_fragment(whole, target_name, method_fragment, index)
      else
        get_var_methods_by_fragment(whole, target_name, method_fragment, index)
      end
    end

    def self.get_class_methods_by_fragment(whole, target_name, method_fragment, index)
      begin
        klass = Kernel.const_get(target_name)
        [whole.size + index - method_fragment.size, klass.methods.grep(/^#{method_fragment}/)]
      rescue
        NO_MATCHES_PARAMS
      end
    end

    def self.get_global_methods_by_fragment(whole, target_name, method_fragment, index)
      target_name = target_name[1..-1] # strip off leading $
      name_val_pair = irb_gvars.find { |array| array[0] == target_name }
      if name_val_pair
        methods = name_val_pair[1].methods.grep /^#{method_fragment}/
                                                return [whole.size + index - method_fragment.size, methods]
      end
      NO_MATCHES_PARAMS
    end

    def self.get_var_methods_by_fragment(whole, target_name, method_fragment, index)
      name_val_pair = irb_vars.find { |array| array[0] == target_name }
      if name_val_pair
        methods = name_val_pair[1].methods.grep /^#{method_fragment}/
                                                return [whole.size + index - method_fragment.size, methods]
      end
      NO_MATCHES_PARAMS
    end

    def self.constant_complete(text)
      index = text =~ CONSTANT
      whole = $1
      fragment = $2
      [whole.size + index - fragment.size, Object.constants.grep( /^#{fragment}/)]
    end

    def self.method_or_variable_complete(text)
      index = text =~ METHOD_OR_VARIABLE
      whole = $1
      fragment = $2
      varnames = irb_varnames.grep /^#{fragment}/
      matching_methods = methods.grep /^#{fragment}/
      [whole.size + index - fragment.size, varnames + matching_methods]
    end

    def self.global_complete(text)
      index = text =~ GLOBAL
      whole = $1
      fragment = $2
      varnames = irb_gvarnames.grep /^#{fragment}/
      [whole.size + index - fragment.size - 1, varnames.map { |name| "$#{name}" }]
    end
  end
end
