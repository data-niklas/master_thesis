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

// codellama: roziereCodeLlamaOpen2024
// mistral: BeowolxMistralHermesCodePro7Bv1Hugging
// deepseek: guoDeepSeekCoderWhenLarge2024 Magicoder: weiMagicoderEmpoweringCode2024

=== Dataset
