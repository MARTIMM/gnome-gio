## Release notes
* 2022-10-13 0.10.8
  * Method get-file-rk() in module **Gnome::Gio::FileIcon** deprecated. And a few more deprecation messages in **Gnome::Gio::File**.
  * Updated documentation of modules.
  
* 2022-10-13 0.10.7
  * File extensions renamed

* 2022-07-25 0.10.6
  * Remove dependency on :_widget in event callback handlers

<!-- Wrong mods to implement
  * Add module **Gnome::Gio::Emblem**.
  * Add module **Gnome::Gio::EmblemedIcon**.
-->
* 2022-05-28 0.10.5:
  * setenv and unsetenv removed from AppLaunchContext.
  * Improved doc in MenuItem and SimpleAction.

* 2022-05-23 0.10.4:
  * Module DesktopAppInfo added.

* 2022-02-20 0.10.3:
  * Pushed a new version after accidentally removing 0.10, 0.10.1 and 0.10.2 from CPAN.

* 2022-02-20 0.10.2:
  * Deprecate all `-rk()` routines. It is possible to coerce from the native object to the Raku object like so;
  ```
  my Gnome::Gdk3::Event $event = …;
  my Gnome::Gdk3::Device() $device = $event.get-device;
  ```

* 2021-12-12 0.10.1
  * Changes for renamed methods in **Gnome::N::TopLevelClassSupport**.

* 2021-11-04 0.10.0
  * Add modules **Gnome::Gio::Icon**, **Gnome::Gio::Emblem**, **Gnome::Gio::EmblemedIcon**, **Gnome::Gio::FileIcon** and **Gnome::Gio::ThemedIcon**.

* 2021-10-27 0.9.2
  * Removed `query-info()` from File because returned native object is of type GFileInfo which is not to be implemented as **Gnome::Gio::FileInfo**. This is done because the file attribute information returned can easily be retrieved in Raku itself.

* 2021-10-27 0.9.1
  * Bug fix: initialization of error objects done wrong.

* 2021-10-24 0.9.0
  * Add **Gnome::Gio::AppInfo**, **Gnome::Gio::AppInfoManager**, **Gnome::Gio::AppLaunchContext**.
  * Modified pod doc of **Gnome::Gio::File**.

* 2021-07-15 0.8.1
  * Due to some changes in **Gnome::GObject::Value**, the `.get-boolean()` method returns `True` or `False` instead of `1` or `0`. `.set-boolean()` is unchanged because Raku could coerse `True` and `False` to integer automatically.

* 2021-03-14 0.7.0
  * Add module **Gnome::Gio::ApplicationCommandLine**.
  * Add module **Gnome::Gio::Notification**.

* 2021-03-05 0.6.1
  * Removed dependency on **Gnome::Glib::OptionContext**.

* 2021-02-24 0.6.0
  * Splitting **Gnome::Gio::MenuModel** in parts; MenuModel, MenuAttributeIter and MenuLinkIter.
  * Add new module **Gnome::Gio::Menu**. Directly split into Menu and MenuIter.

* 2021-02-13 0.5.4
  * made role testing more simple.

* 2021-02-06 0.5.3
  * Modified and tested modules **Gnome::Gio::Action** and **Gnome::Gio::SimpleAction**.
  * Add modules **Gnome::Gio::ActionGroup** and **Gnome::Gio::SimpleActionGroup** and tests.

* 2020-12-19 0.5.2
  * bugfix in test; path tested was only for linux types, not windows.
  * Type mismatch in Application, MenuModel and SimpelAction

* 2020-04-12 0.5.1
  * I was on the verge of removing module MenuModule because of some notes about deprecating application menus. A closer look at a picture on the [page here](https://wiki.gnome.org/HowDoI/ApplicationMenu) showed a menu in the application frame and that is not supported anymore. This is different than the thought that some XML format to describe menus was deprecated.

* 2020-04-06 0.5.0
  * Add File module to Gnome::Gio

* 2020-03-25 0.4.2
  * Added `g_resource_ref()` and `g_resource_unref()` to Resources after changes in Gnome::GObject::Boxed
* 2020-03-19 0.4.1
  * Small changes caused by extracted native classes

* 2020-03-03 0.4.0
  * Add ActionMap module to Gnome::Gio

* 2020-02-29 0.3.0
  * Add Action, SimpleAction modules

* 2020-02-26 0.2.0
  * Add Resource module

* 2020-02-25 0.1.2
  * Bugfixes in Application. There is a change in registration process `g_application_register()`. It now returns a **Gnome::Glib::Error** object. the cancelation object cannot be set because the class is not yet implemented in this package.

* 2020-02-23 0.1.1
  * Bugfixes and docs

* 2019-11-04 0.1.0
  * Added modules Enums, MenuModel, Application

* 2019-10-28 0.0.1
  * Start
