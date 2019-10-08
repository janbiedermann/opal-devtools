class IsomorfeusDevtoolsApp < LucidMaterial::App::Base
  styles do |theme|
    { container: { marginTop: 60 }}
  end
  app_store.inject_mode = false
  app_store.active_view = :console
  app_store.show_menu_drawer = false
  app_store.framework = nil
  app_store.opal_version = nil
  app_store.devtools = false
  app_store.object_registry = {}

  render do
    key = 0
    OpalDevtoolsAppBar(key: key += 1)
    Mui.Container(key: key += 1, class_name: styles.container) do
      if app_store.active_view == :object_browser
        ObjectBrowser(key: key +=1)
      else
        OpalConsole(key: key +=1)
      end
    end
  end

  def page_check_listener(event)
    %x{
      var message = event.detail;
      if (message && typeof message.opal_version === "string") {
        var o = message.opal_version;
        #{Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :opal_version, value: `o`)}
      } else { #{Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :opal_version, value: nil)} }
      if (message && typeof message.framework === "string") {
        var f = message.framework;
        #{Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :framework, value: `f`)}}
      else { #{Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :framework, value: nil)} }
      if (message && message.devtools_support) { #{Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :devtools, value: true)}}
      else { #{
        Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :devtools, value: false)
        Isomorfeus.store.dispatch(type: 'APPLICATION_STATE', name: :active_view, value: :console)
      } }
    }
  end

  component_did_mount do
    `window.addEventListener('OpalDevtoolsPageCheck', #{self}.$page_check_listener)`
  end

  component_will_unmount do
    `window.removeEventListener('OpalDevtoolsPageCheck', #{self}.$page_check_listener)`
  end
end
