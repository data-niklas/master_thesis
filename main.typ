#import "template/0_mod.typ": *
#import "acronyms.typ": *
// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "TITLE",
  author: "Niklas Loeser",
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  date: datetime.today().display(),
  abstract-en: [
        #lorem(300)
  ],
  abstract-de: [
        #lorem(300)
  ],
  acronyms: acronyms,
  bibliography-file: "/bibliography.bib",
  matriculation-number: "3737339",
  date-of-submission: "2024-09-30"
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
