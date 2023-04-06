BINDIR := bin

RUSTDIR  := rust
RUSTAPPS := linevalve
RUSTBINS := $(addprefix $(BINDIR)/,$(RUSTAPPS))

define BUILD_RUST_RELEASE
$(BINDIR)/$(1):
	( cd $(RUSTDIR)/$(1); cargo build --release; )
	mv $(RUSTDIR)/$(1)/target/release/$(1) $(BINDIR)
endef

$(foreach RUSTAPP,$(RUSTAPPS),\
	$(eval $(call BUILD_RUST_RELEASE,$(RUSTAPP)))\
)

all: $(RUSTBINS)

clean:
	for bin in $(RUSTBINS); do [ -e $$bin ] && rm $$bin; done

.PHONY: all clean
