#import "/utils.typ": *
== Contributions<chapter:introduction:contributions>
The main contributions of the thesis are:
1. Performant, robust and generalizable neural code completion using up-to-date package information (engineering contribution).
2. A novel #acrf("IBMS") for injecting context into the model (conceptual contribution).
3. `DependencyEval`, a dataset to evaluate functional and approach correctness (equally conceptual and engineering contribution).

The main contribution integrates information from the currently used packages and local repository into the code completion. The information is retrieved through the code completion and signature help functionality, provided by typical language servers, which generalize this work over different programming languages.
The information includes deprecation information, preventing the model from completing old methods and guiding it towards replacements, using the provided documentation.
Performance wise, the framework only incurs a small performance penalty over the usual predicted code completion.
// mostly engineering due to complexity of combining different conceptual aspects
The contribution combines the novel concept of an #acr("IBMS") with the concepts of a language server and logits manipulation with code completion.
Even so, the contribution is heavily engineering focused, as implementing the #acr("IBMS") for code completion has proven to be a complex task, as it requires a high level of integration into the code completion. Moreover, many improvements were made to the implementation, improving the robustness and performance under different circumstances.

The second contribution is a novel #acr("IBMS"), which may be used outside of code completion. It enables monitoring the prediction similar to Agrawal et al. @agrawalMonitorGuidedDecodingCode, but then injects retrieved information at critical time points into the context "during" the generation.
It is used to inject the retrieved information into the model, nudging it towards the correct completion.
The #acr("IBMS") is the main conceptual contribution of the thesis. It is novel, applies even outside of code completion and can be integrated into many different approaches to e.g. bring tooling feedback closer towards the model.

Lastly, the dataset evaluates if the completed code is functionally correct and uses the correct approach. The evaluation checks, if e.g. a deprecated method was used and then fails the completed code. The dataset includes hand-picked code pieces of rapidly changing packages, legacy packages or new and unused packages. Each item includes the Python version and pinned dependencies, to create a reproducible code environment.
To secure the evaluation, the evaluation pipeline uses Docker containers.
In addition, the evaluation generates a report and draws diagrams.
It is equally a conceptual and engineering contribution, as the dataset is closely built around the concept of reproducible environments unseen in other datasets. The reproducibility increases the effort to implement an evaluation loop, forming the engineering contribution.
