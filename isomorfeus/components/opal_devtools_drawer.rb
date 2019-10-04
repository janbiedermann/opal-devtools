class OpalDevtoolsDrawer < LucidMaterial::Component::Base
  VIEWS = %i[console object_browser]

  styles do
    {
      buttons: {
        textTransform: :none
      }
    }
  end

  event_handler :toggle_inject_mode do
    app_store.inject_mode = !app_store.inject_mode
  end

  event_handler :cycle_active_view do
    i = VIEWS.index(app_store.active_view)
    i += 1
    i = 0 if i >= VIEWS.size
    app_store.active_view = VIEWS[i]
  end

  event_handler :close_menu_drawer do |event|
    app_store.show_menu_drawer = false
  end

  render do
    # Mui.Grid(container: true, direction: :column) do
    #   Mui.Grid(item: true) do
    #     Mui.Button(class_name: styles.buttons, variant: :contained, color: :primary, size: :small, on_click: :toggle_inject_mode) do
    #       "Inject mode is #{app_store.inject_mode ? 'on' : 'off'}"
    #     end
    #     Mui.Button(class_name: styles.buttons, variant: :contained, color: :primary, size: :small, on_click: :cycle_active_view) do
    #       "#{app_store.active_view.split('_').map(&:camelize).join(' ')} is active."
    #     end
    #   end
    # end
    Mui.Drawer(variant: :persistent, anchor: :left, open: app_store.show_menu_drawer) do
      DIV do
        Mui.IconButton(on_click: :close_menu_drawer) do
          MuiIcons.ChevronLeft
        end
      end
      # Mui.Divider()
      # Mui.List do
      #   Mui.ListItem(button: :true) do
      #     Mui.ListItemText 'Test'
      #   end
      # end
    end
  end
end
