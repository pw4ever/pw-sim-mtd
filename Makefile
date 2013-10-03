# node
N?=512
# attacker
AT?=1
# attacker budget
ATB?=16 32 64 128 256
# defender --- how many tries
DF?=100
# defender assets
DFA?=16 32 64 128 256

# duration
D?=250

FILENAME_ROOT=result

.PHONY: all plot clean

all: $(FILENAME_ROOT).txt 

$(FILENAME_ROOT).txt: $(shell find helper-script/review-history -name "*.lisp") $(foreach n,$(N),$(foreach at,$(AT),$(foreach atb,$(ATB),$(foreach df,$(DF),$(foreach dfa,$(DFA),$(foreach d,$(D),$(n)_$(at)_$(atb)_$(df)_$(dfa)_$(d).world))))))
	helper-script/review-history/00-start.sh $(foreach n,$(N),$(foreach at,$(AT),$(foreach atb,$(ATB),$(foreach df,$(DF),$(foreach dfa,$(DFA),$(foreach d,$(D),$(n)_$(at)_$(atb)_$(df)_$(dfa)_$(d).world)))))) > $(FILENAME_ROOT).txt

define SIM_body
$(n)_$(at)_$(atb)_$(df)_$(dfa)_$(d).world: $(n)_$(at)_$(atb)_$(df)_$(dfa).param
	./00-start.sh --world-param=$(n)_$(at)_$(atb)_$(df)_$(dfa).param --output=$$@ --duration=$(d)

$(n)_$(at)_$(atb)_$(df)_$(dfa).param: $(shell find helper-script/make-world-param -name "*.lisp")
	helper-script/make-world-param/00-start.sh --world=$$@ --node=$(n) --attacker=$(at) --budget=$(atb) --defender=$(df) --asset=$(dfa)
endef

$(foreach n,$(N),$(foreach at,$(AT),$(foreach atb,$(ATB),$(foreach df,$(DF),$(foreach dfa,$(DFA),$(foreach d,$(D),$(eval $(SIM_body))))))))

plot: $(FILENAME_ROOT).pdf

$(FILENAME_ROOT).pdf: $(FILENAME_ROOT).stat 01plot/plot.R
	01plot/plot.R $(FILENAME_ROOT)

%.stat: %.txt 01plot/stat.R
	01plot/stat.R $*

clean:
	@rm -f *.world *.param
