#import "/utils.typ": *
== Outlook
The thesis combines many topics from static analysis, to prompt injection, to logits manipulation, achieving a higher level of control over the model for code generation.
An especial central component in the success of the model edits is the high quality information provided through the #acr("LSP").
While this thesis utilizes information from completion items and the signature help, there are many more sources of information that could be used to further improve the model edits.
These include the diagnostic information, which provides feedback on the already written code, such that may alter previously generated code.

Another venue for research is the focus on low resource languages.
Models face difficulties in learning low resource languages, as they have fewer data to learn from.
For this reason, it is of especial interest to improve the language support for these languages.
Future work could focus on the improvement of code generation for low resource languages, analyzing how embedding static analysis information can improve the model's performance.
It is still left to be seen, how models react to the control techniques used in this thesis, when applied to low resource languages.

Other works already focus on different means of control, such as model weight editing, which allows for the manipulation of the model's weights.
Future work could combine information from static analysis through the #acr("LSP") with model weight editing, similar to Imgrund (2024)@imgrundLocatingEditingKnowledge2024, to further improve the control over the model.

Furthermore, future work could focus on the area of context injection. This work injects context into the system prompt, as the instruction tuned models have issues following instructions in other formats.
Custom special tokens could be added to the vocabulary, which signify the start of certain embedded code context, such as the signature help.
By training the model with the added tokens, and a fitting dataset, the instruction following capabilities for embedded contexts could potentially be improved for code completion.

At last, the thesis uses the novel dataset DependencyEval, to evaluate the approach used by completed code. It is the first of its kind, providing different types of tests to distinguish between functionally correct code and code using the correct approach.
Due to the high effort associated with creating the dataset, and it not being the focus of the thesis, the dataset is still small and only contains #num-dataset samples.
Future work could focus on expanding the dataset, to provide a more comprehensive evaluation of the model's performance using more samples.

// Thesis touches on lots of topics, which may be deepened
// LSP / static analysis
// use more information, such as diagnostic information

// deepen language support and test improvements on low resource languages

// also, LLM may be controlled through many different means
// thesis touches upon the prompt AND manipulates logits
// future work could combine other areas of control, such as model weight editing (=> imger)
// additionally, one could even go towards model training, by setting the goal of improving custom context embedding
// train with custom tokens signifying a certain embedded 'meta' context for code, similar how FIM specifies positional information
// or add instructions to other places, such that the model will follow instructions
