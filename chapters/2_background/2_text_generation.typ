#import "/utils.typ": *
== Text Generation Strategies <chapter:bg:text_generation>
// Text generation strategy
To generate a full sequence of token ids and thus a document, the model must choose the next probable token id in the document using a text generation strategy. After choosing the next token id $hat(w)$, where $1 lt.eq hat(w) lt.eq |V|$, it is appended to the old sequence $w_1...w_n$ to form $w_1...w_n,hat(w)$.
// TODO: maybe figure here
Depending on the text generation strategy, the models generate different documents of varying quality. Each text generation strategy has different advantages and drawbacks. The next sections will introduce a few core sampling strategies and highlight the main advantages and drawbacks.

=== Greedy Decoding
Greedy decoding is the simplest of sampling strategies. The strategy always chooses the token id with the highest probability. This always yields the best next token id, but not necessarily the best token id overall.

Its main advantage is the simplicity. The strategy does not require additional state. Only the current probabilities are needed. This also leads to low hardware requirements, compared to other strategies.

As the current best next token id is not often the best token id overall, the strategy does not produce the highest quality documents.
The next token id is chosen by the following formula:

$
  hat(w) = "argmax"_(w in V) P(w_i | w_1...w_(i-1)).
$<greedy_decoding>

// TODO fix all the can's and remove them
=== Beam Search
Greedy decoding suffers from the problem of always choosing the current most probable token id, even if it is not the best token id overall. Beam search improves upon this by modeling the decoding process as a search tree. Instead of choosing only a single token id, the strategy keeps $k$ possible token id choices. These $k$ possible token id choices are called `hypothesis`. At each time step the beam search uses the current $k$ hypothesis to independently continue the generation to create $k dot V$ possible token id combinations. The strategy then keeps the top-k combinations as new hypothesis.

By modeling the decoding process as a search tree, beam search can choose token ids that are better overall. This leads to a higher quality generation.

But as beam search keeps $k$ hypothesis and decodes $k dot V$ possible token id combinations, the strategy requires more memory and processing power.

=== Top-k
Top-k is a generalization of greedy decoding and a sampling strategy. Sampling strategies randomly choose the next token id from the probability distribution. Top-k chooses the next token id from the top $k$ most probable next token ids. Hence, the model chooses a wider variety of token ids, leading to richer outputs.

// k could be changed
As top-k is a generalization of greedy decoding, it has the advantage of being more powerful.

The main drawback is the loss of determinism. Lacking determinism may complicate interpretability methods @fanHierarchicalNeuralStory2018.

=== Top-p
Top-k always chooses from the top $k$ most probable token ids, even if most token ids are very unlikely and only few of the $k$ token ids are probable. Top-p allows for more dynamic shapes of probability distributions, by only sampling from the top $p$ percent of token ids @holtzmanCuriousCaseNeural2020.

=== Temperature sampling
Temperature sampling takes a different approach to top-p. It does not adapt to the shape of the probability distribution, but reshapes it. It divides the raw probability scores by a temperature $tau$:
$
  y = "softmax"(u / tau).
$<temperature_sampling>

// TODO define all symbols centrally and check consistency

The softmax function normalizes the logits to the range $(0, 1)$, where the sum of all values equals $1$. When dividing by $tau < 1$ all values increase in total. After normalization this skews the probability distribution towards the most probable token ids.
In contrast, when dividing by $tau > 1$ the probability distribution is flattened. This leads to a more uniform distribution.
