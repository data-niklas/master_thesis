#import "/utils.typ": *
== Causal Language Models <chapter:bg:llms>
This section briefly introduces the main components of causal language modeling.
It touches on topics such as the general modeling, autoregressivity, the problem of vocabulary and special tokens.

// langauge modeling:
A language model determines the probability of a sequence of words:
$
  P(w_1...w_n)
$,
where $w_1...w_n$ is the sequence of words and $w_i$ the $i$-th word in the sequence@goodmanBitProgressLanguage2001.
// probability of sequence of words

The probability of a sequence of words can be broken down into the product of the probabilities of each word given the previous words@goodmanBitProgressLanguage2001:
$
  P(w_1...w_n) = product_(i=1)^n P(w_i|w_1...w_(i-1))
$
// decomposition into probabilities of word given previous word sequence
// example 1

#align(
  center,
  example(
    table(
      columns: (auto, auto),
      stroke: none,
      [/ Previous text: ], [_"The quick brown fox jumps over the lazy \_"_],
      [/ Prediction: ], [_"dog"_],
    ),
    caption: "Language model predicting the last word of the famous English pangram.",
  ),
)

// statistical language modeling
#acrpl("CLM") are neural statistical language models.
Statistical language models model the probability function as a parameterized function, which is learned from a given corpus.
To battle the high dimensionality of the problem, neural statistical language models are used, as they can generalize well to unseen data@SpeechLanguageProcessing.
Neural statistical language models learn twicefold:
1. Learn a distributed representation of words, called word feature vectors or embeddings,
2. Learn the parameters of the probability function, working on the embeddings@bengioNeuralProbabilisticLanguage.
// parameterized function with many parameters
// learn embeddings
// learn parameters of probability function

Given a fixed vocabulary $V$, the embedding function is defined as:
$
  f_"embedding": V arrow.r RR^m
$,
which represents a matrix of size $|V| times m$, the feature matrix.
Ideally, the embedding function is reversible: $w = f_"embedding"^(-1) (f_"embedding" (w))$.

The probability function is defined as:
$
  P: RR^m times...times RR^m arrow.r RR^(|V|)
$

The learned model function consisting of both the embedding function and the probability function the becomes:
$
  f_"model" (w_1...w_n) = P(f_"embedding" (w_1)...f_"embedding" (w_n))
$

// clm, open-end-generation, autoregressivity
The next step in causal language modeling is the property `autoregressivity`. Decomposing the probability function into a series of next word predictions enables an open-end-generation.
The model can predict the next word, which is appended to the input sequence.
This process is repeated for the new sequence, which serves as the new input sequence for the next word prediction.

// problem of strategy => later
An important aspect of the next word prediction is the strategy used to determine the next word from the word prediction.
The next best token may not be the best choice overall. The chosen text generation strategy has a significant impact on the quality of the generated text.
Several strategies will be introduced in the next section.

// problem of vocabulary:
A problem in language modeling is the vocabulary size.
While the vocabulary $V$ of a #acr("CLM") is fixed, the number of possible words in a language is infinite.

// - must be limited

