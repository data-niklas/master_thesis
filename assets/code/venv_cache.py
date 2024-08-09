# dependency_eval/venv_cache.py
from venv import EnvBuilder
def create_venv(venv_directory: str, requirements: str):
    tqdm.write("Creating new venv in cache")
    builder = EnvBuilder(
        system_site_packages=False,
        clear=False,
        symlinks=False,  # Important for the Docker container!
        upgrade=False,
        with_pip=True,
        prompt=None,
        upgrade_deps=False,
    )
    builder.create(venv_directory)
    context = builder.ensure_directories(venv_directory)
    with open(REQUIREMENTS_FILE, "w") as f:
        f.write(requirements)
    cmd = [context.env_exec_cmd, "-m", "pip", "install", "packaging", "wheel"]
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    cmd = [context.env_exec_cmd, "-m", "pip", "install", "-r", REQUIREMENTS_FILE]
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    os.remove(REQUIREMENTS_FILE)

