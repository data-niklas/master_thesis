#import "/utils.typ": *
== Contributions<chapter:introduction:contributions>
The main contributions of the thesis are:
1. Performant, robust and generalizable neural code completion using up-to-date package information.
2. A novel #acrf("IBMS") for injecting context into the model.
3. `DependencyEval`, a dataset to evaluate functional and approach correctness.

The main contribution integrates information from the currently used packages and local repository into the code completion. The information is retrieved through the code completion and signature help functionality, provided by typical language servers, which generalize this work over different programming languages.
The information includes deprecation information, preventing the model from completing old methods and guiding it towards replacements, using the provided documentation.
Performance wise, the framework only incurs a small performance penalty over the usual predicted code completion.

The second contribution is a novel #acr("IBMS"), which may be used outside of code completion. It enables monitoring the prediction similar to Agrawal et al.@agrawalMonitorGuidedDecodingCode, but then injects retrieved information at critical time points into the context "during" the generation.
It is used to inject the retrieved information into the model, nudging it towards the correct completion.

Lastly, the dataset evaluates if the completed code is functionally correct and uses the correct approach. The evaluation checks, if e.g. a deprecated method was used and then fails the completed code. The dataset includes hand-picked code pieces of rapidly changing packages, legacy packages or new and unused packages. Each item includes the Python version and pinned dependencies, to create a reproducible code environment.
To secure the evaluation, the evaluation pipeline uses Docker containers.
In addition, the evaluation generates a report and draws diagrams.
