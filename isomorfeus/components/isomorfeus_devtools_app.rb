class IsomorfeusDevtoolsApp < LucidMaterial::App::Base
  styles do |theme|
    {
      sidebar: { backgroundColor: '#7A8DBE' },
      container: { }
    }
  end

  app_store.inject_mode = false
  app_store.active_view = :console
  app_store.show_menu_drawer = false

  render do
    OpalDevtoolsAppBar()
    OpalDevtoolsDrawer()
    Mui.Grid(class_name: styles.container, container: true, direction: :row) do
      Mui.Grid(item: true, xs: 12) do
        if app_store.active_view == :object_browser
          ObjectBrowser()
        else
          OpalConsole()
        end
      end
    end
  end
end
