test:
	./rigger stubbs:test --module rigger

test-%:
	./rigger stubbs:test --module rigger --plan $(subst test-,,$@)
