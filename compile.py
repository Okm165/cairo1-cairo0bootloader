from setup import log_and_run

if __name__ == "__main__":
    log_and_run([
        "cargo run --release ../../cairo1.cairo --layout all_cairo --cairo_pie_output ../../cairo1_pie.zip --append_return_values"
    ], "Compiling cairo1 pie", cwd="cairo-vm/cairo1-run")