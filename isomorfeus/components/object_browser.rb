class ObjectBrowser < LucidMaterial::Component::Base
  styles do |theme|
    { title: { flexGrow: 1 },
      button: { backgroundColor: '#7A8DBE', boxShadow: :none, textTransform: :none }}
  end

  store.render = 0
  state.classes = []

  event_handler :refresh do
    @object_registry = {}
    get_classes
  end

  event_handler :handle_expansion do |node_id, expanded|
    `console.log("handle_expansion:", node_id, expanded)`
    if expanded
      class_name, obj_id = node_id.split('|')
      get_object_path(class_name, obj_id)
    end
  end

  def object_registry
    @object_registry ||= {}
  end

  def object_registry=(o)
    @object_registry = o
  end

  def get_classes
    javascript_code = <<~JAVASCRIPT
      var result;
      if (typeof Opal !== "undefined" && typeof Opal.opal_devtools_object_registry !== "undefined") {
        result = Object.keys(Opal.opal_devtools_object_registry);
      }
      result
    JAVASCRIPT
    %x{
      chrome.devtools.inspectedWindow.eval(javascript_code, {}, function(result, exception_info) {
        if (exception_info) {
          if (exception_info.isError) { console_log(exception_info.description) }
          if (exception_info.isException) { console.log(exception_info.value) }
        }
        if (result) { #{state.classes = `result` } }
      });
    }
  end

  def get_object_path(class_name, obj_id = nil)
    object_registry[class_name] = {} unless object_registry.key?(class_name)
    `console.log("get_object_path:", class_name, obj_id)`
    javascript_code = <<~JAVASCRIPT
      var class_name = "#{class_name}";
      var obj_id = "#{obj_id}";
      var result;
      if (typeof Opal !== "undefined" && typeof Opal.opal_devtools_object_registry !== "undefined") {
        var ore = Opal.opal_devtools_object_registry;
        if (typeof Opal.opal_devtools_object_registry.hasOwnProperty(class_name)) {
          if (obj_id !== "" && ore[class_name].hasOwnProperty(obj_id)) {
            result = [];
            var keys = Object.keys(ore[class_name][obj_id]);
            for (var i=0; i < keys.length; i++) {
              if (keys[i] !== "$$id") {
                var value = ore[class_name][obj_id][keys[i]];
                if (typeof value.$$is_hash !== "undefined") {
                  value = value.$to_n();
                  value = JSON.stringify(value);
                } else if (typeof value.$$id !== "undefined") {
                  t_value = "object|";
                  if (typeof value.constructor.$$full_name !== "undefined" && value.constructor.$$full_name && value.constructor.$$full_name !== "") { t_value = t_value + value.constructor.$$full_name; }
                  else if (typeof value.constructor.$$name !== "undefined" && value.constructor.$$name && value.constructor.$$name !== "") { t_value = t_value + value.constructor.$$name; }
                  value = t_value + '|' + value.$$id.toString();
                } else if (typeof value === "object") {
                  try {
                    value = JSON.stringify(value);
                  } catch {
                    value = "Unserializable Javascript Object";
                  }
                } 
                result[i] = [keys[i], value];
              }
            }
            result = result.filter(function(el) { return el != null; });
          } else {
            result = Object.keys(ore[class_name]);
          }
        }
      }
      result
    JAVASCRIPT
    %x{
      chrome.devtools.inspectedWindow.eval(javascript_code, {}, function(result, exception_info) {
        if (exception_info) {
          if (exception_info.isError) { console_log(exception_info.description) }
          if (exception_info.isException) { console.log(exception_info.value) }
        }
        if (result) {
          #{
            `console.log("Current Registry 1:", #{object_registry})`
            if obj_id
              object_registry[class_name][obj_id] = {} unless object_registry[class_name].key?(obj_id)
              `result`.each do |varval|
                object_registry[class_name][obj_id][varval[0]] = varval[1]
              end
            else
              `result`.each do |obj_id|
                object_registry[class_name][obj_id] = {}
              end
            end
            store.render = store.render += 1
          }
        }
      });
    }

  end

  render do
    @collapse_icon ||= get_react_element { ExpandMoreIcon() }
    @expand_icon ||= get_react_element { ChevronRightIcon() }
    key = 0
    Mui.Toolbar(key: key += 1) do
      Mui.Typography({key: key += 1, class_name: styles.title, variant: :h6}, "Object Browser")
      Mui.Button(key: key += 1, class_name: styles.button, color: :default, variant: :contained, on_click: :refresh) do
        "Refresh Classes"
      end
    end
    Mui.Container(key: key += 1) do
      MuiLab.TreeView(key: key += 1, on_node_toggle: :handle_expansion, default_collapse_icon: @collapse_icon, default_expand_icon: @expand_icon) do
        state.classes.sort.each do |class_name|
          MuiLab.TreeItem(key: key += 1, node_id: class_name, label: class_name) do
            if object_registry.key?(class_name)
              object_registry[class_name].keys.sort.each do |obj_id|
                MuiLab.TreeItem(key: key += 1, node_id: "#{class_name}|#{obj_id}", label: obj_id) do
                  Mui.Table(key: key += 1, size: :small) do
                    Mui.TableBody(key: key += 1) do
                      if object_registry[class_name][obj_id].any?
                        object_registry[class_name][obj_id].keys.sort.each do |var_name|
                          Mui.TableRow(key: key += 1) do
                            Mui.TableCell(key: key += 1) { var_name.start_with?('$') ? var_name : "@#{var_name}" }
                            Mui.TableCell(key: key += 1) do
                              v = "#{object_registry[class_name][obj_id][var_name]}"
                              if v.start_with?('object|')
                                _, cn, oid = v.split('|')
                                [cn, oid].join(" ")
                              else
                                v
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            else
              MuiLab.TreeItem(key: key += 1, node_id: "#{class_name}|", label: "Object Id") do
                Mui.Table(key: key += 1, size: :small) do
                  Mui.TableBody(key: key += 1) do
                    Mui.TableRow(key: key += 1) do
                      Mui.TableCell(key: key += 1) { "@instance_variable_name" }
                      Mui.TableCell(key: key += 1) { "value" }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  component_did_mount do
    get_classes()
  end
end
