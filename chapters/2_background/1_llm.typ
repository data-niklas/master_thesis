#import "/utils.typ": *
== Causal Language Models <chapter:bg:llms>
This section briefly introduces the main components of causal language modeling.
It touches on topics such as the general modeling, autoregressivity, the problem of vocabulary and special tokens.

// langauge modeling:
A language model determines the probability of a sequence of words. The following formula calculates the probability of the sequence of words $w_1...w_n$, where $w_i$ is the $i$-th word@goodmanBitProgressLanguage2001:
$
  P(w_1...w_n).
$
// probability of sequence of words

The probability of a sequence of words can be broken down into the product of the probabilities of each word given the previous words@goodmanBitProgressLanguage2001:
$
  P(w_1...w_n) = product_(i=1)^n P(w_i|w_1...w_(i-1)).
$
// decomposition into probabilities of word given previous word sequence
// example 1

#align(
  center,
  example(
    table(
      columns: (auto, auto),
      stroke: none,
      [/ Previous words: ], [_"The quick brown fox jumps over the lazy \_"_],
      [/ Predicted next word: ], [_"dog"_],
    ),
    caption: [Language model predicting the last word of the famous English pangram.],
  ),
)

// statistical language modeling
#acrpl("CLM") are neural statistical language models.
Statistical language models model the probability function as a parameterized function, which is learned from a given corpus.
The parameterized function requires a high number of parameters, as many different word combinations are possible, many of them unseen in the corpus.
To battle the high dimensionality of the problem, neural statistical language models are used, as they generalize well to unseen data@SpeechLanguageProcessing.
Neural statistical language models are composed of the following components:
1. A distributed representation of words, called word feature vectors or embeddings. Given a fixed vocabulary $V$ and $m$ features, the embeddings are obtained from the embedding function:
$
  f_"embedding": V arrow.r RR^m.
$
2. Parameterized probability function, working on the embeddings@bengioNeuralProbabilisticLanguage:
$
  P: RR^m times...times RR^m arrow.r RR^(|V|).
$

The composition of both functions results in the model function:
$
  f_"model" (w_1...w_n) = P(f_"embedding" (w_1)...f_"embedding" (w_n)).
$

The model learns both functions from a given corpus. By learning the distributed representation of words using $m$ features, the model can generalize well to unseen data while keeping the number of parameters low.
The probability function represents a matrix of size $|V| times m$, the feature matrix.

// clm, open-end-generation, autoregressivity
The next step in causal language modeling is the property `autoregressivity`. Decomposing the probability function into a series of next word predictions enables an open-end-generation.
The model can predict the next word, which is appended to the input sequence afterward.
This process is repeated for the new sequence, which serves as the new input sequence for the next word prediction.

// problem of strategy => later
An important aspect of the next word prediction is the strategy used to determine the next word from the word prediction.
The next best token may not be the best choice over the whole future sequence. The chosen text generation strategy has a significant impact on the quality of the generated text.
Several strategies will be introduced in the next section.

// problem of vocabulary:
A problem in language modeling is the vocabulary size.
While the vocabulary $V$ of a #acr("CLM") is fixed, the number of possible words in a language is infinite. Languages change frequently, with old words falling out of use and new words emerging.
Prominent examples include teenage slang, technical terms, and word combinations.
Using a fixed vocabulary comprised of words makes it impossible to model the language accurately.
In contrast, using a vocabulary at the character level is not feasible, as many eastern languages feature thousands of characters. Additionally, encoding a sentence of a western language into characters would require a sequence of many vocabulary "words".
The solution lies in-between, using sub-word fragments as vocabulary items.
Popular choices used in modern language models are #acr("BPE") and SentencePiece@gageNewAlgorithmData@kudoSentencePieceSimpleLanguage2018.
The vocabulary entries are called tokens, with the process of encoding natural language into tokens called tokenization. The reverse process is called detokenization.
The tokenization function is defined as follows:
$
  f_"tokenization" ("text") = w_1...w_n,
$
where $w_i in V$ are tokens in the vocabulary $V$ and $"text"$ is any natural text.
Ideally, the tokenization is reversible:
$
  "text" = f_"detokenization" (f_"tokenization" ("text")).
$

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
  caption: [Natural language encoded into tokens and token ids using a word based vocabulary.],
)<example:tokens>

@example:tokens showcases the tokenization for the start of the famous English pangram. The token values correspond to the index in the given vocabulary.
// Special tokens
Not only does the vocabulary contain tokens for natural language, but also special tokens. These special tokens encode further semantic information for the #acr("CLM"). Common special tokens are the #acr("BOS"), #acr("EOS") and #acr("PAD") tokens:
/ #acr("BOS"): Marks the beginning of a natural text. Used to delimit several unrelated texts.
/ #acr("EOS"): Marks the end of a natural text. Used in combination with #acr("BOS"). The text generation is stopped, when the model predicts the #acr("EOS") token as the next token.
/ #acr("PAD"): Used to pad sequences from either side to a fixed length. This is necessary for the model to process several sequences of varying lengths at once.

// popular LLM's today
// argmax
Especially vital to modern language models is the decomposition of the probability function into a series of next word predictions.
This enables easy unsupervised training through the following learning objective: maximize the likelihood of the next word given the previous words over the corpus.
To increase the stability of the training, the log-likelihood is maximized instead of the likelihood@radfordImprovingLanguageUnderstanding@radfordLanguageModelsAre:
$
  "argmax"_theta sum_(i=1)^n log P_theta(w_i|w_1...w_(i-1)).
$
