#import "/utils.typ": *
= Introduction <introduction>
// Code gen: description prompt, or completion
Code generation describes the task of generating code for a specific programming language. Generally the code could be generated from a description of the desired functionality, or as a continuation of existing code.

// Focus on completion, in a repository of a developer
// Reduce manual effort, increase productivity, reduce writing skeleton code
An important use of code generation is to provide code completions in an #acr("IDE"). There the completed code removes the need to write boilerplate code.

// Important aspects in an IDE are speed,

/*
- LLM are versatile and can be used for many tasks
- Code generation is one domain, where LLM used to assist developers: programming, designing architectures, understanding code, etc.
*/

/* ~ General flow ~
  1. Code gen horribly bad, outdated or slow or inaccurate
  2. Fast, accurate, dynamic to code (choose to generate for old code, it works both ways!!!!)
  3. (2) is goal (3) is the fact check where I sell my project
*/

#{
  include "1_motivation.typ"
  include "2_goals.typ"
  include "3_contributions.typ"
}
