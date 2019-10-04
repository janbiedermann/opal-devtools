class ConsoleMessage < React::Component::Base
  prop :type, default: nil
  prop :value, default: []

  render do
    DIV(class_name: "react-console-message" + (props.type ? " react-console-message-" + props.type : "")) do
      i = 0
      props.value.each do |val|
        if `(typeof val === 'string')`
          val.split('\n').each do |line|
            i += 1
            DIV(key: i) { line }
          end
        elsif `(typeof val === 'object' && val.type === 'link')`
          i += 1
          DIV(key: i) { A(href: val.href, target: (val.target ? val.target : '')) { val.text }}
        else
          i += 1
          DIV(key: i) { `JSON.stringify(val)` }
        end
      end
    end
  end
end
