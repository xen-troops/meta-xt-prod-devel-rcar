# Removing dependency to the librsvg, as it is using rust.
# And usage of rust is increasing the build time a lot.
PACKAGECONFIG:remove = " rsvg"
