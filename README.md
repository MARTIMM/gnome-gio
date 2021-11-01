![gtk logo][logo]

# Gnome Gio

![T][travis-svg] ![A][appveyor-svg] ![L][license-svg]

[travis-svg]: https://travis-ci.org/MARTIMM/gnome-gio.svg?branch=master
[travis-run]: https://travis-ci.org/MARTIMM/gnome-gio

[appveyor-svg]: https://ci.appveyor.com/api/projects/status/github/MARTIMM/gnome-gio?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true
[appveyor-run]: https://ci.appveyor.com/project/MARTIMM/gnome-gio/branch/master

[license-svg]: http://martimm.github.io/label/License-label.svg
[licence-lnk]: http://www.perlfoundation.org/artistic_license_2_0


# Description

From the Gnome documentation;

GIO is striving to provide a modern, easy-to-use VFS API that sits at the right level in the library stack, as well as other generally useful APIs for desktop applications (such as networking and D-Bus support). The goal is to overcome the shortcomings of GnomeVFS and provide an API that is so good that developers prefer it over raw POSIX calls. Among other things that means using GObject. It also means not cloning the POSIX API, but providing higher-level, document-centric interfaces.

That being said, the Raku implementation is not implementing all of it, only those parts interesting to the other packages like application, resource and settings handling or DBus I/O.


# Documentation
* [ 🔗 Website](https://martimm.github.io/gnome-gtk3/content-docs/reference-gio.html)
* [ 🔗 Travis-ci run on master branch][travis-run]
* [ 🔗 Appveyor run on master branch][appveyor-run]
* [ 🔗 License document][licence-lnk]
* [ 🔗 Release notes][changes]
* [ 🔗 Issues](https://github.com/MARTIMM/gnome-gtk3/issues)

# Installation
Do not install this package on its own. Instead install `Gnome::Gtk3`.

`zef install Gnome::Gtk3`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my Gnome::Gtk3 github project][issues].

# Attribution
* The inventors of Raku (formerly called Perl6) of course and the writers of the documentation which help me out every time again and again.
* The builders of the GTK+ library and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/perl6-gnome-gio/blob/master/CHANGES.md
[logo]: https://martimm.github.io/gnome-gtk3/content-docs/images/gtk-perl6.png
[issues]: https://github.com/MARTIMM/perl6-gnome-gtk3/issues
