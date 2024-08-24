# dependency_eval/eval.py
def get_docker_cmd(item: Dict[str, Any], code_file: str, requirements_file: str):
    return [
        "docker",
        "run",
        "-it",
        "--rm",
        "--name",
        "dev_dataset_eval_item_" + SALT,
        "-v",
        f"{requirements_file}:/tool/requirements.txt",
        "-v",
        f"{code_file}:/code/llm_lsp_code.py",
        "-w",
        "/code",
        "--cpus",
        "1",
        # "--network", "none", # TODO: use docker build
        get_docker_image(item["python_version"]),
        "sh",
        "-c",
        "apt update >/dev/null 2>/dev/null&& apt install git -y >/dev/null 2>/dev/null && python -m venv /tool/venv && /tool/venv/bin/pip install -r /tool/requirements.txt 2>error.log >/dev/null && /tool/venv/bin/python llm_lsp_code.py || cat error.log",
    ]
