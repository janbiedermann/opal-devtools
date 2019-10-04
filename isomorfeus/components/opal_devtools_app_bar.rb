class OpalDevtoolsAppBar < LucidMaterial::Component::Base
  event_handler :toggle_menu_drawer do |event|
    app_store.show_menu_drawer = !app_store.show_menu_drawer
  end

  render do
    Mui.AppBar(position: :fixed, color: :default) do
      Mui.Toolbar do
        # Mui.Typography(variant: :h6) do
        #   "Opal Developer Tools"
        # end
        # Mui.IconButton(class_name: styles.title_logo, color: :inherit, aria_label: :menu) do
        #   Kursator.Logo()
        # end
        # Mui.IconButton(edge: :start, color: :inherit, aria_label: :menu) do
        #   MuiIcons.Menu(on_click: :toggle_menu_drawer)
        # end
        #Mui.Typography(variant: :h6, class_name: styles.title) { props.title }
        # Mui.Typography(variant: :button) do
        #   "Test"
        # end
      end
    end
  end
end
