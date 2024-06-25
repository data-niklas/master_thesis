#import "/utils.typ": *
== Goals
This thesis aims to combine up-to-date information from static analysis with the prediction capabilities of #acrpl("CLM"). The combination shall provide the neural code completion with the contextual information needed, to suggest code fitting the local code environment.

In addition, the time impact of the proposed approach shall be kept low, to ensure a responsive system.

// General RQ on interrupt based method
The following research questions guide the thesis toward the goal:
+ RQ1: Which sources provide #acrpl("CLM") with the necessary information to suggest fitting code?
+ RQ2: How to filter sourced information to provide the most relevant information to #acrpl("CLM")?
+ RQ3: How to integrate the contextual information into the neural code completion?
+ RQ4: How to ensure the robustness of the approach?
+ RQ5: How to generalize the approach to work with different programming languages?
+ RQ6: How to reduce the performance impact of the approach?