// example 2
#example(
  table(
    columns: (auto, auto),
    align: (right, left),
    stroke: none,
    [/ Vocabulary: ],
    [_{"The", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog", "\_", ".", "\<BOS\>", "\<EOS\>"}_],

    [/ Text: ], [_"The quick brown fox jumps"_],
    [/ Tokens ids: ], [_{11, 0, 9, 1, 9, 2, 9, 3, 4}_],
    [/ Tokens: ],
    [_{"\<BOS\>", "The", "\_", "quick", "\_", "brown", "\_", "fox", "\_", "jumps"}_],

  ),
  caption: "Natural language encoded into tokens and token ids.",
)<example:tokens>

@example:tokens showcases the tokenization for the start of the famous English pangram. The tokens values correspond to the index in the given vocabulary. The given vocabulary only provides tokens for full words and does not provide tokens for sub-word fragments.
// Special tokens
Not only does the vocabulary contain tokens for natural language, but also special tokens. These special tokens encode further semantic information for the #acr("CLM"). Common special tokens are the #acr("BOS"), #acr("EOS") and #acr("PAD") tokens:
/ #acr("BOS"): Marks the beginning of a natural text. Used to delimit several unrelated texts.
/ #acr("EOS"): Marks the end of a natural text. Used in combination with #acr("BOS"). The text generation is stopped, when the model predicts the #acr("EOS") token as the next token.
/ #acr("PAD"): Used to pad sequences from either side to a fixed length. This is necessary for the model to process several sequences of varying lengths at once.

// popular LLM's today

/*
== Causal Language Models <chapter:bg:llms>
This section will first introduce the concept of a #acrpl("LM"), then move from neural language models, to #acrpl("CLM"). Important text generation strategies for #acr("CLM") are discussed in depth in the next section.

// TODO: test
=== Language Models
Generally, #acrpl("LM") are probabilistic models of natural language@SpeechLanguageProcessing. // TODO: insert ref
They predict the next upcoming words based on already seen words@SpeechLanguageProcessing:
#align(
  center,
  example(
    table(
      columns: (auto, auto),
      stroke: none,
      [/ Previous text: ], [_"The quick brown fox jumps over the lazy \_"_],
      [/ Prediction: ], [_"dog"_],
    ),
    caption: "Language model predicting the last word of the famous English pangram.",
  ),
)
// Development led to CLM, which are powerful, thus widespread use
Development on #acrpl("LM") has led to powerful models. These now find widespread use in various applications, such as ChatGPT@ChatGPT.

// Chapter 7 in slp
=== Neural Language Models
Neural language models are a type of #acr("LM"). Their name stems from the McCulloch-Pitts neuron, which is a simplified view of a biological neuron as a computational unit@HttpsHomeCsulb@SpeechLanguageProcessing.

In contrast, a modern neural language model is a network of small computing units. Each of the units is a function that takes a sequence of values and returns a singular output value@SpeechLanguageProcessing:
$
  f_"unit": RR^n arrow.r RR
$<math_unit_function>

Combining many units into a network allows the computation of a complex function $f_"network"$. The behavior of $f_"network"$ can be changed by modifying the parameters inside of the network. By applying changes according to feedback, complex functions can be learned.

// TODO: improve mentioning transformers
// TODO: references
One very popular architecture for neural language models is the Transformers architecture.

As can be seen in @math_unit_function, the network is unable to process sequences of natural language directly. The text must first be encoded into numbers, the model can work with. After processing the encoded text, the result can be decoded into natural language once again.

Each neural language model encodes tokens of natural language into increasing numbers called token ids using a vocabulary $V$. The vocabulary is usually fixed, but can be changed as will be shown in the thesis.
// TODO: instead of thesis ref the correct chapter later
Each token id represents a piece of natural language, such as a part of a word, or even parts of a sentence. The models initially map natural language to tokens for processing. After processing the tokens these are decoded back into natural language.

#example(
  table(
    columns: (auto, auto),
    align: (right, left),
    stroke: none,
    [/ Vocabulary: ],
    [_{"The", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog", "\_", ".", "\<BOS\>", "\<EOS\>"}_],

    [/ Text: ], [_"The quick brown fox jumps"_],
    [/ Tokens ids: ], [_{11, 0, 9, 1, 9, 2, 9, 3, 4}_],
    [/ Tokens: ],
    [_{"\<BOS\>", "The", "\_", "quick", "\_", "brown", "\_", "fox", "\_", "jumps"}_],

  ),
  caption: "Natural language encoded into tokens and token ids.",
)<example:tokens>

@example:tokens showcases the tokenization for the start of the famous English pangram. The tokens values correspond to the index in the given vocabulary. The given vocabulary only provides tokens for full words and does not provide tokens for sub-word fragments.
// Special tokens
Not only does the vocabulary contain tokens for natural language, but also special tokens. These special tokens encode further semantic information for the #acr("CLM"). Common special tokens are the #acr("BOS"), #acr("EOS") and #acr("PAD") tokens:
/ #acr("BOS"): Marks the beginning of a natural text. Used to delimit several unrelated texts.
/ #acr("EOS"): Marks the end of a natural text. Used in combination with #acr("BOS"). The text generation is stopped, when the model predicts the #acr("EOS") token as the next token.
/ #acr("PAD"): Used to pad sequences from either side to a fixed length. This is necessary for the model to process several sequences of varying lengths at once.

// TODO: BPE?

=== Definition
Causal language models in turn are a type of neural language model. They rely on the assumption that the probability of a word occuring in a document depends only on the words occuring before it.

This property is called `autoregressivity` and highly favourable towards text generation, as it enables the continuation of any text. Given a text $i_0$ as input, the causal language model can predict the next word, as all previous words $i_0$ are known. After predicting the next word, the word is appended to the input to form the new input $i_1$. This process is repeated until the model predicts the end of the document using the special #acr("EOS") token after $n$ steps. $i_n$ then forms the output and the whole generated text.

When applied to text completion or code completion, a program need only return the output $i_n$ without the prefix $i_0$.

For the purposes of this thesis, a #acr("CLM") can be defined using the following components:
- Raw next token prediction function $f_"rntpf"$ // TODO: rename to logits?
// - Normalization function // TODO
- Text generation strategy
- Autoregressive property

The raw next token prediction function is a mathematical function that takes a sequence of tokens and returns the prediction for the next tokens:
$
  f_"rntpf" (x) = u\
  f_"rntpf": NN^n arrow.r RR^(|V|)
$<math_rntpf>

The output $u$ has the shape of the vocabulary, where each value $u_i$ represents the logistical probability of token $i$ being the next token. These values are called `logits`.

In an additional step, the logistical probabilities are normalized into values in the range of $(0, 1)$ to form a probability distribution.

The intermediary step of forming logits provides the benefit, that individual logits can be changed individually without disrupting the probability distribution. This property is essential for the main contributions in this thesis.
*/
