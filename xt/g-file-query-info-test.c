/*
  package config run:
    pkg-config --libs --cflags glib-2.0
    --> -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -lglib-2.0

  locations of my source files
    /home/marcel/Software/Packages/Sources/Gnome/glib-2.70.0

  compile:
    gcc -I/home/marcel/Software/Packages/Sources/Gnome/glib-2.70.0 \
      -I/home/marcel/Software/Packages/Sources/Gnome/glib-2.70.0/glib \
      -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include \
      -lglib-2.0 -lgio-2.0 \
      -o g-file-query-info-test g-file-query-info-test.c

 See also:
   https://www.tutorialspoint.com/c_standard_library/limits_h.htm
   https://www.tutorialspoint.com/cprogramming/c_data_types.htm
   https://en.wikibooks.org/wiki/C_Programming/limits.h
   https://www.gnu.org/software/libc/manual/html_node/Range-of-Type.html
*/

#include <stdio.h>

#include <gio/gio.h>
#include <gio/gfile.h>
#include <gio/gfileinfo.h>

int main(int argc, char** argv) {

  //g_type_init...;

  GFile *file;
  GFileInfo *qi;
  GError *error = NULL;

  file = g_file_new_for_uri ("file:///nonexistendfile");

  // same args as used in g_file_query_default_handler()
  qi = g_file_query_info (
    file, G_FILE_ATTRIBUTE_STANDARD_CONTENT_TYPE, 0, NULL, &error
  );

  // check error if NULL
  if (qi == NULL) {
    if (error != NULL) {
      fprintf (stderr, "Unable to read file: %s\n", error->message);
      g_error_free (error);
    }

    else {
      fprintf (stderr, "No file info and no error set");
    }
  }

  else {
    fprintf (stderr, "seems to be alright\n");
  }

  return 0;
}
