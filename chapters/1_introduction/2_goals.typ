#import "/utils.typ": *
== Goals
This thesis aims to combine up-to-date information through static analysis with the prediction capabilities of #acrpl("CLM"). The combination shall provide the neural code completion with the contextual information needed, to suggest code fitting the local code environment.
The contextual information shall be provided at specific instances to guide the model *away* from incorrect suggestions *towards* correct suggestions.
Additionally, the performance impact of the proposed approach shall be kept low, to ensure a responsive system. This will enable integration into #acrpl("IDE") and other tools.

Initially, the thesis will introduce important concepts and technologies, from Causal Language Modeling to Controllable Generation, followed by important details on libraries implementing these concepts for use in the approach implementation.
Moreover, related work will be introduced to provide a basis for the proposed approach.

Afterward, the thesis will introduce the requirements for a proposed approach, then
analyze shortcomings of current approaches and propose a new approach to address these shortcomings.
Possible solutions will be discussed and evaluated, to find a promising approach.

Then, the thesis will describe the components of the proposed approach.

Finally, the approach will be implemented and evaluated, according to the defined requirements.

At last, the thesis will conclude with a summary of the results and an outlook on future work.
//
// In addition, the time impact of the proposed approach shall be kept low, to ensure a responsive system.
//
// In detail, the thesis will focus on combining static analysis through the use of language servers with the Transformers library, which offers a high level of control over the code generation.

// General RQ on interrupt based method
// TODO: move as requirements into design
// The following research questions guide the thesis toward its goal:
