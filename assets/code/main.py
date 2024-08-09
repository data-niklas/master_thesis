# dependency_eval/__main.py__
import click

@click.group()
@click.version_option(VERSION)
@click.pass_context
def cli(ctx):
    ctx.obj = None


@cli.command()
@click.option("--dataset-file", default=DEFAULT_DATASET_PATH)
@click.option("--llm-lsp-directory", required=True)
@click.option("--venv-cache-directory", default=DEFAULT_VENV_CACHE_DIRECTORY)
@click.pass_obj
def create_venvs(
    args, dataset_file: str, llm_lsp_directory: str, venv_cache_directory: str
):
    dataset = load_dataset(dataset_file)
    for item in tqdm(dataset.items):
        tqdm.write(item["task_name"])
        get_venv_for_item(venv_cache_directory, None, llm_lsp_directory, item)


if __name__ == "__main__":
    cli()

