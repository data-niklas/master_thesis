#import "/utils.typ": *
== Recap
// large language models used everywhere
// code completion
// while useful for helping to reduce boilerplate
// struggle with rapidly changing dependencies
// IDE tooling promises cross-language retrieval of accurate code context

// explores different ways to control code completion using accurate code context at runtime
// it first presents the IBMS

// additionally, it uses a concept known as monitor-guided generation to observe the model at runtime, retrieving context relevant to the to be generated code
// Then, uses same mechanism to control logits
// After looking at different examples, it combines both mechanisms of control for different purposes

// Issues in code completion datasets
// no use of external dependencies
// no focus on a reproducable code project environment, containing pinned dependency version and code execution version

