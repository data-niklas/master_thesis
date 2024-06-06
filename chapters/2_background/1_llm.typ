#import "/utils.typ": *
== Causal Language Models <bg_llms>
This section will first introduce the concept of #acrpl("LM"), then move from neural language models, to #acrpl("CLM") and at last compare different text generation strategies.

// TODO: test
=== Language Models
Generally, #acrpl("LM") are probabilistic models of natural language. // TODO: insert ref
They use statistical and probabilistic methods to "understand" natural language input and then generate further pieces of natural language. Over time the development on #acrpl("LM") has led to ever more powerful #acrpl("LM"). Thus, #acrpl("LM") find widespread use in many different tasks, such as code generation. // TODO: other areas

=== Neural Language Models
Neural language models are a type of #acr("LM") which use neural networks. It learns complex patterns in natural language and encodes these patterns in the weights of the neural network. One very popular architecture for neural language models is the Transformers architecture. 

Neural language models cannot work with natural language directly. They must first encode natural language to analyze patterns and store these in their weights during the training steps. To produce generated text, model generated data must be decoded into natural language again.

Each neural language model encodes natural language into increasing numbers called `tokens` using a vocabulary $V$. The vocabulary is usually fixed. Each token represents a piece of natural language, such as a part of a word, or even parts of a sentence. The models initially map natural language to tokens for processing. After processing the tokens these are decoded back into natural language.

// TODO: BPE?


=== Definition
Causal language models in turn are a type of neural language model. They rely on the assumption that the probability of a word occuring in a document depends only on the words occuring before it. 

This property is called `autoregressivity` and highly favourable towards text generation, as it enables the continuation of any text. Given a text $i_0$ as input, the causal language model can predict the next word, as all previous words $i_0$ are known. After predicting the next word, the word is appended to the input to form the new input $i_1$. This process can be repeated until the model predicts the end of the document after $n$ steps. $i_n$ then forms the output and the whole generated text.

When applied to text completion or code completion, a program need only return the output $i_n$ without the prefix $i_0$.


For the purposes of this thesis, a #acr("CLM") can be defined using the following components:
- Raw next token prediction function $"RNTPF"$
- Normalization function
- Text generation strategy
- Autoregressive property


The raw next token prediction function is a mathematical function that takes a sequence of tokens and returns the prediction for the next tokens. The prediction values are not normalized yet and are called logits.
$
    "RNTPF"((x_1, x_2, ..., x_n)) = (u_1, u_2, ..., u_(|V|))
$

The output $u$ has the shape of the vocabulary, where each value $u_i$ represents the probability of token $i$ being the next token.

The normalization function takes the logits and normalizes them to a probability distribution. Typically a softmax function is used:
$
    y = "softmax"(u)
$

// Text generation strategy 
To generate a full sequence of tokens and thus a document, the model must choose the next probable token in the document using a text generation strategy `TGS`. After choosing the next token $n$, where $1 lt.eq n lt.eq |"vocab"|$, it is appended to the old input $x$ to form $x'$:
$x' = (x_1, x_2, ..., x_n, n)$.

Depending on the text generation strategy, the models generate different documents of varying quality. Each text generation strategy has different advantages and drawbacks. The next sections will introduce a few core sampling strategies and highlight the main advantages and drawbacks.

=== Greedy Decoding
Greedy decoding is the simplest of sampling strategies. The strategy always chooses the token with highest probability. This always yields the current best next token, but not necessarily the best token overall.

Its main advantage is the simplicity. The strategy does not require additional state. Only the current probabilities are needed. This also leads to low hardware requirements, compared to other strategies.

As the current best next token is not often the best token overall, the strategy does not produce the highest quality documents.

$
    hat(w) = "argmax"_(w in V) P(w | w_(lt t))
$



=== Beam Search
Greedy decoding suffers from the problem of always choosing the current most probable token, even if it is not the best token overall. Beam search improves upon this by modeling the decoding process as a search tree. Instead of choosing only a single token, the strategy keeps $k$ possible token choices. These $k$ possible token choices are called `hypothesis`. At each time step the beam search uses the current $k$ hypothesis to independently continue the generation to create $k * V$ possible token combinations. The strategy then keeps the top-k combinations as new hypothesis.

$
    
$

By modeling the decoding process as a search tree, beam search can choose tokens that are better overall. This leads to a higher quality generation.

But as beam search keeps $k$ hypothesis and decodes $k * V$ possible token combinations, the strategy requires more memory and processing power.


=== Top-k
Top-k is a generalization of greedy decoding and a sampling strategy. Sampling strategies randomly choose the next token from the probability distribution. Top-k chooses the next token from the top $k$ most probable next tokens. Hence, the model chooses a wider variety of tokens, leading to richer outputs.

// k could be changed
As top-k is a generalization of greedy decoding, it has the advantage of being more powerful.

The main drawback is the loss of determinism. Lacking determinism may complicate interpretability methods.

=== Top-p
Top-k always chooses from the top $k$ most probable tokens, even if most tokens are very unlikely and only few of the $k$ tokens are probable. Top-p allows for more dynamic shapes of probability distributions, by only sampling from the top $p$ percent of tokens.

=== Temperature sampling
Temperature sampling takes a different approach to top-p. It does not adapt to the shape of the probability distribution, but reshapes it. It divides the raw probability scores by a temperature $tau$:
$
    y = "softmax"(u / tau)
$

The softmax function normalizes the logits to the range $ (0, 1) $, where the sum of all values is $1$. When dividing by $tau < 1$ all values increase in total. After normalization this skews the probability distribution towards the most probable tokens.
In contrast, when dividing by $tau > 1$ the probability distribution is flattened. This leads to a more uniform distribution.
