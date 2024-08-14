#import "/utils.typ": *

== Experiment Environment <chapter:experiments:setup>
The experiments were designed to use minimal resources and to be easily reproducible.
They were run on a single server with the following specifications:

#figure(
  table(
    columns: 2,
    table.header([*Component*], [*Value*]),
    [*CPU*],
    [2x AMD EPYC 7713 64-Core],
    [*Memory*],
    [1 TB],
    [*GPU*],
    [4x NVIDIA GeForce RTX 3090],
  ),
  caption: [The experiments were run on the server `Luke`, with the specifications listed in the table. Only a single GPU is required for the experiments.],
)<table:experiments:setup>

The server will be referred to as `Luke` throughout the experiments.
The code is available in the #link("https://github.com/data-niklas/DependencyEval")[dataset repository].

`Luke` is running Ubuntu with kernel version 5.15.0 and has Docker installed. The experiments use Docker, Python 3.9.18, Transformers 4.39.0, PyTorch 2.2.1, Nvidia CUDA 11.8.
All other dependencies are automatically installed through the used Docker images at runtime.

=== Models
As the thesis focuses on improving neural code completion, only code completion models are used.
Furthermore, only instruction tuned models are used, as instruction following capabilities are crucial for context injection techniques.
The goal is to improve small models, as they can easily be run locally on developers' machines and on `Luke`.

In particular, models of about seven to nine billion parameters are used. They offer a good trade-off between the quality of the completion, instruction following capabilities, and the computational requirements.
The experiments employ models of the Llama 2@touvronLlamaOpenFoundation2023, Mistral@jiangMistral7B2023, and DeepSeek@deepseek-aiDeepSeekLLMScaling2024 architectures.
Every model is based on the Transformer architecture, each with #acr("RoPE")@suRoFormerEnhancedTransformer2023 and most with #acr("GQA")@ainslieGQATrainingGeneralized2023.

The first model is Code Llama Instruct 7B@roziereCodeLlamaOpen2024, which is based on the Llama 2 architecture and will be referred to as Code Llama.
It has 7 billion parameters and supports a context length of 4096 tokens.
The next model is MistralHermes-CodePro@BeowolxMistralHermesCodePro7Bv1Hugging, a 7 billion parameter model based on the Mistral architecture, and will be referred to as MistralHermes.
In contrast to other architectures, MistralHermes uses sliding window attention and was trained on a context of 8k tokens.
Lastly, the Magicoder-S-DS@weiMagicoderEmpoweringCode2024 model is based on the DeepSeek architecture and has 6.7 billion parameters.
It supports a context size of 16k tokens and is the only model that does not have #acr("GQA") enabled for the small model.

After determining that the models behave similarly, the experiments will only use the Code Llama model, to reduce the computational requirements.

Each of the previous models has support for the Transformers runtime, which enables the normal use of the models in the experiments.
Next to these models, the behavior of the popular Copilot tool is of interest. While the model behind Copilot, Codex@chenEvaluatingLargeLanguage2021a, cannot be integrated into the approach, it can be used for normal code completion. It will be used as a baseline.
// TODO: maybe talk about used data

=== Dataset
As shown in the design chapter, currently no dataset contains code samples of dependencies, where the whole environment is specified.
For the environment, the dependency versions must be specified, and the required version of the programming language must be known.
Additionally, the dataset entries must include examples of deprecated code.
The design section listed several scenarios, such as the use of alternatives to deprecated code or the use of e.g. renamed function parameters.

The consequence is that this thesis created a new dataset, the DependencyEval dataset.
The experiments will use the 22 hand chosen tasks from the dataset to evaluate the new approach in a controlled environment on several different scenarios.
As the dataset only contains 22 tasks, a few experiment results will additionally be evaluated by hand.
