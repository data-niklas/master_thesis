#import "/utils.typ": *
== Goals
This thesis aims to combine up-to-date information through static analysis with the prediction capabilities of #acrpl("CLM"). The combination shall provide the neural code completion with the contextual information needed, to suggest code fitting the local code environment.

In addition, the time impact of the proposed approach shall be kept low, to ensure a responsive system.

In detail, the thesis will focus on combining static analysis through the use of language servers with the Transformers library, which offers a high level of control over the code generation.

// General RQ on interrupt based method
The following research questions guide the thesis toward its goal:
#figure(
  table(
    columns: 3,
    table.header([Identifier], [Keyword], [Description]),
    [*RQ1*],
    [Information source selection],
    [Which sources provide #acrpl("CLM") with the necessary information to suggest fitting code?],
    [*RQ2*],
    [Context processing],
    [How to filter sourced information to provide the most relevant information to #acrpl("CLM")?],
    [*RQ3*],
    [Context integration],
    [How to integrate the contextual information into the neural code completion?],
    [*RQ4*],
    [Robustness],
    [How to ensure the robustness of the approach?],
    [*RQ5*],
    [Generalizability],
    [How to generalize the approach to work with different programming languages?],
    [*RQ6*],
    [Performance],
    [How to reduce the performance impact of the approach?],
  ),
  caption: "Research questions guiding the thesis.",
)<research_questions>
