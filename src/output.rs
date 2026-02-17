use clap::ValueEnum;

#[derive(Clone, Debug, PartialEq, ValueEnum)]
pub enum Output {
    Quiet,
    Default,
    Pretty,
    #[value(name = "github")]
    GitHub,
}
