#
# $1 - some string possibly quoted with double quotes
#
# returns:
#   double-quote and whitespace stripped version of $(1)
#
define qstrip
$(strip $(subst ",,$(1)))
endef

#
# $1 - some string possibly containing newline chars
#
# returns:
#   the same string with all newline chars replaced with spaces
#
define newline2space
$(subst $(_newline),$(_space),$(1))
endef

#
# $1 - pattern (regular wildcard parameter)
#
# Overcomes the following deficiency of $(sort $(wildcard ...))
#
# $(sort xyz-suffix xyz):
#    returns (as expected) "xyz xyz-suffix"
# $(sort xyz-suffix/... xyz/...):
#    however returns "xyz-suffix/... xyz/..."
#    which is actually correct (ASCII code of "-" is smaller than that of "/")
#    but not what one would expect when sorting is applied to filepaths.
#
# sorted-wildcard returns "xyz/... xyz-suffix/..." for "xyz-suffix/... xyz/..."
#
define sorted-wildcard
$(strip $(subst $(_bang),/,$(sort $(subst /,$(_bang),$(wildcard $(1))))))
endef

#
# $1 - some string representing a version of some package
# $2 (optional) - number of version components to be included, default 2
#
# returns:
#   major version of the package, i.e. x.y for x.y.z
#
define GET_MAJOR_VERSION
$(strip $(subst $(_space),.,$(wordlist 1,$(if $(2),$(2),2),$(subst .,$(_space),$(1)))))
endef


# SUBST_MAP
# Substitute according to map src:dst
#  $1 - some string
#  $2 - list of src:dst pairs
SUBST_MAP = $(strip		\
	$(eval __tmp := $1)	\
	$(foreach s,$2,		\
		$(eval __tmp := $(subst $(word 1,$(subst :, ,$s)),$(word 2,$(subst :, ,$s)),$(__tmp))))	\
	$(__tmp))
SUBST_MAP_TOLOWER := A:a B:b C:c D:d E:e F:f G:g H:h I:i J:j K:k L:l M:m N:n O:o P:p Q:q R:r S:s T:t U:u V:v W:w X:x Y:y Z:z
SUBST_MAP_TOUPPER := a:A b:B c:C d:D e:E f:F g:G h:H i:I j:J k:K l:L m:M n:N o:O p:P q:Q r:R s:S t:T u:U v:V w:W x:X y:Y z:Z
SUBST_MAP_NAME := -:_
SUBST_MAP_TOUPPER_NAME := $(SUBST_MAP_TOUPPER) $(SUBST_MAP_NAME)
SUBST_MAP_TOLOWER_NAME := $(SUBST_MAP_TOLOWER) $(SUBST_MAP_NAME)

# TOUPPER_NAME
# Convert letters to uppercase, minus to underline
#   $1 = string to convert
TOUPPER_NAME = $(call SUBST_MAP,$1,$(SUBST_MAP_TOUPPER_NAME))

#
# $1 - git repository
# $2 - (optional) branch name, if omitted "master" is used
#
# returns:
#   latest revision of the specified branch
#
define git-get-latest-revision
$(shell rev=$$(git ls-remote --heads $(strip $(1)) $(if $(strip $(2)),$(strip $(2)),master) | sed -rn -e 's,^([0-9a-f]{10})[0-9a-f]{30}.*,\1,p'); echo "$${rev:-FAILED_TO_DETERMINE_LATEST_REVISION}")
endef
