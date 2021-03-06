PREFIX = /usr/local
LD = ld
CC = cc
PKG_CONFIG = pkg-config
INSTALL = install
CFLAGS = -g -O2 -Wall -Wextra
LDFLAGS = -pthread
LIBS =
VLC_PLUGIN_CFLAGS := $(shell $(PKG_CONFIG) --cflags vlc-plugin)
VLC_PLUGIN_LIBS := $(shell $(PKG_CONFIG) --libs vlc-plugin)
VLC_PLUGIN_DIR := $(shell $(PKG_CONFIG) --variable=pluginsdir vlc-plugin)

plugindir = $(VLC_PLUGIN_DIR)/misc

SOURCES = listenbrainz.c
SOURCES_DIR = vlc-3.0

override CC += -std=gnu99
override CPPFLAGS += -DPIC -I. -Isrc
override CFLAGS += -fPIC
override LDFLAGS += -Wl,-no-undefined,-z,defs

override CPPFLAGS += -DMODULE_STRING=\"listenbrainz\"
override CFLAGS += $(VLC_PLUGIN_CFLAGS)
override LIBS += $(VLC_PLUGIN_LIBS)

TARGETS = liblistenbrainz_plugin.so

all: liblistenbrainz_plugin.so

install: all
		mkdir -p -- $(DESTDIR)$(plugindir)
		$(INSTALL) --mode 0755 liblistenbrainz_plugin.so $(DESTDIR)$(plugindir)

install-strip:
		$(MAKE) install INSTALL="$(INSTALL) -s"

uninstall:
		rm -f $(plugindir)/liblistenbrainz_plugin.so

clean:
		rm -rf liblistenbrainz_plugin.so **/*.o

mostlyclean: clean

$(SOURCES:%.c=$(SOURCES_DIR)/%.o): %: $(SOURCES_DIR)/listenbrainz.c

liblistenbrainz_plugin.so: $(SOURCES:%.c=$(SOURCES_DIR)/%.o)
		$(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS)

.PHONY: all install install-strip uninstall clean mostlyclean