class ConsoleMessage < React::Component::Base
  prop :type, default: nil
  prop :value, default: []

  render do
    DIV(key: 'cm1', class_name: "react-console-message" + (props.type ? " react-console-message-" + props.type : "")) do
      i = 0
      props.value.each do |val|
        if `(typeof val === 'string')`
          val.split('\n').each do |line|
            DIV(key: i += 1) { line }
          end
        elsif `(typeof val === 'object' && val.type === 'link')`
          DIV(key: i += 1) { A(href: val.href, target: (val.target ? val.target : '')) { val.text }}
        else
          DIV(key: i += 1) { `JSON.stringify(val)` }
        end
      end
    end
  end
end
