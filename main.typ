#import "template/0_mod.typ": *
#import "acronyms.typ": *
#import "/utils.typ": print-mode
#import "/constants.typ": *
// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
title: title,
author: author,
  print-mode: print-mode,
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract-en: include "/chapters/0_abstract/en.typ",
  abstract-de: include "/chapters/0_abstract/de.typ",
  acronyms: acronyms,
  bibliography-file: bibliography-file,
  matriculation-number: matriculation-number,
  supervisor: supervisor,
  supervisor-link: supervisor-link,
  date-of-submission: datetime(
    year: 2024,
    month: 09,
    day: 30
  ),
  date-of-signature: datetime(
    year: 2024,
    month: 09,
    day: 27
  ),
  thesis-repo: "https://github.com/data-niklas/master_thesis",
  appendix: include "/chapters/appendix/0_mod.typ",
  link-style-exception-cb: it => str(it.dest).starts-with("https://data-niklas.github.io/master_thesis")
)

// We generated the example code below so you can see how
// your document will look. Go ahead and replace it with
// your own content!
#include "chapters/0_mod.typ"

/*= Prerequisites
- Key information about general setup information
- Types of used models
- Datasets
- Tasks (FIM? )


= Stylistic Dataset
== Introduction
== Data types
- Removed
- Added
- Moved
(C(R)UD)

== Style detection
- Mock objects

== Evaluation implementation
- venvs
- caching
- security / dockerss

= Interrupt based Meta strategy
== Introduction
== Components
== Theoretical Underpinnings
== Design Principles
== Implementation
== Summary

= LSP guided generation
== Hybrid approach
== LSP protocol
== Guided generation
== Targeted documentation
== Performance
- Beams
- Batching

= Editing thingy
Using targeted information to rewrite the past

== Actions

= Evaluation and Results
== Research Questions
== RQ1
== RQ2
== RQ3
== RQ4

= Conclusion
== Summary and Implications
== Limitations and Future Work
== Concluding Remarks
- Editing based
- DAP protocol
*/
