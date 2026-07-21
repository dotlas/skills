# Install dev tooling and git hooks
setup:
    uv sync
    uv run lefthook install

# Format markdown
fmt:
    uv run flowmark --inplace --nobackup .

# Verify markdown formatting
lint:
    uv run flowmark --check .
