use args::{process_args, FuncArgs};
use cairo1_run::Cairo1RunConfig;
use cairo_vm::types::layout_name::LayoutName;
use clap::{Parser, ValueHint};
use std::path::PathBuf;
pub mod args;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    #[clap(long = "sierra_program", value_parser, value_hint=ValueHint::FilePath)]
    sierra_program: PathBuf,
    #[clap(long = "args", default_value = "", value_parser=process_args)]
    args: FuncArgs,
    #[clap(long = "cairo_pie_output", value_parser, value_hint=ValueHint::FilePath)]
    cairo_pie_output: PathBuf,
}

fn main() -> std::io::Result<()> {
    let args = Args::parse();

    // Try to parse the file as a sierra program
    let file = std::fs::read(&args.sierra_program)?;
    let sierra_program: cairo_lang_sierra::program::Program =
        match serde_json::from_slice::<cairo_lang_sierra::program::VersionedProgram>(&file) {
            Ok(program) => program.into_v1().unwrap().program,
            Err(_) => panic!("program parsing failed"),
        };

    let (runner, vm, _return_values, _serialized_output) = cairo1_run::cairo_run_program(
        &sierra_program,
        Cairo1RunConfig {
            args: &args.args.0,
            layout: LayoutName::all_cairo,
            finalize_builtins: true,
            serialize_output: true,
            append_return_values: true,
            ..Default::default()
        },
    )
    .unwrap();

    runner
        .get_cairo_pie(&vm)
        .unwrap()
        .write_zip_file(&args.cairo_pie_output)
        .unwrap();

    Ok(())
}
