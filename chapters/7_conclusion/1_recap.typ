#import "/utils.typ": *
== Recap
#acrpl("LLM") are widely used in the field of code completion. Tools like Copilot find a widespread use, reducing the need to write boilerplate code.
While these tools are useful, they especially struggle with rapidly changing dependencies. Adapting the model to changed dependencies requires significant resources. Alternatives use the inherent model capabilities to inject accurate dependency information.
Previous approaches often retrieve code context using #acr("RAG") and inject it into the prompt.

The goal of this thesis was to explore different ways to guide code completion, injecting accurate code context at runtime, additionally reducing model runtime compared to multi-step generation approaches.
Accurate code context is retrieved using #acr("IDE")-tooling, retrieving code documentation, completion items and signature information. This enables the approach to inject context for all code, from the repository itself to external dependencies.
#acr("IDE")-tooling is used through the #acr("LSP"), retrieving context for any supported programming language. This allows the approach to be language-agnostic.

Then #acr("MGD") is explored, observing the model at runtime to solve the "context retrieval problem". Observing the model at runtime allows the approach to provide relevant context online, reducing the need for multi-step generation approaches and reducing runtime.
To inject the retrieved context, two different mechanisms are explored.
The first mechanism adds context to the prompt. It is suited for unstructured context, such as code documentation of completion items and guides the model softly.
As shown, the model may be biased towards generating deprecated code, even when the prompt includes code context stating otherwise (@code:evaluation:invalid_copilot_pydantic).
In these cases the model must be guided through other means - the second mechanism.
The second mechanism modifies the model logits at runtime, reranking the token id scores of the next predicted token.
This mechanism is best suited for completion items and signature help information, as that context may be used to directly influence the next token.
Next tokens of suggested deprecated completion items are used to downrank the model logits, while next tokens of other suggested completion items are used to uprank the model logits.

The approach then combines both mechanisms, softly guiding the model through the prompt and reranking the logits at runtime. This enables a more robust approach, as the hard logits reranking solves the issue of the model generating deprecated code, while the soft context injection guides the model through the prompt.
The thesis then introduces the #acr("IBMS"), a method which injects context into the prompt during generation, removing the need for multi-step generation approaches.
It is designed to work with any context, working with retrieved code context, but compatible with other tasks. #acr("IBMS") is capable of removing injected context, enabling injection of scoped context.

To evaluate the approach, the thesis introduces the dataset DependencyEval, a dataset containing handcrafted Python code completion tasks with external dependencies. Each task includes the exact dependencies, including the Python version. Additionally, it features an evaluation pipeline to automatically evaluate the approach in different configurations, collecting different metrics and plotting results.
Each task includes two unit tests, for testing the functional correctness and the approach correctness of the generated code. The approach correctness verifies that no deprecated code was used.
The dataset can be built from individual code files, simplifying the process of creating new tasks.

Lastly, the thesis evaluates the approach on DependencyEval. The results show that the approach successfully guides the model away from deprecated code, using the correct alternatives. It notes that choosing the correct approach and model configurations and code models have drastic effects on the results. Models using beam search with sampling perform the best.
Even so, the high complexity of the approach increases the difficulty to make it robust. While the provided implementation improves the robustness of the approach using several mechanisms, the model still struggles with several scenarios, such as type hints that include literals.

In conclusion, this thesis explores and combines many different and new areas of code completion and model controlling.
It shows how hybrid approaches can complement each other, providing a more robust and accurate code completion approach.
It leaves many areas of optimizations open, which will be discussed in the final section.
