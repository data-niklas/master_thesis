#import "/utils.typ": *

== Motivation
Neural code completion tools, such as GitHub Copilot, have seen a massive adoption in the software development community.

// Promise
Such tools promise to complement typical code completion tools by providing context-aware code completions spanning multiple lines.
These multi-line completions reduce the need to write boilerplate code further, thus improving the productivity.

// Copilot and other models
// Typical code completion uses statical analysis through language servers
While typical code completion tools use static analysis to provide completions, neural code completions tools use causal language models trained on code to predict the next tokens.
// neural code completion uses causal language models trained on code to predict the next tokens
// can predict more than just a symbol
// accepted and changed, as they are used as a starting point / used as example
As Ziegler et al. @zieglerProductivityAssessmentNeural2022 have shown, the completions provided by Copilot serve as a template to tinker with.
// has context information on code, or even other files, but lacks further information in the prediction typically provided through static analysis

Even if the completions provide a starting point, this work argues that current neural code completions do not use enough context to be accurate and are insufficient if used without the correct documentation.

#acrpl("CLM") are released together with a "cutoff date", which is the date until which the training data has been collected.
These models are incapable of predicting code completions which rely on information released after the cutoff date.
Even worse, the training data may contain information on a mixture of several old versions of the same item.

Widely used code packages are updated frequently, in which code is added, removed, or changed. Often the code is not removed directly, but marked as deprecated. It is still available, but should not be used anymore.

It is no surprise, that given a coding environment with specific versions of packages, the completions are often incapable of using correct code items.
// Symptoms
When using cutting-edge packages, the suggestions may not know anything, contain now renamed function parameters or use long deprecated methods.
For legacy projects the reverse is true, as the neural code completion may suggest items from newer versions, which are not available in the project.
As such, developers are forced to use the suggestions as a rough template, which they have to adjust to the correct documentation. Hence, developers use classical #acr("IDE") tooling or consult documentation directly to check single suggested items.

Methods such as retraining the model with correct package information ad-hoc are not feasible, as they are slow and require a lot of computational resources. // TODO: ref
Other dynamic methods providing the model with up-to-date information are not flexible enough and do not provide enough context to be accurate yet.
Additionally, some current methods are too slow to be used in a real-time coding environment.
