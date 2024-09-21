#import "/template/acronyms.typ": *
#Acrfpl("LLM") have proven themselves successful in many fields, including code generation.
Models can complement regular #acrf("IDE")-based code completion by predicting a completion based on the surrounding code context.
Even so, #acrpl("LLM") perform best on data represented in their training data. Training is usually done once, as continuous training is slow and expensive.
Models thus struggle with ever-changing dependencies, as they provide code completions based on outdated dependency versions. Moreover, even when predicting code of an older version represented in training data, models have issues distinguishing different versions of a dependency.
This thesis retrieves accurate code context of dependencies using #acr("IDE") tooling,
injecting the context during model inference. The injected context guides the model to generate accurate completions based on the exact project environment.

We first propose a novel method, #acrf("IBMS"), to efficiently inject context into the prompt during the generation. Natural language context such as code documentation is best fit for injection, as more structured context may be used to more directly guide the model. This method is universal and may be used with any context formattable into the prompt. It is an improvement over multi-generation step meta-strategies, as the performance overhead is greatly reduced, as the model only generates code once.

Next, the thesis shows that the model may often ignore context injected into the prompt, such as deprecation information, due to inherent model bias. To remediate the issue, the thesis present a novel approach, combining the #acr("IBMS") with logits manipulation and #acr("IDE") tooling.
#acr("IDE") tooling is used to retrieve deprecation information, code completion entries and function signatures during the generation of the completion, watching the model in realtime.
When appropriate, the retrieved context is injected into the prompt using the #acr("IBMS"), softly guiding the model to generate completions based on the exact project environment.
To reduce the effect of the model bias towards deprecated items in the training data, the predicted token id scores are reranked based on the retrieved context, such as deprecation information and completion items.

Lastly, the thesis presents DependencyEval, a handcrafted dataset and evaluation framework containing Python code completion tasks. The dataset entries contain information describing a reproducable code environment, including the Python version and exact dependency versions. DependencyEval is used to evaluate the approach in different configurations, comparing the results against the baseline.
