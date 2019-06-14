class ConsoleMessage < React::Component::Base
  prop :type, default: nil
  prop :value, default: []

  render do
    DIV(class_name: "react-console-message" + (props.type ? " react-console-message-" + props.type : "")) do
      i = 0
      props.value.map do |val|
        i += 1
        if `(typeof val === 'string')`
          DIV(key: i) { val }
        elsif `(typeof val === 'object' && val.type === 'link')`
          DIV(key: i) { A(href: val.href, target: (val.target ? val.target : '')) { val.text }}
        else
          DIV(key: i) { `JSON.stringify(val)` }
        end
      end
    end
  end
end
